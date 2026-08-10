-- =============================================================================
-- Equity24.io — auth bootstrap
--
-- Turns a Supabase auth user into a profile row, keeps updated_at honest, and
-- seeds the first staff member so the admin console is reachable at all.
--
-- Run this AFTER 0001_schema.sql and 0002_rls.sql.
-- =============================================================================

-- --------------------------------------------------------------- profiles ---
-- Every auth user gets exactly one profile. The signup form supplies
-- account_type, full_name and (for corporate accounts) company_name in the
-- user metadata; OAuth providers supply name under one of several keys.
create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  m         jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_type    account_type;
  v_name    text;
  v_company text;
begin
  v_type := coalesce(nullif(m->>'account_type', '')::account_type, 'private_investor');

  -- Google sends full_name and name; LinkedIn sends name. Fall back to the
  -- local part of the email rather than violating the not-null constraint.
  v_name := coalesce(
    nullif(trim(m->>'full_name'), ''),
    nullif(trim(m->>'name'), ''),
    nullif(trim(concat_ws(' ', m->>'given_name', m->>'family_name')), ''),
    split_part(new.email, '@', 1)
  );

  v_company := nullif(trim(m->>'company_name'), '');

  -- profiles.corporate_needs_company would otherwise fail with an opaque
  -- constraint error that surfaces to the user as a 500 on sign-up.
  if v_type = 'corporate_investor' and v_company is null then
    raise exception 'company_name is required for a corporate investor account'
      using errcode = '23514';
  end if;

  insert into profiles (id, account_type, full_name, email, country, company_name,
                        company_registry_code)
  values (new.id, v_type, v_name, new.email,
          coalesce(nullif(m->>'country', ''), 'EE'),
          v_company,
          nullif(trim(m->>'company_registry_code'), ''))
  on conflict (id) do nothing;

  -- Bootstrap staff. Without this the staff_roles write policy (is_staff('board'))
  -- can never be satisfied, because the table starts empty — nobody could ever
  -- grant the first role through the client. Controlling the mailbox is the
  -- control here, so this must stay a short list of addresses we own, and
  -- Supabase email confirmation must stay switched on.
  if lower(new.email) in ('mardo.soo@gmail.com') then
    insert into staff_roles (profile_id, role) values (new.id, 'board')
    on conflict (profile_id) do nothing;
  end if;

  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ------------------------------------------------------------- updated_at ---
create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at := now(); return new; end $$;

drop trigger if exists profiles_touch on profiles;
create trigger profiles_touch before update on profiles
  for each row execute function touch_updated_at();

drop trigger if exists kyc_sessions_touch on kyc_sessions;
create trigger kyc_sessions_touch before update on kyc_sessions
  for each row execute function touch_updated_at();

-- =============================================================================
-- Adding a colleague later — run as the service role (SQL editor), once they
-- have signed up and their profile exists:
--
--   insert into staff_roles (profile_id, role)
--   select id, 'compliance' from profiles where email = 'andra@equity24.io'
--   on conflict (profile_id) do nothing;
--
-- Roles: 'board' (can grant roles), 'compliance' (decisions), 'operations'.
-- Revoke by setting revoked_at rather than deleting — ECSPR art 26.
-- =============================================================================

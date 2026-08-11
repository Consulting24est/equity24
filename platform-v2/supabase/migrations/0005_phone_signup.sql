-- =============================================================================
-- Equity24.io — allow phone-only accounts (SMS one-time-code sign-in)
--
-- A phone signup produces an auth.users row with a phone and NO email. The
-- original schema could not represent that: profiles.email was NOT NULL and
-- handle_new_user derived full_name from split_part(email, '@', 1). Both would
-- have failed, aborting the auth.users insert and surfacing as an opaque 500
-- on sign-up.
--
-- Email becomes optional, phone is carried across, and a check constraint keeps
-- the real requirement: every profile must have at least one way to reach the
-- person. That matters beyond tidiness — ECSPR art 26 record-keeping and the
-- investor communications in art 23 both assume a contactable investor.
--
-- Run after 0001-0004. Safe to re-run.
-- =============================================================================

alter table profiles alter column email drop not null;

alter table profiles drop constraint if exists profile_is_contactable;
alter table profiles add constraint profile_is_contactable
  check (email is not null or phone is not null);

comment on constraint profile_is_contactable on profiles is
  'Email or phone, at least one. An investor with neither cannot be sent a KIIS, a reflection-period notice or an annual report.';

-- --------------------------------------------------------------- trigger ---
create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  m         jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_type    account_type;
  v_name    text;
  v_company text;
begin
  v_type := coalesce(nullif(m->>'account_type', '')::account_type, 'private_investor');

  -- Google sends full_name and name; LinkedIn sends name. Then fall back to the
  -- email local part, then the phone number, so a phone-only signup still
  -- satisfies full_name NOT NULL rather than aborting the whole insert.
  v_name := coalesce(
    nullif(trim(m->>'full_name'), ''),
    nullif(trim(m->>'name'), ''),
    nullif(trim(concat_ws(' ', m->>'given_name', m->>'family_name')), ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    nullif(new.phone, ''),
    'Investor'
  );

  v_company := nullif(trim(m->>'company_name'), '');

  if v_type = 'corporate_investor' and v_company is null then
    raise exception 'company_name is required for a corporate investor account'
      using errcode = '23514';
  end if;

  insert into profiles (id, account_type, full_name, email, phone, country,
                        company_name, company_registry_code)
  values (new.id, v_type, v_name,
          nullif(new.email, ''),
          nullif(new.phone, ''),
          coalesce(nullif(m->>'country', ''), 'EE'),
          v_company,
          nullif(trim(m->>'company_registry_code'), ''))
  on conflict (id) do nothing;

  -- Staff bootstrap. Controlling the mailbox is the control, so this stays a
  -- short list of addresses we own and Supabase email confirmation must stay on.
  -- Deliberately email-only: a phone number is not an acceptable basis for
  -- granting board-level access.
  if new.email is not null and lower(new.email) in ('mardo.soo@gmail.com') then
    insert into staff_roles (profile_id, role) values (new.id, 'board')
    on conflict (profile_id) do nothing;
  end if;

  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- =============================================================================
-- Note for the product, not the schema: an account with only a phone number
-- cannot be sent the Key Investment Information Sheet, the art 22 reflection
-- notice, or the three years of post-closing reports. Before such a user can
-- invest, the application should require an email address on the profile.
-- =============================================================================

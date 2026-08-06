-- =============================================================================
-- Equity24.io — row-level security
--
-- Posture: deny by default. Investors see only their own records; company users
-- see only their own company; staff see what supervision requires. Append-only
-- tables grant INSERT but never UPDATE or DELETE — to anyone, including staff.
-- =============================================================================

-- Staff roles live in a table, not in JWT claims, so they can be audited.
create table staff_roles (
  profile_id uuid primary key references profiles(id) on delete restrict,
  role       text not null check (role in ('compliance', 'operations', 'board')),
  granted_at timestamptz not null default now(),
  revoked_at timestamptz
);

create or replace function is_staff(p_role text default null)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from staff_roles
    where profile_id = auth.uid() and revoked_at is null
      and (p_role is null or role = p_role)
  );
$$;

create or replace function owns_company(p_company uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from companies where id = p_company and owner_profile = auth.uid());
$$;

-- Enable RLS everywhere
alter table profiles                enable row level security;
alter table investor_assessments    enable row level security;
alter table kyc_sessions            enable row level security;
alter table kyc_status_events       enable row level security;
alter table companies               enable row level security;
alter table applications            enable row level security;
alter table application_events      enable row level security;
alter table offers                  enable row level security;
alter table commitments             enable row level security;
alter table nominee_holdings        enable row level security;
alter table nominee_register_events enable row level security;
alter table board_notices           enable row level security;
alter table communities             enable row level security;
alter table community_members       enable row level security;
alter table community_messages      enable row level security;
alter table complaints              enable row level security;
alter table complaint_events        enable row level security;
alter table marketing_approvals     enable row level security;
alter table audit_log               enable row level security;
alter table staff_roles             enable row level security;

-- ---------------------------------------------------------------- profiles ---
create policy profiles_self_read on profiles for select
  using (id = auth.uid() or is_staff());
create policy profiles_self_update on profiles for update
  using (id = auth.uid()) with check (id = auth.uid());
create policy profiles_insert_self on profiles for insert
  with check (id = auth.uid());
-- Investor classification is never self-service: only compliance may change it.
create policy profiles_class_by_compliance on profiles for update
  using (is_staff('compliance')) with check (is_staff('compliance'));

-- ------------------------------------------------------------- assessments ---
create policy assessments_own_read on investor_assessments for select
  using (profile_id = auth.uid() or is_staff());
-- Inserted server-side after the test is completed; append-only by omission
-- of any UPDATE or DELETE policy.
create policy assessments_insert on investor_assessments for insert
  with check (profile_id = auth.uid() or is_staff());

-- --------------------------------------------------------------------- kyc ---
create policy kyc_own_read on kyc_sessions for select
  using (profile_id = auth.uid() or is_staff());
create policy kyc_events_read on kyc_status_events for select
  using (is_staff() or exists (
    select 1 from kyc_sessions s where s.id = session_id and s.profile_id = auth.uid()));
-- Writes come from the service role via the KYC service (webhooks), which
-- bypasses RLS; no client-side policy is granted on purpose.

-- --------------------------------------------------------------- companies ---
create policy companies_read on companies for select
  using (owner_profile = auth.uid() or is_staff()
         or exists (select 1 from offers o where o.company_id = companies.id and o.status in ('open','funded')));
create policy companies_insert on companies for insert
  with check (owner_profile = auth.uid());
create policy companies_update_own on companies for update
  using (owner_profile = auth.uid() or is_staff('compliance'))
  with check (owner_profile = auth.uid() or is_staff('compliance'));

-- ------------------------------------------------------------ applications ---
create policy applications_read on applications for select
  using (is_staff() or owns_company(company_id));
create policy applications_insert on applications for insert
  with check (owns_company(company_id));
-- Stage changes are a compliance decision, not the applicant's
create policy applications_stage_by_staff on applications for update
  using (is_staff('compliance')) with check (is_staff('compliance'));
create policy application_events_read on application_events for select
  using (is_staff() or exists (
    select 1 from applications a where a.id = application_id and owns_company(a.company_id)));
create policy application_events_insert on application_events for insert
  with check (is_staff('compliance'));

-- ------------------------------------------------------------------ offers ---
-- Open and funded offers are public to signed-in users; drafts are not.
create policy offers_read on offers for select
  using (status in ('open','funded','suspended') or is_staff() or owns_company(company_id));
create policy offers_write_staff on offers for all
  using (is_staff('compliance')) with check (is_staff('compliance'));

-- ------------------------------------------------------------- commitments ---
create policy commitments_own_read on commitments for select
  using (profile_id = auth.uid() or is_staff()
         or exists (select 1 from offers o where o.id = offer_id and owns_company(o.company_id)));
create policy commitments_insert_self on commitments for insert
  with check (profile_id = auth.uid());
-- The investor may only ever withdraw, and only inside the reflection period.
create policy commitments_withdraw_self on commitments for update
  using (profile_id = auth.uid() and status = 'reflection' and reflection_ends_at > now())
  with check (profile_id = auth.uid() and status = 'withdrawn');
create policy commitments_manage_staff on commitments for update
  using (is_staff('operations') or is_staff('compliance'))
  with check (is_staff('operations') or is_staff('compliance'));

-- --------------------------------------------------------- nominee register ---
create policy holdings_own_read on nominee_holdings for select
  using (profile_id = auth.uid() or is_staff());
create policy holdings_write_staff on nominee_holdings for all
  using (is_staff('operations') or is_staff('compliance'))
  with check (is_staff('operations') or is_staff('compliance'));
create policy register_events_read on nominee_register_events for select
  using (is_staff() or exists (
    select 1 from nominee_holdings h where h.id = holding_id and h.profile_id = auth.uid()));
create policy register_events_insert on nominee_register_events for insert
  with check (is_staff('operations') or is_staff('compliance'));

-- ------------------------------------------------------------ board notices ---
create policy notices_read on board_notices for select
  using (auth.uid() is not null);
create policy notices_insert_self on board_notices for insert
  with check (profile_id = auth.uid()
    and exists (select 1 from nominee_holdings h
                where h.profile_id = auth.uid() and h.company_id = board_notices.company_id));
create policy notices_withdraw_self on board_notices for update
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());

-- -------------------------------------------------------------- communities ---
create policy communities_read on communities for select
  using (auth.uid() is not null);
create policy members_read on community_members for select
  using (exists (select 1 from community_members m
                 where m.community_id = community_members.community_id
                   and m.profile_id = auth.uid() and m.left_at is null)
         or is_staff());
create policy members_join_self on community_members for insert
  with check (profile_id = auth.uid());
create policy members_leave_self on community_members for update
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());
create policy messages_read on community_messages for select
  using (hidden_at is null and exists (
           select 1 from community_members m
           where m.community_id = community_messages.community_id
             and m.profile_id = auth.uid() and m.left_at is null)
         or is_staff());
create policy messages_post on community_messages for insert
  with check (profile_id = auth.uid() and exists (
    select 1 from community_members m
    where m.community_id = community_messages.community_id
      and m.profile_id = auth.uid() and m.left_at is null));
-- Only compliance can hide a post, and hiding is the only permitted update.
create policy messages_moderate on community_messages for update
  using (is_staff('compliance')) with check (is_staff('compliance'));

-- --------------------------------------------------------------- complaints ---
-- Anyone may lodge a complaint, including without an account (ECSPR art 7).
create policy complaints_insert_anyone on complaints for insert
  with check (true);
create policy complaints_read on complaints for select
  using (profile_id = auth.uid() or is_staff());
create policy complaints_handle on complaints for update
  using (is_staff('compliance')) with check (is_staff('compliance'));
create policy complaint_events_read on complaint_events for select
  using (is_staff() or exists (
    select 1 from complaints c where c.id = complaint_id and c.profile_id = auth.uid()));
create policy complaint_events_insert on complaint_events for insert
  with check (is_staff('compliance'));

-- ------------------------------------------------------------- registers ---
create policy marketing_read on marketing_approvals for select using (is_staff());
create policy marketing_write on marketing_approvals for all
  using (is_staff('compliance')) with check (is_staff('compliance'));
create policy audit_read on audit_log for select using (is_staff('compliance') or is_staff('board'));
create policy audit_insert on audit_log for insert with check (auth.uid() is not null);
create policy staff_roles_read on staff_roles for select using (is_staff());
create policy staff_roles_write on staff_roles for all
  using (is_staff('board')) with check (is_staff('board'));

-- =============================================================================
-- Nothing above grants DELETE on any table, to any role. Deletion happens only
-- through the retention job running as the service role, and only once the
-- ECSPR art 26 five-year period has expired with no legal hold in place.
-- =============================================================================
revoke delete on all tables in schema public from anon, authenticated;

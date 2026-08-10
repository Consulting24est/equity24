-- =============================================================================
-- Equity24.io — full schema, in order. Paste into the Supabase SQL editor and
-- run once:  Dashboard -> SQL Editor -> New query -> paste -> Run. Safe to re-run.
-- =============================================================================

-- >>>>>>>>>>>>>>>>>>>>>> 0001_schema.sql >>>>>>>>>>>>>>>>>>>>>>

-- =============================================================================
-- Equity24.io — core schema
-- AureviaFund OÜ · ECSPR (EU) 2020/1503 crowdfunding platform
--
-- Design principle: the regulation's hard rules live in the database, not only
-- in application code. Status histories are append-only, nothing is hard
-- deleted, and an investment cannot be recorded unless verification and the
-- appropriateness assessments are valid at that moment.
-- =============================================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------------ enums ---
create type account_type as enum ('private_investor', 'corporate_investor', 'company');
create type investor_class as enum ('non_sophisticated', 'sophisticated');

-- Didit statuses, case-sensitive in the provider's API, normalised here.
create type kyc_status as enum (
  'not_started', 'in_progress', 'awaiting_user', 'in_review',
  'approved', 'declined', 'abandoned', 'resubmitted', 'expired', 'kyc_expired'
);
create type kyc_kind as enum ('user', 'business');          -- KYC vs KYB

create type application_stage as enum (
  'submitted', 'eligibility_screening', 'due_diligence',
  'kiis_preparation', 'kiis_check', 'offer_open', 'settled',
  'declined', 'withdrawn'
);
create type offer_status as enum ('draft', 'open', 'suspended', 'cancelled', 'funded', 'failed');
create type commitment_status as enum ('reflection', 'confirmed', 'withdrawn', 'refunded', 'settled');
create type assessment_kind as enum ('knowledge_test', 'loss_simulation');
create type complaint_status as enum ('received', 'acknowledged', 'investigating', 'answered', 'closed');
create type complaint_outcome as enum ('upheld', 'partly_upheld', 'not_upheld', 'settled', 'withdrawn');
create type community_role as enum ('founder', 'team', 'investor', 'moderator');
create type notice_side as enum ('selling', 'buying');

-- --------------------------------------------------------------- profiles ---
create table profiles (
  id                    uuid primary key references auth.users on delete restrict,
  account_type          account_type not null default 'private_investor',
  investor_class        investor_class not null default 'non_sophisticated',
  -- ECSPR art 12: sophisticated status lasts a maximum of two years
  investor_class_until  timestamptz,
  full_name             text not null,
  email                 text not null,
  phone                 text,
  country               text not null default 'EE',
  company_name          text,
  company_registry_code text,
  avatar_url            text,
  -- Evidence of acceptance — which version, and exactly when
  terms_version         text,
  terms_accepted_at     timestamptz,
  privacy_version       text,
  privacy_accepted_at   timestamptz,
  -- Declared net worth, stored as a band (data minimisation, lisa 9 §4)
  net_worth_band        text,
  net_worth_midpoint    numeric(14,2),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- Retention marker; rows are never hard deleted (ECSPR art 26)
  closed_at             timestamptz,
  constraint sophisticated_needs_expiry
    check (investor_class = 'non_sophisticated' or investor_class_until is not null),
  constraint corporate_needs_company
    check (account_type <> 'corporate_investor' or company_name is not null)
);
comment on table profiles is 'Platform accounts. Never hard delete — ECSPR art 26 requires 5-year retention.';

-- --------------------------------------------- appropriateness assessments ---
-- Append-only. A retake is a new row; history is the record (art 26).
create table investor_assessments (
  id            uuid primary key default gen_random_uuid(),
  profile_id    uuid not null references profiles(id) on delete restrict,
  kind          assessment_kind not null,
  passed        boolean not null,
  score         int,
  -- What the investor was shown, hashed, so we can prove it later
  content_hash  text,
  -- 10% of net worth, the figure shown by the loss simulation
  bearable_loss numeric(14,2),
  taken_at      timestamptz not null default now(),
  -- knowledge test: 2 years · loss simulation: 1 year (ECSPR art 21(6))
  valid_until   timestamptz not null
);
create index on investor_assessments (profile_id, kind, valid_until desc);
comment on table investor_assessments is 'Append-only. Never update or delete a row — retake by inserting a new one.';

-- Latest valid assessment per kind
create or replace function assessment_valid(p_profile uuid, p_kind assessment_kind)
returns boolean language sql stable as $$
  select exists (
    select 1 from investor_assessments
    where profile_id = p_profile and kind = p_kind
      and passed and valid_until > now()
  );
$$;

-- ----------------------------------------------------------- kyc sessions ---
create table kyc_sessions (
  id                  uuid primary key default gen_random_uuid(),
  profile_id          uuid references profiles(id) on delete restrict,
  provider            text not null default 'didit',
  provider_session_id text not null unique,
  kind                kyc_kind not null,
  status              kyc_status not null default 'not_started',
  vendor_data         text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index on kyc_sessions (profile_id, status);

-- Append-only status history — every webhook is evidence
create table kyc_status_events (
  id             bigserial primary key,
  session_id     uuid not null references kyc_sessions(id) on delete restrict,
  status         kyc_status not null,
  provider_event text unique,             -- Didit event_id, gives idempotency
  webhook_type   text,
  verified_via   text,                    -- which signature variant passed
  received_at    timestamptz not null default now(),
  raw            jsonb
);
comment on table kyc_status_events is 'Append-only. Provider webhooks; provider_event unique so retries are idempotent.';

create or replace function kyc_approved(p_profile uuid, p_kind kyc_kind default 'user')
returns boolean language sql stable as $$
  select exists (
    select 1 from kyc_sessions
    where profile_id = p_profile and kind = p_kind and status = 'approved'
  );
$$;

-- -------------------------------------------------------------- companies ---
create table companies (
  id              uuid primary key default gen_random_uuid(),
  owner_profile   uuid not null references profiles(id) on delete restrict,
  legal_name      text not null,
  registry_code   text not null,
  country         text not null,
  sector          text not null,
  website         text,
  incorporated_on date,
  revenue_last_fy numeric(14,2),
  created_at      timestamptz not null default now(),
  unique (registry_code, country)
);

-- ----------------------------------------------------------- applications ---
create table applications (
  id            uuid primary key default gen_random_uuid(),
  reference     text not null unique,
  company_id    uuid not null references companies(id) on delete restrict,
  stage         application_stage not null default 'submitted',
  target_amount numeric(14,2),
  equity_offered numeric(5,2),
  pre_money     numeric(14,2),
  submitted_at  timestamptz not null default now(),
  decided_at    timestamptz,
  decline_reason text,
  constraint target_within_ecspr_range
    check (target_amount is null or (target_amount >= 100000 and target_amount <= 5000000))
);
comment on constraint target_within_ecspr_range on applications is
  'Upper bound is the ECSPR art 1(2)(c) ceiling of EUR 5,000,000 per project owner per 12 months.';

create table application_events (
  id             bigserial primary key,
  application_id uuid not null references applications(id) on delete restrict,
  stage          application_stage not null,
  note           text,
  actor          uuid references profiles(id),
  occurred_at    timestamptz not null default now()
);

-- ----------------------------------------------------------------- offers ---
create table offers (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete restrict,
  application_id uuid references applications(id),
  status         offer_status not null default 'draft',
  min_target     numeric(14,2) not null,
  max_target     numeric(14,2) not null,
  equity_offered numeric(5,2) not null,
  pre_money      numeric(14,2) not null,
  price_per_share numeric(14,4) not null,
  instrument     text not null default 'OÜ shares · via nominee',
  opens_at       timestamptz,
  closes_at      timestamptz,
  -- KIIS: the project owner's document. We record the version we checked.
  kiis_version   text,
  kiis_url       text,
  kiis_checked_by uuid references profiles(id),
  kiis_checked_at timestamptz,
  kiis_second_reviewer uuid references profiles(id),   -- four-eyes
  created_at     timestamptz not null default now(),
  constraint min_le_max check (min_target <= max_target),
  constraint max_within_ceiling check (max_target <= 5000000),
  -- An offer may not open until a KIIS has passed the check by two reviewers
  constraint open_requires_kiis_four_eyes check (
    status <> 'open' or (
      kiis_version is not null and kiis_checked_by is not null
      and kiis_second_reviewer is not null and kiis_second_reviewer <> kiis_checked_by
    )
  )
);
comment on constraint open_requires_kiis_four_eyes on offers is
  'ECSPR art 23 completeness check with the four-eyes rule from lisa 18 §4.';

-- ------------------------------------------------------------ commitments ---
create table commitments (
  id                uuid primary key default gen_random_uuid(),
  offer_id          uuid not null references offers(id) on delete restrict,
  profile_id        uuid not null references profiles(id) on delete restrict,
  amount            numeric(14,2) not null check (amount >= 100),
  -- Evidence that the art 21(7) warning was shown and consented to
  threshold_warning_shown boolean not null default false,
  threshold_consent_hash  text,
  kiis_version_shown text not null,
  status            commitment_status not null default 'reflection',
  committed_at      timestamptz not null default now(),
  -- ECSPR art 22: four CALENDAR days, server-side, UTC.
  -- Set by the commitments_reflection trigger below, never by the client. It
  -- cannot be a generated column: timestamptz + interval is only STABLE, not
  -- IMMUTABLE, because the result depends on the session time zone.
  reflection_ends_at timestamptz not null,
  withdrawn_at      timestamptz,
  settled_at        timestamptz,
  payment_method    text,          -- 'sepa' | 'card'
  psp_reference     text
);
create index on commitments (offer_id, status);
create index on commitments (profile_id, status);
comment on column commitments.reflection_ends_at is
  'Trigger-set, not application-supplied: ECSPR art 22 four calendar days cannot be shortened by a bug.';

-- The reflection period is computed from committed_at in UTC and overwritten on
-- every insert and on any change to committed_at, so nothing the application
-- sends can shorten it. Fires before the constraint check, so the not-null
-- column needs no default.
create or replace function set_reflection_ends_at()
returns trigger language plpgsql as $$
begin
  -- 96 hours, not '4 days': adding a day-interval to a timestamptz is resolved
  -- in the session time zone, so a DST change could make the period 95 hours.
  -- Hours are absolute and can never come out shorter than four full days.
  new.reflection_ends_at := new.committed_at + interval '96 hours';
  return new;
end;
$$;
create trigger commitments_reflection
  before insert or update of committed_at on commitments
  for each row execute function set_reflection_ends_at();

-- Compliance gate: an investment may only be recorded when every
-- precondition is satisfied at that moment (lisa 19 §8).
create or replace function enforce_investment_preconditions()
returns trigger language plpgsql as $$
declare
  v_class investor_class;
begin
  select investor_class into v_class from profiles where id = new.profile_id;

  if not kyc_approved(new.profile_id, 'user') then
    raise exception 'Investment blocked: identity verification is not approved (ECSPR art 5 / AML).';
  end if;

  -- Sophisticated investors are exempt from the appropriateness assessments
  if v_class = 'non_sophisticated' then
    if not assessment_valid(new.profile_id, 'knowledge_test') then
      raise exception 'Investment blocked: entry knowledge test missing or expired (ECSPR art 21(1)-(3),(6)).';
    end if;
    if not assessment_valid(new.profile_id, 'loss_simulation') then
      raise exception 'Investment blocked: loss-bearing simulation missing or expired (ECSPR art 21(5)).';
    end if;
  end if;

  if not exists (select 1 from offers where id = new.offer_id and status = 'open') then
    raise exception 'Investment blocked: the offer is not open.';
  end if;

  return new;
end;
$$;
create trigger commitments_preconditions
  before insert on commitments
  for each row execute function enforce_investment_preconditions();

-- Funds may not be released while any reflection period is still running
create or replace function offer_may_settle(p_offer uuid)
returns boolean language sql stable as $$
  select not exists (
    select 1 from commitments
    where offer_id = p_offer and status = 'reflection' and reflection_ends_at > now()
  );
$$;

-- ------------------------------------------------------- nominee register ---
-- AureviaFund OÜ is the registered shareholder; this is the record of who
-- each holding is actually for (lisa 5 §6.3.4).
create table nominee_holdings (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete restrict,
  profile_id    uuid not null references profiles(id) on delete restrict,
  shares        numeric(18,4) not null check (shares > 0),
  nominal_value numeric(14,4),
  acquired_at   timestamptz not null,
  acquired_price numeric(14,4),
  commitment_id uuid references commitments(id),
  created_at    timestamptz not null default now()
);
create index on nominee_holdings (profile_id);
create index on nominee_holdings (company_id);

create table nominee_register_events (
  id           bigserial primary key,
  holding_id   uuid references nominee_holdings(id) on delete restrict,
  event        text not null,        -- 'entry' | 'transfer_in' | 'transfer_out' | 'correction'
  shares_delta numeric(18,4) not null,
  counterparty uuid references profiles(id),
  -- Tamper-evidence: hash of the register state after this event
  state_hash   text,
  actor        uuid references profiles(id),
  occurred_at  timestamptz not null default now(),
  note         text
);
comment on table nominee_register_events is 'Append-only. The nominee register''s audit trail (lisa 5 §6.3.4).';

-- ------------------------------------------------- bulletin board (art 25) ---
-- Notices only. No matching, no execution, no platform pricing.
create table board_notices (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references companies(id) on delete restrict,
  profile_id   uuid not null references profiles(id) on delete restrict,
  side         notice_side not null,
  shares       numeric(18,4) not null check (shares > 0),
  -- The poster's own non-binding indication; nullable because price is optional
  indicated_price numeric(14,4),
  posted_at    timestamptz not null default now(),
  expires_at   timestamptz,
  withdrawn_at timestamptz
);
comment on table board_notices is
  'ECSPR art 25 bulletin board: notices of interest only. There is deliberately no matching table, no order book and no execution path.';

-- ------------------------------------------------------------ communities ---
create table communities (
  id         uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete restrict unique,
  name       text not null,
  created_at timestamptz not null default now()
);
create table community_members (
  community_id uuid not null references communities(id) on delete restrict,
  profile_id   uuid not null references profiles(id) on delete restrict,
  role         community_role not null default 'investor',
  joined_at    timestamptz not null default now(),
  left_at      timestamptz,
  primary key (community_id, profile_id)
);
create table community_messages (
  id           uuid primary key default gen_random_uuid(),
  community_id uuid not null references communities(id) on delete restrict,
  profile_id   uuid not null references profiles(id) on delete restrict,
  body         text not null,
  posted_at    timestamptz not null default now(),
  -- Moderation for ECSPR art 27: a project-owner post must stay consistent
  -- with the KIIS. Hidden, never deleted, so the record survives.
  hidden_at    timestamptz,
  hidden_by    uuid references profiles(id),
  hidden_reason text
);
create index on community_messages (community_id, posted_at desc);

-- ------------------------------------------------------------- complaints ---
create table complaints (
  id             uuid primary key default gen_random_uuid(),
  reference      text not null unique,
  profile_id     uuid references profiles(id),         -- nullable: no account needed
  complainant_name  text not null,
  complainant_email text not null,
  is_consumer    boolean not null default true,
  channel        text not null,
  offer_id       uuid references offers(id),
  summary        text not null,
  status         complaint_status not null default 'received',
  outcome        complaint_outcome,
  handler        uuid references profiles(id),
  received_at    timestamptz not null default now(),
  acknowledged_at timestamptz,
  answered_at    timestamptz,
  closed_at      timestamptz,
  redress_amount numeric(14,2),
  root_cause     text,
  regulatory_breach boolean not null default false,
  -- lisa 17: acknowledge within 5 business days, final answer within 15 (max 35)
  ack_due_at     timestamptz not null default (now() + interval '5 days'),
  answer_due_at  timestamptz not null default (now() + interval '15 days')
);
create table complaint_events (
  id           bigserial primary key,
  complaint_id uuid not null references complaints(id) on delete restrict,
  status       complaint_status not null,
  note         text,
  actor        uuid references profiles(id),
  occurred_at  timestamptz not null default now()
);

-- ------------------------------------------------ marketing approvals reg ---
create table marketing_approvals (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  channel       text not null,
  offer_id      uuid references offers(id),
  kiis_version_checked text,
  created_by    uuid references profiles(id),
  approved_by   uuid references profiles(id),
  approved_at   timestamptz,
  published_at  timestamptz,
  withdrawn_at  timestamptz,
  content_ref   text
);
comment on table marketing_approvals is
  'ECSPR art 27: every marketing communication is approved before publication and checked against the live KIIS.';

-- ------------------------------------------------------------- audit log ---
create table audit_log (
  id          bigserial primary key,
  actor       uuid references profiles(id),
  action      text not null,
  entity      text not null,
  entity_id   text,
  detail      jsonb,
  ip          inet,
  occurred_at timestamptz not null default now()
);
create index on audit_log (entity, entity_id, occurred_at desc);
comment on table audit_log is 'Append-only. ECSPR art 26: retain at least 5 years and produce on request.';

-- --------------------------------------------------------- updated_at glue ---
create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
create trigger profiles_touch before update on profiles
  for each row execute function touch_updated_at();
create trigger kyc_sessions_touch before update on kyc_sessions
  for each row execute function touch_updated_at();

-- >>>>>>>>>>>>>>>>>>>>>> 0002_rls.sql >>>>>>>>>>>>>>>>>>>>>>

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

-- >>>>>>>>>>>>>>>>>>>>>> 0003_auth_bootstrap.sql >>>>>>>>>>>>>>>>>>>>>>

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

-- >>>>>>>>>>>>>>>>>>>>>> 0004_fix_community_rls.sql >>>>>>>>>>>>>>>>>>>>>>

-- =============================================================================
-- Equity24.io — fix infinite recursion in the community policies
--
-- 0002 wrote membership checks as subqueries against community_members from
-- inside a policy ON community_members, so evaluating the policy re-evaluated
-- the policy: 42P17 "infinite recursion detected in policy". Both tables
-- existed but every read failed.
--
-- The fix is the standard one: move the membership test into a security definer
-- function. It runs as the owner, so RLS is not re-applied inside it and the
-- cycle is broken. The visibility rule itself is unchanged — you see a
-- community's members and messages only if you are currently a member of it.
--
-- Run after 0001-0003. Safe to re-run.
-- =============================================================================

create or replace function is_community_member(p_community uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from community_members
    where community_id = p_community
      and profile_id = auth.uid()
      and left_at is null
  );
$$;

-- --------------------------------------------------------- community_members ---
drop policy if exists members_read on community_members;
create policy members_read on community_members for select
  using (is_community_member(community_id) or is_staff());

-- -------------------------------------------------------- community_messages ---
drop policy if exists messages_read on community_messages;
create policy messages_read on community_messages for select
  using ((hidden_at is null and is_community_member(community_id)) or is_staff());

drop policy if exists messages_post on community_messages;
create policy messages_post on community_messages for insert
  with check (profile_id = auth.uid() and is_community_member(community_id));

-- messages_moderate (compliance-only UPDATE, i.e. hiding) is unaffected: it
-- never referenced community_members.

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

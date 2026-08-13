-- =============================================================================
-- Equity24.io — verification invites
--
-- An applicant lists the people behind the company: board members, shareholders
-- over 25%, beneficial owners. Each of those people has to prove who they are
-- and hand over a criminal-record extract. They are not our users, they have no
-- account, and most of them never asked to be here — so the flow has to work
-- from a single link in a single email.
--
-- The link carries a token. The token resolves to this row, which already holds
-- the person's name, the company that listed them and why. That matters: the
-- alternative is asking them to type their own name and their company's name on
-- arrival, which is friction on an unwilling participant and, as evidence,
-- worth nothing — a self-declared name proves only that someone can type.
--
-- Identity comes from the ID document instead, and name_match_grade() compares
-- what the document says against what the applicant declared. See the note on
-- that function for why a mismatch is never allowed to auto-fail.
--
-- Run after 0001-0005. Safe to re-run.
-- =============================================================================

do $$ begin
  create type invite_status as enum (
    'sent',              -- email dispatched
    'opened',            -- the link was followed
    'id_verified',       -- identity check approved
    'records_received',  -- criminal-record extract uploaded
    'complete',          -- both done, nothing outstanding
    'expired',
    'revoked'            -- applicant removed the person, or re-sent (old token dies)
  );
exception when duplicate_object then null; end $$;

-- ------------------------------------------------------------- the invite ---
create table if not exists verification_invites (
  id              uuid primary key default gen_random_uuid(),

  -- Who is asking. The application itself still lives in the applicant's
  -- browser, so the invite hangs off the profile rather than an application
  -- row; company_name is copied in at send time so the email and the landing
  -- page can name the company without reading anything else.
  owner_profile   uuid not null references profiles(id) on delete cascade,
  company_name    text not null,

  -- Who is being asked. person_key matches the app's own personKey() — the
  -- lowercased email — so somebody listed as both director and 50% owner is
  -- one row and gets one email, not two.
  person_key      text not null,
  declared_name   text not null,
  declared_email  text not null,
  roles           text[] not null default '{}',   -- board / shareholder / ubo
  equity_pct      numeric(6,3),
  is_entity       boolean not null default false, -- corporate shareholder: KYB, not KYC
  needs_criminal_record boolean not null default true,

  -- The credential. Only the SHA-256 of the token is stored: a leaked backup,
  -- a stray log line or a curious staff member with table access still cannot
  -- reconstruct a working link.
  token_hash      text not null unique,
  expires_at      timestamptz not null default (now() + interval '30 days'),

  status          invite_status not null default 'sent',
  sent_at             timestamptz not null default now(),
  opened_at           timestamptz,
  id_verified_at      timestamptz,
  records_received_at timestamptz,
  completed_at        timestamptz,

  -- Outcome of the identity check
  kyc_session_id  uuid references kyc_sessions(id),
  verified_name   text,                            -- the name on the document
  name_match      text check (name_match in ('exact', 'close', 'mismatch')),
  review_required boolean not null default false,
  review_note     text,

  -- Delivery, so "they never got it" is answerable
  email_provider_id text,
  email_error       text,

  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  -- One live invite per person per applicant. Re-sending overwrites the row
  -- with a fresh token, which is what kills the previous link.
  unique (owner_profile, person_key)
);

create index if not exists verification_invites_owner_status on verification_invites (owner_profile, status);
create index if not exists verification_invites_status_expiry on verification_invites (status, expires_at);

comment on column verification_invites.token_hash is
  'SHA-256 of the link token, hex. The token itself exists only in the email.';
comment on column verification_invites.needs_criminal_record is
  'Board members and everyone over 25%. Set at send time from the matrix the applicant sees.';

drop trigger if exists verification_invites_touch on verification_invites;
create trigger verification_invites_touch before update on verification_invites
  for each row execute function touch_updated_at();

-- Status is derived, never assigned. Three different callers move this row —
-- the landing page on open, the KYC webhook on approval, the upload endpoint on
-- receipt — and each of them knows only about its own step. Letting them each
-- write a status is how a person ends up 'opened' after they have finished.
create or replace function invite_status_from_progress()
returns trigger language plpgsql as $$
begin
  if new.status = 'revoked' then return new; end if;

  if new.id_verified_at is not null
     and (not new.needs_criminal_record or new.records_received_at is not null) then
    new.status := 'complete';
    new.completed_at := coalesce(new.completed_at, now());
  elsif new.records_received_at is not null then
    new.status := 'records_received';
  elsif new.id_verified_at is not null then
    new.status := 'id_verified';
  elsif new.opened_at is not null then
    new.status := 'opened';
  else
    new.status := 'sent';
  end if;
  return new;
end $$;

drop trigger if exists verification_invites_status on verification_invites;
create trigger verification_invites_status
  before insert or update on verification_invites
  for each row execute function invite_status_from_progress();

-- --------------------------------------------------------------- documents ---
-- Deliberately NOT readable by the applicant. A company does not need to hold
-- its own directors' criminal-record extracts — we do, under art 26. Keeping
-- the file on our side is also the only reason a director will upload it at
-- all: they are handing it to a supervised platform, not to the colleagues
-- they sit on a board with.
create table if not exists verification_documents (
  id            uuid primary key default gen_random_uuid(),
  invite_id     uuid not null references verification_invites(id) on delete cascade,
  kind          text not null default 'criminal_record',
  storage_path  text not null unique,
  original_name text,
  bytes         bigint,
  content_type  text,
  uploaded_at   timestamptz not null default now()
);
create index if not exists verification_documents_invite on verification_documents (invite_id);

comment on table verification_documents is
  'Criminal-record extracts and similar. Visible to staff only — never to the applicant company.';

-- ------------------------------------------------------------ name matching --
-- Strips case, diacritics and punctuation, then compares the set of name parts.
-- unaccent() is an extension that may not be present, so the fold is explicit.
-- translate() pairs the two strings character by character and DELETES any
-- source character with no partner, so these two must stay exactly the same
-- length. They are written in aligned groups for that reason: an off-by-one
-- here does not error, it silently folds 'ô' to the wrong letter and every
-- character after it too, which would show up only as unexplained name
-- mismatches on people with accents in their names.
create or replace function name_normalise(p text)
returns text[] language sql immutable as $$
  select coalesce(
    array_remove(
      string_to_array(
        regexp_replace(
          translate(
            lower(coalesce(p, '')),
            'äöüõšžåæø' || 'éèêë' || 'áàâã' || 'íìîï' || 'óòô' || 'úùû' || 'ñçýÿ' || 'đřćčłń',
            'aouoszaao' || 'eeee' || 'aaaa' || 'iiii' || 'ooo' || 'uuu' || 'ncyy' || 'drccln'
          ),
          '[^a-z ]', ' ', 'g'),
        ' '),
      ''),
    '{}'::text[]);
$$;

-- Fails the migration rather than shipping a fold that quietly mangles names.
do $$
begin
  if name_normalise('Mardo Sõõ-Öö') <> array['mardo', 'soo', 'oo'] then
    raise exception 'name_normalise is not folding correctly: got %', name_normalise('Mardo Sõõ-Öö');
  end if;
  if name_normalise('Ôlaf Ümar') <> array['olaf', 'umar'] then
    raise exception 'diacritic table is misaligned: got %', name_normalise('Ôlaf Ümar');
  end if;
end $$;

-- 'exact'    — the same name parts, in any order
-- 'close'    — one name is contained in the other (middle names, dropped
--              patronymics) or differs by a single part
-- 'mismatch' — anything else
--
-- A 'mismatch' must never auto-fail the person. In practice it is almost always
-- a typo by the applicant, a married name, or a transliterated passport — but it
-- is also exactly what a forwarded link looks like, so it has to be seen by a
-- human rather than decided by this function.
create or replace function name_match_grade(p_declared text, p_verified text)
returns text language plpgsql immutable as $$
declare
  a text[] := name_normalise(p_declared);
  b text[] := name_normalise(p_verified);
  shared int;
begin
  if array_length(a, 1) is null or array_length(b, 1) is null then
    return 'mismatch';
  end if;

  -- same parts, any order
  if (select array_agg(x order by x) from unnest(a) x)
   = (select array_agg(x order by x) from unnest(b) x) then
    return 'exact';
  end if;

  select count(distinct x) into shared
  from unnest(a) x where x = any(b);

  -- every part of the shorter name appears in the longer one
  if shared = least(array_length(a, 1), array_length(b, 1)) then
    return 'close';
  end if;
  -- or they differ by exactly one part, and at least two parts agree
  if shared >= 2 and shared >= greatest(array_length(a, 1), array_length(b, 1)) - 1 then
    return 'close';
  end if;

  return 'mismatch';
end $$;

-- The cases this has to get right, asserted rather than described. Each one is
-- a real thing that happens: shouted-out casing, an Estonian passport against a
-- form typed without diacritics, a middle name the applicant did not know, a
-- registry that prints surname first — and, last, an actual different person.
do $$
begin
  if name_match_grade('Mardo Soo', 'MARDO SOO')          <> 'exact'    then raise exception 'case folding'; end if;
  if name_match_grade('Mardo Soo', 'Soo, Mardo')         <> 'exact'    then raise exception 'name order'; end if;
  -- Deliberate, and the one place this is deliberately permissive: folding
  -- diacritics means Soo and Sõõ become the same name. Estonian forms lose õ ä
  -- ö ü constantly, so not folding would flag a large share of honest people;
  -- folding lets through the rare pair of real surnames that differ only by an
  -- accent. The first failure mode is common and the second is not.
  if name_match_grade('Mardo Soo', 'Mardo Sõõ')          <> 'exact'    then raise exception 'diacritics must fold'; end if;
  if name_match_grade('Mardo Soo', 'Mardo Andres Soo')   <> 'close'    then raise exception 'middle name'; end if;
  if name_match_grade('Anna Maria Tamm', 'Anna Maria Kask') <> 'close' then raise exception 'married name, 3 parts'; end if;
  if name_match_grade('Anna Tamm', 'Anna Kask')          <> 'mismatch' then raise exception 'two-part surname change must be looked at'; end if;
  if name_match_grade('Mardo Soo', 'Jaan Tamm')          <> 'mismatch' then raise exception 'different person'; end if;
  if name_match_grade('Mardo Soo', '')                   <> 'mismatch' then raise exception 'empty'; end if;
  if name_match_grade('Mardo Soo', null)                 <> 'mismatch' then raise exception 'null'; end if;
end $$;

-- ---------------------------------------------------------------- policies ---
alter table verification_invites   enable row level security;
alter table verification_documents enable row level security;

-- The applicant sees the people they listed and how far each has got. They
-- cannot insert or edit: invites are created by the send-verification function
-- under the service role, so a token can only ever come from a real send.
drop policy if exists invites_owner_read on verification_invites;
create policy invites_owner_read on verification_invites
  for select using (owner_profile = auth.uid() or is_staff());

drop policy if exists invites_staff_write on verification_invites;
create policy invites_staff_write on verification_invites
  for update using (is_staff()) with check (is_staff());

-- Staff only, per the comment on the table.
drop policy if exists documents_staff_read on verification_documents;
create policy documents_staff_read on verification_documents
  for select using (is_staff());

-- ------------------------------------------------------------------ status ---
-- What the applicant's screen shows, without exposing tokens or documents.
create or replace function invite_progress(p_owner uuid default auth.uid())
returns table (
  person_key text, declared_name text, declared_email text,
  status invite_status, roles text[], is_entity boolean,
  needs_criminal_record boolean, review_required boolean,
  sent_at timestamptz, opened_at timestamptz, completed_at timestamptz,
  expires_at timestamptz
) language sql stable security definer set search_path = public as $$
  select i.person_key, i.declared_name, i.declared_email,
         case when i.status not in ('complete', 'revoked') and i.expires_at < now()
              then 'expired'::invite_status else i.status end,
         i.roles, i.is_entity, i.needs_criminal_record, i.review_required,
         i.sent_at, i.opened_at, i.completed_at, i.expires_at
  from verification_invites i
  where i.owner_profile = p_owner
    and (p_owner = auth.uid() or is_staff())
  order by i.sent_at desc;
$$;

-- =============================================================================
-- Storage: create a PRIVATE bucket named 'verification-documents' in the
-- dashboard. No public policy — files are reached only through a signed URL
-- issued by an edge function to a member of staff.
-- =============================================================================

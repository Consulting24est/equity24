# Supabase — equity24.io

Project `wmwcpfdqxkvojuddwhls` · https://wmwcpfdqxkvojuddwhls.supabase.co

## Applying the migrations

The Supabase CLI is not installed on this machine and `supabase login` needs an
interactive browser, so run these yourself:

```bash
brew install supabase/tap/supabase
supabase login
supabase link --project-ref wmwcpfdqxkvojuddwhls
supabase db push
```

Or paste `migrations/0001_schema.sql` then `migrations/0002_rls.sql` into the
SQL editor at supabase.com → your project → SQL Editor. Order matters.

## What the schema enforces, so the app cannot forget

| Rule | How it is enforced |
|---|---|
| 4-calendar-day reflection period (art 22) | `commitments.reflection_ends_at` is a **generated** column — the app cannot shorten it |
| Investment blocked without verification and valid assessments (art 21, lisa 19 §8) | `enforce_investment_preconditions()` trigger raises on insert |
| Knowledge test valid 2 years, simulation 1 year (art 21(6)) | `valid_until` on each assessment row; `assessment_valid()` checks it |
| KIIS checked by two different reviewers before an offer opens (art 23, lisa 18 §4) | `open_requires_kiis_four_eyes` check constraint |
| EUR 5,000,000 ceiling per project owner (art 1(2)(c)) | `max_within_ceiling` check constraint |
| Funds not released while any reflection period runs | `offer_may_settle()` |
| Bulletin board is notices only (art 25) | There is no matching table, no order book, no execution path — by design |
| 5-year retention, no destruction of evidence (art 26) | Status histories are append-only; **no DELETE policy exists for any role** |
| Complaints free and open to anyone (art 7) | `complaints_insert_anyone` allows insert without an account |

## Keys

- **Publishable key** (`sb_publishable_…`) — safe in the browser, in `config.json`.
- **Service-role key** — server-side only. Put it in `kyc-service/.env` as
  `SUPABASE_SERVICE_KEY`; never commit it, never paste it into chat.
- **Database password** — only for direct `psql`/CLI use. Never in the repo.

The KYC service writes `kyc_sessions` and `kyc_status_events` with the service
role, which bypasses RLS — that is why no client-side insert policy exists on
those tables.

## Still to do

1. Apply the migrations (above).
2. Enable the auth providers the signup flow offers — Google and LinkedIn are
   currently **disabled** on this project (checked via `/auth/v1/settings`).
3. Add `SUPABASE_SERVICE_KEY` to `kyc-service/.env` and switch the KYC service
   from `kyc-store.json` to the database.
4. Seed `staff_roles` with the compliance, operations and board users — until
   then no one can act as staff, which is the safe default.

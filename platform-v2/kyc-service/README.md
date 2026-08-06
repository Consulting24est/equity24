# KYC integration — Didit

Server-side integration for identity verification. Zero dependencies, Node 18+.

## Why there is a server at all

The Didit API key grants full access to your Didit account. It can never live in
the browser: the landing page and the app prototype are static files served to
anyone. So the browser only ever sees a **session id** and a **hosted verification
URL**; every call carrying the key happens in `server.js`.

## Run it

```bash
cd kyc-service
node server.js
```

It serves the whole product on one origin — landing at `/`, app at `/app/`, KYC at
`/api/kyc/*` — so the front-end can call the API without CORS.

| URL | Purpose |
|---|---|
| `http://localhost:8787/` | landing page |
| `http://localhost:8787/app/` | app prototype |
| `http://localhost:8787/api/kyc/health` | config check (never prints the key) |
| `http://localhost:8787/api/kyc/webhook` | register this in the Didit console |

## Configuration — `.env` (chmod 600, gitignored, never deployed)

| Variable | Status | Where to get it |
|---|---|---|
| `DIDIT_API_KEY` | **set** | Didit console → API keys |
| `DIDIT_WORKFLOW_ID` | **required, not yet set** | Didit console → Workflows → copy the workflow UUID |
| `DIDIT_WEBHOOK_SECRET` | **required, not yet set** | Didit console → Webhooks → destination `secret_shared_key` |
| `PUBLIC_BASE_URL` | set | must be the public HTTPS URL once you expose the webhook |

Until `DIDIT_WORKFLOW_ID` is set, `POST /api/kyc/session` returns a clear error
instead of calling Didit — no accidental pay-as-you-go charges.

## Endpoints

**`POST /api/kyc/session`** → `{ user_id, account_type, email, language }`
Creates a Didit session (`POST /v3/session/`) and returns `{ session_id, url, status }`.
`vendor_data` carries our user id so the webhook can be attached to the right account.

**`GET /api/kyc/session/:id`** → polls `GET /v3/session/{id}/decision/`.
Returns **only** `session_id`, `status`, `vendor_data`, timestamps — the full decision
document contains ID images and personal data and is deliberately not proxied to the browser.

**`POST /api/kyc/webhook`** → Didit pushes the outcome here.
- rejects anything with `X-Timestamp` outside ±300s (replay protection)
- verifies `X-Signature` (raw bytes), `X-Signature-V2` (canonical JSON) or
  `X-Signature-Simple` (envelope) with HMAC-SHA256 and constant-time comparison
- deduplicates on `event_id` because Didit retries

**`GET /api/kyc/sessions`** → feeds the admin console's Users · KYC view.

Session statuses are case-sensitive: `Not Started`, `In Progress`, `Approved`,
`Declined`, `In Review`, `Abandoned`, `Resubmitted`, `Awaiting User`, `Expired`, `Kyc Expired`.

## To finish the integration

1. Paste `DIDIT_WORKFLOW_ID` and `DIDIT_WEBHOOK_SECRET` into `.env`.
2. Expose the server over HTTPS and set `PUBLIC_BASE_URL` to that address
   (`cloudflared tunnel --url http://127.0.0.1:8787` works for testing).
3. Register `<PUBLIC_BASE_URL>/api/kyc/webhook` in the Didit console.
4. Run one sandbox verification end to end and confirm the webhook is accepted
   (`[didit] webhook ok: … (x-signature)` in the log).

## Before production

- **Storage.** `kyc-store.json` is a prototype convenience. Move to Postgres with an
  append-only status history — ECSPR art 26 requires records kept for 5 years.
- **Data minimisation.** Keep the decision and its timestamp; do not copy document
  images into your own storage without a documented lawful basis (lisa 9 §3 treats
  identity documents as restricted data, and GDPR art 10 applies to criminal-record
  data in the project-owner checks).
- **The KYC decision must gate the investment path**, not just the profile badge:
  the investment API should reject any commitment where the account's status is not
  `Approved`, alongside the knowledge test and appropriateness checks (lisa 19 §8).
- **Outsourcing.** Didit becomes a processor under GDPR art 28 and, more importantly,
  an outsourcing arrangement under ECSPR art 9 — add it to the register in lisa 15
  with its jurisdiction, data categories, audit rights and exit plan.

## Company verification (KYB) — added 2026-08-06

Company accounts are verified with a **separate Didit workflow**. The API endpoint is the
same (`POST /v3/session/`) — the `workflow_id` decides whether Didit opens a *user* (KYC)
or *business* (KYB) session, so the server picks the workflow by account type:

| Account type | Workflow used | Session kind |
|---|---|---|
| `private` / `corporate` (investors) | `DIDIT_WORKFLOW_ID` | `user` |
| `raise` (company raising) | `DIDIT_KYB_WORKFLOW_ID` | `business` |

For KYB the server also pre-fills `expected_details` with the company name, registration
number and country taken from the application form, which shortens the applicant's journey.
KYB webhooks carry `business_session_id` instead of `session_id`; both are handled.

**In the product this is enforced, not decorative:** the company console shows a
verification banner until KYB is approved, the application pipeline displays the KYB status
on the *Eligibility screening* stage, and the application cannot move past screening until
the status is `Approved`. That mirrors lisa 5: an offer cannot be published before the
project owner has passed the art 5 checks.

Both workflow ids are still empty in `.env` — until they are set the server returns a clear
error naming the missing one and never calls Didit, so no pay-as-you-go charges occur.

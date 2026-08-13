# Verification flow — what is built and what is still missing

An applicant lists the people behind their company. Each of those people gets one
email, follows one link, verifies themselves, and the applicant's screen updates
on its own. Nobody types their own name into a form, because a self-declared name
is not evidence — the ID document is, and `name_match_grade()` compares the two.

## The pieces

| | |
|---|---|
| `migrations/0006_verification_invites.sql` | `verification_invites`, `verification_documents`, name matching |
| `functions/send-verification` | applicant presses the button → token minted, invite written, email sent |
| `functions/verify-invite` | the endpoint behind `/verify` — open, start KYC, upload |
| `functions/didit-webhook` | identity result → name match → status |
| `platform-v2/verify.html` → `/verify/` | the page the person lands on |

The token exists in exactly two places: the email, and — as a SHA-256 — the invite
row. Nothing in either browser can be turned back into a working link. Re-sending
overwrites the row, which is what kills the previous link.

## Deploy

**1. Schema.** Paste `supabase/APPLY-ALL.sql` into the SQL editor. It is safe to
re-run. Two `do $$` blocks assert that the diacritic fold and the name grading
behave — if either is wrong the migration refuses to apply rather than quietly
mangling Estonian surnames.

**2. Storage.** Create a bucket named `verification-documents`, **private**, no
public policy. Criminal-record extracts land here and are reachable only through
a signed URL issued to a member of staff. The applicant company can never read
them: it does not need its own directors' criminal records, we do.

**3. Functions.** From this directory:

```bash
supabase functions deploy send-verification
supabase functions deploy verify-invite --no-verify-jwt
supabase functions deploy didit-webhook --no-verify-jwt
```

`verify-invite` and `didit-webhook` must skip JWT verification — the person
following the link has no account, and Didit does not carry a Supabase token.
Both authenticate on their own terms instead: the token hash, and an HMAC
signature.

**4. Secrets.** Dashboard → Edge Functions → Secrets. Never in the repo, which
is public.

| Name | Needed for | Status |
|---|---|---|
| `RESEND_API_KEY` | sending the email at all | **missing** |
| `SITE_URL` | `https://equity24.io` | optional, defaults correctly |
| `VERIFY_FROM` | `Equity24 <kyc@equity24.io>` | optional, defaults correctly |
| `DIDIT_API_KEY` | opening an identity check | present elsewhere, **rotate first** |
| `DIDIT_WORKFLOW_ID` | which KYC flow to run | **missing** |
| `DIDIT_KYB_WORKFLOW_ID` | corporate shareholders | **missing** |
| `DIDIT_WEBHOOK_SECRET` | trusting the result | **missing** |

**5. Resend.** `equity24.io` has to be a verified sending domain in whichever
Resend account is used, with its DKIM and SPF records added to the DNS. Until
then `kyc@equity24.io` cannot send. Paste the API key straight from Resend into
the Supabase secrets field — not through chat, not into a file here.

## What happens before any of that is done

Nothing breaks and nothing lies:

- **No `RESEND_API_KEY`** — the invite is created, the token is real and the link
  works. Nothing is delivered. The function returns `delivered: false`, the
  applicant is told *"email is not switched on yet, so nothing was sent"*, and the
  link is written to the function log so the whole flow can be walked by hand.
- **No Didit workflow** — the person sees *"Identity checks are not switched on
  yet. You will get another email when this step is ready."* They are not left
  pressing a button that silently does nothing.
- **Criminal-record upload works today.** It needs only the storage bucket.

## The one judgement call worth knowing about

`name_match_grade()` folds diacritics, so `Soo` and `Sõõ` compare as the same
name. That is deliberate: Estonian forms lose õ ä ö ü constantly, and not folding
would flag a large share of honest people. It does mean the rare pair of real
surnames differing only by an accent would pass. The common failure was chosen
over the rare one.

A mismatch never auto-fails. It sets `review_required` and waits for a person.
A mismatch is nearly always a typo, a married name or a transliterated passport
— but it is also exactly what a forwarded link looks like, so it has to be seen
rather than decided.

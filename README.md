# Equity24.io

ECSPR (Regulation (EU) 2020/1503) equity crowdfunding platform.
Operator: **AureviaFund OÜ**, Tallinn, Estonia. Domain: **equity24.io**.

> **Authorisation pending.** No crowdfunding service is provided and no investment
> can be made until Finantsinspektsioon grants authorisation.

## Layout

```
├── lisa-*.md, T*.md, 01-, 00-, 99-   Licence application package (Estonian)
├── platform-v2/
│   ├── mockup-en-v2.html             Landing page
│   ├── app-prototype-v1.html         App: signup, investor, company, admin
│   ├── how-we-choose | risks | complaints .html   Mandatory art 19 disclosures
│   ├── pages.css                     Shared stylesheet for the disclosure pages
│   ├── legal/                        T&C, privacy policy, pricing (drafts)
│   ├── supabase/migrations/          Database schema + row-level security
│   ├── kyc-service/                  Didit KYC/KYB integration + static host
│   └── *.md                          Research, design system, audit records
```

## Running it locally

```bash
cd platform-v2/kyc-service
cp ../../.env.example .env     # then fill in the values
node server.js                 # http://localhost:8787
```

One Node process serves the landing page, the app and the `/api/kyc/*` endpoints
on a single origin.

## Database

Supabase project `wmwcpfdqxkvojuddwhls`. Apply `platform-v2/supabase/migrations/`
in order — see `platform-v2/supabase/README.md`. The schema deliberately enforces
the regulation's hard rules in the database: the four-calendar-day reflection
period is a generated column, an investment insert is blocked by trigger unless
verification and both appropriateness assessments are valid, and no role holds a
DELETE policy anywhere.

## Secrets

Never commit `kyc-service/.env`. It holds the Didit API key, the Didit workflow
ids and the Supabase service-role key. `.env.example` shows the shape.
The Supabase *publishable* key is safe in the browser and is committed on purpose.

## Status

| Area | State |
|---|---|
| Landing page, disclosure pages | Built |
| App prototype (investor / company / admin) | Built, simulated data |
| Supabase schema + RLS | Written, **not yet applied** |
| Didit KYC + KYB | Wired, waiting on workflow ids and webhook secret |
| Licence application | Draft; two legal opinions outstanding (ECSPR art 10(3) and art 8(1)) |
| Hosting and domain | Not yet deployed |

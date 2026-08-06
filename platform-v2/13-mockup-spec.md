# Osalus Landing Page — UX/Content Spec (v1, mockup-to-production)

**Design direction (global):** Institutional-calm fintech in the Estonian digital-state idiom: generous whitespace, 12-col grid (max-width 1200px), one typeface (Inter or IBM Plex Sans), near-black ink on paper-white; dark mode inverts to warm charcoal. Single accent: deep pine green (#0F5132-ish) — no gradients, no stock photos, no upward-arrow imagery. Numbers in tabular figures. All risk/legal copy at full body size and full contrast — never grey-on-grey. Light/dark via CSS variables.

---

## 0. Persistent risk warning bar (every page)

**Purpose:** ECSPR art 19(2)/23 mandatory warning; also our trust signal — we lead with it.
**Layout:** Full-width bar pinned above the header (not sticky-dismissable, not collapsible, no close button). Muted amber background (#FDF3E0 light / #3A2E14 dark), dark text, small "Risk warning" label. Wraps to 2–3 lines on mobile at readable size.
**Copy (verbatim, do not edit):**
> **Risk warning:** Investing in crowdfunding projects involves risks, including the loss of all of the money invested. Your investment is not covered by deposit guarantee or investor compensation schemes. You may not be able to sell your investment when you wish, and you may receive no return.

## 1. Header / nav

**Layout:** Logo left; nav: *Invest · How it works · Fees · Bulletin board · For companies*; right: ghost button **Log in**, solid button **Create account**. Under logo, 11px line: *"Authorisation pending — Finantsinspektsioon (Estonia)"*.

## 2. Hero

**Purpose:** State the category and the un-copyable claim (register-backed ownership) in one screen. No returns language, no hype.
**Layout:** Two columns — left: H1, subhead, CTAs, three proof chips; right: a stylised offering card (use Sample Card 1) with a thin caption. Mobile stacks.
**Copy:**
- H1: **Own real shares in Estonia's proven companies.**
- Subhead: *Invest from €100 directly into established Estonian businesses. Your shares are registered in the Estonian Business Register in your name — not held by us, not held by a nominee. And you pay no investor fees. Ever.*
- Primary CTA: **View open offerings** · Secondary CTA: **How direct ownership works**
- Proof chips: `Shares in your name — Business Register` · `€0 investor fees, contractually` · `Operating companies only — 3+ years trading`
- Micro-disclosure under CTAs (small but full-contrast): *Osalus does not provide investment advice or recommendations. Crowdfunding offers are not approved or endorsed by Finantsinspektsioon or any other authority.*

## 3. Direct-ownership explainer ("They survive us")

**Purpose:** The differentiator + insolvency-survival claim; converts P2P-literate skeptics.
**Layout:** Three equal cards on one band, icon + head + 2 lines. Band header left-aligned.
**Copy:** Section head: **Your shares don't live on our servers.**
1. **Registered to you.** *When an offer completes, you are entered as a shareholder in the Estonian Business Register — the state registry, in your own name.*
2. **No nominees, no custody.** *We never hold your shares. Our digital cap-table is an evidentiary convenience; legal title sits with the state register.*
3. **Platform-independent.** *If Osalus disappeared tomorrow, your shareholding would be unaffected. It exists in the Business Register, with or without us.*
Link: **Read how digital share transfers work →**

## 4. Live offerings + offering-card component

**Purpose:** The product. Cards must be art-27-clean: factual key information, no projected returns, no "expected yield," no past-performance implication.
**Layout:** Section head + 3-card grid (1-col mobile). Above grid, one line: *Every offer includes a Key Investment Information Sheet (KIIS) prepared by the project owner. Read it before investing. Offers are not vetted or approved by any supervisory authority.*

**Card anatomy (top→bottom):** company name + legal form · sector tag + city · risk badge (platform risk class A–D with tooltip "Osalus internal assessment of business risk — not a credit rating") · data rows in a 2-col mini-table: *Target (min–max)* / *Equity offered* / *Pre-money valuation* / *Instrument* · progress bar with *funded % of minimum* + *days left* · footer row: **Download KIIS (PDF)** text-link + **View offering** button. No return figures anywhere; progress bar accent green; risk badge outlined, not alarmist red.

**Sample cards (recommended vertical: established Estonian SMEs):**
1. **Valdek Metall OÜ** — Precision metal fabrication · Tartu · Risk class B. Target: **€250,000 – €400,000** · Equity: **7.2% – 11.1%** · Pre-money: **€3.2M** · Instrument: *OÜ shares (admitted instrument)* · **68% of minimum funded · 19 days left** · Download KIIS · View offering.
2. **Muhu Pagar OÜ** — Food production (bakery, retail + export) · Muhu · Risk class C. Target: **€150,000 – €300,000** · Equity: **7.7% – 14.3%** · Pre-money: **€1.8M** · Instrument: *OÜ shares (admitted instrument)* · **41% of minimum funded · 26 days left** · Download KIIS · View offering.
3. **Vesta Energia AS** — Commercial solar installation · Tallinn · Risk class B. Target: **€400,000 – €800,000** · Equity: **6.4% – 12.1%** · Pre-money: **€5.8M** · Instrument: *AS shares (transferable securities)* · **112% of minimum funded · 8 days left** · Download KIIS · View offering.

## 5. How it works (5-step strip)

**Purpose:** Legally accurate journey; makes the knowledge test and reflection period feel like features.
**Layout:** Horizontal numbered strip (vertical on mobile), one sentence each.
**Copy:** Head: **From sign-up to shareholder — fully digital.**
1. **Verify & learn.** *Sign up with ID-card, Mobile-ID or Smart-ID. Before your first investment you take a short knowledge test and see a simulation of your ability to bear a loss of 10% of your net worth. You can proceed either way — we'll warn you, not block you.*
2. **Read the KIIS.** *Each offer has a Key Investment Information Sheet: the business, the terms, the risks — six pages, plain language.*
3. **Invest.** *Subscribe digitally from €100. Investing over €1,000 or 5% of your net worth per offer triggers an extra confirmation step.*
4. **Change your mind — free.** *You have a 4-calendar-day reflection period after committing. One click withdraws your commitment, no reason needed, no cost.*
5. **Become a registered shareholder.** *When the offer succeeds, funds move via a segregated third-party payment account and you're entered in the Estonian Business Register.*

## 6. How we select ("The Osalus bar")

**Layout:** Two columns: criteria checklist left, exclusions right.
**Copy:** Head: **We list companies, not ideas.** Sub: *Fewer offers, real businesses. Our admission criteria:* ✓ *3+ years of operating history* ✓ *€0.5–3M annual revenue* ✓ *At least €10,000 fully paid-in share capital* ✓ *Articles of association enabling digital (notary-free) share transfers* ✓ *Management background and financials reviewed.* **We do not list:** *pre-revenue startups, passive asset-holding vehicles, regulated financial firms, gambling, adult, weapons or crypto businesses.* Footnote: *Selection reflects our admission criteria only — it is not investment advice or an endorsement, and does not remove the risks above.*

## 7. Fees

**Layout:** Two side-by-side panels, investor panel visually dominant.
**Copy:** Head: **One side pays. It isn't you.**
- **Investors — €0.** *No account fee. No investment fee. No custody fee. No exit fee. No inactivity fee. Permanently — it's in our terms, not a promo.*
- **Project owners:** *€1,000 listing fee + 6% success fee on funds raised. Charged only on successful offers. No hidden charges to either side.*

## 8. Bulletin board teaser

**Layout:** Slim band, muted background, head + body + disclaimer in-line (not footnoted).
**Copy:** Head: **Want to sell later? There's a notice board.** Body: *Shareholders can post buying and selling interests on our bulletin board and settle transfers digitally between themselves.* Disclaimer (same size): *The bulletin board is not a trading venue and does not match orders. Any reference price shown is non-binding and may not reflect achievable value. A buyer may not exist when you want to sell.*

## 9. Fraud warning + disclosures band

**Layout:** Bordered box, warning icon, above footer.
**Copy:** **Protect yourself:** *Only ever invest through the Osalus platform via our payment partner's segregated client account. Never transfer money directly to a project owner or to anyone contacting you outside the platform — we will never ask you to. Osalus does not provide investment advice; nothing on this site is a recommendation.*

## 10. Footer

**Layout:** 4 columns + legal block. Columns: *Platform* (Offerings, How it works, Fees, Bulletin board) · *Companies* (Raise capital, Criteria) · *Legal* (Terms, Privacy, Complaints, Conflicts of interest policy) · *Registers* (Estonian Business Register, Finantsinspektsioon, ESMA crowdfunding register).
**Legal block copy:** *Osalus Capital OÜ, Tallinn, Estonia. Authorisation as a crowdfunding service provider under Regulation (EU) 2020/1503 is pending with Finantsinspektsioon — no crowdfunding services are provided until authorisation is granted. Complaints are handled free of charge — see our complaints procedure. Osalus does not hold client funds or client shares; payments are processed by [PSP name] through segregated accounts.* Persistent risk-warning bar repeats above the footer on long pages.
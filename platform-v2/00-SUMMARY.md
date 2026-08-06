# Platform v2 brainstorm — executive summary
### 15-agent research pass · August 2026 · companion to the ECSPR application package

**Contents of this folder:** `research/` = 10 raw research reports (7 market + 3 SEO/LLM) · `10–13` = strategy syntheses (positioning, vertical, naming, mockup spec) · `14` = adversarial critique + next actions · `mockup-en.html` = first English mockup.

---

## 1. The headline finding: the Estonian ECSPR equity slot is empty

Verified against the live FI register (see `research/R2-ecspr-register.md`):

- **Exactly one** Estonian-authorised crowdfunding service provider exists — **Estateguru OÜ**, and it is a real-estate *lender* in a multi-year recovery (>60% of its ~€197M AUM in default/recovery, retroactive investor fees, negative equity).
- **Crowdestate returned its licence voluntarily** (withdrawn 13.04.2026) and wound down — its stated reason was that platform economics didn't work at ~€10M/yr volume. Its displaced investors are searching for alternatives *right now* (autocomplete-verified).
- **Fundwise** never got an ECSPR licence and is effectively dormant (~€6.8M raised in 10 years). **Funderbeam** pivoted to institutional B2B under a MiFID licence and abandoned retail equity crowdfunding — its SPV/note structure (investors never owned the underlying shares) is the anti-pattern our direct-register model answers.
- The passporting targets are nearly as empty: Finland's only domestic ECSP is a lender; Latvia's only equity CSP (CrowdedHero) has raised ~€600k lifetime; Lithuania's equity scene is thin. EU majors (Crowdcube, Republic Europe) hold passports but have originated ~zero Baltic deals.

**Implication:** there is no incumbent to beat — the competition is *category damage* (the word "ühisrahastus" is associated with lending losses) and *unit economics* (Crowdestate's killer). Both are addressable; both shape the strategy below.

## 2. Positioning (full text: `10-positioning.md`)

Core claim stack no competitor can copy:
1. **Direct, state-register ownership** — shares in the investor's own name in the Business Register; no SPV, no nominee; the holding survives platform insolvency. *(⚠️ must be legally confirmed first — see §6.)*
2. **€0 investor fees, contractually and permanently** — lands hard against EstateGuru's fee U-turn (the sector's most-cited grievance).
3. **Operating companies only** — 3+ years, €0.5–3M revenue; curation *is* the brand.
4. **The rung under First North** — one-tenth the raise size and cost; AS-share track makes "First North later" the credible liquidity narrative.

Marketing posture: lead with the regulator, radical scheduled transparency (live stats page, monthly reports), never oversell safety, and target the *diversification euro* of the existing 100–300k P2P-literate Baltic investors rather than new savers.

## 3. Vertical recommendation (full text: `11-vertical.md`)

**Vertical-flavoured generalist: "Estonian real-economy growth companies."** Hard verticals can't feed 15–30 deals/yr at this market size; pure horizontality is what killed the low-curation generalists. Two flavour pillars:
- **Consumer brands** (La Muu, Põhjala-tier F&B, ÖÖD/Huum-tier product companies) = the *audience engine* — customers become shareholders and the issuer markets its own raise (the art-27-compliant channel).
- **Manufacturing / green industry** (timber & modular construction, metal/machinery, green-transition retooling) = the *revenue engine* — €400–800k rounds, dividend-capable, and the pillar that travels to FI/LV/LT.

Defence/dual-use: keep the weapons exclusion verbatim; accept defence-*adjacent* civilian-revenue companies case-by-case; never market it as a vertical (PSP-refusal and export-control risk). Renewables: operating companies only — single-project SPVs are the AIFMD trap the application already excludes.

## 4. Name (full text: `12-naming.md`)

**Working name: Osalus** (Osalus Capital OÜ; osalus.com/.eu/.ee) — semantically exact ("shareholding"), the *osa* root travels to Finnish, no fintech collisions found. Tagline: *Real companies. Real shares. Fully digital.* / *Päris ettevõtted. Päris osalus. Täisdigitaalne.* Runner-ups: Partem, Kasvu (Kasvu has Finnish-market collisions). Generic-word trademark weakness → file composite (word+logo) EUIPO mark before launch. Tone-of-voice: regulated-calm — numbers over adjectives, no urgency mechanics, risk warning at full body size, "licence application pending" until granted.

## 5. Fees & liquidity benchmark (full: `research/R6-fees-liquidity.md`)

- **6% + €1,000 + €0 investor fees is competitive-to-cheap but not an outlier on the success fee** — Eurocrowd's study of 44 ECSP platforms found avg 5.8% inclusion + 3.95% closure fees. The *investor-side* zero is the real differentiator: Republic Europe charges 2.5% in + 5% of profit out; CrowdedHero 1.25% + 5.5% of dividends + 9% carry.
- **Secondary liquidity:** everything beyond an art 25 bulletin board (no matching, non-binding reference price) needs a MiFID licence. The honest sell: "digitally transferable when you find a buyer — minutes, not a notary appointment," plus the First North graduation story. Reset hold-period expectations (3–7 years) at onboarding.

## 6. What the critic killed (full text: `14-critique-next-actions.md` — read this first)

The adversarial pass flagged real problems; the loudest:

1. **The flagship legal claim is unproven.** OÜ Business Register shareholder data has historically been *informative, not title-constitutive* unless the company opts into the post-2023 register-reliability regime (or Nasdaq CSD). The "survives platform insolvency" marketing cannot run until Estonian counsel confirms the regime and every issuer opts in. Also: the notary waiver alone isn't enough — statutory pre-emption (ÄS §149) handling must be designed too.
2. **Art 27 scrubs needed:** kill "proven companies," "only platform in Europe," "invest in 3 minutes," and Mintos-style referral investment credits (inducement risk). *(The mockup already applies these fixes.)*
3. **Pre-licence perimeter:** "authorisation pending" + a live "Create account" CTA flirts with unlicensed marketing — the mockup uses a waitlist instead.
4. **Blocker dependencies:** the nominee-vs-direct decision gates the entire brand story; the backup-servicer contract gates the survival claim; the AIFMD opinion gates the vertical list; second board member + prudential option gate the filing date.
5. **Every load-bearing market statistic should be source-checked before it goes into the FI application or public copy** — the research agents browsed live sources, but numbers like default percentages, register dates and volumes must be re-verified at fi.ee/ESMA before reliance.

**Top next actions (critic's priority order):** counsel opinion on OÜ shares/§149/register effect → nominee decision → verify FI register facts → PSP term sheet → second board member → AIFMD opinion → source-check statistics → EUIPO/domain clearance for Osalus → marketing-copy legal scrub → financial model stress-test (15–30-deal breakeven vs realistic Estonian year-1 deal flow).

## 7. SEO + LLM ranking layer (full: `research/S1–S3`)

**Estonian (45 keywords, `S1`):** three time-sensitive quick wins — (1) Crowdestate-churn capture content ("Crowdestate lahkus turult…" pitched to Äripäev/Geenius), (2) own the July-2025 *investeerimiskonto × ühisrahastus* tax-change topic (definitive guide + EMTA screenshots + calculator — realistically #1 within months on a fresh domain), (3) capture Fundwise's orphaned brand demand. Then: directory listings (RahaFoorum, Financer.ee, crowdinform) before content SEO; digital PR via Investor Toomas ecosystem, rahageek, dividendinvestor.ee, LHV foorum; community via Naisinvestorite klubi + InvesteerimisFestival + r/eesti.

**English (57 keywords, `S2`):** E-E-A-T is the #1 lever for a YMYL site — licence number + deep links to the exact FI/ESMA register entries in every footer, named humans with credentials on all content, Organization/FAQPage schema (NO review-star markup on offers — Google penalty + art 27 problem). **Start the /learn, /regulation, /compare content layer 6+ months before licence grant** — it needs no authorisation and domain age compounds during FI's review. E-residency angle: pitch e-resident.gov.ee blog + investinestonia.com.

**LLM/AEO (18 target queries, `S3`):** Reddit is the #1 cited domain across AI engines (~40% aggregate) — honest founder presence in r/eupersonalfinance, r/eesti, rahafoorum. Sequence: entity foundation now (LEI, Wikidata, Crunchbase, one locked boilerplate sentence, FinancialService JSON-LD + llms.txt) → register-driven visibility at authorisation (ESMA/FI entries propagate into eurocrowd.org automatically) → directory blitz at launch (crowdinform, thecrowdspace, p2pmarketdata, findcrowdfunding) → get into 3–5 refreshed English "best of" listicles (that's ChatGPT's citation diet) → publish citable original data (quarterly Baltic equity crowdfunding market report).

## 8. Go-to-market mechanics worth stealing (full: `research/R7-growth-playbooks.md`)

- **Anchor-first is the single biggest success lever:** campaigns hitting 30% of target in week one succeed ~75% vs ~20% baseline. The plan's 40% pre-commitment discipline is above that bar — recruit EstBAN leads privately pre-launch (outside art 27's live-offer perimeter) and display anchor names/amounts on offer pages.
- Launch with 1–2 consumer-brand offers for visible oversubscription; defend a 100%-of-minimum success record at all costs (Springvest's playbook); every closed round becomes press.
- Bank-referral partnerships (LHV/Coop/SEB — the Rabobank–Invesdor model) as an exclusive deal-flow channel; Hooandja community as a rewards-to-equity graduation funnel.

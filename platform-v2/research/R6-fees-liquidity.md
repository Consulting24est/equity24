# Fee benchmark + secondary-liquidity practice

## Strategic insights

- FEE VERDICT — 6% + EUR 1,000 + EUR 0 investor fees is competitive-to-cheap but not an outlier on the success fee itself. Eurocrowd's study of 44 ECSP platforms (Feb 2024, eurocrowd.org) found average project-owner charges of 5.8% inclusion + 3.95% closure fees, with total cost of capital just under 10%; Italian market average is ~6%; SeedBlink charges 5-7% + EUR 3,000, Capital Cell 8% + EUR 1,500, Republic Europe 6% + ~GBP 12,000 fixed + GBP 2,000/yr, Crowdcube 5-8% + 2.5% platform fee + GBP 4,995-9,995 listing, SoWeFund up to 9% + EUR 15-20k listing, Companisto ~15%. The client's real differentiators are (a) the near-zero EUR 1,000 fixed cost — lowest verified in the EU — and (b) NO annual/nominee/admin fees, which at Republic (GBP 2k/yr), SoWeFund (EUR 5k/yr min) and SeedBlink (renewal fees after year 5) quietly add 1-3% lifetime cost.
- EUR 0 investor fees is a genuine weapon against exactly the platforms in the client's expansion path, but is table stakes in Southern Europe. UK giants double-charge investors (Republic: 2.5% in + 5% of profit out; Crowdcube: 2.49% in + 5% of profit out), CrowdedHero (Latvia) charges 1.25% in + 5.5% of dividends + 9% of exit, SeedBlink stacks access+management+carry, SoWeFund 1-5% in + up to 19.5% carry via holding. But Capital Cell, Mamacrowd, CrowdFundMe, Companisto and Springvest all charge investors zero upfront. Positioning should therefore be 'no fees ever — including no exit carry', which nobody else in the Baltics/UK/CEE offers.
- One pricing gap to close before the licence application: payment/processing costs. Nearly every peer passes PSP costs through (Crowdcube bakes 2.5% platform fee in; Republic 0.5%; SoWeFund 1-5% investor-side is largely Lemonway costs). With art 10(5) segregated PSP accounts, the client must decide explicitly whether the 6% absorbs PSP fees (~0.5-1.5%) or they are recharged to project owners — silent margin erosion of up to a quarter of the success fee otherwise.
- LIQUIDITY LAW — under a plain ECSPR licence only an art 25 bulletin board is possible: clients may ADVERTISE buying/selling interest in instruments originally offered on the platform, but the provider may NOT bring interests together via protocols/internal procedures resulting in a contract, and may NOT run an internal matching system executing orders multilaterally (ESMA Q&A ESMA35-42-1088). ESMA also expects the selling client to disclose the month/year the original KIIS was provided. A non-binding reference price is permitted (provider must disclose its basis). Continuous matched trading requires a MiFID investment-firm/regulated-market authorisation on top — exactly the client's planned design (bulletin board + non-binding reference price) is the legal maximum.
- LIQUIDITY PRACTICE — nobody has made ECSPR secondaries big. Adoption is thin (only 16 of 46 Dutch-market ECSPs operate a bulletin board). Best-in-class ECSPR implementation is SeedBlink: limited-visibility bulletin board (offers visible to same-SPV shareholders or verified members), bilateral price negotiation off-board, platform settles in QUARTERLY batches, min EUR 30 or 3% fee on both sides. The at-scale secondary markets are all NON-ECSPR: Republic Europe (UK nominee, historically 1 week/month cycle from first Tuesday, moved to continuous trading with buyer price-indication in July 2025; seller pays 7.5% of profit only; IPEV fair-value pricing caps at last round price) and Crowdcube (event-driven company-approved liquidity events at 5-7.5% fee; Freetrade event: GBP 5.8M sold by 1,063 shareholders at 47x). Funderbeam built true 24/7 auto-matching but needed a Singapore Recognised Market Operator + Estonian MiFID investment firm (Venturebeam Markets AS, licence 31 Dec 2020) + UK entity to do it — and still saw thin volumes and pivoted B2B. Conclusion: build the art 25 board as a retention/marketing feature priced at ~1-3% per side or free, expect negligible revenue, and treat 'MiFID upgrade later' as a real but expensive option only if dealflow proves demand.
- The client's notary-waiver OÜ articles + Business Register title design is the same move that made Capital Cell the EU's #1 ECSP by 2025 volume (EUR 36.7M) — Capital Cell uses Dutch STAK certificates precisely to make transfers possible without notaries, and openly markets digital transferability. The client achieves this natively in Estonian company law without a foreign foundation layer, AND with legal title in the state register rather than in platform SPVs (unlike Funderbeam notes / SeedBlink SPVs / UK nominees) — 'your shares survive our insolvency' is a verifiable claim no nominee-model competitor can make. This should be the KIIS/marketing centrepiece and also de-risks the art 25 board: transfers advertised on the board can actually settle digitally within days.
- Estonia is an open goal: only two ECSP licences were ever issued by Finantsinspektsioon (Estateguru — loans; Crowdestate — revoked at own request 13 Apr 2026), so as of August 2026 there is NO ECSPR-licensed equity crowdfunding platform in Estonia and Fundwise is dead. First-mover status is available, but Finantsinspektsioon has zero equity-ECSP precedent — expect the full 25-working-day completeness + 3-month assessment, EUR 1,000 state fee, applications via the FI portal (mandatory since 18 Mar 2026), and extra scrutiny on the cap-table layer (must be framed as evidentiary record-keeping, not custody or settlement, to stay outside MiFID/CSDR).
- Market sizing supports the niche but demands passporting fast: EU ECSP equity crowdfunding was only EUR 280M across 354 campaigns in 2025 (+12.2% YoY; 68,500 investors; avg round EUR 789k, median EUR 468k — the client's EUR 150-800k band brackets the median). France (EUR 98.3M) and Spain/Italy dominate; Baltic volumes are negligible; Finland's incumbents (Springvest, Invesdor) compete on curation, not price. Plan Finland/Latvia/Lithuania passporting within 12-18 months of licence — Estonia alone cannot feed a 6% success-fee P&L (EUR 5M/yr platform volume = EUR 300k revenue).
- Fee transparency itself is a differentiator: of 16 platforms checked, only ~half publish issuer pricing at all (Invesdor, CONDA, Springvest, CrowdedHero issuer-side are all 'contact us'). Publishing a flat 'EUR 1,000 + 6%, investors pay nothing, no annual fees' schedule would be near-unique in Northern Europe and aligns with ECSPR art 19 cost-disclosure expectations Finantsinspektsioon will test anyway.
- Failure/pivot patterns to design against: FundedByMe/Pepins (SE) died after repeated mergers — periodic retail trading windows did not fix unit economics; Fundwise (EE) died at the ECSPR licensing hurdle; Crowdestate handed back its licence; Funderbeam abandoned retail crowdfunding for B2B infrastructure; CrowdFundMe is publicly listed and visibly low-margin. Survivors share three traits the client's model already has (established revenue-generating issuers, success-fee-plus-low-fixed pricing, vertical or structural differentiation) — the one trait to resist is subsidising growth with investor-side fees later, which is where CrowdedHero and SoWeFund became attackable.

## Platforms

### Republic Europe (ex-Seedrs)
- **Country:** UK (FCA); EU offers via ECSP entity authorised in Ireland — verify current ESMA register entry
- **Licence:** UK FCA regulated; rebranded from Seedrs to Republic Europe July 2024 after Republic's $100M acquisition; ECSPR authorisation for EU obtained via Central Bank of Ireland (2023)
- **Model:** equity (nominee structure); all sectors, strong fintech/consumer
- **Instruments:** ordinary/preference shares held via Republic Europe nominee
- **Fees:** Company: £5,000 pre-registration + £5,000 launch fee + 6% success fee + 0.5% payment processing + £2,000/yr nominee fee (+historic £2,500 completion fee). Investor: 2.5% entry fee (min £5, max £250) + 5% carry on profit at exit. Secondary market: seller pays 7.5% of PROFIT only (no buyer fee, no fee if sold at/below cost); older schedule was 1.5-2% per side.
- **Volumes:** ~£2.8-3.0B cumulative across ~2,400 rounds since 2012 (as of 2025); investors in 60+ countries
- **Strengths:** Largest cumulative volume in Europe; Only at-scale retail secondary market in EU/UK crowdfunding (running since 2017); Nominee makes transfers frictionless for issuers — zero issuer admin
- **Weaknesses:** High fixed costs for issuers (~£12k before success fee); Investor pays both entry fee and exit carry — double charge; Secondary liquidity capped by fair-value pricing rules (last round price, <=3yrs) — no price discovery upside
- **Notes:** Secondary market mechanics: historically open 1 week/month (first Tuesday 11:00 to next Tuesday); July 2025 moved to continuous trading with buyer price-indication feature (crowdfundinsider.com). Valuation policy = IPEV-based 4 tiers, shares of inactive companies marked to zero. Sales only inside the nominee — legally an assignment within Republic's nominee, which is why it works without ECSPR art 25 constraints (UK regime, not ECSPR).

### Crowdcube
- **Country:** UK (FCA); EU via Crowdcube Spain (CNMV ECSP licence)
- **Licence:** FCA (UK) + ECSPR licence via Spanish CNMV for EU offers — largest ECSP by campaign count in EU 2025
- **Model:** equity; all sectors, strong fintech (Monzo, Freetrade, Revolut heritage)
- **Instruments:** shares (direct + nominee)
- **Fees:** Company: listing fee £4,995 (Focus) to £9,995 (Full Access) + success fee 5% (Focus) to 8% (Full Access) + 2.5% platform fee on all funds raised (covers PSP/AML/reconciliation) + annual nominee fee £750-1,000. Investor: 2.49% investment fee (min ~£5, max £250; up to 5% on some deals) + 5% success fee on profit at exit. Secondary: 5-7.5% 'liquidity fee' on arranged secondary events.
- **Volumes:** £1.4B+ raised for 1,300+ businesses (own claim; other sources ~£2.2B incl. all campaign types); 1.7M members; EU ECSP volume €28.8M in 2025 (ECCL study) — 3rd largest ECSP by volume, 1st by campaign count
- **Strengths:** Brand and 1.7M-strong investor community; Proven event-driven secondaries (Freetrade: £5.8M sold by 1,063 shareholders, 47x); Dual UK+EU licensing
- **Weaknesses:** Total issuer cost can reach 10.5%+ (8% + 2.5% platform fee) plus listing fee; Cubex never became a continuous market — reverted to episodic 'Direct Community Offers'; Investor entry fee introduced 2021 eroded goodwill
- **Notes:** Cubex launched May 2021 as aspirational pan-European secondary marketplace incl. non-Crowdcube companies; in practice it operates as demand-registration + company-approved liquidity events (5-7.5% fee), not continuous trading. Since 2017 >£16M liquidity delivered pre-Cubex. Key lesson: even with FCA scope, continuous retail secondary trading was shelved; company consent per event is the operating model.

### SeedBlink
- **Country:** Romania (ASF); pan-EU passported
- **Licence:** ECSPR licence from Romanian ASF (Nov 2022; first in CEE)
- **Model:** equity co-investment alongside VCs; tech/deep-tech; also equity management SaaS (Nimity)
- **Instruments:** shares via SPV/nominee structures
- **Fees:** Company: public round €3,000 one-time access fee + 5-7% success fee; private round 1.5% structuring fee (min €3,000, max €15,000) + first 15 investors free then €50/investor; €2M cap on standard private deals; post-5yr admin renewal min €2,000. Investor: access fees + management fees + carry by tier (pay-on-success); primary min ticket €2,500. Secondary market: min €30 or 3% fee charged to BOTH buyer and seller.
- **Volumes:** cumulative >€300M claimed across Europe (not independently verified); Romania's dominant equity platform
- **Strengths:** Only CEE platform with functioning ECSPR art 25 secondary (since Apr 2023); VC co-investment model gives price validation; Monetises cap-table software (Nimity) beyond fees
- **Weaknesses:** Investor-side fee stack (access+management+carry) — most expensive investor proposition in CEE; Secondary settles only quarterly; SPV layers between investor and company
- **Notes:** Secondary market design (directly relevant to client): limited-visibility bulletin board under ECSPR art 25 — offers visible only to co-shareholders in same SPV or to verified members; price negotiated bilaterally off-board; SeedBlink executes settlement in quarterly batches. This is the practical ceiling of an art 25 board: advertise interest, negotiate privately, platform handles paperwork in batches. No matching engine.

### Companisto
- **Country:** Germany
- **Licence:** Operates OUTSIDE ECSPR under German national regime (analysed separately in ECCL study; Germany is the only major EU market where equity crowdfunding predominantly runs outside ECSP) — this is how it can exceed the €5M ECSPR cap (DiaMonTech raised €8M in 2025)
- **Model:** equity/participation; established growth companies + angel club
- **Instruments:** profit-participation / subordinated instruments and shares via brokerage structure
- **Fees:** Company: ~15% performance-based commission on amount raised (highest found in EU). Investor: free to register/invest; 10% of profits/payouts at exit (one source says 15% carry — sources conflict, 10% is the better-documented figure)
- **Volumes:** €49M in 2025 — highest-volume equity crowdfunding platform in the EU (ECCL 2025); hosted largest single EU round 2025 (DiaMonTech €8M)
- **Strengths:** EU volume leader despite 15% fee — proves curated later-stage dealflow beats price competition; Angel Club hybrid (accredited + retail); €8M single-round capacity outside ECSPR cap
- **Weaknesses:** 15% all-in cost is 2.5x client's 6%; National regime = no EU passport; Instruments often not true registered shares
- **Notes:** Strategic reference point: proves issuers will pay 15% for execution certainty and investor quality. Also proves the ECSPR €5M cap matters at the top end of the market the client is NOT targeting (€150-800k rounds unaffected).

### Invesdor (merged with Oneplanetcrowd)
- **Country:** Finland origin; group active DACH/Nordics/Benelux, HQ functions Germany/Austria
- **Licence:** ECSPR-licensed (Invesdor Oy was among the first FIN-FSA ECSP authorisations, 2022); EEA-wide passport
- **Model:** equity + bonds/convertibles (mixed investment-based); SME and growth
- **Instruments:** shares, bonds, convertibles
- **Fees:** NOT published — bespoke per deal: fixed up-front listing fee (due at term-sheet) + success fee (% of funds collected, 'varies by case') + fixed closing fee + 0.5% p.a. management fee on principal for bond administration. Industry positioning ~6-9% all-in per Eurocrowd averages. Investors: no platform fees on primary investments.
- **Volumes:** 180,000+ registered investors across 30+ countries; >€500M cumulative group claim (not independently verified)
- **Strengths:** True multi-country footprint (FI/DE/AT/NL); Both equity and debt — repeat issuer relationships; Long track record since 2012
- **Weaknesses:** Zero fee transparency — everything 'contact us'; Equity share of volume has shrunk vs bonds; No secondary market / bulletin board found live
- **Notes:** Direct competitor in Finland expansion. Its non-transparent bespoke pricing is an opening for the client's published flat 6% + €1,000.

### Funderbeam (Venturebeam Markets)
- **Country:** Estonia founded; EEA access via Venturebeam Markets AS (Tallinn)
- **Licence:** NOT ECSPR — Venturebeam Markets AS holds an Estonian investment firm (MiFID) licence from Finantsinspektsioon (permit 4.1-1/212, effective 31 Dec 2020); the marketplace itself is legally operated as a Recognised Market Operator in SINGAPORE (MAS oversight), with the Estonian and UK entities acting as trading members giving EEA/non-EEA clients access
- **Model:** syndicate/SPV primary raises + continuous secondary trading marketplace; pivoted toward B2B 'private market as a service' for angel networks/VCs
- **Instruments:** loan-note/SPV-based tradable instruments (blockchain-recorded), not direct shares
- **Fees:** Investors: free to invest upfront; 3% carry on successful exit. Trading: 3% fee on every trade charged to the SELLER, buyer pays nothing. Company fundraising fees: per non-public fee schedule (success fee + setup + cancellation fees).
- **Volumes:** modest primary volumes; total company funding raised $105.8M for itself incl. €36M in 2023; marketplace liquidity thin (no published trade volumes)
- **Strengths:** Only Baltic player that built genuine 24/7 auto-match continuous trading; Proved digital secondary settlement works technically
- **Weaknesses:** Needed a THREE-jurisdiction structure (Singapore RMO + Estonian MiFID firm + UK entity) to do legally what ECSPR forbids — enormous regulatory overhead; Thin liquidity despite the tech; pivoted away from retail crowdfunding; Instruments are SPV notes, not registered shares — investor title depends on Funderbeam structures surviving
- **Notes:** THE cautionary tale for the liquidity question: continuous matched trading is impossible under a plain ECSPR licence (art 25 explicitly bans internal matching executing orders multilaterally), and Funderbeam's workaround cost was a Singapore-recognised market operator plus MiFID firm. Its struggle to generate volume also shows demand-side limits of startup secondaries. Client's Business-Register-anchored cap-table is the philosophical opposite (title survives platform failure) — a strong selling point against SPV/note models.

### CrowdedHero
- **Country:** Latvia
- **Licence:** ECSPR licence from Latvian FCMC/Latvijas Banka, Aug 2022 — first in Latvia, 3rd ECSP in the EU
- **Model:** equity; established/revenue businesses (not pre-revenue startups) — closest strategic twin to the client
- **Instruments:** shares (incl. Latvian SIA structures), some dividend-paying deals
- **Fees:** Investor-side (win-win framing): 1.25% of amount invested per project (processing/administration) + 5.5% fee on dividend distributions + 9% fee on successful exit. Project-owner fees not published (success-fee based).
- **Volumes:** small — single-digit €M/yr range; Latvian market leader by default
- **Strengths:** Same 'established companies with cash flows' positioning as client; Dividend-deal focus differentiates in Baltics; EU passport in use (Southern Europe deals)
- **Weaknesses:** Charges investors on the way in, on dividends, AND on exit — directly attackable with client's €0 investor fees; Small dealflow; Limited brand outside Latvia
- **Notes:** Primary Baltic competitor for the client's target segment; its investor fee stack (1.25%+5.5%+9%) makes the client's 0/0/0 investor proposition a clean marketing weapon in LV/LT expansion.

### Capital Cell
- **Country:** Spain
- **Licence:** ECSPR via Spanish CNMV (PFP licence no. 12 heritage)
- **Model:** equity; biotech/health/life sciences vertical only
- **Instruments:** shares, largely via Dutch STAK certificate structure (transferable without notary — same problem/solution space as client's OÜ articles waiver)
- **Fees:** Company: €1,500 publication fee (older sources: €750) covering legal docs + 8% cash success fee on total raised at close; card payment costs + notary/legal borne by company. Investor: zero fees of any kind. Secondary: informal contact-matching market, no stated fee.
- **Volumes:** €36.7M in 2025 across 28 campaigns — LARGEST ECSP platform in the EU by volume (ECCL 2025)
- **Strengths:** Proof that vertical focus wins: #1 EU ECSP volume from one sector; STAK certificates deliberately engineered to bypass notarised transfers — validates client's core thesis; Investor-free fee model at scale
- **Weaknesses:** 8% + €1,500 pricier than client's 6% + €1,000; Secondary is just introductions; pre-emption rights slow every sale; Single-sector concentration risk
- **Notes:** Most important structural comparable: Capital Cell already proved that removing the notary from share transfers (via STAK) + zero investor fees + fixed-fee-plus-success pricing is a winning ECSP formula. Client does the same natively in Estonian company law (art. of association waiving notarised form) without an intermediate foundation layer.

### SoWeFund
- **Country:** France (AMF)
- **Licence:** ECSPR via AMF France
- **Model:** equity co-investment alongside VCs/BPI
- **Instruments:** shares (direct or via holding vehicle)
- **Fees:** Company: listing fee €15,000-20,000 by deal type + success commission up to 9% of amounts raised + annual admin €2,500 + €5/investor/yr (min €5,000 total). Investor: 1-5% of invested amount (entry/payment) + via holding route: 5% accompaniment + 2% holding costs + 19.5% carried interest on profits; direct route adds 5% premium. Exit: 0% platform fee.
- **Volumes:** €32.1M in 2025 — 2nd largest ECSP in EU (ECCL 2025); France is largest EU market (€98.3M, 35.2% of EU volume, 106 campaigns)
- **Strengths:** #2 EU ECSP by volume; VC/BPI co-investment validation; France's deep retail equity-crowdfunding culture
- **Weaknesses:** Most expensive platform verified on BOTH sides: ~€20k fixed + 9% for issuers and up to 26.5%+carry lifetime cost for investors; Complex holding-vehicle fee opacity
- **Notes:** Shows top-volume platforms can charge far above client's rates; also shows French investors tolerate heavy fee stacks — fee competition is not what wins France.

### Mamacrowd
- **Country:** Italy (Consob; Azimut group)
- **Licence:** ECSPR via Consob/Banca d'Italia
- **Model:** equity (startups, SMEs, real estate equity)
- **Instruments:** S.r.l. quotas / shares (Italian regime allows dematerialised-ish quota subscription via banks)
- **Fees:** Company: success-fee-only model, paid only if campaign closes above minimum target (Italian platform norm 5-8% of raise; Italian market average ~6%). Investor: zero administrative/investment fees.
- **Volumes:** 4th-ranked European platform 2025 (ECCL); Italy total 2025: €39.4M, down 25% YoY
- **Strengths:** Azimut asset-manager backing; Success-only pricing = zero issuer risk; Diversified verticals
- **Weaknesses:** Italian market shrinking (-25% in 2025); No meaningful secondary solution
- **Notes:** Italy overall: investors pay nothing on the major platforms; success fee ~6% is the market rate — client's 6% is exactly at Italian norm.

### CrowdFundMe
- **Country:** Italy (Consob)
- **Licence:** ECSPR via Consob; also listing sponsor for ExtraMOT Pro3 bond segment
- **Model:** equity + real estate + minibonds; listed company itself (Borsa Italiana)
- **Instruments:** shares/quotas, minibonds
- **Fees:** Investor: zero fees (only own bank transfer costs). Company: success fee not published; Italian norm 5-8%, avg ~6%.
- **Volumes:** 3rd in Europe by campaign count 2025 (ECCL); highest Italian campaign counts
- **Strengths:** Itself publicly listed (transparency); Pipeline to real listings: alumni CleanBnB, TrenDevice (Borsa Italiana), i-RFK (Euronext Paris) — 'crowdfunding as pre-IPO' narrative; Debt+equity mix
- **Weaknesses:** Own share price has performed poorly since 2019 IPO — platform unit economics visible and weak; Shrinking home market
- **Notes:** Its exit-via-listing track record is the credible liquidity story that does not require any secondary market — relevant alternative narrative for client's KIIS/marketing.

### Wefunder Europe
- **Country:** Netherlands (AFM)
- **Licence:** ECSPR via Dutch AFM
- **Model:** equity 'community rounds' (US platform's EU arm, launched Feb 2023)
- **Instruments:** shares/SPVs
- **Fees:** US benchmark: 7.9% of raise (Reg CF) + admin fee lesser of $1,000/0.5%; private rounds 10% SPV setup capped $10k + 5% on Wefunder-audience money + 10% carry. Separate EU fee schedule not published — assume ~7.5-7.9% positioning. Investors: broadly fee-free on standard equity deals.
- **Volumes:** EU arm still subscale; stated ambition 20,000 founders by 2029
- **Strengths:** US brand + founder-friendly marketing; Passported from day one
- **Weaknesses:** EU traction limited so far; US-style SPV mechanics translate awkwardly to EU cap tables
- **Notes:** Demonstrates ECSPR's design goal working (US entrant using one Dutch licence for 27 countries) — same passport the client will use from Estonia.

### CONDA (CONDA Capital Market)
- **Country:** Austria (FMA)
- **Licence:** ECSPR via Austrian FMA
- **Model:** investment-based; historically subordinated-loan crowdinvesting, now 'structured capital market products' under ECSP
- **Instruments:** bonds, subordinated instruments, some equity
- **Fees:** Not published: fixed preparation/setup costs payable on engagement + success commission (% of collected funds, only if threshold reached) + annual service flat rate until instrument matures. Bespoke quotes only.
- **Volumes:** long-tail DACH volumes; Austria market leader historically
- **Strengths:** DACH SME network; White-label tech business as second revenue line
- **Weaknesses:** Fee opacity; Mostly debt-like instruments, thin true-equity comparability
- **Notes:** Another 'contact us' pricing incumbent — published flat pricing remains rare in DACH.

### Springvest
- **Country:** Finland
- **Licence:** Finnish investment firm (MiFID) arranging share issues — NOT an ECSP; supervised by FIN-FSA
- **Model:** equity for Finnish deep-tech/growth companies; 8-10 curated rounds/yr; itself listed on Nasdaq First North Helsinki
- **Instruments:** shares (often with listed-company trajectory)
- **Fees:** Commission on successfully raised funds, varies per campaign (not published); also takes warrants/options in funded companies (option-fee income is a disclosed revenue line). Investors: no platform fees.
- **Volumes:** consistently among Finland's largest equity raisers; single rounds regularly €2-6M+
- **Strengths:** Curated quality bar, large average rounds; Warrant-based upside aligns with issuers; Public company transparency
- **Weaknesses:** Finland-only; Not ECSPR — cannot passport under crowdfunding regime
- **Notes:** Main incumbent to face when passporting into Finland; competes on curation and institutional co-investment, not price.

### Fundwise
- **Country:** Estonia
- **Licence:** DEFUNCT/dormant — never obtained an ECSPR licence; Estonia has only ever issued two ECSP licences (Crowdestate AS, Estateguru OÜ — both lending/real-estate) and Fundwise was not among them; site effectively inactive
- **Model:** equity (launched 2015, CEE focus)
- **Instruments:** OÜ/AS shares
- **Fees:** n/a (historically ~5-7% success fee + listing fee)
- **Volumes:** historic only (~€10M-range cumulative in its lifetime)
- **Weaknesses:** Died in the licensing transition — could not or did not clear the ECSPR bar by the Nov 2023 grandfathering deadline
- **Notes:** Its disappearance means the client would launch into an EMPTY home market: as of mid-2026 there is NO ECSPR-licensed equity crowdfunding platform in Estonia (Estateguru = loans only; Crowdestate's licence revoked at its own request 13 Apr 2026, per Finantsinspektsioon announcement).

### FundedByMe / Pepins
- **Country:** Sweden
- **Licence:** CLOSED — FundedByMe status 'closed' (Wikipedia); acquired Pepins Group 2021, group absorbed by Navian Aug 2023; no ECSP continuation
- **Model:** equity (FundedByMe) + trading-window marketplace (Pepins 'Alpcot' style share trading)
- **Instruments:** shares
- **Fees:** n/a historic
- **Volumes:** historic only
- **Weaknesses:** Merged repeatedly, then wound down — Nordic cautionary tale on unit economics
- **Notes:** Pepins is relevant liquidity history: it ran periodic trading windows for shares of its funded companies under a Swedish arrangement before dying — periodic-auction retail secondaries did not save the business.

### Crowdestate AS (context entry)
- **Country:** Estonia
- **Licence:** ECSP licence granted 6 Mar 2023 by Finantsinspektsioon; REVOKED at company's own request 13 Apr 2026; retains payment institution licence
- **Model:** real-estate/lending crowdfunding (not equity) — included only as Estonian ECSP precedent
- **Instruments:** loans
- **Fees:** n/a for equity benchmark
- **Volumes:** declining post-2022
- **Notes:** Proves Finantsinspektsioon CAN and does license ECSPs (process: 25 working days completeness check + 3 months decision; €1,000 state fee; from 18 Mar 2026 applications only via the Finantsinspektsioon portal), but its exit leaves Estonia with one ECSP (Estateguru, loans). Client would be Estonia's first equity ECSP.

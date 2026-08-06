# Osalus master design — synthesis of the 4-masterbrain panel
### Tech/SaaS/AI/fintech focus · Estonia → EU → international companies establishing an EU presence

**Raw directions:** `design-panel/*.json` (4 complete, buildable specs). **Built as:** `mockup-en-v2.html`.

---

## The judgment

All four masterbrains — briefed with different lenses (terminal, digital-state, editorial-SaaS, founder-story) and researching different references — **independently made the Estonian Business Register the hero artifact**. Four-way convergence means this isn't a style choice; it's the design thesis:

> **The register entry is the product. Everything else is workflow.** *(Registry Grade's pull-line)*

**Winner: Register Terminal** — the platform styled as a precision instrument. Dark-first with a fully designed light theme, hairline grids, monospace tabular data as the signature, register extracts instead of photography, dated facts instead of countdowns, and the ECSPR risk warning rendered as the terminal's permanent status line — compliance as a credibility asset. It is the sharpest fit for the new audience: tech investors and founders trust what looks like it computes.

**Grafts taken from the runners-up:**

| From | Graft | Why |
|---|---|---|
| Registrikaart (digital state) | The **digital-signature stamp block** ("DIGIALLKIRJASTATUD / DIGITALLY SIGNED" + timestamp) inside the hero register extract; the **e-ID chips row** (ID-card · Smart-ID · Mobiil-ID · eIDAS) | Makes the notary-free transfer *visible*; the auth chips are the Estonian trust vocabulary |
| Registry & Portrait (founder story) | **Lead-investor row** in the offer-card data table ("Lead investor — EstBAN syndicate · EUR 40 000 · identical terms") and a founder-tenure line | Factual social proof that replaces FOMO — the only art-27-safe social mechanic; founderless cards were Invesdor's biggest gap |
| Registry & Portrait | **Outcomes register commitment** section ("Every outcome, published" with an honest empty state) | The Springvest honesty pattern; pre-licence trust manufactured through committed future transparency |
| Registry Grade (editorial SaaS) | **CTA-adjacent disclosure blocks** (every CTA followed within 24px by the no-advice line at full contrast) | The Mercury pattern — compliance language sharing the design system's craft |

**Retired from v1:** the Charter prospectus-serif display (3 of 4 panels dropped it; system grotesk + mono reads native to the tech audience), the bakery/metal-fabrication sample companies, the amber top-bar placement (risk line moves to a fixed bottom status line — terminal grammar).

## Token system (as built)

| Token | Light | Dark (default) | Use |
|---|---|---|---|
| --bg | #F6F7F9 | #0B0D10 | page ground (cool blue-grey cast) |
| --surface | #FFFFFF | #10151A | cards, panels, nav |
| --surface-raised | #EDF1F6 | #19202A | table heads, hover, chips |
| --ink | #141A22 | #E8EBF0 | primary text + ALL risk copy |
| --ink-muted | #556070 | #9AA4B1 | secondary; never for legal copy |
| --hairline | #DEE3EA | #273040 | every border, 1px |
| --accent | #0052FF | #5C8DFF | conversion blue (Coinbase-class electric blue in light; accessible sky-royal in dark); single accent |
| --on-accent | #FFFFFF | #081226 | text on accent fills |
| --risk-bg | #FBF1D6 | #221B0B | risk line + fraud notice only (amber is semantic, not accent) |
| --risk-ink | #5F4A0E | #F2D588 | risk copy, ≥7:1 contrast |

> **Accent revision (user decision, 2026-08-01):** the pine/phosphor green was replaced by a high-converting fintech blue — #0052FF light / #5C8DFF dark — and the neutral family's green cast was shifted to a cool blue-grey so the grounds agree with the accent. Both pairs verified ≥5.4:1 on their fills. v1 (mockup-en.html) keeps the original pine palette for comparison.

**Type:** system grotesk (SF/Segoe stacks) at 500–600 for display, 400 body; `ui-monospace` + `tabular-nums` for every number, date, registry code, label — the signature. Scale: 11/13/14/16/20/30/48. EUR amounts thin-space separated, never abbreviated; dates ISO; no legal text below 14px or in muted ink.

**Motion:** instrument-calm — hover border/background transitions (150ms), open-status LED pulse, hero cursor blink, one 600ms parameter count-up; all killed under `prefers-reduced-motion`. Forbidden: countdowns, carousels, parallax, translate/scale hovers, anything resembling a live price feed.

## Page architecture (v2, as built)

Nav (blur + AUTHORISATION PENDING chip) → Hero (H1 + register-extract panel with YOU row, blinking cursor, digital stamp, e-ID chips) → Parameter strip (€0 / €100 / 4 days / 3+ yrs — honest platform parameters, not vanity volume stats) → 01/OFFERS (sector chips + 3 illustrative tech offers) → 02/PROCESS (Invest/Raise tab ledger) → 03/OWNERSHIP (Osalus vs nominee/SPV comparison table) → 04/RAISE (e-Residency route diagram: NON-EU TECH COMPANY → ESTONIAN OÜ → ECSPR OFFER → EU INVESTORS) → 05/FEES → 06/BOARD (bulletin table, "a bulletin board, not an exchange") → 07/OUTCOMES (empty-state outcomes register) → 08/STATUS (typographic trust badges) → Waitlist → Fraud notice → Footer legal band → **fixed bottom risk status line** (verbatim, non-collapsible, on every page).

## Art 27 enforcement by omission

The offer-card template **contains no field where a return figure could exist** — no yield slot, no IRR, no projection. The only performance-adjacent datum is historical audited revenue labelled with its year ("Revenue (FY2025)"). Status shows a closing *date*, never a countdown. CTA verbs: "View offer" / "Join the waitlist" — never "Invest now".

## Invesdor audit (consolidated)

**Steal:** stats-banner slot (filled with platform parameters, since a pre-licence platform has no volume to claim) · dual Invest/Raise paths · status badges · instrument-aware cards · the trust-badge slot done as typography with live register links.
**Avoid:** per-annum yields on cards (their bond pattern — illegal on our equity cards) · "3 days left" urgency chips · risk text demoted to fine print · adjective-led hero ("Together we fund the future") · cookie banner outranking compliance content · "Invest now" verbs.

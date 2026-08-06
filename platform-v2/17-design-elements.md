# Osalus design-element catalogue
### 4-agent element panel, 2026-08-06 · 37 proposals · 10 built into mockup-en-v2.html

Elements marked **BUILT** are live in the page. The rest are specified and ready to implement.

## Motion & interaction

### Deal-card boot sequence (hero, page load) `[M]` — **BUILT**
**Where:** Hero right column — the E-ÄRIREGISTER · EXTRACT deal card; runs once on first paint, never on scroll-back

**Spec:** All rows exist in the DOM from first paint (no JS-injected text — SEO/screen-reader safe); the sequence is purely opacity/transform reveals gated by a `.booted` class added on `DOMContentLoaded + 120ms`. Order and timings: (1) titlebar hairline: `border-bottom` element scaleX 0→1, transform-origin left, 200ms cubic-bezier(.25,0,.2,1); (2) titlebar text 'E-ÄRIREGISTER · EXTRACT' opacity 0→1 120ms, starting at t=180ms, with a 1ch-wide block caret (`::after`, background: var(--accent), width .55em, height 1em) that blinks twice (opacity steps(2) 300ms x2) then sets to 0; (3) the six kv rows (Company/Website/Nominee/For sale/Raising/Valuation) each: opacity 0→1 + translateY(4px)→0, 120ms ease-out, staggered 70ms apart via `transition-delay: calc(var(--i) * 70ms)` (set --i:0..5 inline) — total row phase 470ms; (4) at t=760ms the 'Buy now' button materialises: opacity 0→1 + border-color transparent→var(--hairline) 150ms — no scale, no glow; (5) caption 'Illustrative offer. Not a live listing.' fades in 150ms at t=860ms — the caption must NEVER appear after the button with a longer delay than 100ms (compliance: the disclaimer may not lag the CTA perceptibly; if in doubt fade caption+button together). Under `@media (prefers-reduced-motion: reduce)` the `.booted` gate is skipped entirely: everything static at opacity 1, carets `display:none`. Each individual transition ≤200ms; only opacity/transform/border animate.

**Why:** Turns the illustrative extract into the page's one moment of theatre — a registry terminal printing a record — which sells the 'this is infrastructure, not a pitch deck' positioning to tech-literate investors without a single adjective. One-shot, calm, and the disclaimer arrives with the CTA.

**Risk:** Art 27 fair/not-misleading: the CTA must not be visually privileged over the 'Illustrative offer' caption — mitigated by hard-coupling caption reveal ≤100ms after the button and keeping the button reveal a flat fade (no pulse/glow). Rows are real DOM text from first paint, so no cloaking/SEO risk.

### Section-divider hairline draw on scroll `[S]` — **BUILT**
**Where:** Every full-bleed hairline divider above sections 00–10, plus the divider above the fraud notice

**Spec:** Each divider is `height:1px; background:var(--hairline); transform:scaleX(0); transform-origin:left center;`. One shared `IntersectionObserver` (threshold .9, rootMargin '0px 0px -8% 0px') adds `.drawn` → `transform:scaleX(1); transition: transform 250ms cubic-bezier(.25,0,.2,1);` then unobserves (draws once, never re-runs). The adjacent mono section index ('01 / FOCUS') fades opacity 0→1 over 150ms with `transition-delay:120ms` so the line appears to print the label. Reduced-motion: dividers ship with `.drawn` server-side/inline and the observer never registers (guard: `if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;`). GPU-only (transform), no layout shift because height is constant.

**Why:** Reinforces the ledger/ruled-paper grammar — sections read as entries being ruled into a register as you scroll. Cheapest possible motion vocabulary reuse: one observer, one keyframe-free transition.

**Risk:** none

### Offer meter fill-on-reveal with threshold tick check `[S]`
**Where:** 02 / OFFERS — the progress meter inside each of the 3 offer cards

**Spec:** Meter track: 1px-bordered 4px-tall bar; fill is an inner div `transform:scaleX(0); transform-origin:left;` with `--fill` set inline from the dated figure (e.g. `--fill:.34`). On card intersection (same observer pattern as dividers, threshold .5, once), add `.revealed` → `transform:scaleX(var(--fill)); transition:transform 300ms cubic-bezier(.2,0,.1,1);`. The minimum-threshold tick (1px × 8px, var(--muted)) is static; when the fill crosses it, at t=300ms the tick does a single confirmation blink: `opacity 1→.35→1` over 200ms (only if `--fill` ≥ threshold — computed in JS, class `.min-met`). Percentage label next to the meter is STATIC text — no number animation here (see parameter count-up element for the page's single count-up). Timestamp row beneath is untouched. Reduced-motion: fill rendered at final scaleX via the inline var with `transition:none`, tick never blinks.

**Why:** The meter is the page's key evidence surface; a single 300ms fill makes the funded-vs-minimum relationship legible at a glance, and the tick blink confirms 'minimum met' as an instrument reading, not a celebration.

**Risk:** Urgency-mechanic adjacency: an animating raise bar can read as 'filling fast, act now'. Mitigated: one-shot on reveal only, fixed 300ms regardless of fill %, no live re-fills, no animated numbers, figures remain dated facts with visible timestamp.

### Single permitted count-up: parameter strip `[S]`
**Where:** Parameter strip under the hero (EUR 0 / EUR 100 / 4 days / 3+ yrs)

**Spec:** This is the page's ONE count-up per the design grammar. On strip intersection (once), each mono figure counts from 0 to final over 280ms using rAF with ease-out (t*(2-t)), rendered with `tabular-nums` so width never shifts ('EUR 100' counts 0→100; 'EUR 0' and '3+ yrs' simply fade in 150ms — do not count trivial values). Format via the same formatter as static render so the end state is byte-identical to server text. Implementation: figures ship as final text in HTML; JS snapshots the number, sets it to 0, animates, restores — if JS fails or reduced-motion matches, the true text was never removed. No other numeral anywhere on the page may animate.

**Why:** Spends the grammar's single count-up allowance on regulatory-fact parameters (fees, minimum ticket) rather than raise amounts — motion draws the eye to 'EUR 0 fees / EUR 100 minimum', the two strongest conversion facts, with zero urgency connotation.

**Risk:** Animated money figures near offers can look like performance data — mitigated by restricting to static platform parameters (never raise/valuation figures), 280ms one-shot, exact static end-state.

### Sector tile hover / focus state `[S]`
**Where:** 01 / FOCUS — the 6 mandate sector tiles

**Spec:** Rest: `border:1px solid var(--hairline); background:var(--surface);` mono index (e.g. '01') in var(--muted), LED dot `opacity:.45`. Hover/focus-within: `border-color:var(--accent); background:var(--raised);` mono index → var(--accent); LED dot opacity .45→1; all via `transition: border-color 150ms, background-color 150ms, opacity 150ms, ease-out`. NO translateY, NO shadow, NO scale — the tile stays planted (instrument, not card game). Cursor stays default if tiles are non-interactive; if they anchor to offers filtered by sector, add `cursor:pointer` and make the whole tile the `<a>` with the focus-visible treatment below. Touch devices: hover styles behind `@media (hover:hover)` so tiles don't stick lit after tap. Reduced-motion: `transition-duration:0ms` (state change still occurs, instantly).

**Why:** Border-and-ink state change is the purest expression of the system's 1px grammar — feedback without levitation. Accent is reserved and single, so tiles lighting blue quietly says 'this is where the mandate points'.

**Risk:** none

### Nav condense + hairline latch on scroll `[S]`
**Where:** Fixed top nav (wordmark + AUTHORISATION PENDING chip + theme toggle + Sign up)

**Spec:** Two states driven by a scroll threshold (`scrollY > 24`, applied via rAF-throttled listener or a 1px sentinel + IntersectionObserver — prefer the sentinel, zero scroll-jank). At rest: nav padding-block 20px, `border-bottom:1px solid transparent`, background transparent. Condensed: padding-block 12px, `border-bottom-color:var(--hairline)`, `background:color-mix(in srgb, var(--bg) 88%, transparent)` + `backdrop-filter:saturate(1) blur(6px)` (progressive enhancement; solid var(--bg) fallback). Transition: `padding 200ms, border-color 150ms, background-color 150ms` ease-out. The AUTHORISATION PENDING chip and its LED are untouched — it must remain readable at both sizes; wordmark does not scale. Reduced-motion: states swap with `transition:none`. Note padding animation causes one cheap reflow of a fixed element only — acceptable; do not animate height directly.

**Why:** Signals depth-of-page and keeps the compliance chip + Sign up persistently visible without a heavy sticky bar; the hairline 'latching in' on scroll is the same ruled-line vocabulary as the section dividers.

**Risk:** AUTHORISATION PENDING must never be clipped/faded during condense (it is a required-prominence status) — mitigated by fixed chip size and padding-only animation.

### Theme transition: single crossfade, no per-element cascade `[M]`
**Where:** Theme toggle in nav; affects the whole document

**Spec:** Never put `transition: background-color/color` on `*` (causes staggered, smeary swaps). Instead: on toggle, add class `.theming` to `<html>` which sets exactly `html.theming, html.theming body { transition: background-color 150ms ease, color 150ms ease; }` plus the same on `.surface, .raised` container classes and `border-color 150ms` on hairline elements — a curated selector list of ~6 rules; remove `.theming` on `transitionend` (fallback `setTimeout 200ms` — carry the transitionend-fallback pattern). Toggle writes `data-theme` on `<html>` and persists to `localStorage`; an inline head script applies the stored theme pre-paint to prevent flash. LED dots and accent swap instantly (no transition) so status colors never blend through intermediate hues. Reduced-motion: `.theming` class is never added — hard cut. Icon on the toggle: two overlaid glyphs cross-fading opacity 150ms.

**Why:** A single coherent 150ms swap reads as an instrument changing display mode; the curated-selector approach avoids the amateur 'everything melts' cascade and keeps status LEDs semantically instant.

**Risk:** none

### Copy-to-clipboard on registry codes and mono facts `[M]`
**Where:** Deal-card rows (registry code, valuation, raise figure), 04 / OWNERSHIP nominee table codes, footer legal entity code — any 11px mono value with a stable identifier

**Spec:** Wrap each copyable value: `<button class='copy' aria-label='Copy registry code 16938495'><code>16938495</code></button>`. Rest: no affordance beyond `cursor:copy` and a hover `border-bottom:1px solid var(--hairline)` fading in 150ms. On click: `navigator.clipboard.writeText()` (execCommand fallback), then a mono microlabel `COPIED` (11px uppercase, letter-spacing .08em, var(--accent)) fades in 150ms opacity-only, positioned absolutely right of the value (no layout shift — reserve the space or overlay), LED-style dot beside it at full opacity; both fade out 150ms after 1600ms. Also set `aria-live='polite'` region announcing 'Copied'. Failure path: label reads `SELECT + COPY` and the text gets `user-select:all`. Reduced-motion: label appears/disappears instantly, same 1600ms hold. Never attach to the Buy now button or any figure inside offer cards' Raising row if it could be mistaken for an action on the offer — copy affordance only on identifier-class values.

**Why:** Tech-literate Estonian users will paste registry codes into e-äriregister/RIK to verify — making verification one click is the highest-trust interaction the page can offer and perfectly on-brand for a registry terminal.

**Risk:** Must not imply the illustrative deal card's figures are live verifiable records — mitigated by attaching copy only to real identifiers (actual entity codes in footer/ownership) and NOT to the illustrative card, or keeping the card's copy limited to the nominee entity's real code.

### Process ledger keyboard tabs + sliding index rail `[M]`
**Where:** 03 / PROCESS — the Invest / Raise tab ledger (steps 01–05)

**Spec:** Full WAI-ARIA tabs pattern: `role=tablist/tab/tabpanel`, roving tabindex, ArrowLeft/ArrowRight cycle (Home/End jump), selection follows focus. Active-tab indicator is a single 1px underline element translated between tabs: `transform:translateX(var(--x)) scaleX(var(--w))` transition 200ms cubic-bezier(.25,0,.2,1) — measured on activation via `getBoundingClientRect`, recomputed on resize. Panels swap with a 150ms opacity crossfade (outgoing 0, incoming 1; no slide — content is a ledger, not a carousel). The 01–05 step rows in the incoming panel get a 40ms stagger opacity fade (5 rows = 160ms total, within budget). Reduced-motion: indicator jumps (`transition:none`), panels hard-swap, no stagger. Also add a page-level skip link ('Skip to offers') visible on focus, styled as a mono chip.

**Why:** Keyboard-first tabs telegraph engineering seriousness to the exact audience (developers/founders who tab through pages), and the underline translating between Invest/Raise is the system's one permitted piece of spatial motion — a needle moving on a gauge.

**Risk:** none

### Focus-visible instrument ring (global) `[S]`
**Where:** Every interactive element sitewide: nav links, CTAs, Buy now, tiles, tabs, copy buttons, form fields, theme toggle, footer links

**Spec:** Global rule: `:focus { outline:none } :focus-visible { outline:2px solid var(--accent); outline-offset:2px; border-radius:inherit; }` — never remove outlines without this replacement. For inputs in the Sign up panel additionally `border-color:var(--accent)` with `transition:border-color 150ms`. For the bottom risk status line, if it contains a link, focus ring must render fully within viewport (add `scroll-padding-bottom` equal to the bar height on `html` so keyboard focus is never hidden behind the fixed bar; same `scroll-margin-top` for the fixed nav: `scroll-margin-top:80px` on all section anchors). The AUTHORISATION PENDING chip, if non-interactive, gets `tabindex` omitted — no fake focusability. No animation on the ring itself (instant appearance is correct for focus); the only transition is the input border tint. Nothing to disable under reduced-motion.

**Why:** Focus polish is the cheapest credibility signal for a regulated platform — WCAG 2.4.7/2.4.11 conformance out of the box, and the accent-blue ring reuses the single accent as 'the machine acknowledges you'.

**Risk:** none

## Data furniture

### Cap-table structure bar `[S]` — **BUILT**
**Where:** 04/OWNERSHIP — directly beneath the "One nominee. Clean cap tables." table, full content width

**Spec:** A single horizontal segmented bar, 28px tall, 8px radius, 1px hairline outer border, built from flex divs. Segments for the illustrative deal: Founders 93.9% (fill: raised token #EDF1F6/#19202A), AureviaFund OÜ nominee 6.1% (fill: accent #0052FF/#5C8DFF at 100%). 1px hairline separators between segments. Above the bar: mono microlabel "CAP TABLE — AFTER OFFER (ILLUSTRATIVE)" 11px uppercase .08em. Below each segment, a leader line (1px hairline, 12px tall) dropping to a mono label pair: "FOUNDERS · 93.9%" and "AUREVIAFUND OÜ (NOMINEE) · 6.1% · 1 REGISTRY ENTRY". Right-aligned mono caption: "vs. 40+ direct entries without a nominee". Second variant row beneath, 12px tall and 60% opacity, labelled "WITHOUT NOMINEE", chopped into ~40 hairline-separated slivers of the same 6.1% span — the visual argument for the nominee, no JS needed. Hover on a segment: bg shifts one step, 150ms border transition. Numbers in ui-monospace tabular-nums. Caption line: "Illustrative structure. Not a live offer." in muted.

**Why:** Makes the nominee value proposition legible in one glance — the one-entry-vs-forty-slivers comparison is the strongest visual on the page and it is pure structure, zero performance implication. Segmented bars with leader lines are annual-report grammar, native to the terminal aesthetic.

**Risk:** Could be read as a real offer's cap table — mitigated by the mandatory "ILLUSTRATIVE" microlabel and the existing caption pattern already used on the hero deal card.

### Fee worked-example meter `[S]` — **BUILT**
**Where:** 06/FEES — replaces or sits under the EUR 0 vs EUR 1000+6% panels as a shared footer row spanning both

**Spec:** Two stacked horizontal bars on a common scale, each 20px tall, hairline-bordered, labeled in mono. Scale = cost on a EUR 200 000 raise (ties to the hero deal figure). Bar 1: "THIS PLATFORM — EUR 0" renders as an empty track (surface bg) with a single 2px accent tick at 0 and mono value "EUR 0" right-aligned. Bar 2: "TYPICAL PLATFORM — EUR 1 000 + 6%" fills 100% of track width in raised token (NOT red), value "EUR 13 000". Under the pair, a hairline divider and mono footnote: "WORKED EXAMPLE ON A EUR 200 000 RAISE. TYPICAL FEE = LISTING EUR 1 000 + 6% SUCCESS FEE. SURVEYED 2026-08." Optional single count-up (the page's one allowed count-up) animating 0→13 000 on first intersection, 900ms, tabular-nums so width never jumps; skipped entirely under prefers-reduced-motion. No color coding beyond accent tick vs raised fill — no green/red.

**Why:** Turns the fee claim from adjectives into an instrument reading. Cost comparison (not return comparison) is the one chart this page is allowed to have, and anchoring it to the same EUR 200 000 as the hero deal makes the whole page feel internally consistent.

**Risk:** Comparative marketing claim (art 27 fair/not-misleading): the 6% figure must be substantiable — mitigated by the dated "SURVEYED 2026-08" footnote and the word TYPICAL; keep a source list off-page.

### Subscription figure block (progress typography) `[S]`
**Where:** 02/OFFERS — inside each offer card, replacing the bare meter's label row; also reusable on the hero deal card

**Spec:** Above the existing meter: a two-line figure block. Line 1: committed amount in 22px/600 ui-monospace tabular-nums, "EUR 128 400" in ink, followed by " / 200 000" in muted at the same size — the slash construction reads as an instrument register. Line 2: mono microlabel row, space-between: left "64.2% SUBSCRIBED · MIN 60% ✓" (the ✓ only renders once past the min tick; before threshold it reads "MIN 60% — TICK AT EUR 120 000"), right "AS OF 2026-08-05 14:00 EET" in muted. The meter itself: 6px track, hairline border, accent fill, min-threshold tick as a 1px ink line extending 3px above/below the track with a tiny mono "MIN" flag. State when offer is illustrative: entire block gets the existing "Illustrative" caption and the LED dot on the card status row stays muted, not accent. No animation on fill (fills at layout, no grow-in) except a one-time 150ms opacity fade.

**Why:** The committed/target figure is the single most factual, most terminal-native number the platform has — promoting it from a meter caption to display typography makes cards feel like live instruments while every character stays a dated historical fact.

**Risk:** Subscription level can nudge social-proof urgency — mitigated by the static AS OF timestamp (dated fact, never live-ticking), no "only X left" phrasing, and no color change as it fills.

### Registry-extract row grammar for the deal card `[S]`
**Where:** Hero right column — upgrade of the existing E-ÄRIREGISTER · EXTRACT card body

**Spec:** Restyle the six kv rows as numbered registry entries: each row gets a 24px left gutter with a mono row index ("01"–"06", 11px, muted), dotted leader line (border-bottom: 1px dotted hairline token on a flex spacer) between key and value, values right-aligned tabular mono. Add row 07 "REGISTRY CODE" with a placeholder-formatted code "16XXXXXX" and a copy-affordance icon (inline SVG, 12px) that copies on click and swaps to "COPIED" mono text for 1.2s. Titlebar gains a right-aligned LED dot + "EXTRACT · GENERATED 2026-08-05" mono stamp. The "For sale 6.1%" and "Raising EUR 200 000" rows render their numerals at 15px/600 while keys stay 13px/400 — a two-weight register hierarchy. Keep the full-width Buy now button and the illustrative caption untouched. Print-style bottom edge: 1px hairline + centered mono "— END OF EXTRACT —" 10px muted.

**Why:** The deal card is the page's hero object; making it forensically resemble an actual e-Business Register extract (numbered entries, dotted leaders, generated-stamp, end-of-document mark) is the highest-leverage precision signal for an Estonian audience that has seen real extracts.

**Risk:** Imitating an official registry document could mislead — mitigated by keeping the existing "Illustrative offer. Not a live listing." caption, the XXXXXX placeholder code, and no Ärireg logo/crest, ever.

### Event ledger strip (honest ticker) `[S]` — **BUILT**
**Where:** Between the parameter strip and 00/START, full-bleed with hairline top/bottom dividers

**Spec:** A single-row horizontal strip, 40px tall, styled like a terminal tape but strictly dated facts: entries separated by " · " hairline-bordered pills? No — plain mono text nodes separated by 24px gaps and a 3px LED dot each. Content examples (verbatim): "2026-07-28 — CSPR AUTHORISATION APPLICATION SUBMITTED", "2026-08-01 — AUREVIAFUND OÜ REGISTERED", "2026-08-04 — FOUNDING TEAM PUBLISHED". Max 4 entries, hard-coded array in JS. Overflow behavior: the strip is a horizontal scroll container (overflow-x auto, scrollbar hidden) — NO marquee/auto-scroll. Every 8s, one entry's LED does a single opacity pulse (the existing LED pulse pattern), cycling through entries; killed under prefers-reduced-motion. Left edge anchor: mono microlabel "LOG" in an 11px uppercase tag with right hairline. Entries are 12px mono, dates in muted, event text in ink. Newest first.

**Why:** Delivers the "alive instrument" feeling of a ticker while being the exact opposite of urgency mechanics — an append-only audit log of things that already happened, which is precisely the trust register a pre-authorisation platform should keep.

**Risk:** None — dated past facts only; the no-auto-scroll rule keeps it out of urgency/carousel territory.

### Route comparator table (angel round vs ECSPR offer) `[M]`
**Where:** 05/RAISE — beneath the route diagram, above the skyline SVG

**Spec:** A three-column spec table, hairline grid, 8px radius container: column 1 = mono row labels, columns 2–3 headed "DIRECT ANGEL ROUND" / "ECSPR OFFER (THIS PLATFORM)" with 11px mono uppercase headers and a muted vs accent left-border (3px) respectively. Rows (all factual/procedural, zero return language): MIN TICKET → "typ. EUR 10 000+" / "EUR 100"; INVESTOR PAPERWORK → "notarised share transfer per investor" / "e-ID signature online"; CAP-TABLE ENTRIES → "one per investor" / "1 (nominee)"; NOTARY VISITS → "required" / "0"; INVESTOR RESIDENCY → "any" / "EU (ECSPR)"; DISCLOSURE DOCUMENT → "none required" / "KIIS (art 23)"; COOLING-OFF → "—" / "4 days (art 22)". Numbers tabular mono right-ish alignment within cells, text 13px. Row hover: bg to raised, 150ms. Mobile: columns stack into two cards with the same row labels repeated. Footer mono caption: "Procedural comparison. Legal requirements summarised; not advice."

**Why:** Founders comparing routes is the actual decision moment on this page; a cold spec-sheet comparison (Mercury/Stripe pricing-table grammar) answers it with process facts and quietly restates the platform's regulatory articles, reinforcing the compliance-as-feature positioning.

**Risk:** "none required" for angel disclosure could read as legal advice — mitigated by the "not advice" footer and keeping every cell procedural (tickets, signatures, entries), never outcomes.

### Reflection-period rail (T+ timeline) `[S]`
**Where:** 03/PROCESS — Invest tab, inserted between ledger steps 03 and 04 (or as a footer of the Invest ledger)

**Spec:** A horizontal rail, 2px hairline track, four tick marks with mono labels beneath: "T+0 — COMMITMENT SIGNED (E-ID)", "T+0…T+4D — CANCEL FREELY, NO REASON (ART 22)", "T+4D — REFLECTION PERIOD ENDS", "CLOSE — FUNDS MOVE ONLY IF TARGET MET". The T+0→T+4D span renders as a slightly thicker (4px) segment in accent at 30% opacity with a mono overline "INVESTOR PROTECTION WINDOW". Ticks are 1px ink lines 8px tall; labels 11px mono, two-line max, muted with the T-codes in ink. Crucially static: this is a schematic of the rule, not a live countdown for any offer — no dates, only T-notation. Mobile: rail rotates vertical, ticks on the left. Endcap arrowhead none; square ends. One-line caption: "Applies to every offer on the platform under ECSPR art 22."

**Why:** Settlement-timeline rails are core terminal furniture (bond/settlement UIs), and here the instrument being diagrammed is the investor's own protection — it converts a legal footnote into the page's most reassuring graphic and directly answers 'what if I change my mind'.

**Risk:** None — it diagrams a statutory right in T-notation; the no-real-dates rule keeps it categorically distinct from a countdown.

### Platform status register `[S]`
**Where:** 10/STATUS — replaces the plain WHO WE ONBOARD kv panel's sibling area, above the trust-strip badges

**Spec:** A status-page-style table (statuspage/terminal system monitor grammar): hairline-bordered card, titlebar "PLATFORM STATUS · AS OF 2026-08-05" in mono. Rows, each: LED dot (8px) + item label + right-aligned mono status + dated fact. Row set: "ECSPR AUTHORISATION" → amber-token LED (the page's only third amber use — justified: it IS a risk/status signal; if that violates the amber reservation, use muted LED + text "PENDING") + "PENDING — SUBMITTED 2026-07-28"; "NOMINEE ENTITY (AUREVIAFUND OÜ)" → accent LED + "REGISTERED — 2026-08-01"; "LIVE OFFERS" → muted LED + "0 — ACCEPTING ISSUER APPLICATIONS"; "INVESTOR PAYOUTS PROCESSED" → muted LED + "0 — NO COMPLETED OFFERS YET". LED states: muted dot static, accent dot static, pending dot uses the existing LED pulse (one 2s opacity cycle, loops, killed under reduced-motion). Safer default per the token law: use muted LED + mono "PENDING" text, no amber. Everything tabular mono, 13px.

**Why:** Radical honesty as furniture: publishing zeros ("0 live offers, 0 payouts") in status-page format is the strongest possible anti-hype signal and matches the empty-state Outcomes register in 08 — the page starts keeping the books before there is anything to book.

**Risk:** Restating AUTHORISATION PENDING must never imply approval is certain — mitigated by verbatim "PENDING — SUBMITTED <date>" phrasing and keeping the nav chip wording identical; default to muted LED to preserve the amber-for-risk-only token law.

### Tabular refinement pass (leaders, alignment, copy affordance) `[S]`
**Where:** Global — every kv table on the page: deal card, offer cards, 04/OWNERSHIP table, 10/STATUS panel, footer legal ids

**Spec:** A shared CSS component .reg-row applied everywhere: display:flex; key 13px/400 ink; spacer flex:1 with border-bottom 1px dotted hairline token, 4px bottom offset so the leader sits on the text baseline; value right-aligned ui-monospace tabular-nums font-variant-numeric: tabular-nums slashed-zero. All EUR amounts formatted with thin non-breaking spaces as thousands separators ("EUR 200 000") via a single JS formatter used everywhere. Codes/IDs (registry codes, LEI-style ids in footer) get class .reg-code: click-to-copy with navigator.clipboard, 12px inline copy SVG at 40% opacity rising to 100% on row hover (150ms), "COPIED" mono confirmation replacing the icon for 1.2s. Percent values always one decimal ("6.1%"), dates always ISO "2026-08-05". Row hover across all tables: background to raised, 150ms, no shadow.

**Why:** The difference between looking like a terminal and being one is numeric discipline — one shared row primitive with dotted leaders, uniform EUR formatting, and slashed zeros makes every existing section snap into the same instrument, at near-zero build cost.

**Risk:** None — purely typographic; the single formatter also reduces compliance risk by making inconsistent or ambiguous number formatting impossible.

## Trust & registry

### Registry anchor chip (system-wide primitive) `[S]` — **BUILT**
**Where:** Introduced in 10/STATUS trust strip; reused inline in 04/OWNERSHIP (nominee row), 07/BOARD, and footer legal block

**Spec:** A <a> chip, 28px tall, 8px radius, 1px hairline border (var --hairline), surface bg, mono 11px uppercase letter-spacing .08em. Anatomy: 6px LED dot + label + '↗' glyph (plain text, 12px, muted ink) with 4px gap. Three concrete instances: [1] 'E-BUSINESS REGISTER · 16631770 ↗' → https://ariregister.rik.ee/eng/company/{regcode} (green LED #3AA76D-equivalent? NO — use accent-colored LED since red/green trading colors are forbidden only for price movement; safest: accent blue LED = 'record exists'). [2] 'FINANTSINSPEKTSIOON REGISTER ↗' → fi.ee supervised-entities search; pre-licence this chip renders in a DISABLED state: dashed 1px border, muted text, no LED, suffix text 'NOT YET LISTED' instead of ↗, cursor default, aria-disabled. [3] 'ESMA CSP REGISTER ↗' same disabled treatment. Hover (enabled only): border-color → accent, bg → raised, 150ms; killed under prefers-reduced-motion. All links target=_blank rel=noopener. Build as one .chip-registry class with .is-pending modifier so states flip with a single class change on licence grant.

**Why:** Outbound deep links to registers the user can verify independently are the cheapest trust mechanism that exists — the page stops asserting and starts pointing. The disabled state turns the pre-licence gap into visible honesty rather than an omission, which is exactly the register-terminal voice.

**Risk:** Linking FI/ESMA while unlisted could imply supervision. Mitigated: those two chips ship in the explicit 'NOT YET LISTED' dead state (no link, dashed border) until the licence is granted; only the e-Business Register chip is live, and a company registry entry is a verifiable fact today.

### KIIS document object (designed file card) `[M]`
**Where:** Replaces the plain 'KIIS link' inside each of the 3 offer cards in 02/OFFERS; same component reused later for any legal doc

**Spec:** Card 100% width inside the offer card, raised bg, 8px radius, 1px hairline, 12px padding, grid: 36px file glyph column + body. Glyph: inline SVG, 1.5px-stroke line-art page with folded corner and 'PDF' mono caption — no color fill. Body line 1: mono 12px filename 'KIIS_{ticker}_v1.2.pdf' in ink. Line 2 (mono 11px muted, dot-separated): '14 PAGES · 412 KB · ET / EN'. Language tags are 2 mini-chips (16px tall, hairline border). Line 3: 'SHA-256 a3f9c1…e77b' — first 6 + last 4 hex chars, with a copy-on-click button (copies full hash, tooltip 'COPIED' in mono, 150ms fade). Bottom-right ghost button 'OPEN ↗'. Above the filename a full-width mono 10px banner row: 'KEY INVESTMENT INFORMATION SHEET — NOT APPROVED OR REVIEWED BY ANY COMPETENT AUTHORITY' in muted ink on surface bg (this sentence is the ECSPR Art 23 mandated disclaimer, verbatim territory). While offers are illustrative, overlay a corner tag 'SPECIMEN' (mono 10px, rotated 0deg, hairline border, muted) and disable OPEN.

**Why:** A hash + page count + language tags makes the KIIS feel like an artifact of record rather than a marketing PDF link. The mandated 'not approved' line converts a compliance obligation into a trust prop — the register aesthetic makes disclaimers look native.

**Risk:** Showing a hash for a specimen doc could imply a real filed document. Mitigated: SPECIMEN tag + disabled OPEN until a real KIIS exists; hash is then computed from the actual file at build time (one-line shell step documented in a code comment).

### Licence-status module (pending → granted state machine) `[M]`
**Where:** Top of 10/STATUS, above the WHO WE ONBOARD kv panel; the nav 'AUTHORISATION PENDING' chip becomes a #status anchor link to it

**Spec:** Full-width panel, surface bg, hairline border, 8px radius. Header row: mono index 'AUTHORISATION' left, LED right. Body = 4-row kv table (hairline row dividers, mono values, tabular-nums): AUTHORITY → 'Finantsinspektsioon (Estonia)'; LEGAL BASIS → 'Regulation (EU) 2020/1503, Art 12'; APPLICATION → 'Submitted {DD.MM.YYYY}' (dated fact, never a countdown or progress bar); STATUS → 'UNDER REVIEW'. State is driven by one data-attribute on the panel: [data-licence=pending] → LED muted-gray with slow 2s opacity pulse (killed under reduced-motion), status text muted; [data-licence=granted] → LED accent blue solid, STATUS row becomes 'GRANTED {date} · REG NO {n}' and a live FI registry-anchor chip (element 1) appears in a fifth row. Both states fully built in CSS/JS now; flipping the attribute is the launch-day change. Below the table, one body-400 sentence: 'AureviaFund OÜ may not provide crowdfunding services until authorisation is granted.'

**Why:** The single biggest trust question a pre-licence platform faces is 'are you allowed to do this?' — answering it in a register-styled kv table with a dated fact reads as confidence, not weakness. Pre-building the granted state means launch day is a one-attribute flip, not a redesign.

**Risk:** Art 12/marketing risk of implying imminent approval. Mitigated: no timeline, no progress meter, no 'expected' date — only the submission date (verifiable fact) plus an explicit may-not-operate sentence.

### Signature stamp — system-wide 'verified record' object `[S]`
**Where:** Defined once as an inline SVG symbol; applied to 08/OUTCOMES entries (future), the 04/OWNERSHIP nominee table footer, and the deal-card in the hero (as SPECIMEN)

**Spec:** A stamp block 200×64px max: 1px hairline rounded-rect (8px) frame, internal 2-column grid. Left column 40px: line-art SVG checkmark-in-document glyph, 1.5px stroke, ink color. Right column, three mono lines 10px uppercase: 'DIGITALLY SIGNED', 'ASICE CONTAINER', '{DD.MM.YYYY HH:MM} UTC' (tabular-nums). A second variant [data-stamp=specimen] swaps line 1 for 'SPECIMEN — UNSIGNED' with dashed frame and no timestamp. Colors: frame + text ink at 100%, glyph ink; NO accent, NO amber (amber is reserved). Do not imitate DigiDoc/Dokobit visual branding — generic frame only. Provide as <template id=stamp-verified> cloned by JS with a data-timestamp attribute so every future signed record renders identically. Hover: none (a stamp does not react).

**Why:** Estonian users pattern-match digital-signature confirmations as the strongest local proof-of-record. One reusable stamp object gives every future signed document/outcome the same instantly-recognizable verification furniture, and its deliberate non-interactivity signals 'record, not button'.

**Risk:** Rendering a signed-state stamp where no signature exists would be fabrication. Mitigated: only the SPECIMEN variant may appear pre-launch; the verified variant is template-only until a real .asice container backs it, and it never imitates a certified provider's mark.

### Page version + change log line (site audit trail) `[S]`
**Where:** Single mono line directly above the footer legal block, full-bleed hairline above it; change log expands in place

**Spec:** Line: 'PAGE VERSION 2026-08-05.2 · CONTENT CHANGE LOG +' — mono 11px uppercase, muted, letter-spacing .08em, tabular-nums for the version. The '+' is a <button> toggling (aria-expanded) an inline <ul> of the last 5 dated changes, each row: '{DD.MM.YYYY} — {change description, body 400, max 90 chars}' with hairline row separators, e.g. '05.08.2026 — Fee table updated: payment processing pass-through added.' Expand = height auto via grid-template-rows 0fr→1fr, 150ms, none under reduced-motion. Versions are hand-maintained in a JS array at the top of the file (const CHANGELOG = [...]) so the developer edits one place. No external requests.

**Why:** Marketing pages silently rewrite themselves; registers keep history. A visible, dated change log applies the audit-trail promise to the page itself — the strongest possible signal that numbers here are maintained, not sprayed.

**Risk:** Only risk is a stale log contradicting page content. Mitigated: the changelog array sits adjacent to the version constant in source with a comment 'bump on every content edit' — one edit surface.

### Supervision map (how we're supervised diagram) `[M]`
**Where:** 07/BOARD, inserted between the art 25 notice feed and the does/doesn't columns

**Spec:** Horizontal line diagram in the skyline-SVG dialect: 1px hairline connectors, 8px-radius node boxes, mono 11px uppercase labels, viewBox 0 0 720 120, currentColor strokes so it themes automatically. Four nodes left→right: 'EU — ECSPR 2020/1503' → 'FINANTSINSPEKTSIOON' → 'AUREVIAFUND OÜ' → 'INVESTORS'. Connector 1 caption (mono 9px muted, under the line): 'empowers'. Connector 2: 'authorises + supervises — PENDING' with the pending word in a dashed-border mini-chip; the FI→platform connector itself is dashed (4 2 dash) until granted, then solid via the same [data-licence] attribute as element 3. Connector 3: 'art 19 disclosures'. Under the diagram one caption line: 'SUPERVISORY CHAIN — STATUS AS OF {date}'. On viewports <640px the SVG swaps to a vertical variant (media query, second viewBox) — no horizontal page scroll.

**Why:** Retail investors cannot evaluate ECSPR text but instantly parse a chain-of-authority picture. Making the pending link literally dashed is honest-by-geometry and reuses the licence state machine, so the whole page's truth flips from one attribute.

**Risk:** A solid FI connector pre-licence would imply active supervision. Mitigated: dashed connector + 'PENDING' chip bound to the same data-licence source of truth as the status module — the two can never disagree.

### Complaint path ledger `[S]`
**Where:** New sub-panel at the bottom of 07/BOARD (right column, under the does/doesn't lists), anchor-linked from footer legal as 'Complaints'

**Spec:** Reuses the 03/PROCESS tab-ledger row style: three hairline-separated rows, each 'mono index + step'. '01 — WRITE TO US · complaints@{domain} · acknowledged within 5 business days, resolved within the ECSPR complaints-handling timeframe' (body 400, email in mono). '02 — UNRESOLVED? · Finantsinspektsioon consumer complaint form' + registry-anchor chip 'FI.EE ↗' (live link — filing a complaint with FI is always available, listed or not). '03 — RECORD · every complaint receives a case number ({YYYY}-{NNN}, tabular-nums) and a dated written reply.' Header row: mono microlabel 'COMPLAINTS — ART 7, ECSPR'. No form on-page; mailto link only, so nothing collects data.

**Why:** Publishing the escalation path before anyone has complained is a category signal — regulated firms are required to have one (ECSPR Art 7) and scams never volunteer it. The case-number promise extends the register motif to dispute handling.

**Risk:** Quoting exact response-day counts before internal procedures are approved could bind the firm. Mitigated: '5 business days' is stated as the acknowledgement target only; resolution references the ECSPR timeframe rather than inventing a number — dev ships the copy exactly as specced.

### Outcomes register schema header + genesis line `[S]` — **BUILT**
**Where:** 08/OUTCOMES, restructuring the existing empty-state block

**Spec:** Render the empty register as a real table with its schema visible: header row of mono 10px uppercase column labels — 'DATE · COMPANY · REG CODE · RAISED (EUR) · INVESTORS · SIGNED EXTRACT' — hairline underline, then one full-width empty-state row: centered mono 11px muted 'NO COMPLETED RAISES. THIS REGISTER POPULATES ONLY AFTER FUNDS ARE RETURNED OR SHARES ARE REGISTERED.' Below the table a genesis line, left-aligned mono 11px: 'REGISTER INITIALISED {DD.MM.YYYY} · 0 ENTRIES · APPEND-ONLY' with a muted LED. The SIGNED EXTRACT column is where element 4's verified stamp will live per row — note this in a code comment with a commented-out example row so future population needs zero design decisions. Columns collapse to a stacked kv card under 640px (same pattern as offer cards).

**Why:** Showing the schema of future proof is stronger than hiding an empty section: it commits publicly to WHAT will be disclosed (reg codes, signed extracts) before there is anything to disclose. 'Append-only' imports ledger vocabulary the audience already trusts.

**Risk:** 'APPEND-ONLY' is a promise — breaking it later (deleting a bad outcome) would be worse than never claiming it. Named and accepted: the memory note says outcomes are an empty-state register by design; the mitigation is the genesis line making any future tampering conspicuous, which is the point.

### Nominee registry extract card `[M]`
**Where:** 04/OWNERSHIP, right of (desktop) or below (mobile) the 'One nominee. Clean cap tables.' explainer table

**Spec:** A card styled as a terminal window echoing the hero deal card: titlebar 'E-ÄRIREGISTER · COMPANY RECORD' (mono 10px, hairline bottom border, three 6px hairline circles left as window dots). Body kv rows (mono values, tabular-nums): NAME → 'AureviaFund OÜ'; REGISTRY CODE → '{regcode}' (dev inserts the real code — build must fail loudly if placeholder remains: JS console.error + visible '—' if value starts with '{'); STATUS → 'REGISTERED'; LEGAL FORM → 'Osaühing (OÜ)'; ADDRESS → registered address. Footer row inside the card: registry-anchor chip 'VIEW LIVE RECORD ↗' (element 1, live) + caption mono 10px muted 'EXTRACT REPRODUCED {DD.MM.YYYY} — VERIFY AGAINST THE LIVE REGISTER.' Static data, no fetch (CSP-safe); the reproduce-date makes staleness honest.

**Why:** The nominee is the single entity investors must trust with legal title, so it gets the deepest verification treatment on the page: its actual registry record, mirrored in the same visual dialect as the hero's fictional extract — specimen up top, real record down here, same typography. That rhyme is the whole trust argument of the site.

**Risk:** A stale mirrored extract could diverge from the live register (address change etc.). Mitigated: 'EXTRACT REPRODUCED {date} — VERIFY AGAINST THE LIVE REGISTER' caption plus the live deep link make the page the pointer, not the authority; date bumps ride the element-5 changelog.

## Estonian–EU identity

### Section data-caption rail (coordinate/registry captions per section) `[S]` — **BUILT**
**Where:** Right end of every numbered section header row (00/START through 10/STATUS), same baseline as the mono section index, right-aligned.

**Spec:** Extend the existing section header to a flex row: left `<span class="idx">01 / FOCUS</span>`, right `<span class="cap">…</span>`. `.cap`: ui-monospace, 11px, uppercase, letter-spacing .08em, color var(--muted), tabular-nums, white-space nowrap; hidden below 640px (`display:none`). Fixed caption table (verifiable facts only): 00 START — "EST · EE · EUR · UTC+2"; 01 FOCUS — "MANDATE REF 2020/1503 ART 3"; 02 OFFERS — "REGISTER STATE AS OF 2026-08-05 EET"; 03 PROCESS — "LEDGER 01–05"; 04 OWNERSHIP — "NOMINEE: AUREVIAFUND OÜ"; 05 RAISE — "59°26′14″N 24°45′43″E"; 06 FEES — "EUR 0.00 · TABULATED"; 07 BOARD — "ECSPR ART 25 NOTICES"; 08 OUTCOMES — "RECORDS: 0"; 09 TEAM — "TALLINN, ESTONIA"; 10 STATUS — "AUTHORISATION: PENDING". Dates render once at build time — never live-updating in section captions.

**Why:** Turns every section header into an instrument readout — the 'Estonian digital state' feel comes from registry-style provenance data, not imagery. Reinforces the dated-facts-never-countdowns grammar and gives the mono microlabel system a consistent job across the whole page.

**Risk:** Captions are claims. Every value above is either self-referential (record counts, refs) or static fact; 10/STATUS caption must be updated the day authorisation is granted. No other risk.

### EU-27 dot matrix (passporting motif) `[S]` — **BUILT**
**Where:** Section 05/RAISE, directly under the NON-EU→ESTONIAN OÜ→ECSPR OFFER→EU INVESTORS route diagram, above the skyline SVG.

**Spec:** Inline SVG, viewBox 0 0 540 40: 27 circles r=4, cx spaced 20px, cy=20. 26 circles: fill none, stroke var(--hairline), stroke-width 1. One circle (position 8, alphabetical position of Estonia in the EU-27 list — any fixed position is fine, pick index 8 and keep it) : fill var(--accent), no stroke, plus a 1px hairline ring at r=7 around it. Beneath, a mono microlabel row (11px uppercase, .08em, var(--muted)): "ONE AUTHORISATION · 27 MEMBER STATES · REG (EU) 2020/1503" and a second line in var(--muted): "PASSPORTING AVAILABLE UPON AUTHORISATION. AUTHORISATION PENDING." Hover (desktop only, 150ms border/bg rule): hovering any hollow dot shows a title tooltip with the ISO code (AT, BE, BG…) via native <title> elements — no JS. Under prefers-reduced-motion nothing animates (the dots never animate anyway). Explicitly NOT the EU emblem: no circle arrangement, no 12 stars, no blue field, no gold.

**Why:** Tells the single best structural story of the platform — one Estonian authorisation, 27 markets — in pure geometry that matches the LED-dot grammar. Estonia as the one lit dot is the identity statement without a flag.

**Risk:** Two named risks, both mitigated: (1) EU-emblem misuse — avoided by a linear 27-dot matrix, not a 12-star circle, no emblem colors; (2) implying passporting is live while the chip says AUTHORISATION PENDING — mitigated by the mandatory second caption line, which must ship with the graphic and may not be dropped.

### EET brand tick (timestamp convention + footer clock) `[S]`
**Where:** Convention applied to every timestamp on the page (02/OFFERS card timestamps, 07/BOARD notice feed, fraud-notice date); the clock itself sits in the footer legal row, right-aligned.

**Spec:** Convention: all timestamps become ISO-8601 + EET, ui-monospace tabular-nums: "2026-08-05 14:32 EET". Search-and-replace any other date format on the page. Footer clock: `<span class="eet"><i class="led"></i>TALLINN 14:32:07 EET</span>` — .led is the existing 6px LED dot in var(--accent) with the standard LED pulse; JS `setInterval` 1000ms formats via `Intl.DateTimeFormat('sv-SE',{timeZone:'Europe/Tallinn',hour12:false,…})` and prints "TALLINN HH:MM:SS EET" (label EEST when tz offset is +3; derive from `timeZoneName:'short'`). Under prefers-reduced-motion: interval never starts, LED static, clock shows load-time value without seconds ("TALLINN 14:32 EET"). No external time API — device clock only.

**Why:** Timezone-as-brand: the platform's ground truth is Tallinn time, the way exchanges brand their sessions. One quiet live element that reads as instrumentation, not urgency, and it standardises every date on the page in one pass.

**Risk:** None — device-clock display, clearly a clock, no countdown semantics. Must remain a clock, never a deadline.

### e-ID auth chip component v2 (state-aware, reused 3×) `[M]`
**Where:** (1) existing hero position under the deal card; (2) inside 03/PROCESS Invest tab, step 01 IDENTIFY row; (3) Sign up panel, above the button.

**Spec:** One component: `<span class="eid" data-state="live|planned"><i class="led"></i>SMART-ID</span>`. Chip: 1px hairline border var(--hairline), border-radius 8px, padding 4px 10px, ui-monospace 11px uppercase .08em, color var(--ink). LED 6px: data-state=live → var(--accent) fill; data-state=planned → transparent fill, 1px var(--muted) ring, and chip text color var(--muted). Chips: ID-CARD, SMART-ID, MOBIIL-ID, EIDAS — set each chip's state to match what onboarding will actually support at launch (developer sets from a single JS const EID_STATES object so all 3 placements stay in sync). Below each chip row, one mono microlabel: "AUTHENTICATION METHODS AT LAUNCH · QUALIFIED EID UNDER REG (EU) 910/2014". Hover: border-color transitions to var(--accent) over 150ms, no bg change. In 03/PROCESS the row is prefixed "IDENTIFY WITH —".

**Why:** e-ID vocabulary is the most credible Estonian signal there is for this audience — but only if it never overstates. Making support state machine-readable (one const, three placements) turns the chips from decoration into an honest capability register, on-grammar with LED dots.

**Risk:** Claiming an auth method that isn't integrated = misleading marketing to retail investors. Mitigated structurally: planned methods render visibly muted with a hollow LED, the caption scopes the claim to "at launch", and a single source-of-truth const prevents placement drift. eIDAS reference is a factual regulation citation, not an endorsement claim.

### Skyline micro-silhouette footer divider `[S]` — **BUILT**
**Where:** Footer, replacing the plain top hairline of the legal/footer block (the full-size skyline in 05/RAISE stays).

**Spec:** Reuse the exact same Tallinn skyline SVG path, second instance: height 18px, width 100%, preserveAspectRatio="xMidYMax meet", stroke var(--hairline), stroke-width 1, fill none; the silhouette's baseline continues left and right as a plain 1px hairline to full bleed (draw the hairline as part of the same SVG: `<line>` from x=0 and to x=100% at the baseline y). Directly under it, centered, the coordinates caption in 10px mono var(--muted): "TALLINN · 59°26′14″N 24°45′43″E". No hover, no motion. Dark/light handled automatically by the hairline token.

**Why:** The one custom illustration the system allows, echoed at whisper scale — the divider literally becomes the city's horizon line. Cheap, self-contained (same path reused), and it closes the page on place rather than product.

**Risk:** None — geographic fact, own artwork, no third-party assets.

### ET / EN toggle (mono pill, honest scope) `[M]`
**Where:** Fixed nav, between the AUTHORISATION PENDING chip and the theme toggle.

**Spec:** Pill: 1px hairline border, radius 8px, two segments `<button>ET</button><button>EN</button>`, ui-monospace 11px uppercase, padding 4px 8px each, 1px hairline divider between segments. Active segment: color var(--ink), font-weight 600; inactive: var(--muted). Phase 1 (ship now): toggle switches `document.documentElement.lang` and a data-lang attribute, persisted in localStorage, and translates ONLY the mono microlabel layer + nav + CTAs + risk line via a flat JS dictionary `I18N = {et:{...}, en:{...}}` keyed by data-i18n attributes — body prose stays EN and gets a visible mono note when ET is active: "TÄISVERSIOON EESTI KEELES — TULEKUL. PÕHIDOKUMENDID INGLISE KEELES." placed under the hero sub. The verbatim ECSPR risk warning must render in the selected language using the official ET/EN sentence from the regulation — hardcode both official strings, never machine-translate the risk warning. If the ET dictionary is not ready at build time, do not render the toggle at all (no dead controls).

**Why:** For Estonian retail investors an ET surface is both a trust signal and, eventually, an expectation; a partial-but-honest toggle shows the intent without faking a full translation. The õäöü in TÄISVERSIOON/PÕHIDOKUMENDID doubles as the deliberate Estonian typographic accent in live UI.

**Risk:** Two named: (1) misleading a user into thinking full ET docs exist — mitigated by the visible scope note and EN-labelled documents; (2) the ECSPR risk warning must stay verbatim per language — mitigated by hardcoding the two official regulation texts only. If either mitigation can't be met, ship EN-only and omit the toggle.

### Registry vocabulary strip (Estonian legal terms, glossed) `[S]`
**Where:** Section 04/OWNERSHIP, as a full-bleed hairline-bounded strip directly under the nominee explainer table.

**Spec:** Single row (wraps to 2×2 below 720px), 4 cells separated by 1px vertical hairlines, each cell: Estonian term in ui-monospace 12px uppercase .08em var(--ink) on line 1, EN gloss in 12px regular var(--muted) on line 2. Cells: "OSAÜHING (OÜ) — private limited company" · "ÄRIREGISTER — e-Business Register" · "OSANIKE NIMEKIRI — list of shareholders" · "OSAKAPITAL — share capital". Strip header microlabel above: "REGISTER VOCABULARY — ET/EN". Padding 16px per cell, no radius (full-bleed strip), no hover, no motion. The õ/ä/ü glyphs must render from the system stack — verify SF Pro/Segoe coverage (both cover Estonian; no webfont needed).

**Why:** Shows the platform is native to the Estonian legal layer it operates in — the terms investors will actually meet in extracts and shareholder lists — while teaching non-Estonian founders the vocabulary. Estonian language as substance, not garnish.

**Risk:** None — dictionary-level legal translations; all four glosses are standard official-register English equivalents.

### Dated-facts jurisdiction line (trust strip upgrade) `[S]`
**Where:** Section 10/STATUS, appended as the last row of the existing trust-strip text badges.

**Spec:** One mono line (11px uppercase .08em, var(--muted), tabular-nums), items separated by " · ": "EE — EU MEMBER STATE SINCE 2004-05-01" · "EURO AREA SINCE 2011-01-01" · "ECSPR — REG (EU) 2020/1503, APPLICABLE SINCE 2021-11-10" · "SUPERVISOR: FINANTSINSPEKTSIOON". Wraps naturally; on wrap each item stays intact (wrap at the · separators via wrapping spans). No links except SUPERVISOR, which may link to fi.ee with the standard hover. No motion.

**Why:** This is the 'EU regulated market' half of the identity done in the house grammar: membership and regulation as dated facts in tabular mono, zero adjectives. Also quietly corrects the jurisdiction story (Finantsinspektsioon, not FIU) on-page.

**Risk:** All four are verifiable public facts. Naming Finantsinspektsioon as supervisor is accurate for ECSPR authorisation but must not imply current endorsement — keep it inside the STATUS section where AUTHORISATION PENDING is stated, and never pair it with the word 'approved'.

### Founder-card coordinate captions `[S]`
**Where:** Section 09/FOUNDING TEAM, bottom row of each of the two founder cards, replacing any tagline text.

**Spec:** Under name/role/LinkedIn in each card, a hairline-topped footer row: left, mono 10px uppercase var(--muted) "BASED — TALLINN, EE"; right, tabular-nums mono "59.437°N 24.754°E". If a founder is based elsewhere, use that city's real coordinates — never fake Tallinn. Padding 10px 16px, no hover, no motion.

**Why:** Extends the coordinates caption system from the skyline to people, making the team legible in the same instrument language as the rest of the page — location as data, not biography fluff.

**Risk:** Only accuracy: coordinates must match each founder's actual stated base. No other risk.

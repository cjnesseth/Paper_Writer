# Implementation Plan: Revision to Shapiro Price-Cap Framing

**Status:** APPROVED
**Date:** 2026-03-28
**New title:** "Capping the Capacity Market: A Supply Function Equilibrium Analysis of Price Controls in PJM"
**Revision type:** Major reframe — "SFE identifies market power" → "SFE provides counterfactual prices to evaluate Shapiro price-cap intervention"

---

## Key Facts (from source documents)

### Shapiro press release (PA.gov, January 28, 2025)
- Complaint filed December 30, 2024 against PJM Tariff
- 2025/26 BRA cost $14.7B — "over 800% increase from prior year"
- 65 million consumers across 13 PJM states, including 13 million Pennsylvanians
- Shapiro's stated counterfactual: "over $500/MW-Day" — this is the **unconstrained VRR Point(a) price** under dual-fuel CT reference technology, not a strategic equilibrium price
- Agreement announced January 28, 2025; lowers cap "from over $500/MW-Day to $325/MW-Day"

### PJM consultation slides (February 7, 2025, Special MC/TOA-AC)
- **Legal theory of complaint**: "price cap on the demand curve is **too high given lower expectation for new entry in the near-term**" — this is an investment-adequacy argument, not a market-conduct argument
- Proposed remedy in complaint: lower cap to **1.5 × Net CONE**, remove reliance on Gross CONE
- **Settlement terms**: cap ~$325/MW-day UCAP, floor ~$175/MW-day UCAP (ICAP equivalents: $256.75/$138.25 at 79% dual-fuel CT accreditation)
- Settlement **reshapes the VRR curve**: flat top at $325 (not just a cap overlay), existing slope between $325 and $175, flat bottom at $175 clearing all available supply
- Applied to **all LDA demand curves**, not just RTO
- CETL limitations still apply under settlement
- Timeline: complaint Dec 30, 2024 → settlement Jan 28, 2025 → PJM filing target Feb 14, 2025 → 2026/27 auction July 2025 → 2027/28 auction December 2025

### Critical analytical implication
The $500+ counterfactual in Shapiro's "$21 billion" claim refers to the **VRR Point(a) unconstrained price** (gray dashed curve in PJM slides reaching ~$500 at low quantities), not any strategic equilibrium. This means the $21B calculation compares the settlement-modified curve outcome (~$325) to the original curve outcome (~$500). Our SFE model provides a third number: $p^*$ under strategic bidding against the settlement-modified curve. This is the paper's key analytical contribution.

---

## Decisions Resolved

1. **Cap level**: $325 UCAP confirmed; $175 UCAP floor is substantive and should be analyzed
2. **Literature**: Retained as standalone section (§2), adding §2.5 on price controls in oligopolistic markets
3. **`discussion.tex`**: Deleted (not just retired from `\input`)
4. **Lerner notation**: Retain symbol $L$ and equation labels throughout; change narrative text to "price-cost margin" at first use with "(Lerner index)" parenthetical; update table/figure labels to "Price-Cost Margin" — see §2 below
5. **$21B sourcing**: Use PA.gov press release (January 28, 2025) as primary citation; cross-reference PJM slides for the $500+ VRR counterfactual

---

## Lerner Notation Decision

**Keep:** Mathematical symbol $L$, `\label{eq:lerner}`, `\ref{eq:lerner}`, all equation references, ODE variable names.

**Change in narrative only:**
- First narrative use per section: "price-cost margin $L = (p^* - c)/p^*$ (Lerner index)"
- Subsequent uses: "price-cost margin" or simply $L$
- Table column headers: "Price-Cost Margin $L$"
- Figure axis labels: "Price-Cost Margin"
- Remove: standalone "Lerner index" as a noun without mathematical context

**Rationale**: The symbol is standard in industrial organization and its mathematical definition is unchanged. The reframing is about interpretation (descriptive markup measure vs. welfare indicator), not about notation.

---

## Statistical Tests: What Changes

**No substantive statistical edits required.** The RSI and TPS tests are market structure diagnostics — their methodology and results are unchanged. Only framing changes:

| Current language | Revised language |
|---|---|
| `RSI$_3$ as the **identifying criterion**` (calibration.tex:141) | `RSI$_3$ as the **calibration criterion**` |
| "clean counterfactual for the cost of mitigation inaction" (calibration.tex:203) | "benchmark for interior equilibrium outcomes prior to the settlement" |
| "no evidence of strategic withholding" (calibration.tex:118) | "equilibrium consistent with competitive pricing at low capacity margins" |

**Why these are minor:** RSI < 1 and TPS outcomes are retained as structural facts motivating K=3. They show that three sellers are collectively pivotal — the premise for running the SFE. The word "identifies" (calibration.tex:141) conflates statistical identification with PJM's colloquial use; "calibration criterion" is more precise and consistent with the revised framing. No new tests, no deleted tests, no recalculations.

---

## New Section Map (old → new)

| New § | New title | Source | Action |
|---|---|---|---|
| 1 | Introduction | `introduction.tex` | Full rewrite |
| 2 | Literature | `literature.tex` | Write prose + add §2.5 price-cap lit |
| 3 | Institutional Background | `institutional.tex` | Add §3.6 Shapiro settlement; edit §3.4 fwd ref |
| 4 | SFE Framework | `model.tex` | Language edits only |
| 5 | Calibration | `calibration.tex` | Complete stubs + reframe statistical language |
| 6 | Results: Equilibrium Prices vs. the Settlement | `results.tex` | Restructure + add settlement comparison |
| 7 | The Allocative Cost of Price Controls | NEW `sec6_allocative_cost.tex` | ~1,200 words |
| 8 | Evaluating the Lead-Time Argument | NEW `sec7_leadtime.tex` | ~900 words |
| 9 | Evaluating the $21 Billion Claim | NEW `sec8_21billion.tex` | ~800 words |
| 10 | Policy Alternatives | NEW `sec9_policy_alternatives.tex` | ~900 words |
| 11 | Conclusion | `conclusion.tex` | Full rewrite |

---

## Phase-by-Phase Plan

### Phase 1 — Bibliography + `main.tex` Scaffold

**1A. `Bibliography_base.bib` — add entries:**
```
@misc{Shapiro2025_press_release,  % PA.gov Jan 28, 2025 press release }
@misc{PJM2025_settlement_slides,  % PJM Feb 7, 2025 MC/TOA-AC consultation slides }
@article{Hayek1945_knowledge,     % AER 35(4):519–530 }
@article{Weitzman1974_prices,     % RES 41(4):477–491 }
@article{GlaeserLuttmer2003_rent, % AER 93(4):1027–1046 }
```
Note: `Vossler2009_price_caps` already in bib; confirm key.

**1B. `Paper/main.tex` changes:**
- New title
- Create stub files for §§7–10 (empty, just `\section` + `\label`)
- Update `\input` sequence
- Abstract placeholder (written in Phase 6)

**1C. Delete `discussion.tex`**

**Verification:** Dry-run 3-pass compile with stubs — zero structural errors.

---

### Phase 2 — Language Substitution Pass (all existing sections)

**Systematic replacements:**

| Old | New | Scope |
|---|---|---|
| "market power" | "equilibrium markup" / "strategic pricing" | Narrative; preserve PJM institutional uses |
| "Lerner index" (standalone noun) | "price-cost margin" (with parenthetical at first use) | Narrative only; keep $L$ in math |
| "structurally identifies" | "is consistent with" | ~3 instances |
| "RSI$_3$ as the identifying criterion" | "RSI$_3$ as the calibration criterion" | calibration.tex:141 |
| "counterfactual for the cost of mitigation inaction" | "benchmark for interior equilibrium prior to the settlement" | calibration.tex:203 |
| "no evidence of strategic withholding" | "equilibrium consistent with competitive pricing" | calibration.tex:118 |
| Normative welfare loss language | Neutral phrasing | Various |

**Verification:** Grep for "market power" → only PJM institutional uses; grep "structurally identifies" → zero hits.

---

### Phase 3 — Revisions to Existing Sections

#### 3A. `introduction.tex` — Full Rewrite (~700 words)

New paragraph structure:
1. **Hook**: Dec 30, 2024 — Governor Shapiro files FERC complaint against PJM Tariff alleging VRR cap "too high given lower expectation for new entry in the near-term." Agreement reached Jan 28, 2025: cap at $325/MW-day UCAP, floor at $175/MW-day UCAP, applied for 2026/27 and 2027/28 BRAs.
2. **Policy question**: The settlement modifies the demand curve used in PJM's capacity auctions. What price would these auctions clear at absent the modification, and what are the consequences of suppressing prices to $325?
3. **Our approach**: SFE counterfactual. Note the two-tier structure: existing VRR Point(a) cap (part of market design since 2007) vs. the Shapiro settlement cap (political intervention). Our model provides $p^*$ — the equilibrium under the unmodified VRR curve — against which to evaluate the settlement.
4. **Four findings** (reframed with "consistent with" language):
   - Under K=3, the at-cap outcome in 2026/27 is consistent with strategic equilibrium — the settlement is binding
   - The settlement's $175 floor has a distinct economic function (investment adequacy floor vs. revenue cap)
   - The $500+ counterfactual in Shapiro's $21B claim is the unconstrained VRR price, not a strategic equilibrium; our SFE provides a third, structural estimate
   - Transmission expansion (CETL) shifts LDAs from cap-binding to interior-clearing regimes organically
5. **Road map**: 11 sections.

#### 3B. `institutional.tex` — Add §3.6 + Edit §3.4

**New §3.6** (~500 words): "The Shapiro Settlement: A Modified Demand Curve for 2026/27 and 2027/28"
- Dec 30, 2024 complaint: legal theory is investment-adequacy, not conduct — cap "too high given lower expectation for new entry in near-term"
- Original proposed remedy: 1.5 × Net CONE cap
- Settlement (Jan 28, 2025): cap ~$325/MW-day UCAP, floor ~$175/MW-day UCAP (ICAP: $256.75/$138.25 at 79% accreditation)
- **VRR curve mechanism**: settlement doesn't impose an external overlay — it replaces the demand curve shape with flat top at $325, existing slope in middle, flat bottom at $175 clearing all sub-$175 supply (PJM Feb 7, 2025 slides)
- Applied to all LDA curves; CETL limitations still apply
- PJM's own characterization: "protects consumers via lower price cap AND suppliers by setting a price floor" — this two-sided mechanism is important
- The $175 floor sets a price above Net CONE (~$212–$243 in revision instructions — check against actual data), intended to "support near-term investment" per PJM
- Subject to FERC approval under FPA §205 filing

**Edit §3.4** (Lead-Time Irregularity): update forward reference to point to §8 (lead-time evaluation section).

#### 3C. `model.tex` — Language Edits Only

- Lines 282–283: "primary measure of market power" → "primary measure of strategic markup"
- First narrative use of "Lerner index" → "price-cost margin $L$ (Lerner index)"
- No structural changes

#### 3D. `calibration.tex` — Complete Stubs + Statistical Reframing

Three stubs to write (§4.3 Market Structure, §4.4 Cost Parameters, §4.5 Benchmark Years) — same content as originally planned.

Statistical language edits (per Phase 2 list above).

Add to §4.5 Benchmark Years: note that 2026/27 is the first year where the Shapiro settlement applies; the SFE simulation treats the **unmodified** VRR curve as the counterfactual demand curve. The settlement-modified curve (truncated at $325/$175) is the policy intervention whose effects we analyze in §§6–9.

#### 3E. `results.tex` — Restructure + Settlement Comparison

- Rename section: "Results: Equilibrium Prices vs. the Shapiro Settlement"
- **Revise `tab_baseline`**: rename column from "Lerner index $L$" to "Price-Cost Margin $L$"; add column "$\bar{p}_S$ (Settlement Cap)" = $325 for 2026/27 and 2027/28, N/A for 2023/24
- Add paragraph after `tab_baseline`: the settlement cap is binding in 2026/27 ($p^* = \$329 > \$325$) and would be binding in 2027/28 under similar structural conditions. In 2023/24, the cap is non-binding ($p^* = \$330$ but this is the old VRR design; the settlement doesn't apply). The $175 floor clears all supply offered below $175 — under K=3, this effectively procures the full reliability requirement at above-competitive prices.
- Reframe K comparative static (§5.3 regime classification): at K ≤ 3, settlement cap is binding; at K ≥ 4, settlement cap may be slack (interior clearing below $325 possible). The observed at-cap 2026/27 outcome is consistent with K ≤ 3.
- Retain CETL analysis but reframe: CETL expansion shifts LDAs from cap-binding to interior regime, achieving price reduction organically without suppressing scarcity signals.

---

### Phase 4 — Four New Sections

#### 4A. NEW `sections/sec6_allocative_cost.tex` (~1,200 words)
**Title:** "The Allocative Cost of Price Controls"

Structure:
1. **Frame**: The settlement imposes a hard cap on the demand curve. When the SFE equilibrium falls above the cap, the settlement is binding and changes market outcomes. The question is whether binding the cap improves welfare or creates misallocation.
2. **SFE counterfactual vs. settlement**: $p^*$ (strategic equilibrium against unmodified VRR) vs. $\bar{p}_S = \$325$ (settlement cap). Our results show $p^* > \$325$ in cap-binding years. This does not mean $p^*$ is "too high" — it is where strategic equilibrium falls given the market structure. The settlement shifts the outcome from $p^*$ to $\bar{p}_S$.
3. **What the settlement changes**: revenue transfer per MW-year from sellers to buyers; implied change in investment return for a marginal entrant (compare settlement clearing price to Net CONE). Note that PJM itself argues the floor at $175 "supports near-term investment" — PJM's own framing acknowledges the investment distortion risk of the cap side.
4. **The floor's distinct role**: The $175 floor is not symmetric to the cap. It guarantees revenue to sub-$175 suppliers regardless of market outcomes. This is an investment adequacy mechanism — consistent with the missing money literature (Joskow, Cramton-Stoft). Analyze whether $175 > Net CONE (if so, the floor is above the competitive investment threshold, which is an implicit subsidy).
5. **Misallocation logic** (Glaeser-Luttmer applied): cap below strategic equilibrium reduces signal to new entrants; floor above competitive level keeps marginal plants online. The settlement is a price band, not a competitive equilibrium.
6. **Quantification**: Use `tab_baseline` numbers to compute revenue transfer per MW-year for 2026/27 and 2027/28.

**New table:** `tab_cap_comparison` — VRR Point(a) cap, Shapiro settlement cap ($325), SFE $p^*$, settlement floor ($175), Net CONE, gap ($p^* - \$325$), implied revenue transfer per MW-year.

#### 4B. NEW `sections/sec7_leadtime.tex` (~900 words)
**Title:** "Evaluating the Lead-Time Argument"

Structure:
1. **The legal theory**: Shapiro's complaint argues the VRR cap is "too high given the lower expectation for new entry in the near-term." This is an implicit lead-time argument: if new entry cannot respond to high prices within the procurement horizon, then high prices provide no supply-side benefit and represent pure transfers.
2. **PJM's lead-time record**: Reference Table from §3 (0.8-month vs. 36-month design intent). The 2024/25 BRA was a spot auction; 2026/27 has ~10 months lead time.
3. **What the SFE model says**: The model is static and takes capacity endowments as given. It does not model entry response. The price $p^*$ is the clearing price under strategic bidding given current endowments — it is the revenue that existing capacity earns, not the return required to justify new construction.
4. **The argument misunderstands price functions** (five channels from revision instructions): expectations for future periods, retirement margin, mobile resources (DR, storage, imports), contracting and hedging behavior, information revelation.
5. **Hayek (1945)**: prices aggregate dispersed private information; capping them suppresses information regardless of lead time.
6. **The correct response**: restore auction timing (which PJM is pursuing per slides — 2026/27 in July 2025, 2027/28 in December 2025). The settlement applies even as lead times are partially restored.
7. **Empirical check** (where available): any evidence of supply-side response to 2025/26 price spike (deferred retirements, DR registrations, storage deployment)?

#### 4C. NEW `sections/sec8_21billion.tex` (~800 words)
**Title:** "Evaluating the \$21 Billion Claim"

Structure:
1. **The claim**: PA.gov press release (Jan 28, 2025) states the settlement will "save consumers over \$21 billion over the next two years." The implied calculation is: (counterfactual price $-$ \$325) $\times$ quantity $\times$ 2 delivery years.
2. **The counterfactual price**: Shapiro's stated counterfactual is "over \$500/MW-Day." PJM's own slides show the gray dashed VRR curve (under dual-fuel CT reference technology) reaching ~\$500 at the reliability requirement quantity. This is the **VRR Point(a) price** under the original tariff — not a strategic equilibrium price. The settlement lowers this to \$325.
3. **Three counterfactuals compared**:
   - **PJM tariff baseline** (~\$500 UCAP): VRR Point(a) price under dual-fuel CT — Shapiro's assumed counterfactual
   - **SFE equilibrium** ($p^*$, K=3): strategic equilibrium under unmodified VRR — our model's counterfactual
   - **Competitive equilibrium** (~\$150 ACR): perfectly competitive outcome — the theoretical lower bound

   The \$21B calculation uses counterfactual (1). Our SFE model provides counterfactual (2), which is lower than (1) because strategic equilibrium falls inside the VRR curve (below Point(a) in interior years). The settlement is more binding against counterfactual (1) than against counterfactual (2).

4. **Three-scenario sensitivity table**: using existing model outputs, compute revenue transfer under each counterfactual for 2026/27 and 2027/28.

5. **The quantity assumption**: \$21B holds quantity fixed at the reliability requirement (perfectly inelastic supply). PJM's settlement slides acknowledge the floor is designed to "support near-term investment" — implicitly acknowledging that supply is not perfectly inelastic and that the cap may reduce future supply. A correct calculation should account for supply response.

6. **Correct interpretation**: \$21B is an upper bound using the VRR-curve counterfactual with perfectly inelastic supply. Using the SFE counterfactual gives a lower bound on the settlement's direct price effect; accounting for supply response reduces the "savings" further.

**New table:** `tab_21billion` — three-scenario revenue transfer (VRR baseline, SFE, competitive) for 2026/27 and 2027/28.

#### 4D. NEW `sections/sec9_policy_alternatives.tex` (~900 words)
**Title:** "Policy Alternatives"

Structure (adapts and extends original `discussion.tex` §2):
1. **Frame**: Four structural levers exist to address high capacity prices without suppressing equilibrium price signals.
2. **Option 1 — The Shapiro settlement (current policy)**: Reshapes demand curve, binding for 2026/27 and 2027/28. PJM itself characterizes this as a "two-year compromise." Achieves immediate price reduction; does not address structural source of high prices; creates investment adequacy concerns (partially mitigated by floor).
3. **Option 2 — CETL expansion**: CETL results from §6.4–6.5; 10pp CETL expansion → ~5pp price-cost margin reduction. Organic price reduction by expanding competition; preserves scarcity signals; structural rather than temporary.
4. **Option 3 — VRR curve redesign**: The ER25-1357 redesign (referenced in existing results) moves toward a steeper demand curve. Effects on equilibrium prices via ODE mechanism.
5. **Option 4 — Entry promotion / deconcentration**: K comparative static shows K ≥ 7 produces near-competitive outcomes. Policy levers: interconnection queue reform, permitting streamlining, storage incentives.
6. **Ranking**: Structural options (2–4) address causes; Option 1 addresses symptoms. Option 1 is justified as emergency measure during lead-time compression; Options 2–4 are durable. Note that PJM's own settlement framing calls for "reform the capacity market" alongside the cap — consistent with this ranking.

---

### Phase 5 — Conclusion and Abstract Rewrite

#### 5A. `conclusion.tex` — Full Rewrite (~450 words)

Restate as: evaluating a specific policy intervention (Shapiro settlement) using a structural counterfactual (SFE).

Five-finding summary:
1. Settlement is binding: SFE $p^*$ > \$325 in constrained conditions
2. Settlement modifies the demand curve — floor at \$175 as investment adequacy mechanism
3. The $21B claim uses the VRR-curve counterfactual; SFE provides a lower (structural) estimate
4. Lead-time argument misunderstands price functions; correct response is schedule restoration
5. CETL expansion and entry promotion dominate price controls as durable structural remedies

#### 5B. `main.tex` — New Abstract (~160 words)

Use abstract from revision instructions document, updated to reflect:
- "Settlement" rather than just "cap" (since the instrument is a cap+floor reshaping the VRR curve)
- The floor at \$175 as a distinct element
- The VRR-curve vs. SFE counterfactual distinction in the \$21B analysis

---

### Phase 6 — Literature Section Prose

Write prose for 5 existing skeleton subsections (~250 words each) + new §2.5:

**New §2.5: Price Controls in Oligopolistic Markets** (~350 words):
- Weitzman (1974): prices vs. quantities as regulatory instruments
- Glaeser-Luttmer (2003): misallocation under binding price controls applied to capacity investment
- Anderson-Philpott (2005) on SFE with price caps: caps change boundary condition, not strategic incentive structure
- Vossler (2009): focal point clustering at cap in uniform-price auctions
- Cramton-Stoft (2005, 2007): missing money problem as motivation for capacity markets — the settlement risks recreating the problem it was designed to solve

Total literature: ~1,800 words.

---

### Phase 7 — Quality Assurance

**7A. Global checks:**
- Grep "market power" → only PJM institutional uses remain
- Grep "Lerner index" → only parenthetical first-use instances remain
- Grep "structurally identifies" → zero hits
- Grep "identifying criterion" (calibration.tex) → replaced with "calibration criterion"
- Grep "mitigation inaction" → replaced
- Check all `\ref{sec:discussion}` → retired; replace with specific new section refs
- Check all forward refs in §§1–5 for new section numbering (§§6–8 shifted to §§7–10)
- Check all undefined `\cite` keys

**7B. Table verification:**
- `tab_baseline`: new column "$\bar{p}_S$" values match settlement terms
- `tab_cap_comparison`: revenue transfer numbers checkable from `tab_baseline`
- `tab_21billion`: three-scenario numbers consistent across scenarios

**7C. Full 3-pass compile:**
```bash
cd /home/chris/projects/Paper_Writer/Paper
TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex
BIBINPUTS=..:$BIBINPUTS bibtex main
TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex
```

**7D. Quality score target:** ≥90/100

---

## Files Summary

### Files to Modify
| File | Scope |
|---|---|
| `Paper/main.tex` | Title, abstract, `\input` list |
| `Bibliography_base.bib` | Add 5 entries |
| `Paper/sections/introduction.tex` | Full rewrite |
| `Paper/sections/institutional.tex` | Add §3.6 settlement subsection; edit §3.4 fwd ref |
| `Paper/sections/model.tex` | Language substitution only |
| `Paper/sections/calibration.tex` | Complete 3 stubs; reframe statistical language |
| `Paper/sections/results.tex` | Add settlement cap column; add §6.1 paragraph; rename section |
| `Paper/sections/literature.tex` | Write prose + add §2.5 |
| `Paper/sections/conclusion.tex` | Full rewrite |

### Files to Create (new)
| File | Section | ~Words |
|---|---|---|
| `Paper/sections/sec6_allocative_cost.tex` | §7 | 1,200 |
| `Paper/sections/sec7_leadtime.tex` | §8 | 900 |
| `Paper/sections/sec8_21billion.tex` | §9 | 800 |
| `Paper/sections/sec9_policy_alternatives.tex` | §10 | 900 |
| `Paper/tables/tab_cap_comparison.tex` | §7 table | — |
| `Paper/tables/tab_21billion.tex` | §9 table | — |

### Files to Delete
| File | Reason |
|---|---|
| `Paper/sections/discussion.tex` | Disaggregated into §§7–10; no longer needed |

---

## Session Order

| Session | Phases | Key deliverables |
|---|---|---|
| 1 | Phase 1 (bib + scaffold) + delete `discussion.tex` | Compiling paper skeleton with 11 sections |
| 2 | Phase 2 (language substitution) + Phase 3C + 3D | Clean language throughout; calibration stubs written |
| 3 | Phase 3A + 3B + 3E | New introduction; institutional §3.6; results restructured |
| 4 | Phase 4A + 4B | New §§7–8 (allocative cost, lead-time) |
| 5 | Phase 4C + 4D | New §§9–10 ($21B, policy alternatives) |
| 6 | Phase 5 + Phase 6 | Conclusion, abstract, literature prose |
| 7 | Phase 7 (QA + compile) | Clean compile; quality score ≥ 90 |

**Total estimated:** 19–26 hours across 7 sessions.

---

## Risk Register

| Risk | Mitigation |
|---|---|
| `\ref{sec:discussion}` appears in multiple sections | Phase 7A grep; fix before compile |
| UCAP vs. ICAP confusion in tables (settlement values are UCAP, existing tables may be mixed) | Confirm unit labels in `tab_baseline` and `tab_cap_comparison` — add explicit "UCAP" notation |
| $175 floor > Net CONE claim needs verification against actual Net CONE data | Pull Net CONE from calibration data before writing §4A |
| New bib entries may conflict with existing keys | Follow `AuthorYYYY_shortname` convention; grep bib before adding |
| Forward references in introduction break when sections renumbered | Write road map last; use `\ref{}` not hard-coded numbers |

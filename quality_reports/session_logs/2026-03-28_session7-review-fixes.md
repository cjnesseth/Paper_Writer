# Session Log: Session 7 — Literature Prose + HHI Axis + Review Fixes
**Date:** 2026-03-28
**Branch:** PJM-Paper

## Goal
Complete literature §2.3–2.4, add HHI secondary axis to fig02b, run proofread + domain review agents, apply all critical/major fixes.

## Work Done

### literature.tex §2.3–2.4 (~500 words)
- §2.3: California simulation tradition (Borenstein/Bushnell/Wolak) → British empirical tests
  (Wolfram 1999, Sweeting 2007) → vertical contracting (Bushnell et al. 2008)
- §2.4: Baker-Bresnahan residual demand → VRR IS the administratively-observed residual
  demand curve, turning econometric estimation into a calibration exercise

### fig02b HHI secondary axis
- Added `sec_axis(transform = ~10000/.x)` to K-axis in p_cs2b
- Fixed deprecated `trans` → `transform` argument
- Regenerated fig02b_K_lerner.pdf with dual x-axis (K bottom, HHI top)

### Proofread fixes (5 high, 6 medium, 3 low)
- H1: "RTO RTO" → "RTO"
- H2: RSI₃ year order corrected (2025/26=0.62, 2026/27=0.64)
- H3: Wrong citation Holmberg2008 → Anderson2008_sfe_asymmetric in limitations
- H4: Introduction roadmap order corrected (§2 literature before §3 institutional)
- H5: K→∞ limit reference corrected from prop:holmberg → eq:sfe_ode
- M: 6× missing space after \textit{Notes:} in figure captions
- M: "by" → "under" standard antitrust benchmarks
- M: "see footnote" → "(see footnote above)"
- L: "develops" → "develop" (parallel construction)
- L: "reduce K below three" → "reduce K to fewer than three"
- L: "a Lerner" → "a Lerner index"

### Domain review fixes (6 major confirmed genuine)
- M2 (ODE interpretation): Rewrote s(p)/(p-c) interpretation — was inverted; now describes
  markup-boundary feedback enforcing lower boundary of supply function
- M1 (Holmberg deterministic vs stochastic): Added footnote acknowledging that deterministic
  BRA setting imposes boundary condition as selection criterion motivated by Holmberg's result
- M3 (K identification): Clarified that RSI₃<1 establishes K≤3; 2026/27 at-cap rules out K≥4;
  TPS test individual pivotality supports K=3 over K=2
- M4 (Cournot label): "evaluated at residual demand" → "market demand (=residual in symmetric case)"
- M6 (Anderson-Xu): Separated from Allaz-Vila; now describes existence conditions only
- M7 (order of magnitude): Removed unsubstantiated claim; replaced with "HHI cannot quantify"

### Apparent blocking issue B1 ruled out
- Domain reviewer flagged mw_cleared as potentially using cleared qty instead of total available
- Verified: mw_cleared = reliability_req × (1 + capacity_margin) = total available capacity
  (exact match for all three benchmark years)
- Added code comment to 04_calibrate.R explaining the column name is misleading
- Fixed DATA_PATH to use .here (minor robustness fix)

## Verification
- 3-pass LaTeX + BibTeX: clean, 49 pages, no undefined references
- Quality score: 100/100 (EXCELLENCE)

## Next Session (Session 8)
- Final proofread pass if any issues remain from this session
- Address minor domain review items: m3 (2023/24 "no strategic withholding" wording),
  m4 (fringe cost footnote), m5 (table decimal precision)
- PR to main

---

## Major Redirection: Shapiro Reframe (Sessions 1-2 of new revision arc)

**Date:** 2026-03-28 (same day, new work)
**New direction:** Revise paper around Shapiro FERC settlement as policy motivation.

### Session R1 (scaffold)
- New title: "Capping the Capacity Market: A Supply Function Equilibrium Analysis of Price Controls in PJM"
- Added 5 bib entries: Shapiro2025_press_release, PJM2025_settlement_slides, Hayek1945_knowledge, Weitzman1974_prices, GlaeserLuttmer2003_rent
- Scaffolded 4 new section stubs: sec6_allocative_cost, sec7_leadtime, sec8_21billion, sec9_policy_alternatives
- Deleted discussion.tex (content to be disaggregated into new §§7-10)
- Updated main.tex \input sequence; abstract placeholder inserted
- Revision plan saved: quality_reports/plans/2026-03-28_revision_shapiro_reframe.md
- Supporting sources added: Shapiro_Rationale.pdf, PJM settlement slides PDF

### Session R2 (language substitution + calibration)
- Systematic language pass across all existing sections:
  - "market power" → "strategic pricing/markup" (preserved PJM institutional uses)
  - "Lerner index" → "price-cost margin (Lerner index)" at first use; symbol L retained
  - "structurally identifies" → "is consistent with"
  - "identifying criterion" (calibration) → "calibration criterion"
  - "cost of mitigation inaction" → "baseline interior equilibrium"
  - Figure/table captions updated: "Lerner Index" → "Price-Cost Margin" throughout
- Calibration status updated: all §§4.3-4.5 confirmed complete from prior sessions
- Added Shapiro settlement robustness note to §4.5 linking benchmark years to binding/non-binding regimes
- Commit b53697b pushed to PJM-Paper

### Key design decisions recorded in plan
- Complaint legal theory: "VRR cap too high given lower expectation for new entry" (not market power)
- Shapiro's $500 counterfactual = unconstrained VRR Point(a) price, not strategic equilibrium
- Settlement reshapes entire VRR curve (flat top $325, existing slope, flat bottom $175)
- $175 floor is investment-adequacy mechanism; PJM itself calls it "supporting near-term investment"
- Statistical tests (RSI, TPS) unchanged substantively — framing only

### Remaining sessions
- Session R3: Introduction rewrite, institutional §3.6 Shapiro subsection, results restructure
- Session R4: New §§7-8 (Allocative Cost, Lead-Time)
- Session R5: New §§9-10 ($21B claim, Policy Alternatives)
- Session R6: Conclusion + abstract rewrite; literature prose
- Session R7: QA + compile + quality score ≥ 90

---

### Session R3 — COMPLETED

**3A (introduction.tex):** Full 5-paragraph rewrite — hook (complaint/settlement), two-cap distinction ($\bar{p}$ vs $\bar{p}_S$), SFE-as-counterfactual framing, 4 findings, 11-section road map.

**3B (institutional.tex):** Added §3.4 forward ref to sec:leadtime; added §3.6 "The Shapiro Settlement" (~500 words) covering complaint legal theory, settlement terms ($325/$175 UCAP), VRR curve mechanism, two-cap notation.

**3E (results.tex):** Section renamed to "Results: Equilibrium Prices vs.\ the Shapiro Settlement"; added $\bar{p}_S$ column to tab_baseline (N/A for 2023/24 and 2025/26, \$325 for 2026/27); added settlement-binding paragraph after table noting $p^* = \$329 > \$325$ at RTO level, larger gaps in LDAs, forward refs to §§5.5 and 8.

**Verification:** 3-pass LaTeX clean, 50 pages.

### Session R4 — COMPLETED

**sec6_allocative_cost.tex (~1,200 words):** "The Allocative Cost of Price Controls"
- §6.1: tab_cap_comparison table — $\bar{p}$, $\bar{p}_S$, $p^*$, Net CONE, floor, binding gap for 2026/27 ($4.17) and 2027/28 ($8.44)
- §6.2: Entry distortion — cap suppresses Hayek price signal; Anderson2005_sfe_pricecaps on SFE cap effects
- §6.3: Floor's distinct role — investment adequacy mechanism; $175 < Net CONE at RTO ($212.14) but > Net CONE in SWMAAC ($171.02)
- §6.4: Glaeser-Luttmer misallocation — price band ($175–$325) is non-competitive in $K=3$ regime

**sec7_leadtime.tex (~900 words):** "Evaluating the Lead-Time Argument"
- §7.1: Legal theory — investment-adequacy claim, not market conduct
- §7.2: Lead-time record — 0.8 months (2024/25) vs. 10.2 months (2026/27) vs. 16.8 months (2027/28)
- §7.3: Five channels — retirement deterrence, mobile resources, contracting, regulatory signaling, forward expectations
- §7.4: Hayek (1945) + Weitzman (1974) — price suppression destroys information; schedule restoration is the correct remedy

**Verification:** 3-pass LaTeX + BibTeX clean, 59 pages, zero undefined references.

### Session R5 — COMPLETED

**sec8_21billion.tex (~800 words):** "Evaluating the \$21~Billion Claim"
- §8.1: Shapiro's VRR counterfactual ($500) explained vs. SFE structural alternative
- §8.2: tab_21billion — 3-scenario comparison (VRR $17.16B, SFE $0.61B, competitive reversed); gap explained by LDA effects
- §8.3: Quantity assumption — fixed quantity is upper bound; supply response further reduces true savings

**sec9_policy_alternatives.tex (~900 words):** "Policy Alternatives"
- §9.1: Settlement as current policy — temporary, preserves no price signal, zero markup reduction
- §9.2: CETL expansion — 30% fringe → -24pp margin; 10pp CETL → 4-6pp margin; organic, signal-preserving
- §9.3: VRR redesign — slope factor ≥1.4 shifts 2026/27 to interior clearing even at K=3
- §9.4: Entry/deconcentration — K=4 → $228 in 2026/27; 3 levers: interconnection reform, DR/storage, targeted mitigation
- §9.5: tab_policy_comparison — 4 options ranked on mechanism, duration, signal, regulatory lever

**Verification:** 3-pass LaTeX + BibTeX clean, 68 pages, zero errors.

### Session R6 — COMPLETED

**conclusion.tex (full rewrite, ~600 words):** Five-finding structure aligned to settlement evaluation
1. Settlement binding: p*=$329 > $325; price-cost margin unchanged at 0.54
2. Demand curve modification: $175 floor below Net CONE ($212); price band neither competitive nor strategic equilibrium
3. $21B uses wrong counterfactual: VRR ~$17.2B vs SFE ~$612M (35× gap); LDA effects explain remainder
4. Lead-time argument partial: 5 channels active at 10.2-month horizon; schedule restoration is correct remedy
5. Structural alternatives dominate: CETL, VRR redesign, entry promotion preserve price signal permanently

**main.tex abstract (~170 words):** Replaced TODO placeholder with polished abstract covering settlement terms, structural model, binding gap, $612M SFE estimate, lead-time partial defense, CETL organic remedy

**literature.tex §2.5 (~400 words):** "Price Controls in Oligopolistic Markets"
- Weitzman (1974): prices vs. quantities in inelastic-supply setting
- Glaeser-Luttmer (2003): dynamic misallocation from binding caps
- Anderson2005_sfe_pricecaps: caps modify ODE boundary condition throughout, not just at ceiling
- Vossler (2009): floor as potential focal point for future auctions
- Cramton-Stoft (2005): cap recreates missing money problem the market was designed to solve

**Verification:** 3-pass LaTeX + BibTeX clean, 71 pages, zero errors.

### Remaining sessions
- Session R7: QA + full compile + quality score ≥ 90

---
**Context compaction (auto) at 16:35**
Check git log and quality_reports/plans/ for current state.

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

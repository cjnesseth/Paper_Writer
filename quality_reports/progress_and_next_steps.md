# Progress and Next Steps
**Project:** IO Paper 2 — Calibrated SFE Simulation of Market Power in PJM Capacity Auctions
**Branch:** PJM-Paper
**Date:** 2026-03-28

---

## What Is Done

### Data Pipeline (complete)
- `Data/cleaned/calibration_master.csv` — full 7-year × ~15-LDA panel with VRR anchor points, CETL import limits, reliability requirements, BRA clearing prices, RSI-3 (RTO-level), and derived variables
- Manual IMM extraction for 2026/27 VRR parameters, including the `new_4pt` design variant (EMAAC, MAAC, COMED, JCPL, PS, PS NORTH, PEPCO, PL)

### R Solver (complete)
| Script | Purpose | Status |
|--------|---------|--------|
| `01_vrr_demand.R` | VRR D(p), D'(p), kinks — three design variants (`old`, `new`, `new_4pt`) | ✅ Complete |
| `02_sfe_symmetric.R` | RK4 ODE solver (τ substitution + kink restart), equilibrium finder | ✅ Complete |
| `04_calibrate.R` | RTO-level calibration from RSI-3 | ✅ Complete |
| `05_results_baseline.R` | Baseline K=3 results for 3 benchmark years | ✅ Complete |
| `06_comparative_statics.R` | Four CS: K, VRR slope, fringe supply; saves 4 figures + RDS | ✅ Complete |
| `07_lda_analysis.R` | CETL-based LDA calibration, 41 LDA-year cells, 2 figures + LaTeX table | ✅ Complete |

### Paper Sections
| Section | Status | Notes |
|---------|--------|-------|
| Introduction | ✅ Complete | 5 paragraphs; results preview updated to match actual outputs |
| Institutional Background | ✅ Complete | RPM overview, VRR design history, FERC ER25-1357, lead-time data, TPS test |
| Literature Review | ⚠️ Skeleton | Citation stubs only — no prose in any of the 5 subsections |
| Model | ✅ Complete | SFE setup, VRR schedule, FOC/ODE, Holmberg selection, symmetric special case |
| Calibration | ⚠️ Partial | §4.1 (data sources) and §4.2 (VRR parameters) are written; §4.3–4.5 are `\TODO` stubs |
| Results | ✅ Complete | 5 subsections: baseline, K sensitivity, VRR slope, fringe CS, LDA-level |
| Discussion | ❌ Not started | `\TODO` stub only |
| Conclusion | ❌ Not started | `\TODO` stub only |
| Abstract | ❌ Not started | `\TODO` in `main.tex` |

### Figures (all saved to `Figures/`)
| File | Content |
|------|---------|
| `fig01_supply_functions.pdf` | SFE supply functions + VRR demand curves, 3 benchmark years |
| `fig02a_K_price.pdf` | Equilibrium price vs. K (2–10) |
| `fig02b_K_lerner.pdf` | Lerner index vs. K |
| `fig03_vrr_slope.pdf` | Lerner vs. VRR slope scaling factor |
| `fig04_fringe.pdf` | Lerner vs. fringe supply scaling factor |
| `fig05_lda_lerner.pdf` | Grouped bar: Lerner by LDA and benchmark year |
| `fig06_cetl_scatter.pdf` | Import penetration (CETL/rel. req.) vs. Lerner |

### Key Results Summary
- **Baseline (K=3, ACR=$150):** Lerner 0.54–0.65 across benchmark years; 2026/27 clears at-cap ($329.17) matching observed price exactly — no calibration tuning
- **Concentration:** K=4 cuts Lerner by 33–45pp; K≥7 is near-competitive (L<0.02)
- **VRR slope:** Doubling slope reduces Lerner ~20–30pp in interior-clearing years
- **LDA-level:** Uniform high market power (L=0.48–0.70); import penetration (CETL/rel. req.) is the primary cross-LDA predictor; DEOK (97% import penetration) is the best LDA near-match to observed prices
- **2026/27 identification:** At-cap outcome rules out K≥4 — serves as natural experiment

---

## What Remains

### Priority 1 — Complete the Paper Text

#### 1A. `calibration.tex` §4.3–4.5 (3 stubs, ~300 words total)
- **§4.3 Market Structure:** HHI by LDA from IMM SotM; symmetric K=3 justification (TPS threshold = three pivotal suppliers); note RSI-3 availability only at RTO level
- **§4.4 Cost Parameters:** ACR=$150/MW-day (CC average from 2025 IMM SotM); fringe at same ACR; CETL as fringe capacity for LDA calibration
- **§4.5 Benchmark Delivery Years:** Justify 2023/24 (low price / mitigation active), 2025/26 (price spike / partial mitigation), 2026/27 (at-cap / new VRR); note 2024/25 exclusion (spot auction; 0.8-month lead time gives no forward signal)

#### 1B. `literature.tex` — 5 subsections need prose (~1,500 words total)
The citation skeleton (30 cites, 5 subsections) is in place. Each subsection needs 250–350 words of connecting prose:
1. **SFE Theory** — Klemperer-Meyer equilibrium range, Holmberg uniqueness under capacity constraint
2. **Numerical Methods for SFE** — Anderson-Hu best-response iteration; Baldick linear SFE
3. **Market Power in Electricity Markets** — Borenstein/Bushnell simulation tradition; Sweeting BRA studies
4. **Residual Demand / Baker-Bresnahan** — connection to structural demand estimation
5. **Capacity Market Design** — missing money problem; sloped-demand rationale; MOPR/mitigation rules

#### 1C. `discussion.tex` (~600–800 words)
Three threads to develop:
1. **Comparison to IMM metrics** — TPS test identifies market power (binary) but cannot quantify magnitude; calibrated SFE Lerner of 0.54–0.65 at K=3 implies prices 2–4× competitive level
2. **Policy implications** — (a) VRR redesign: steeper slope reduces markups but new floor $177 sets a binding price floor; (b) CETL expansion: cross-LDA evidence shows each 10pp increase in import penetration cuts Lerner ~5pp; (c) structural remedies necessary for high-power LDAs (PS, EMAAC, COMED)
3. **Limitations** — symmetric firm assumption (all three pivotal suppliers treated identically), static model (no entry/exit or forward contracting), no demand-side uncertainty, ACR=$150 is a technology average not firm-specific

#### 1D. `conclusion.tex` (~400 words)
Standard structure: restate question → summarize findings → policy punchline → future work directions (dynamic SFE with entry, asymmetric firms, empirical structural estimation).

#### 1E. Abstract in `main.tex` (~150 words)
One-sentence each for: motivation, approach, data, key results (Lerner range, K=4 threshold, LDA finding), policy implication.

---

### Priority 2 — Minor Enhancements

| Item | Effort | Notes |
|------|--------|-------|
| HHI axis on K figure | Small | Add secondary x-axis: HHI = 10,000/K on `fig02b_K_lerner.pdf`; edit `06_comparative_statics.R` |
| DOM in 2023/24 | Small | Check whether DOM was an LDA in 2023/24; if not, add a note to tab_lda_lerner footnote |
| PEPCO 2025/26 missing | Small | CETL (6,572) > rel. req. (6,557) — model correctly excludes but footnote should explain |
| Literature prose | Medium | See §1B above |

---

### Priority 3 — Final QA and Submission Prep

1. **Full 3-pass compile** with BibTeX — confirm no undefined citations, no overfull hboxes
2. **Quality score ≥ 90** (PR threshold) — currently at 100/100 for compiled sections, but stubs will drag this down until filled
3. **Proofread pass** — run proofreader agent over all completed sections
4. **Domain review** — run domain-reviewer agent on model and results sections
5. **PR + merge** to `main`

---

## Suggested Session Order

```
Session 6:  calibration.tex §4.3-4.5  +  discussion.tex  +  conclusion.tex  +  abstract
Session 7:  literature.tex prose  +  HHI axis on fig02b  +  full proofread + domain review
Session 8:  Address review feedback  +  3-pass compile + quality gate  +  PR/merge
```

Sessions 6 and 7 can be combined if time permits — the remaining writing is roughly 2,500 words total, all from well-defined outlines already in the `\TODO` stubs and session logs.

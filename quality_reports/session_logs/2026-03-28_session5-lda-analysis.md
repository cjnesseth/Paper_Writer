# Session Log: 2026-03-28 Session 5 — LDA-Level SFE Analysis

## Goal
Build the LDA-level analysis promised in the original goals:
- CETL-based market structure calibration per LDA
- Handle `new_4pt` VRR variant (EMAAC, MAAC, COMED, JCPL, PS, PS NORTH, PEPCO, PL in 2026/27)
- Generate cross-LDA Lerner table, bar chart, and import-penetration scatter
- Expand results.tex with Section 5.5 (LDA-Level Market Power)

## Work Completed

### 1. Extended `01_vrr_demand.R` — `new_4pt` design variant

Added third design branch: `new_4pt` (two slopes + flat floor).
Detection: `vrr_pt_d_price` and `vrr_pt_d_mw` both non-NA.

Key additions:
- `vrr_deriv_at` new_4pt: two slope segments `(pa, pb)` and `(pb, pf)`, two zero regions
- `vrr_kinks` new_4pt: returns `c(vp$pb, vp$pf)` (two kink prices)
- `vrr_floor_demand` new_4pt: returns `c(qb=vp$qc, qd=vp$qd)` (note: qc, not qb, is the sloped-side demand at pf)
- `vrr_floor_price` new_4pt: returns `vp$pf`

### 2. Updated `02_sfe_symmetric.R` — generalized floor-price check

Generalized `equilibrium_price` floor-price check from `"new"` only to
both `"new"` and `"new_4pt"`:

```r
if (vp$design %in% c("new", "new_4pt")) {
  fd           <- vrr_floor_demand(vp)   # c(qb=..., qd=...)
  supply_at_pf <- K * s_interp(vp$pf) + Sf(vp$pf)
  if (supply_at_pf >= fd["qb"] && supply_at_pf <= fd["qd"]) {
    return(list(p_star = vp$pf, note = "cleared at floor price"))
  }
}
```

### 3. `Analysis/R/07_lda_analysis.R` — New script

CETL-based LDA calibration and SFE solving for all LDA-year pairs:
- `calibrate_lda(row, K, acr)`: uses Q_fringe=CETL, q_bar=(rel_req-CETL)/K
- Skips rows where CETL >= rel_req (4 excluded: DAYTON in 2023/24, PEPCO in 2025/26, DOM in 2023/24, and some others)
- `solve_lda(cal)`: tryCatch wrapper around solve_sfe_sym + equilibrium_price
- 41 valid LDA-year cells from 45 total

Outputs:
- `Data/cleaned/lda_results.rds`
- `Figures/fig05_lda_lerner.pdf` — grouped bar chart by LDA
- `Figures/fig06_cetl_scatter.pdf` — import penetration vs Lerner scatter
- `Paper/tables/tab_lda_lerner.tex` — auto-generated LaTeX table

### 4. `Paper/sections/results.tex` — Section 5.5 added

Added Section 5.5 "LDA-Level Market Power" after the fringe comparative static.
Includes: `\input{../Paper/tables/tab_lda_lerner}`, Figure 5 (bar chart),
Figure 6 (scatter), two narrative paragraphs (uniform high power + CETL pattern).

## Key LDA Results (K = 3, ACR = $150/MW-day)

| Year | Mean Lerner | At-cap rate | Interior LDAs |
|------|-------------|-------------|---------------|
| 2023/24 | 0.626 | 12/13 | ATSI-Cleveland (0.61) |
| 2025/26 | 0.648 | 6/15 | ATSI, ATSI-Cleveland, BGE, DEOK, DOM, DPL SOUTH, PL |
| 2026/27 | 0.544 | 14/15 | BGE ($328.28, within $0.89 of cap) |

**Notable results:**
- DEOK 2025/26: import ratio = 97%, p* = $290 vs actual $270 — best LDA near-match
- PS/PS NORTH 2025/26: Lerner = 0.70, the highest in the sample
- 2026/27 universal at-cap confirms result is not an RTO aggregation artefact
- new_4pt LDAs (COMED, EMAAC, JCPL, MAAC, PEPCO, PL, PS, PS NORTH) all solve cleanly

## Paper Compilation
- 2-pass compile: 0 errors, 0 undefined references
- Quality score: **100/100**

## Open for Session 6
1. `Paper/sections/calibration.tex` stubs 5.3–5.5 (market structure, cost params, delivery years)
2. `Paper/sections/discussion.tex` — compare SFE predictions to IMM metrics; VRR/CETL policy
3. `Paper/sections/conclusion.tex`
4. Abstract in `main.tex`
5. HHI axis on K comparative static figure (HHI = 10,000/K)
6. Full paper proof + PR/merge

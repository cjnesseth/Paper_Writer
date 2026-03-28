# Session Log: 2026-03-28 Session 4 — Comparative Statics + Results Section

## Goal
Write comparative statics scripts, generate figures, fill results.tex, and
fix introduction to match actual model outputs.

## Work Completed

### 1. R Solver Debugging (`02_sfe_symmetric.R`)

**Problem:** lsoda failed at kink points with NaN. Root cause: lsoda internally
evaluates the ODE slightly past the segment endpoint (by floating point rounding),
hitting the kink with the wrong segment's D'(p) → NaN.

**Fix:** Rewrote solver with:
- τ = p̄ − p substitution (forward IVP from τ=0)
- RK4 with fixed step (default 0.05 $/MW-day)
- Kink restart: split integration at each VRR kink point; no overshoot possible

### 2. `Analysis/R/06_comparative_statics.R`

Four comparative statics:
- **CS1:** Supply function + VRR demand curves → `fig01_supply_functions.pdf`
- **CS2:** K from 2 to 10, p* and Lerner → `fig02a_K_price.pdf`, `fig02b_K_lerner.pdf`
- **CS3:** VRR slope factor 0.5 to 2.0 → `fig03_vrr_slope.pdf`
- **CS4:** Fringe supply factor 0.7 to 1.5 → `fig04_fringe.pdf`

All figures saved to Figures/ (6.5×4.5, 300 dpi). RDS saved to
Data/cleaned/cs_results.rds.

### 3. `Paper/sections/results.tex` — Full Draft

Five subsections, four figures, two tables:
- **5.1 Baseline:** Table 1 (p*, p_actual, Lerner by year); 2026/27 at-cap
  validation; interpretation of mitigation gap in 2023/24
- **5.2 Concentration:** Fig K sensitivity + Table of p*/L by K=2..10;
  three zones (K≤3 high power, K=4 moderate, K≥7 near-competitive);
  identification: 2026/27 at-cap rules out K≥4
- **5.3 VRR design:** Slope CS + discussion of floor effect in new design
- **5.4 Fringe/Transmission:** Fringe CS + CETL policy interpretation

### 4. `Paper/sections/introduction.tex` — Updated Para 4

Corrected results preview from the pre-solver guess ("Lerner 0.10–0.35") to
actual outputs:
- Baseline K=3: Lerner = 0.54–0.65
- K=4 cuts Lerner by 33–45pp; K=7 near-competitive
- 2026/27 at-cap validates the model (no calibration tuning)
- Fringe +30%: Lerner down 12–18pp

## Key Results

| Year | K=2 | K=3 | K=4 | K=5 |
|------|-----|-----|-----|-----|
| 2023/24 | 0.64 (cap) | 0.55 | 0.30 | 0.11 |
| 2025/26 | 0.67 (cap) | 0.65 | 0.42 | 0.19 |
| 2026/27 | 0.54 (cap) | 0.54 (cap) | 0.34 | 0.15 |

**Key identification fact:** 2026/27 at-cap ↔ K ≤ 3. K=4 predicts interior at $228.

## ACR Note
Technology-average ACR from 2025 SotM: CC = $149/MW-day (validates $150 placeholder).
Default LDA-specific ACR offer caps are in separate IMM BRA analysis reports.

## Compilation
- 3-pass compile: 0 errors, 0 undefined refs, 0 overfull
- Quality score: **100/100**

## Open for Session 5
1. `Paper/sections/calibration.tex` stubs 5.3–5.5 (market structure, cost params, delivery years)
2. `Paper/sections/discussion.tex` — compare SFE predictions to IMM metrics; policy implications
3. `Paper/sections/conclusion.tex`
4. Abstract in `main.tex`
5. Full paper proof + final PR/merge

---
**Context compaction (auto) at 02:25**
Check git log and quality_reports/plans/ for current state.

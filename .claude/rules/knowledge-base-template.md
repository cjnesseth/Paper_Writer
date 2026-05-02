---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
  - "Analysis/**/*.R"
  - "Paper/**/*.tex"
---

# Project Knowledge Base — PJM SFE Paper

Quick reference loaded when working on paper, slide, or analysis files. Fuller domain context lives in `master_supporting_docs/` and the paper itself.

## Notation registry

| Symbol | Meaning | Notes |
|--------|---------|-------|
| $p$, $\bar p_S$ | Clearing price; settlement cap ($\bar p_S \approx 325$ $/MW-day UCAP) | Cap binds in `at-cap` regime |
| $\underline p_S$ | Settlement floor ($\approx 175$/MW-day UCAP) | Applied to RTO and all LDAs |
| $K$ | Number of collectively pivotal suppliers | At-cap regime when $K \leq 3$; interior at $K \geq 4$ |
| $q_i(p)$, $S(p)$ | Strategic supply schedules (firm $i$, aggregate) | Symmetric SFE |
| $D(p)$, VRR | Demand / Variable Resource Requirement curve | Points (a)/(b)/(c) parameterize VRR |
| ACR | Avoidable Cost Rate (proxy for marginal cost) | Used as $c$ in calibration |
| RSI | Residual Supply Index | RSI-3 used to back out top-3 capacity |
| LDA | Locational Deliverability Area | Constrained sub-zones; e.g. EMAAC, ComEd |
| BRA | Base Residual Auction | One per delivery year, ~3y forward |
| UCAP | Unforced capacity | PJM's product unit |
| Lerner | $(p - c) / p$ | Reported per BRA, per LDA |

## BRA delivery years in scope

| Delivery year | Auction date | Lead months | Notes |
|---------------|--------------|-------------|-------|
| 2021/22 | (verify) | (verify) | Pre-pivot baseline |
| 2022/23 | (verify) | (verify) | |
| 2023/24 | (verify) | (verify) | |
| 2024/25 | Dec 2022 | ~18 | Delayed; **not** May 2024 (old metadata wrong) |
| 2025/26 | Jul 2024 | ~10 | Shortest lead in sample |
| 2026/27 | (post-settlement) | — | Cap binding regime |
| 2027/28 | Dec 2025 | — | Cap binding regime; **not** Jan 2026 |

Always cross-check dates against PJM's auction-results releases — see `feedback_pjm_bra_dates.md` memory for the prior incident.

## Tolerance thresholds (for replication / verification)

| Quantity | Tolerance |
|----------|-----------|
| Point estimates (elasticities, slopes) | 1e-4 |
| Lerner indices, markups | 1e-4 |
| Standard errors | 1e-3 |
| Market shares, integers | 1e-6 / exact |
| Coverage rates (MC) | ±0.01 |

## Anti-patterns to avoid

| Anti-pattern | Why it bites |
|--------------|-------------|
| Treating MW-day and MW-year prices interchangeably | Off by factor ~365 |
| Ignoring delivery-year vs auction-date distinction | Mislabels lead times by years |
| OLS on capacity demand without IV | Simultaneity → biased elasticity |
| Pooling RTO and LDA outcomes without zonal indicators | LDA prices diverge sharply post-cap |
| Using RSI-3 estimates without checking pivotal-supplier identity | Identity may swap across years |
| Re-including `sec9_policy_alternatives.tex` | Old draft, not in `main.tex` for a reason |

## R conventions specific to this project

- All R lives in `Analysis/R/` (numbered `01_…` through `10_…`); ad hoc helpers in `scripts/R/` (none currently).
- Scripts are run in numeric order; later scripts depend on `.rds` from earlier ones.
- Figures saved to `Figures/` as PDF, then included by `main.tex` via `\includegraphics{../Figures/...}`.
- See `r-code-conventions.md` for full code style and figure dimensions.

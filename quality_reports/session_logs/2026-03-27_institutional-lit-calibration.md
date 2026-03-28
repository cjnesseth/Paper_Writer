# Session Log: 2026-03-27 — Institutional, Literature, Calibration Prose

## Goal
Write the first substantial prose for the paper. Three sections fully
unblocked with existing data: institutional background, literature capacity
markets subsection, calibration data sources + VRR parameters.

## Work Completed

### 1. `Paper/sections/institutional.tex` — Full Draft (was: stub)
Five subsections, ~1,600 words, two tables:
- **3.1 RPM Overview:** PJM background, BRA mechanism, LDA structure, 110-cell panel
- **3.2 VRR Curve:** Piecewise-linear design, Net CONE anchor, sloped vs. vertical demand rationale
- **3.3 The 2026 VRR Redesign:** FERC ER25-1357, new 4-point design, price floor ~$177–$179/MW-day; Table 1 (BRA timeline + RTO clearing outcomes)
- **3.4 Lead-Time Irregularity:** 0.8-month 2024/25 spot auction, no auction in 2023, implications for investment signals
- **3.5 TPS Test:** RSI definition and data; Table 2 (RSI by LDA/year); binary limitation → motivates SFE approach

### 2. `Paper/sections/literature.tex` — Capacity Markets Subsection (was: bare citations)
~450 words, all eight citations converted to prose:
- Missing money problem + capacity payments (Joskow 2007/2008)
- Sloped vs. vertical demand design (Cramton & Stoft 2005, Hobbs 2007)
- Uniform-price format defense (Cramton & Stoft 2007, Cramton & Ockenfels 2012)
- Market power mitigation + TPS test overview (Bowring 2013, Vossler 2009)

### 3. `Paper/sections/calibration.tex` — Data Sources + VRR Parameters (was: stub)
Two complete subsections + three TODO stubs (market structure, cost params, years):
- **5.1 Data Sources:** 4 datasets described (planning params, BRA results, IMM SotM PDFs, lead times); 110-cell panel noted
- **5.2 VRR Curve Parameters:** Table 3 (RTO VRR params 2022/23–2027/28); 2025/26 anomaly footnoted; 3 benchmark years defined

### 4. `Paper/sections/results.tex` — Added subsection labels
Added four \label{} anchors (subsec:res_baseline, subsec:res_concentration,
subsec:res_vrr, subsec:res_transmission) so cross-references from
institutional.tex resolve cleanly.

### 5. `Preambles/header.tex` — Fixed bibliography style
`aer.bst` not installed on this system; switched to `plainnat` (natbib standard).

## Compilation
- Full 3-pass compile: clean (0 errors, 0 undefined references, 0 overfull boxes)
- Quality score: **100/100** (automated scorer)

## Key Data Facts Used

| Year    | Clearing    | Net CONE   | pt_a       | VRR    | At Cap |
|---------|-------------|------------|------------|--------|--------|
| 2021/22 | $140.00     | $321.57    | $482.36    | Old    | No     |
| 2022/23 | $50.00      | $260.50    | $390.75    | Old    | No     |
| 2023/24 | $34.13      | $274.96    | $412.44    | Old    | No     |
| 2024/25 | $28.92      | $293.19    | $439.79    | Old    | No     |
| 2025/26 | $269.92     | $228.81    | $451.61    | Old    | No     |
| 2026/27 | $329.17     | $212.14    | $329.17    | New    | **Yes** |
| 2027/28 | $333.44     | $242.52    | $333.44    | New    | **Yes** |

RTO RSI-3: 0.62–0.73 throughout; n_pivotal = n_participants throughout.

## Decisions Made

- **Benchmark years:** 2023/24 (low price, old VRR), 2025/26 (price spike,
  old VRR), 2026/27 (at-cap, new VRR). Excludes 2024/25 (spot auction).
- **2025/26 VRR anomaly:** pt_a ($451.61) > 1.5 × Net CONE ($343.22). Handled
  with a footnote noting transitional administrative cap; use published anchor
  points as realized parameters.
- **New design floor description:** ~$177–$179/MW-day across 2026/27 and
  2027/28. Not precisely a Net CONE multiple; described as absolute value.

## Open Questions / Blockers for Session 2

1. Need to read KM1989 + G&N1992 PDFs (on disk) to write SFE theory lit
   subsections with precise equation references.
2. Model section depends on SFE lit subsections being drafted first
   (notation pre-establishment).
3. Market structure calibration (subsec:cal_market_structure) needs IMM
   HHI data — only 21 RSI rows in market_structure.csv; may need supplemental
   IMM extraction.
4. Cost parameters (ACR by LDA) not yet in calibration_master.csv; need to
   source from IMM SotM or PJM CONE studies.

## Quality Score
100/100 (automated)

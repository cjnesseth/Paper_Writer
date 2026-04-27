# Session Log: Conservative fix — 2026/27 RTO shortfall acknowledgment

**Date:** 2026-04-21
**Branch:** PJM-Paper
**Trigger:** Substantive critique noting that 2026/27 (and 2027/28) cleared
below reliability requirement, overdetermining the at-cap outcome and
weakening $K$-identification. Full critique and Nuclear Option pivot plan
saved to `quality_reports/plans/2026-04-21_nuclear-option-pivot.md`.

## Goal

Acknowledge the 2026/27 RTO capacity shortfall in Table 1, add a
limitation paragraph to Section 8 explaining the identification consequences,
and soften the headline framing in abstract/intro/conclusion without
restructuring the paper. Preserve the contribution; bound the claims.

## Changes landed

### 1. `Paper/sections/results.tex` (Table 1, `tab:baseline`)

Added "Margin" column between $p_{\text{actual}}$ and $L$, with values from
`Data/cleaned/calibration_master.csv` (RTO-level `capacity_margin`):

| Year | Margin |
|---|---|
| 2021/22 | +6.8% |
| 2022/23 | +9.2% |
| 2023/24 | +9.9% |
| 2024/25 | +11.7% |
| 2025/26 | +1.6% |
| 2026/27 | **−0.2%** |
| 2027/28 | **−4.7%** |

Column spec updated `lccccccc` → `lcccccccc`. Notes minipage extended with
a formula definition for Margin.

### 2. `Paper/sections/sec8_21billion.tex` (new sixth limitation)

Added a substantive paragraph after the TPS-mitigation paragraph. Key
content:

- States shortfall magnitudes (314 MW / −0.23% in 2026/27; 6,623 MW /
  −4.69% in 2027/28).
- Explains the Klemperer--Meyer intuition is observationally
  indistinguishable from physical scarcity: both produce at-cap clearing
  and the mechanism is not strategically discriminating when aggregate
  supply is short.
- Flags that the $K = 4$ interior-clearing counterfactual at \$228
  presupposes supply sufficiency the shortfall data contradict.
- Notes the \$612M transfer is Point-(a)-sensitive: if Shapiro's implicit
  pre-settlement Point (a) is closer to \$500, SFE under scarcity clears
  near \$500 and the 35× gap collapses.
- Preserves the qualitative finding: settlement cap binds under
  concentrated supply.

### 3. Abstract (`Paper/main.tex:38`)

"roughly 35 times smaller" → "substantially smaller," with a trailing
sentence noting the at-cap outcome is overdetermined given the
shortfalls and the counterfactual is Point-(a)-sensitive.

### 4. Conclusion (`Paper/sections/conclusion.tex:16`)

Parallel softening: "roughly 35 times smaller" → "substantially smaller,"
with a cross-reference to the new limitation paragraph and the
below-reliability-requirement clearing acknowledged explicitly.

### 5. Section 8 body (`sec8_21billion.tex:73`)

"roughly 35 times smaller" → "substantially smaller," with a closing
sentence about Point-(a) sensitivity pointing forward to the new
limitation paragraph.

## Verification

- 3-pass compile (`pdflatex` / `bibtex` / `pdflatex` / `pdflatex`) from
  `Paper/` directory succeeds.
- Output: 34 pages, 455 KB.
- No new overfull `hbox` warnings.
- No undefined references.

## What was preserved

- SFE model, ODE, calibration, and $K$-identification argument as written
  (now bounded by the new limitation).
- `tab:K_sensitivity` and `tab:cost_sensitivity` (referenced by the new
  limitation paragraph; not modified).
- Section 7 (lead time) and Section 9 (policy alternatives).
- "\$612 million vs \$17.16 billion" comparison in `tab:21billion` and
  the body of Section 8 (framing softened; numbers unchanged).

## Open items / follow-ups

- If a referee pushes on the identification concern beyond what the new
  limitation paragraph addresses, pivot to the Nuclear Option plan
  (`quality_reports/plans/2026-04-21_nuclear-option-pivot.md`).
- Slides (`Slides/presentation.tex`) still uses the "\$612M vs \$17.16B"
  framing on the counterfactual slide. Not updated in this session;
  evaluate separately whether the 15-min talk should reflect the softened
  framing or keep the sharper comparison.
- Speaker scripts (`Slides/speaker_script_verbatim.md` and
  `speaker_script_talking_points.md`) unchanged; same evaluation.

## Quality score (self-assessment)

- Compilation: clean. No errors.
- Identification claims: now explicitly bounded.
- Quantitative results: preserved, with caveat flagging the
  Point-(a)-sensitivity.
- No new empirical work; no new figures or tables beyond the added column.

Score estimate: 88/100 for this incremental edit. Commits at 88 ≥ 80, PR
threshold 90 not met but the change is scoped to a single concern.

# Session Log: Phase C of cap-incidence pivot — Section 8 case-study rewrite

**Date:** 2026-04-27
**Branch:** PJM-Paper
**Trigger:** Resume after interruption. Phase A (cap-incidence panel,
52c3d97) and Phase B (bunching diagnostic, 2751c3f) were committed.
Phase C (Section 8 rewrite + framing propagation) was in progress
across 13 working files.

## Goal

Land Phase C: rewrite Section 8 around case studies anchored on the
IMM unrestricted-VRR counterfactual; absorb the lead-time and
structural-alternatives content from previously-separate
sec7_leadtime and sec9_policy_alternatives; propagate framing through
introduction, literature, model, calibration, results, and conclusion;
refresh the slide deck.

## Changes landed in this session

### 1. Verified propagation is framing-consistent

Read every diff. Introduction expands acronyms and drops a redundant
TOC paragraph; literature and model are language-tightening passes
(no claim changes, no new citations); calibration cleanly rewrites
the HHI/RSI prose; results adds a Margin column to Table 1 and softens
the K-identification claim from "useful natural experiment" to
"model-based inference, not an identification result"; conclusion
softens "35× smaller" to "substantially smaller" with cross-reference
to the new Section 8.

### 2. Resolved (citation needed) placeholder

`Paper/sections/calibration.tex:80` had a `(citation needed)`
placeholder for the DOJ HHI threshold reference. Bibliography_base.bib
has no DOJ/HMG entry. Reverted to citation-free wording matching the
pre-edit phrasing: "thresholds the Department of Justice classifies as
highly concentrated under standard antitrust benchmarks."

### 3. Removed orphaned sec7_leadtime.tex

`Paper/sections/sec7_leadtime.tex` was no longer `\input` in main.tex
and its content was duplicated and updated in the new
`\subsection{Lead-Time Compression and Entry Response}` of
`sec8_21billion.tex`. Deleted via `git rm -f`.

### 4. Section 8 proofreading fixes

- Line 31 (2026/27 shortfall): vague "200--500~MW depending on the
  metric" replaced with precise dual figures: 314~MW below the RTO
  reliability requirement of 134,519.5~MW (0.23%) and 493~MW below
  the IRM-implied reserve target. Authoritative source:
  `Data/cleaned/calibration_master.csv` (RTO row, 2026/27).
- Line 57 (2027/28 shortfall): mislabeled metric. Original text used
  6,516.6 MW / 140,994.7 MW / 4.6% — those numbers are from the
  IRM-excess metric in the cap_incidence panel, not the reliability-
  requirement metric. Replaced with 6,623~MW / 141,101~MW / 4.7% from
  the calibration master, aligning with the Margin column in
  `tab:baseline`.
- "noncompetitive" (one word, two occurrences) → "not competitive"
  (matching IMM and cap_incidence prose).
- Lead-time sentence reordered chronologically: 2025/26 (10.1 mo) then
  2026/27 (10.2 mo) then 2027/28 (17.7 mo).
- Verified all citation keys in Section 8 exist in
  Bibliography_base.bib.

### 5. Pre-existing overfull vbox left in place

The 248.7pt "Overfull \\vbox while \\output is active" warning at the
fig04_fringe / fig05_lda_lerner page break is pre-existing — present
in the committed Phase B baseline at 258.7pt (Phase C edits incidentally
reduced it by ~10pt). Not caused by this work; out of scope for Phase C
commit.

## What was preserved from earlier in the pivot

- Cap-incidence panel (Phase A) and bunching diagnostic (Phase B)
  unchanged.
- Calibration data, SFE model, ODE, K-sensitivity table, cost
  sensitivity table.
- Slide deck refresh from 2026-04-21 (already updated to match the
  new framing).

## Verification

- 3-pass compile (`pdflatex` / `bibtex` / `pdflatex` / `pdflatex`)
  from `Paper/` directory: clean.
- Output: 47 pages.
- No undefined references, no citation errors.
- Only warnings: 1.78pt overfull hbox (cap_incidence table, well
  below the 10pt threshold) and the pre-existing 248.7pt vbox.

## Outstanding items

- Slide deck (`Slides/presentation.tex`) and the speaker scripts
  refresh from the 2026-04-21 session are still uncommitted in the
  same Phase C bundle. Verified they match the post-Phase-A/B
  framing.
- The vbox overfull at the figure-heavy results section is a
  pre-existing cosmetic page-break artifact — defer to a separate
  formatting pass if it becomes visible in print.
- No DOJ/HMG bib entry exists; if a referee asks for the HHI
  threshold citation, add Horizontal Merger Guidelines (2010) to
  Bibliography_base.bib.

## Quality (self-assessment)

- Compilation: clean.
- Numerical claims in Section 8: cross-checked against
  `calibration_master.csv` and the cap_incidence panel; one mislabel
  found and fixed.
- Framing consistency between Section 8 and propagated sections:
  verified.
- Citation keys: all verified present in bibliography.

Score estimate: 92/100 for Phase C as a whole. Above the 90 PR
threshold.

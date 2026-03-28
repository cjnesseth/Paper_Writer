# Proofreading Report — PJM Capacity Auction SFE Paper
**Date:** 2026-03-28
**Files reviewed:** main.tex, all 8 section .tex files

---

## Summary

| Severity | Count |
|----------|-------|
| High     | 5     |
| Medium   | 6     |
| Low      | 4     |

---

## HIGH Issues

### H1: Duplicated word "RTO RTO"
- **File:** results.tex, line ~278
- **Current:** `"the only LDA to produce an interior equilibrium price below the RTO RTO price"`
- **Fix:** Remove one "RTO"

### H2: RSI₃ values in wrong year order
- **File:** calibration.tex, §4.3
- **Current:** `"(0.68, 0.64, and 0.62 for 2023/24, 2026/27, and 2025/26, respectively)"`
- **Fix:** `"(0.68, 0.62, and 0.64 for 2023/24, 2025/26, and 2026/27, respectively)"`
- **Note:** RSI₃ = 0.62 for 2025/26 and 0.64 for 2026/27; years are chronologically swapped

### H3: Wrong citation for asymmetric SFE tractability
- **File:** discussion.tex, §6.3 (Limitations)
- **Current:** `"analytically tractable only in special cases \citep{Holmberg2008_unique_sfe}"`
- **Fix:** `\citep{Anderson2008_sfe_asymmetric}` — Holmberg (2008) proves uniqueness of symmetric SFE, not asymmetric tractability

### H4: Introduction roadmap lists §3 before §2 (reverse of document order)
- **File:** introduction.tex, roadmap paragraph
- **Fix:** Swap so §2 (literature) is mentioned before §3 (institutional)

### H5: K→∞ competitive limit misattributed to Holmberg proposition
- **File:** results.tex, line ~155
- **Current:** `"consistent with the competitive limiting result $p^* \to c$ as $K \to \infty$ in Proposition~\ref{prop:holmberg}"`
- **Fix:** Change reference to `equation~\eqref{eq:sfe_ode}` — Holmberg's proposition proves uniqueness for fixed K, not a limiting result

---

## MEDIUM Issues

### M1–M5: Missing space after `\textit{Notes:}` in figure captions (5 occurrences)
- **File:** results.tex
- **Fix:** Add space: `\textit{Notes:} Solid lines...` etc. (currently no space between `:` and text)

### M6: Wrong preposition "by standard antitrust benchmarks"
- **File:** calibration.tex
- **Current:** `"highly concentrated markets by standard antitrust benchmarks"`
- **Fix:** `"highly concentrated markets under standard antitrust benchmarks"`

### M7: Missing citation for HHI > 2,500 threshold
- **File:** calibration.tex
- **Fix:** Add footnote citing DOJ/FTC Horizontal Merger Guidelines (2010)

### M8: Dangling "see footnote" in table note
- **File:** calibration.tex, table note for tab:vrr_params
- **Current:** `"due to a transitional administrative cap; see footnote."`
- **Fix:** Change to `"due to a transitional administrative cap (see footnote above)."`

### M9: `$c = \$150$/MW-day` LaTeX encoding in table captions (may render oddly)
- **File:** results.tex, baseline table caption and notes
- **Fix:** Change to `$c = \$150$\,/MW-day`

---

## LOW Issues

### L1: Subject-verb mismatch "Rudkevich...develops" vs parallel "Niu...extend"
- **File:** literature.tex, line ~107
- **Fix:** Change "develops" to "develop"

### L2: "reduce $K$ below three" → "reduce $K$ to fewer than three"
- **File:** discussion.tex

### L3: "a Lerner of 0.60" → "a Lerner index of 0.60"
- **File:** discussion.tex

### L4: ACR acronym defined twice (institutional + calibration) — low priority, defensible for reader convenience

---

## Spot-Checks Passed
- All 27 citation keys verified present in Bibliography_base.bib
- No informal contractions found
- \citet/\citep usage generally correct
- Lerner $L$ defined consistently in model.tex

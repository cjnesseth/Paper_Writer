# Rewrite Plan: Laser-Focus on Price Suppression and Reliability Shortfall

**Status:** APPROVED 2026-05-02
**Target branch:** `PJM-Paper`
**Plan file (canonical):** `/home/chris/.claude/plans/expressive-crunching-jellyfish.md`

---

## Context

The current 45-page draft accumulated three theses across a year of pivots: an SFE methodological apparatus, a cap-incidence regime story, and a $21B reconciliation case study. The user wants a tightly focused paper answering one question:

> *What are the consequences of suppressing PJM capacity prices below the unconstrained equilibrium, given that both capped delivery years (2026/27 and 2027/28) cleared below their reliability requirements?*

Standard price-control theory predicts that a binding ceiling produces a shortage. PJM's data show shortage emerged precisely once the Shapiro cap bound: 314 MW (0.23%) in 2026/27 and 6,623 MW (4.7%) in 2027/28. The paper traces this textbook–data connection.

**Two refinements:**

1. **No standalone $21B reconciliation section.** A short paragraph in the conclusion is sufficient.
2. **No SFE derivation in body.** Treat SFE as established methodology and cite Klemperer–Meyer (1989), Green–Newbery (1992), Holmberg (2008). The appendix of derivations is deleted entirely.

The 30-page target is soft; **parsimony and laser-focus take precedence**. Final length will likely come in well under 30.

---

## New section structure

| # | Section | Target pp | Notes |
|---|---------|-----------|-------|
| 1 | Introduction | 1.5 | Open with the puzzle |
| 2 | Institutional Background | 2.0 | Compress from 6 pp |
| 3 | A Price-Cap Lens on the Shapiro Settlement | 1.5 | Textbook ceiling theory + SFE-by-reference |
| 4 | Data and Calibration | 1.0 | Just enough to read tables |
| 5 | Cap-Incidence and the Emergence of Shortage | 3.0 | Centerpiece + bunching paragraph absorbed |
| 6 | Capped Auctions: Quantity Rationing in 2026/27 and 2027/28 | 2.5 | Two case studies |
| 7 | Conclusion | 2.0 | Theory–data + $21B paragraph + lead-time + welfare |

Estimated body ≈ 13.5 pp; target total ≈ 18–22 pp.

---

## Files to modify

- **Rewrite:** introduction.tex, conclusion.tex
- **Reframe + slim:** model.tex (→ thin §3), calibration.tex, cap_incidence.tex, institutional.tex
- **Build new:** case_studies.tex (from sec8_21billion.tex case-study subsections)
- **Light trim:** literature.tex
- **Delete:** results.tex, bunching.tex, sec8_21billion.tex, appendix_derivations.tex, appendix_figures.tex
- **Update:** main.tex (\input order, title, abstract)
- **Tables to drop usage:** tab_lda_lerner, tab_cost_sensitivity, tab_bunching (files retained on disk)
- **Tables to keep:** tab_bra_timeline, tab_tps_results, tab_vrr_params, tab_cap_incidence, tab_capped_revenue (extract from sec8 inline)

---

## Open questions resolved during execution

1. **Title:** Recommend *Price Suppression and Reliability Shortfall in PJM's Capacity Market*. User to confirm.
2. **$21B paragraph location:** Conclusion (per plan v2).
3. **LDA content:** Cut entirely.
4. **fig01_supply_functions.pdf:** Cut.

---

## Verification

3-pass `pdflatex` + `bibtex` from `Paper/`. Page count ≤ 30. Cross-references intact. Quality score ≥ 80. Domain reviewer + proofreader agents at the end.

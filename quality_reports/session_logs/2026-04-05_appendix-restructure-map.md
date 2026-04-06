# Session Log: 2026-04-05 -- Table Restructure, Appendix, Map, Revised Cumul Framing

**Status:** COMPLETED

## Objective

Restructure the paper to match its own stated hierarchy of evidence. Keep 4 tables in the main text (descriptive, main results, robustness, incidence), drop the payback table entirely (conceptually vulnerable under the Tiebout capitalization the paper cites), and move the balance and alt-rings tables to a new appendix. Also compute and add four robustness results the draft currently claims but does not show (opening-year treatment timing, 4 km cumulative exposure, joint pre-trends Wald test, treatment-effect heterogeneity) and add a geographic map the draft lacks.

## Key Context

User direction: the paper's core claims (cumulative-exposure null + fragility of localized-harm estimates) should drive the table lineup. Tables that either duplicate that point or rest on shakier interpretation (especially payback) should be cut. The four missing-results claims are load-bearing for the caution level, so they go in an appendix rather than being deleted. Plan was approved after two rounds of revision (appendix → no appendix → appendix again).

## Changes Made

| File | Change | Reason |
|------|--------|--------|
| `scripts/R/09_appendix_results.R` | NEW -- computes 4 appendix tables and 1 event-study figure from cached fits + replayed panel construction | Needed to produce A.3 opening-year, A.4 4km cumul, A.5 pre-trends Wald, A.6 heterogeneity |
| `scripts/R/10_map_figure.R` | NEW -- generates fig_map.pdf using jsonlite + ggplot2 (no sf dependency) | sf package not installed; fell back to direct JSON geojson parsing |
| `Figures/fig_map.pdf` | NEW -- Loudoun DCs, thinned residential transactions, distance rings | User flagged that interpretation depends on clustered geography and industrial buffering |
| `Figures/tab_appx_opening.tex` | NEW -- permit-year vs opening-year ring coefs and SA ATT side-by-side | A.3 |
| `Figures/fig_appx_es_opening.pdf` | NEW -- SA event study under opening-year timing | A.3 |
| `Figures/tab_appx_cumul_4km.tex` | NEW -- 2km vs 4km cumulative exposure side-by-side | A.4 |
| `Figures/tab_appx_pretrends.tex` | NEW -- joint Wald tests on pre-treatment leads | A.5 |
| `Figures/tab_appx_heterogeneity.tex` | NEW -- interaction tests for facility size and cohort timing | A.6 |
| `paper/datacenter_paper.tex` | Added appendix section A.1--A.6, inserted map figure, removed tab_payback input, moved balance/alt_rings inputs to appendix, updated cumulative-exposure prose throughout | Full restructuring per approved plan |
| `explorations/data_collection/processed/appendix_results.rds` | NEW -- fits and summaries from 09 script | Cache |

## Design Decisions

| Decision | Alternatives Considered | Rationale |
|----------|------------------------|-----------|
| Replay data prep inline in 09 rather than modifying 06 to save panel_did | Modify 06 to saveRDS(panel_did); source 06; save panel as RDS in new script | Keeps 06 untouched; data prep is fast; no new dependencies between scripts |
| Use jsonlite + direct ggplot for map, not sf | Install sf system-wide; use tmap | sf not installed and has heavy gdal/geos/proj system dependencies; direct geojson parsing worked cleanly for point-based plotting |
| Exclude event time -4 from joint pre-trends Wald test | Report full test including -4 | That bin has only 2 observations (both 2020, both 2024 cohort with 14 parcels); its coefficient is a bin-sparsity numerical artifact, not a real pre-trend. Table note documents the exclusion explicitly. |
| Reframe cumulative exposure throughout paper as radius-sensitive rather than "precisely estimated null" | Keep original framing with 4km as contradictory footnote | Honesty requires the reframe: 4km shows a modest effect consistent with ring estimates, so the 2km null was not a robust zero. This reframe also strengthens the "evidence is stronger against strong harm than for precise zero" narrative the user wants. |
| LaTeX caption instead of ggplot caption on map figure | Long ggplot caption | Initial ggplot caption overflowed the figure bounding box and got truncated at "Red"; moving all description into the LaTeX \caption fixed it cleanly |

## Incremental Work Log

- Wrote 09_appendix_results.R with minimal inline data-prep block mirroring 06_hedonic_revised.R, loaded cached fits for heterogeneity and pre-trends, estimated new specs for opening-year and 4km cumulative
- First run failed because cached fit_sa's summary() re-evaluates the sunab formula and needs cohort_permit in scope; added cohort_permit and years_to_permit to the panel
- Second run produced A.5 joint pre-trends F=23 which was suspicious; diagnosed by inspecting individual lead coefficients -- event time -4 had coef -0.062 with 2 observations, a bin-sparsity artifact
- Also found A.4 4km cumulative is not null (sqft: -0.0044, count: -0.0018), contradicting the paper's current "precisely estimated null" framing
- Stopped and flagged both findings to user; user chose Option C (investigate further) and then after diagnostics chose to report findings honestly and reframe paper
- Updated 09 to exclude event time -4 from the Wald test and document exclusion in table note
- Generated map using jsonlite/ggplot approach (sf unavailable); iterated once on caption layout after ggplot caption overflowed figure bounds
- Edited paper in order: appendix section, remove tab_payback, balance replacement, remove alt_rings inline, update alt_rings pointer to appendix, pre-trends sentence, opening-year pointer, cumulative exposure paragraph (major rewrite), hierarchy-of-credibility paragraph, discussion cumulative paragraph, abstract, intro (two spots), conclusion, map figure insertion, heterogeneity inline F-test
- Compiled: 32 pages, clean, no undefined refs

## Verification Results

| Check | Result | Status |
|-------|--------|--------|
| 09_appendix_results.R runs clean | 4 .tex files + 1 .pdf figure + 1 .rds produced | PASS |
| 10_map_figure.R runs clean | fig_map.pdf produced (97 DCs, 10342 thinned transactions) | PASS |
| pdflatex 3-pass + bibtex compile | Exit 0, 32 pages | PASS |
| Undefined references | None | PASS |
| Overfull hboxes | 2 pre-existing in tab_main_results/tab_incidence, unrelated to these edits | PRE-EXISTING |
| Map renders with full LaTeX caption | Page 10 | PASS |
| Appendix A.1-A.6 render with correct numbering | Tables 5-10, Figure 5 | PASS |
| Abstract uses revised "null at 2km / modestly negative at 4km" language | Page 1 | PASS |

## Substantive Findings (Reframed in Paper)

- **A.3 Opening-year timing:** SA ATT under opening-year timing -0.0182 (SE 0.0058) vs permit-year -0.0134 (SE 0.0048). Ring coefs comparable across timing conventions.
- **A.4 4km cumulative:** sqft_4km coef -0.0044 (SE 0.0017), count_4km -0.0018 (SE 0.0007). Both significant. Implies ~1.3% price difference at median non-zero exposure. Consistent with 1-2km and 2-4km ring estimates. The 2km cumulative null was not robust to radius.
- **A.5 Pre-trends:** TWFE F(2,49) = 3.23, p = 0.048; SA F(2,50) = 3.81, p = 0.029 (both excluding event time -4). Borderline reject at 5%, fail to reject at 1%. Individual leads at -3 and -2 not significant.
- **A.6 Heterogeneity:** Large-vs-small DC difference 0.009 (p=0.59); early-vs-late cohort difference 0.018 (p=0.39). No significant heterogeneity.

## Open Questions / Blockers

None. The reframed cumulative-exposure narrative and the borderline pre-trends result actually strengthen the user's preferred caution framing ("stronger against strong harm than for precise zero").

## Next Steps

- User may want to re-read the restructured results and discussion sections to confirm the radius-sensitivity narrative holds together
- The paper now has a more honest treatment of specification fragility that better supports the narrow law-and-econ claim
- Commit when user signals ready

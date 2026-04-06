# Plan: Restructure Tables, Add Appendix, Add Map Figure

**Status:** DRAFT (v3, with appendix for robustness checks)
**Date:** 2026-04-05
**Paper:** paper/datacenter_paper.tex

## Context

The paper currently presents 7 tables in the main text. Following the user's hierarchy of evidence (the cumulative-exposure null + fragility of localized-harm estimates is central), the final draft should keep 4 tables in main text (descriptive, main results, robustness, incidence), move 2 to an appendix (balance, alt_rings), and drop 1 entirely (payback, conceptually vulnerable under Tiebout capitalization). The current draft also claims four robustness exercises it does not show: opening-year treatment-timing, 4 km cumulative exposure, joint pre-trends test, and heterogeneity by facility size and cohort. These should be shown in the appendix rather than deleted, since the sentences that reference them are load-bearing for the paper's caution level. The draft has no map even though interpretation depends on clustered geography and industrial buffering.

Intended outcome: 4-table main text + 1 map figure; appendix with 2 moved tables + 4 new robustness items; prose throughout updated to reference the appendix for each claim.

## Implementation Plan

### Phase 1: Paper restructuring (edits only, no estimation)

Edit `paper/datacenter_paper.tex`:

1. Add `\appendix` block before `\bibliography` containing `\section{Appendix: Robustness Checks}` with subsections A.1-A.6.
2. Delete `\input{../Figures/tab_payback}` at L244 and its interpretation at L237-238. Keep the rest of the §7 tab_incidence paragraph.
3. Move `\input{../Figures/tab_balance_repeat}` from L199 into appendix §A.1. Replace L196-200 prose with: "Repeat-sale properties are somewhat selected toward lower-priced, more frequently transacted parcels (Appendix Table~\ref{tab:balance}); the repeat-sales estimates should therefore be read as local effects for this subsample rather than as estimates for the typical Loudoun homeowner."
4. Move `\input{../Figures/tab_alt_rings}` from L209 into appendix §A.2. Update L202 inline reference from "Alternative distance cutoffs (Table~\ref{tab:alt_rings})" to "Alternative distance cutoffs (Appendix Table~\ref{tab:alt_rings})".

### Phase 2: Write `scripts/R/09_appendix_results.R`

One new script that loads `explorations/data_collection/processed/hedonic_results_revised.rds` and the panel data it derives from, produces four new appendix .tex tables, and (for opening-year) a supporting event-study figure.

**A.3 Opening-year treatment timing.** Panel already has `dc_open_year` (06_hedonic_revised.R L158) and `post_open` indicator (L172). Re-estimate the TWFE ring specification and the Sun-Abraham event study replacing `post` with `post_open` (and correspondingly replacing `years_to_treat` with opening-year-centered event time). Produce:
- `Figures/tab_appx_opening.tex`: TWFE ring coefficients under opening-year timing, side-by-side with permit-year (for comparison)
- `Figures/fig_appx_es_opening.pdf`: SA event-study figure under opening-year timing

**A.4 Cumulative exposure at 4 km.** Panel already has `sqft_4km_M` (L145) and the corresponding count variable. Estimate the sqft and count cumulative-exposure specifications at 4 km using the same formula as the cached 2 km fits (`fit_cumul`, `fit_count`). Produce `Figures/tab_appx_cumul_4km.tex` showing 2 km (from cached) vs 4 km specifications side-by-side.

**A.5 Joint pre-trends test.** Not currently computed. Use `fixest::wald()` on the pre-treatment lead coefficients from the cached `fit_sa` and `fit_twfe_es`. Report F-statistic, numerator/denominator df, and p-value. Produce `Figures/tab_appx_pretrends.tex`.

**A.6 Heterogeneity.** `fit_het_size` and `fit_het_time` are already cached in `hedonic_results_revised.rds`. Extract coefficients and standard errors, plus joint Wald tests on the interaction terms. Produce `Figures/tab_appx_heterogeneity.tex`.

### Phase 3: Write `scripts/R/10_map_figure.R`

No existing map-making code in the repo. Build from scratch using sf + ggplot2, reusing the `sf::st_read()` pattern from `02_build_treatment.R`.

Load:
- County boundary from `explorations/data_collection/raw/loudoun_parcels_shp/Loudoun_Parcels.shp` (dissolve) or a county-boundary layer if present
- `explorations/data_collection/raw/dc_building_footprints.geojson` (DC facility footprints)
- `explorations/data_collection/raw/loudoun_zoning.geojson` (industrial / planned-development zones as background shading)
- `explorations/data_collection/processed/dc_centroids.geojson` (DC centroids, colored by permit year if join is possible)

Plot: Loudoun boundary + industrial/PD zoning shaded + DC footprints + thinned residential transaction points from hedonic panel, with optional distance rings around a representative DC cluster. Save `Figures/fig_map.pdf`.

### Phase 4: Paper prose updates

Edit `paper/datacenter_paper.tex`:

1. **Insert map** at end of §4 Data (after tab_descriptive input, L128), as Figure 1.
2. **Update §5 L120** "I report opening year results as a robustness check" to point explicitly: "Opening-year results are reported in Appendix §A.3."
3. **Add inline reference** in §6 Results after cumulative-exposure discussion: "Extending the exposure radius to 4 km yields the same precisely estimated null effects (Appendix Table~\ref{tab:appx_cumul_4km})."
4. **Extend §6 L171** pre-trends sentence: "Pre-treatment coefficients are generally small and not statistically significant; a joint Wald test on the leads fails to reject parallel trends (Appendix Table~\ref{tab:appx_pretrends})."
5. **Extend §6 L202** heterogeneity sentence: "Treatment effect heterogeneity is minimal along both facility size and cohort timing dimensions (Appendix Table~\ref{tab:appx_heterogeneity})."
6. **Ensure table numbering is coherent** after the cut of tab_payback and the moves to appendix (LaTeX will renumber automatically; just verify cross-references).

### Phase 5: Verification

1. `Rscript scripts/R/09_appendix_results.R` → expect four .tex files in `Figures/` and one .pdf, no errors.
2. `Rscript scripts/R/10_map_figure.R` → expect `Figures/fig_map.pdf`, no errors.
3. `pdflatex` 3-pass + bibtex.
4. Grep log for "undefined" (unresolved references/citations).
5. Check no new overfull hboxes in added content.
6. Confirm appendix renders as Appendix A with subsections A.1-A.6.
7. Expected page count: ~32 pages (base 28 − 3 tables cut + 1 map + ~6 appendix pages).

## Critical Files to Modify

| File | Change |
|------|--------|
| `paper/datacenter_paper.tex` | Remove tab_payback; move 2 tables to appendix; add \appendix with A.1-A.6; insert map; update prose |
| `scripts/R/09_appendix_results.R` | NEW |
| `scripts/R/10_map_figure.R` | NEW |
| `Figures/tab_appx_opening.tex` | NEW |
| `Figures/tab_appx_cumul_4km.tex` | NEW |
| `Figures/tab_appx_pretrends.tex` | NEW |
| `Figures/tab_appx_heterogeneity.tex` | NEW |
| `Figures/fig_appx_es_opening.pdf` | NEW |
| `Figures/fig_map.pdf` | NEW |

## Reuse of Existing Infrastructure

- `hedonic_results_revised.rds` → `fit_sa`, `fit_twfe_es`, `fit_het_size`, `fit_het_time`, `fit_cumul`, `fit_count` cached
- Panel with `dc_open_year`, `post_open`, `sqft_4km_M`, count-at-4km already built (06_hedonic_revised.R)
- `fixest::wald()` for joint tests
- `sf::st_read()` pattern from 02_build_treatment.R

## Assumptions / Decisions

- Appendix is structured as a single `\section{Appendix: Robustness Checks}` with `\subsection`s A.1-A.6, not as six separate sections.
- Map figure goes in §4 Data (end), not §5, because it illustrates geographic facts the identification discussion relies on.
- Opening-year robustness gets both a table (ring coefficients) and a figure (event study); the other three items get tables only.
- tab_payback is dropped, not reframed, because reframing would require defensive hedges about within-county vs countywide capitalization that add more text than they're worth.
- If the computed 4 km cumulative result, joint pre-trends test, or heterogeneity test changes the substantive story (unexpected significance, reject pre-trends, substantial heterogeneity), I will stop and flag before applying prose changes.

## Verification

Run the scripts, compile, check cross-references resolve. Re-read the restructured paper to confirm the narrow-law-and-econ framing from yesterday's edits stays consistent through the appendix additions.

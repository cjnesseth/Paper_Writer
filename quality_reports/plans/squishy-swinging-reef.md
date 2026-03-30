# Plan: Draft Term Paper — Data Center Costs and Benefits in Loudoun County

**Status:** DRAFT
**Date:** 2026-03-30
**Format:** LaTeX (.tex) → PDF via pdflatex
**Target:** 25-30 page PhD Econ & Law term paper

## Context

All data is clean and ready (41,368 residential sales, 135 DC parcels, tax revenue, electricity inputs, 42 papers downloaded). The hedonic analysis script exists but runs on synthetic data. Need to: (1) run the real analysis, (2) draft the full paper around actual results.

## Phase 1: Run the Analysis

### Step 1.1: Install R packages
Install `modelsummary`, `broom`, `lubridate`, `kableExtra` from CRAN. (`fixest` already installed.)

### Step 1.2: Create adapted analysis script
**Create:** `scripts/R/05_hedonic_did.R`

New script (not a modification of `hedonic_analysis.R`) because:
- Old script depends on `sf` (unavailable) — distances are pre-computed in the panel
- Column names differ: `parid`/`lon`/`lat`/`living_area`/`baths` vs old `parcel_id`/`longitude`/etc.
- Only 8.3% of parcels have repeat sales → use **census tract FE** (74 tracts) as primary, parcel FE as robustness

**Key design decisions:**
- Treatment timing: join `dc_master_inventory.csv` on `nearest_dc_project` to get `earliest_year`
- Identification: 42 DCs opened 2020-2025 provide staggered treatment variation
- Control group: properties 4+ km from any DC
- Parse `grade` (e.g., "5.0:GOOD" → numeric) and `condition` as factors

**Four specifications:**
1. Cross-sectional hedonic: `log(price) ~ rings + controls | tract + year_qtr`
2. DiD with rings: `log(price) ~ i(ring, post) + controls | tract + year_qtr`
3. Event study: `log(price) ~ i(event_time, ref=-1) + controls | tract + year_qtr` (window [-3, +3])
4. Robustness: parcel FE on repeat-sales subsample (~7,000 obs)

### Step 1.3: Generate figures and tables
Embedded in `05_hedonic_did.R`:
- `Figures/fig_event_study.pdf` — event study coefficients with 95% CI
- `Figures/fig_did_rings.pdf` — ring coefficient dot-whisker
- `Figures/fig_distance_hist.pdf` — distance distribution with ring thresholds
- `Figures/fig_dc_timeline.pdf` — DC construction by year
- `Figures/fig_price_trends.pdf` — median price by year × ring (visual parallel trends)
- `Figures/fig_tax_revenue.pdf` — tax revenue trajectory
- `Figures/fig_benefit_cost.pdf` — NPV comparison bar chart
- `Figures/tab_descriptive.tex` — summary statistics (Table 1)
- `Figures/tab_main_results.tex` — regression table (Table 2)

### Step 1.4: Run and verify
Execute script; verify event study pre-trends, sensible coefficients, all outputs saved.

## Phase 2: Write the Paper

### Step 2.1: Build BibTeX bibliography
**Modify:** `Bibliography_base.bib` — add 43 entries from `explorations/reference_list.md`

### Step 2.2: Create LaTeX document
**Create:** `paper/datacenter_paper.tex`

```
\documentclass[12pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{setspace}\doublespacing
\usepackage{natbib}\bibliographystyle{plainnat}
\usepackage{booktabs, threeparttable}
\usepackage{graphicx, float}
\usepackage{amsmath, hyperref}
```

**Section structure:**
1. Introduction (1.5-2 pp) — motivation, RQ, contribution, findings preview
2. Background (3-4 pp) — port from `background_draft.md` (2,300 words exist)
3. Literature Review (2.5-3 pp) — hedonic disamenity, NIMBY, staggered DiD
4. Data (2-3 pp) — panel construction, DC inventory, fiscal/electricity sources
5. Empirical Strategy (2.5-3 pp) — hedonic model, DiD design, event study, threats
6. Results (3-5 pp) — descriptives, event study, DiD rings, robustness
7. Discussion: Benefit-Cost Synthesis (2-3 pp) — tax, electricity, property values, net assessment
8. Conclusion (1 pp) — summary, limitations, policy implications

### Step 2.3: Write sections
- **Background (§2):** Port `background_draft.md` to LaTeX, add `\cite{}` references
- **Lit review (§3):** Write from reference list (Davis, Currie, Jarvis, CS, Roth, Fischel, etc.)
- **Data (§4):** Describe panel construction, include Table 1
- **Empirical strategy (§5):** Formal specifications, identification, threats
- **Results (§6):** Write around actual regression output from Step 1.4
- **Discussion (§7):** Synthesize three channels using `benefit_cost_summary.csv`
- **Introduction (§1):** Write after results are known
- **Abstract:** Write last

### Step 2.4: Compile
```bash
cd paper && pdflatex datacenter_paper && bibtex datacenter_paper && pdflatex datacenter_paper && pdflatex datacenter_paper
```

## Execution Order

**Parallel track A (analysis):** 1.1 → 1.2 → 1.4
**Parallel track B (writing infrastructure):** 2.1 + 2.2 (can start immediately)
**Sequential after both tracks:** 2.3 (§2-5 can be written before results; §1,6-8 need results) → 2.4

## Files to Create
| File | Purpose |
|------|---------|
| `scripts/R/05_hedonic_did.R` | Core analysis script |
| `paper/datacenter_paper.tex` | Main LaTeX document |
| `Figures/*.pdf` | ~7 figures |
| `Figures/tab_*.tex` | ~2 LaTeX tables |

## Files to Modify
| File | Change |
|------|--------|
| `Bibliography_base.bib` | Add 43 BibTeX entries |

## Verification
- [ ] `05_hedonic_did.R` runs without error
- [ ] Event study shows flat pre-trends (or documents violations)
- [ ] All figures/tables saved to `Figures/`
- [ ] LaTeX compiles clean (no unresolved citations, no overfull hbox >10pt)
- [ ] Page count 25-30

# RGGI Paper — R Pipeline

Reproducible pipeline for *"Carbon Pricing in Reverse: Evidence from Virginia's Exit and
Re-Entry into RGGI."* All estimation lives here; the LaTeX manuscript only `\input{}`s
tables (`Tables/*.tex`) and `\includegraphics` figures (`Figures/*.pdf`) produced by these
scripts. **No numbers are hand-entered in the manuscript.**

## Run order

| Script | Purpose | Phase |
|--------|---------|-------|
| `00_setup.R` | Packages, paths, design constants (events, donor pools), helpers | 0 |
| `01_fetch_eia.R` | Retail prices & generation (EIA 861M/923) | 2 |
| `01_fetch_cems.R` | CO₂ emissions (EPA CEMS / CAMPD) | 2 |
| `01_fetch_pjm.R` | Wholesale LMPs (PJM Data Miner 2.0) | 2 |
| `01_fetch_rggi.R` | Allowance auction prices (RGGI Inc.) | 2 |
| `01_fetch_weather_econ.R` | NOAA weather, EIA gas, BEA/Census, public SCC rider | 2 |
| `02_tidy_panel.R` | Assemble state-month & PJM-zone panels | 2 |
| `03_scm.R` | Synthetic control (primary) | 3 |
| `04_did.R` | Event-study DiD (robustness) | 3 |
| `05_synthdid.R` | Synthetic DiD (bridge) | 3 |
| `06_robustness.R` | §7 threats/robustness; leakage; asymmetry test | 4 |
| `07_figures_tables.R` | Render `Figures/*.pdf` and `Tables/*.tex` | 3–4 |

## Data scope

**Public sources only. No Dominion internal data; no SAS.** The Dominion rider series is
entered from **public Virginia SCC dockets** into a small versioned CSV (`data/raw/scc_rider.csv`).

## Environment

- R 4.3.3. Core packages installed: `data.table`, `ggplot2`, `fixest`, `did`, `modelsummary`, `renv`.
- **Install before Phase 3** (not yet present):
  ```r
  install.packages(c("tidysynth", "Synth", "fect", "rprojroot", "arrow"))
  remotes::install_github("synth-inference/synthdid")
  ```
- Pin versions with `renv::snapshot()` once the package set is final.

## API keys (free; public data)

Set as environment variables where applicable: `EIA_API_KEY`, `EPA_CAMPD_API_KEY`,
`PJM_API_KEY`. Bulk-download fallbacks exist for EIA and CEMS.

## Reproducibility

`data/raw/` and `data/results/` are gitignored (large/derived). Record access dates and
docket numbers in each fetch. Full rebuild: `00 → 01_* → 02 → 03 → 04 → 05 → 06 → 07`,
then compile the manuscript (pdflatex 3-pass + bibtex).

# RGGI Paper — R Pipeline

Reproducible pipeline for *"Carbon Pricing in Reverse: Evidence from Virginia's Exit and
Re-Entry into RGGI."* All estimation lives here; the LaTeX manuscript only `\input{}`s
tables (`Tables/*.tex`) and `\includegraphics` figures (`Figures/*.pdf`) produced by these
scripts. **No numbers are hand-entered in the manuscript.**

## One command

```bash
Rscript scripts/R/run_all.R                 # cached downloads
RGGI_REFRESH=1 Rscript scripts/R/run_all.R  # force re-pull of upstream sources
```

Stops on first error; writes a run log + `sessionInfo()` to `quality_reports/session_logs/`.

## Run order

| Script | Purpose | Status |
|--------|---------|--------|
| `00_setup.R` | Packages, paths, design constants (events, donors), `cached_download()`, `log_vintage()`, `load_analysis_panel()` | working |
| `01_fetch_eia.R` | Retail prices (EIA-861M bulk workbook, keyless) | working |
| `01_fetch_rggi.R` | Allowance auction prices/volumes (RGGI Inc., keyless HTML parse) | working |
| `01_fetch_weather_econ.R` | NOAA CPC HDD/CDD + FRED Henry Hub gas (keyless); SCC rider CSV template | working |
| `01_fetch_cems.R` | Monthly state CO₂ — EIA-923 fuel × EPA factors (keyless fallback; CAMPD preferred once keyed) | working |
| `01_fetch_pjm.R` | Wholesale LMPs (PJM Data Miner 2) | **stub — needs `PJM_API_KEY`** |
| `02_tidy_panel.R` | Join real series → `data/tidy/panel_state_month.{rds,csv}` | working |
| `02_make_sample_panel.R` | SYNTHETIC validation harness (writes `*_SAMPLE.*` only) | working |
| `03_scm.R` | Synthetic control (primary) | needs `tidysynth` |
| `04_did.R` | Event-study DiD (robustness) | working |
| `05_synthdid.R` | Synthetic DiD (bridge) | needs `synthdid` |
| `06_robustness.R` | §7 threats/robustness; leakage; asymmetry | Phase-4 stub |
| `07_figures_tables.R` | `Figures/*.pdf` + `Tables/*.tex` (refuses synthetic input) | working |

## Real vs. synthetic data (hard separation)

- `data/tidy/panel_state_month.*` **only ever contains real data** (`synthetic = FALSE`).
  `02_tidy_panel.R` errors — it does not fall back — when real inputs are missing.
- The synthetic harness (`02_make_sample_panel.R`) writes `panel_state_month_SAMPLE.*`
  with known injected effects (retail +$6/MWh, emissions −12%). Estimation scripts use it
  only with `RGGI_USE_SAMPLE=1`, and then suffix all outputs `_SAMPLE`. Regression guard:
  `RGGI_USE_SAMPLE=1 Rscript scripts/R/04_did.R` should recover ≈ ±6 $/MWh.
- `07_figures_tables.R` refuses to write manuscript artifacts from synthetic data.

## Data vintages

Every fetcher records (source, url, access date, coverage) in `data/raw/VINTAGES.csv`,
which also feeds `Tables/tab_data_sources.tex`. Current vintage (2026-07-19): retail and
CO₂ through **2026-04**; degree days and gas through **2026-06**; auctions through
**#72 (2026-06-03)**. Design constants live in `00_setup.R` (`EVENTS`: entry 2021-01-01,
exit 2023-12-01, reentry_signed 2026-02-20, reentry_regs 2026-04-09, reentry 2026-07-01).

## Data scope

**Public sources only. No Dominion internal data; no SAS.** The Dominion rider series is
entered from **public Virginia SCC dockets** into a small versioned CSV (`data/raw/scc_rider.csv`).
The emissions series is EIA-923-derived (labeled `co2_source = "eia923_derived"`) until an
EPA CAMPD key enables measured CEMS CO₂.

## API keys (optional; free)

The pipeline is fully keyless today except wholesale LMPs:

- `PJM_API_KEY` — register at <https://dataminer2.pjm.com>, create a subscription key at
  apiportal.pjm.com. Unlocks the wholesale (LMP) outcome; until then `lmp = NA`.
- `EPA_CAMPD_API_KEY` — free instant signup at <https://campd.epa.gov>. Upgrades the CO₂
  series from EIA-923-derived to measured CEMS.
- `EIA_API_KEY` — optional; keyless bulk/FRED paths cover current needs.

## Environment

- R 4.3.3. Installed: `data.table`, `ggplot2`, `fixest`, `did`, `modelsummary`, `readxl`,
  `rvest`, `renv`.
- **Install before Phase 3** (not yet present):
  ```r
  install.packages(c("tidysynth", "Synth", "fect", "rprojroot", "arrow"))
  remotes::install_github("synth-inference/synthdid")
  ```
- Pin versions with `renv::snapshot()` once the package set is final.

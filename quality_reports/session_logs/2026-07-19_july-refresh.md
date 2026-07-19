# Session Log: July 2026 Refresh — Refactor + Real Keyless Data + Re-Entry Reframe

**Date:** 2026-07-19
**Branch:** RGGI
**Plan:** `quality_reports/plans/2026-07-19_july-refresh-refactor.md` (APPROVED)
**Continues:** `2026-05-31_rggi-paper-phase0-1.md`

## Goal

(1) Answer "do we have additional data points in July?" — yes: EIA-861M updated 2026-06-25
(adds April 2026), RGGI Auction 72 (2026-06-03) cleared at $35.00 (+40% vs March), and VA's
re-entry took legal effect 2026-07-01 (HB 29 signed 2026-02-20; DEQ final regs 2026-04-09;
one-time six-month control period Jul–Dec 2026, 11.48M-ton budget).
(2) Refactor the pipeline: hard synthetic/real separation (the synthetic harness was written
to the real panel filename — footgun), implement all keyless fetchers, build the real panel
join, add run_all.R + vintage logging, reframe the manuscript's re-entry as occurred (results
still prospective — no post-period outcome data until ~Oct 2026).

## Key decisions

- **No API keys available** (CAMPD/PJM/EIA signups need email verification). Keyless paths:
  861M bulk xlsx (retail), RGGI website (auctions), NOAA CPC (HDD/CDD), FRED fredgraph CSV
  (Henry Hub gas), **EIA-923-derived CO2** (fuel burn × EPA emission factors) as the CEMS
  fallback, labeled `co2_source = "eia923_derived"`. PJM LMP stays pending a key.
- Numbered-script layout retained (econ replication convention) — refactor is behavioral,
  not cosmetic.
- Estimation on real data (03–05) deferred to next session (needs tidysynth/synthdid/scpi).

## Incremental notes

- (start) Plan approved; tasks #1–#6 created.
- EIA-861M Jun-2026 workbook redesign: data sheet now "Monthly-States", residential price
  column header changed "Price" → "Cents/kWh"; fetcher grep updated to accept both.
- RGGI prices-volumes page publishes no data file → parsed the HTML table (rvest); dates
  are ISO format. 82 auctions (1–72 + pilot futures rows); Auction 72 = $35.00 verified.
- EIA-923: current year under /xls/, completed years under /archive/xls/ (301 → HTML
  otherwise); pre-2022 files use "AER Fuel Type Code", newer use "MER". `cached_download`
  now deletes partial downloads (a 60-s-timeout partial zip poisoned the cache) and uses
  a 600-s timeout.
- CO2 factors (kg/MMBtu) documented in 01_fetch_cems.R; biogenic/unknown = 0.
- Sanity checks: VA 2023 retail ≈ $143/MWh (≈14.3 ¢/kWh, matches EIA browser); VA 2023
  power CO2 ≈ 21.6 MM t; WV ≈ 45.8 MM t; in_rggi_va = 35 months (2021-01..2023-11).
- quality_score.py hardcoded Bibliography_base.bib → now resolves the \bibliography{}
  command from the .tex (generic fix, falls back to the default).
- xurl added to preamble (unbreakable bibliography URL caused a 199-pt overfull).

## End-of-session summary

- **Pipeline is real-data end-to-end (keyless):** `Rscript scripts/R/run_all.R` →
  panel_state_month (18 states, 2018-01..2026-04, balanced, synthetic=FALSE, lmp=NA
  pending PJM key); VINTAGES.csv records all five sources (accessed 2026-07-19).
- **Synthetic/real hard separation** implemented (no silent fallback; RGGI_USE_SAMPLE=1;
  _SAMPLE suffixes; 07 refuses synthetic). Sample-mode DiD guard recovers ≈ ±6 $/MWh.
- **Manuscript reframed** for actual re-entry (HB 29 2026-02-20; DEQ regs 2026-04-09;
  effective 2026-07-01, six-month control period); new Fig. allowance prices (Auction 72
  jump visible); tab_data_sources now generated from VINTAGES.csv; 3 new bib entries.
  Compile: 0 errors, 0 undefined citations, 0 bibtex warnings, 1 negligible (3.6 pt)
  overfull. **Quality score: 100/100.**
- **Open:** PJM_API_KEY + EPA_CAMPD_API_KEY (user signup needed); Phase 3 estimation
  package installs; re-entry post-period data from ~Oct 2026; Bibliography_base.bib
  still hook-protected (parallel verified bib remains authoritative).

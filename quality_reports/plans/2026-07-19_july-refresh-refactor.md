# Plan: July 2026 Refresh — Refactor Pipeline, Fetch Real Keyless Data, Reframe Re-Entry

**Date:** 2026-07-19
**Status:** APPROVED (2026-07-19)
**Continues:** `quality_reports/plans/2026-05-30_rggi-paper.md` (Phase 2 of that plan)
**Note:** copy this file to `quality_reports/plans/2026-07-19_july-refresh-refactor.md` at implementation start (repo naming convention).

---

## Context

Two prompts for this pass:

1. **"Do we have additional data points?"** Yes — three things changed since the May 31 session:
   - **EIA-861M** upstream workbook was updated 2026-06-25 (local copy: 2026-05-31, covers through **March 2026**; the new release adds April).
   - **RGGI Auction 72** (June 3, 2026) cleared at **$35.00**, up 40% from March's $24.99 — a large anticipation signal ahead of Virginia's return.
   - **Virginia's re-entry is no longer prospective as a legal event**: HB 29 (Ch. 7, 2026 Acts of Assembly) signed Feb 20, 2026; DEQ final regs adopted Apr 9, 2026; compliance resumed **July 1, 2026** with a one-time six-month control period (Jul–Dec 2026, 11.48M-ton half-year budget; VA sources bid in the Sept and Dec 2026 auctions). Post-re-entry *outcome* data remain essentially nil (retail lags ~2–3 months; CEMS is quarterly), so re-entry **results** stay prospective — but the design section can now cite actual statute/reg dates and a locked pre-period.
   - Larger truth: the real-data pipeline is mostly unbuilt. Only the EIA retail fetcher works; CEMS/PJM/RGGI/weather fetchers are stubs; the analysis panel on disk (`data/tidy/panel_state_month.{rds,csv}`) is the **synthetic test harness written to the real panel's filename** — a footgun this plan removes.

2. **Refactor request.** Structural changes below reflect my preferences; deliberately NOT changed: the numbered-script layout (`00–07`, econ replication-package convention — it's right), the plain-LaTeX + R-writes-tables architecture, and the repo's dual template/project structure.

User decisions (2026-07-19): full keyless fetch; no API keys available — use keyless fallbacks (CAMPD/PJM signups need email verification, so they stay cleanly stubbed).

---

## Changes

### 1. Safety: hard separation of synthetic vs. real data (top priority)

- `scripts/R/02_tidy_panel.R`: **remove the silent synthetic fallback.** `load_panel()` errors with instructions if real tidy inputs are missing; `panel_state_month.{rds,csv}` may only ever contain real data. Implement `build_state_month_panel_real()` (currently a `stop()`): left-join tidy retail + co2 + gas + hdd/cdd on `(state, month)`; `lmp = NA` until a PJM key exists; treatment flags incl. the **second participation window** (`month >= EVENTS$reentry`); QA (coverage, units, balance) and provenance attributes.
- Sample mode becomes explicit: downstream scripts (03–05) read the sample panel only when `RGGI_USE_SAMPLE=1`, and then suffix all outputs `_SAMPLE`. `02_make_sample_panel.R` unchanged in role (writes `*_SAMPLE.*` only).
- `07_figures_tables.R`: refuse to write anything to `Figures/`/`Tables/` from a panel with `synthetic=TRUE`.
- **Delete** the current synthetic `data/tidy/panel_state_month.{rds,csv}` (masquerading as real; `_SAMPLE` copies remain).

### 2. Config & vintages (`00_setup.R`)

- `EVENTS`: reentry no longer "PROSPECTIVE — future"; add `reentry_signed = 2026-02-20` (HB 29) and `reentry_regs = 2026-04-09` (DEQ final regs) for anticipation analyses; comment the six-month control period.
- Keep `SAMPLE_END` an explicit constant (reproducible vintage, not `Sys.Date()`); it stays `2026-06-01` for the panel frame while noting each series' own end.
- New helper `log_vintage(source, url, coverage)` appending to `data/raw/VINTAGES.csv` (source, url, access date, coverage span) — every fetcher calls it. Replaces ad-hoc "record access dates" comments.

### 3. Fetchers (all keyless; shared pattern)

Shared pattern for each `01_fetch_*`: cached download with `RGGI_REFRESH=1` to force re-pull (fixes the current cache-forever bug in `download_eia_861m()`), Last-Modified capture, `log_vintage()`, tidy `.rds` output to `data/tidy/`.

- `01_fetch_eia.R` (working): add refresh logic; re-pull the 2026-06-25 workbook → retail through **April 2026**.
- `01_fetch_rggi.R` (stub → implement): RGGI Inc. "Allowance Prices and Volumes" table (Auctions 1–72) → `data/tidy/allowance_price_q.rds` (auction date, clearing price, quantity, CCR/ECR flags). Feeds the §4 carbon-adder series and a new descriptive anticipation figure.
- `01_fetch_weather_econ.R` (stub → implement, keyless parts):
  - NOAA CPC population-weighted state monthly HDD/CDD (public text files, no key).
  - Henry Hub spot gas via FRED's keyless `fredgraph.csv` export (`DHHNGSP`), monthly-averaged; EIA-API path left as a keyed alternative.
  - BEA/Census annual controls and the SCC rider CSV stay as-is (rider = manual public-docket entry; annual controls are lower priority — not blocking the monthly panel).
- `01_fetch_cems.R` (stub → implement with fallback): monthly state power-sector CO2.
  1. Try EPA CAMPD bulk files with `EPA_CAMPD_API_KEY` if ever set (kept as primary for the future);
  2. **Keyless fallback (what will run now): EIA-923 bulk workbook** — monthly fuel consumption by plant/state × EPA emission factors → estimated CO2, clearly labeled `co2_source = "eia923_derived"` and documented in the Data appendix as the public proxy. Covers through ~April 2026.
- `01_fetch_pjm.R`: stays stubbed (key required). README gains exact signup + `export PJM_API_KEY=...` instructions; manuscript keeps LMP as an outcome whose data are pending.

### 4. Runner & reproducibility

- New `scripts/R/run_all.R`: sources 00 → 01_* → 02 → (03–07 when implemented/packages present) in order, stops on error, writes `sessionInfo()` to `quality_reports/session_logs/` alongside a run log. (Chosen over a Makefile: single-language, works everywhere R does.)
- `renv::snapshot()` still deferred until the Phase-3 estimation packages are installed (per original plan).

### 5. Manuscript reframe (`Paper/rggi_carbon_pricing_reverse.tex`)

- Abstract, §1, §2.2 timeline, §6, §9, App. C: "scheduled to re-enter" → **re-entered July 1, 2026**, citing HB 29 (signed Feb 20, 2026), DEQ final regs (Apr 9, 2026), and the one-time six-month control period (11.48M-ton budget; Sept/Dec 2026 auctions). Results for re-entry remain explicitly prospective — no post-period outcome data yet; the pre-period is now locked, which *strengthens* the pre-analysis plan (App. C).
- Institutional dates/facts go in prose with citations; **market numbers do not** — the Auction-72 anticipation evidence enters as a new R-generated figure (`Figures/fig_allowance_prices.pdf` from `07_figures_tables.R` off the fetched auction series), preserving the no-hand-typed-numbers rule.
- New references (statute, DEQ reg, RGGI CO2 Allowance Tracking/auction results, welcome statement) → `master_supporting_docs/Bibliography_verified.bib` (`Bibliography_base.bib` is still hook-protected; existing TODO stands).

### 6. Docs & state

- `scripts/R/README.md`: new run order, sample-mode env var, refresh flag, key instructions, keyless fallbacks table.
- `CLAUDE.md` "Current Project State": Phase 2 in progress with real data; re-entry occurred 2026-07-01.
- Session log `quality_reports/session_logs/2026-07-19_july-refresh.md` (post-plan + incremental).

---

## Files touched

`scripts/R/{00_setup,01_fetch_eia,01_fetch_cems,01_fetch_rggi,01_fetch_weather_econ,01_fetch_pjm,02_tidy_panel,07_figures_tables}.R` (edit), `scripts/R/run_all.R` (new), `data/tidy/panel_state_month.*` (delete synthetic copies), `Paper/rggi_carbon_pricing_reverse.tex`, `master_supporting_docs/Bibliography_verified.bib`, `scripts/R/README.md`, `CLAUDE.md`, session log + plan copy under `quality_reports/`.

Reuse: fetcher/caching idioms from `01_fetch_eia.R`; `save_result()`/`DIRS` from `00_setup.R`; QA pattern from `qa_panel()` in `02_tidy_panel.R`.

## Out of scope (next session)

- Estimation on real data (03–05) — needs `tidysynth`/`synthdid`/`scpi` installs; run after the real panel lands and passes QA.
- PJM LMPs and CAMPD-primary CO2 (blocked on user-registered keys).
- Re-entry *results* (post-period data start arriving ~Oct 2026: Jul retail in the Sept/Oct 861M releases; Q3 CEMS ~Dec).

## Verification

1. `Rscript scripts/R/run_all.R` completes through `02_tidy_panel.R`; console QA reports a **real** panel (synthetic=FALSE), retail through 2026-04, CO2/gas/HDD-CDD joined, expected 18 states.
2. `data/raw/VINTAGES.csv` has one row per fetched source with today's access date.
3. Spot-check real values against published figures (e.g., VA residential price for a known month vs. EIA browser; Auction 72 = $35.00 in the tidy auction series).
4. Sample mode still works: `RGGI_USE_SAMPLE=1 Rscript scripts/R/04_did.R` recovers the injected +$6/MWh (regression guard for the estimator code).
5. Manuscript: 3-pass pdflatex + bibtex, 0 errors / 0 undefined citations.
6. `python scripts/quality_score.py` ≥ 80 before commit (gate: 90 for PR).

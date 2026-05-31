# ==============================================================================
# 01_fetch_cems.R -- CO2 emissions & generation from EPA CEMS / CAMPD (PUBLIC)
# ==============================================================================
# Source: EPA Clean Air Markets Program Data (CAMPD) hourly emissions.
#   https://campd.epa.gov/  (bulk files + free API key in EPA_CAMPD_API_KEY)
# Plan: pull hourly unit-level CO2 + gross load; aggregate to plant -> state ->
#       PJM-zone, monthly. Heavy: aggregate early, cache tidy monthly panel.
# Output: data/raw/cems_*.parquet; data/tidy/emissions_state_month.parquet
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

fetch_cems_hourly <- function(years = 2018:2026, states = NULL, dest = DIRS$data_raw) {
  # TODO(Phase 2): query CAMPD bulk/API; write per-year parquet.
  stop("Not implemented (Phase 2). Use CAMPD bulk data files.")
}

aggregate_cems_monthly <- function(...) {
  # TODO(Phase 2): hourly -> monthly CO2 by state and by PJM zone.
  stop("Not implemented (Phase 2).")
}

if (sys.nframe() == 0) message("[01_fetch_cems] stub -- implement in Phase 2.")

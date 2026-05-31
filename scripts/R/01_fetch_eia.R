# ==============================================================================
# 01_fetch_eia.R -- retail prices & generation from EIA (PUBLIC)
# ==============================================================================
# Sources:
#   * Form 861M (monthly) and Form 861 (annual): retail price & sales by class.
#       https://www.eia.gov/electricity/data/eia861m/
#   * Form 923: net generation by fuel type.
#       https://www.eia.gov/electricity/data/eia923/
#   * EIA API v2 (Henry Hub etc.) handled in 01_fetch_weather_econ.R.
# Access: bulk zip downloads (no key) OR EIA API v2 (free key in EIA_API_KEY).
# Output: data/raw/eia_*.{csv,parquet}; tidied in 02_tidy_panel.R.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

fetch_eia_861m <- function(years = 2018:2026, dest = DIRS$data_raw) {
  # TODO(Phase 2): download EIA-861M monthly files; bind; write parquet.
  stop("Not implemented (Phase 2). See header for endpoint.")
}

fetch_eia_923 <- function(years = 2018:2026, dest = DIRS$data_raw) {
  # TODO(Phase 2): download EIA-923 generation files; write parquet.
  stop("Not implemented (Phase 2).")
}

if (sys.nframe() == 0) {
  message("[01_fetch_eia] stub -- implement in Phase 2.")
}

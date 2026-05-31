# ==============================================================================
# 01_fetch_weather_econ.R -- weather, gas prices, economic controls, SCC (PUBLIC)
# ==============================================================================
# Sources (all public):
#   * NOAA HDD/CDD: state-month degree days. https://www.ncei.noaa.gov/
#   * Natural gas: EIA Henry Hub & Transco Zone 5 (EIA API v2, EIA_API_KEY).
#   * Economic controls: BEA (income), Census (population, industrial output).
#   * Dominion rider: PUBLIC Virginia SCC dockets (rate-adjustment filings).
#       https://scc.virginia.gov/  -- manual extraction; record docket numbers.
# Output: data/raw/{noaa,gas,bea,census,scc}_*; data/tidy/controls_state_month.parquet
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

fetch_degree_days <- function(...) stop("Not implemented (Phase 2). NOAA NCEI.")
fetch_gas_prices  <- function(...) stop("Not implemented (Phase 2). EIA API v2.")
fetch_econ_controls <- function(...) stop("Not implemented (Phase 2). BEA/Census.")

# Dominion rider: enter PUBLIC SCC docket values into a small versioned CSV.
# (No Dominion internal data.) Template written here; values added in Phase 2.
write_scc_rider_template <- function(path = file.path(DIRS$data_raw, "scc_rider.csv")) {
  template <- data.table(
    effective_date = as.Date(character()),
    rider_dollar_per_month = numeric(),
    docket = character(),
    source_url = character()
  )
  fwrite(template, path)
  message("Wrote SCC rider template: ", path)
}

if (sys.nframe() == 0) message("[01_fetch_weather_econ] stub -- implement in Phase 2.")

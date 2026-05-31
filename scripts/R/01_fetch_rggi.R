# ==============================================================================
# 01_fetch_rggi.R -- allowance auction prices & volumes (PUBLIC)
# ==============================================================================
# Source: RGGI Inc. auction results + Potomac Economics market monitor reports.
#   https://www.rggi.org/auctions/auction-results
# Plan: quarterly clearing price, quantity, CCR/ECR triggers -> the carbon-adder
#       series pi_allow used in the Sec. 4 model and as a treatment-intensity covariate.
# Output: data/raw/rggi_auctions.csv; data/tidy/allowance_price_q.parquet
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

fetch_rggi_auctions <- function(dest = DIRS$data_raw) {
  # TODO(Phase 2): download auction results table; tidy to quarterly series.
  stop("Not implemented (Phase 2).")
}

if (sys.nframe() == 0) message("[01_fetch_rggi] stub -- implement in Phase 2.")

# ==============================================================================
# 02_tidy_panel.R -- assemble the analysis panel from REAL public data
# ==============================================================================
# Joins the tidy outputs of the 01_fetch_* scripts into the state-month panel
# consumed by 03-07. This script writes data/tidy/panel_state_month.{rds,csv}
# and those files may ONLY ever contain real data (synthetic = FALSE).
#
# There is deliberately NO fallback to the synthetic sample here: if real inputs
# are missing the script stops with instructions. The synthetic harness lives in
# 02_make_sample_panel.R (writes *_SAMPLE.* only) and estimation scripts opt into
# it explicitly with RGGI_USE_SAMPLE=1 (see load_analysis_panel in 00_setup.R).
#
# Outcomes: retail ($/MWh), lmp ($/MWh; NA until a PJM key exists), co2
# (million metric tons/month, EIA-923-derived). Covariates: gas, hdd, cdd.
# Treatment flags: va, in_rggi_va (entry..exit, and again >= reentry), rggi_cont.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

ALL_STATES <- c(TREATED_STATE, DONORS_NONRGGI_PJM, DONORS_CONT_RGGI)
REQUIRED_COLS <- c("state", "month", "retail", "lmp", "co2",
                   "gas", "hdd", "cdd", "va", "in_rggi_va", "rggi_cont")

REQUIRED_INPUTS <- c(
  retail = "eia_retail_state_month.rds",     # 01_fetch_eia.R
  co2    = "emissions_state_month.rds",      # 01_fetch_cems.R
  gas    = "gas_price_month.rds",            # 01_fetch_weather_econ.R
  dd     = "degree_days_state_month.rds"     # 01_fetch_weather_econ.R
)
OPTIONAL_INPUTS <- c(lmp = "lmp_zone_month.rds")  # 01_fetch_pjm.R (needs key)

tidy_path <- function(f) file.path(DIRS$data_tidy, f)

build_state_month_panel_real <- function() {
  missing <- REQUIRED_INPUTS[!file.exists(tidy_path(REQUIRED_INPUTS))]
  if (length(missing)) {
    stop("[02_tidy_panel] missing real inputs: ",
         paste(missing, collapse = ", "),
         "\nRun the 01_fetch_* scripts first (see scripts/R/README.md). ",
         "For pipeline validation without real data use the sample harness ",
         "(02_make_sample_panel.R + RGGI_USE_SAMPLE=1).")
  }
  retail <- as.data.table(readRDS(tidy_path(REQUIRED_INPUTS["retail"])))
  co2    <- as.data.table(readRDS(tidy_path(REQUIRED_INPUTS["co2"])))
  gas    <- as.data.table(readRDS(tidy_path(REQUIRED_INPUTS["gas"])))
  dd     <- as.data.table(readRDS(tidy_path(REQUIRED_INPUTS["dd"])))

  # balanced frame: bounded by the shortest required state-level series
  end_by_series <- c(retail = max(retail$month), co2 = max(co2$month),
                     gas = max(gas$month), dd = max(dd$month))
  panel_end <- min(end_by_series)
  message("[02_tidy_panel] series end months: ",
          paste(sprintf("%s=%s", names(end_by_series),
                        format(end_by_series, "%Y-%m")), collapse = ", "),
          " -> panel ends ", format(panel_end, "%Y-%m"))
  frame <- CJ(state = ALL_STATES,
              month = seq(SAMPLE_START, panel_end, by = "month"))

  panel <- retail[, .(state, month, retail)][frame, on = c("state", "month")]
  panel <- co2[, .(state, month, co2)][panel, on = c("state", "month")]
  panel <- dd[, .(state, month, hdd, cdd)][panel, on = c("state", "month")]
  panel <- gas[, .(month, gas)][panel, on = "month"]   # national series

  if (file.exists(tidy_path(OPTIONAL_INPUTS["lmp"]))) {
    lmp <- as.data.table(readRDS(tidy_path(OPTIONAL_INPUTS["lmp"])))
    panel <- lmp[, .(state, month, lmp)][panel, on = c("state", "month")]
  } else {
    panel[, lmp := NA_real_]   # wholesale outcome pending PJM_API_KEY
  }

  panel[, va := as.integer(state == TREATED_STATE)]
  panel[, in_rggi_va := as.integer(state == TREATED_STATE &
          ((month >= EVENTS$entry & month < EVENTS$exit) |
            month >= EVENTS$reentry))]
  panel[, rggi_cont := state %in% DONORS_CONT_RGGI]
  panel[, synthetic := FALSE]

  setcolorder(panel, c(REQUIRED_COLS, "synthetic"))
  setorder(panel, state, month)
  panel[]
}

qa_panel <- function(dt) {
  stopifnot(all(REQUIRED_COLS %in% names(dt)))
  issues <- list()
  miss <- setdiff(ALL_STATES, unique(dt$state))
  if (length(miss)) issues[["missing_states"]] <- miss
  # lmp is expected to be all-NA until a PJM key exists; flag other NA columns
  na_cols <- names(which(colSums(is.na(dt)) > 0))
  lmp_pending <- "lmp" %in% na_cols && all(is.na(dt$lmp))
  na_cols <- setdiff(na_cols, if (lmp_pending) "lmp" else character())
  if (length(na_cols)) issues[["cols_with_NA"]] <- na_cols
  if (any(dt$retail <= 0, na.rm = TRUE)) issues[["nonpos_retail"]] <- TRUE
  per <- dt[, .N, by = state]
  if (uniqueN(per$N) != 1L) issues[["unbalanced"]] <- TRUE
  list(
    n_rows = nrow(dt), n_states = uniqueN(dt$state),
    span = paste(format(min(dt$month)), "..", format(max(dt$month))),
    synthetic = isTRUE(dt$synthetic[1]),
    lmp_pending = lmp_pending,
    issues = issues
  )
}

if (sys.nframe() == 0) {
  panel <- build_state_month_panel_real()
  qa <- qa_panel(panel)
  if (isTRUE(qa$synthetic)) stop("[02_tidy_panel] refusing to write a synthetic panel.")
  saveRDS(panel, file.path(DIRS$data_tidy, "panel_state_month.rds"))
  fwrite(panel, file.path(DIRS$data_tidy, "panel_state_month.csv"))
  message(sprintf("[02_tidy_panel] REAL panel: %d rows, %d states, %s%s",
                  qa$n_rows, qa$n_states, qa$span,
                  if (qa$lmp_pending) "  (lmp pending PJM key)" else ""))
  if (length(qa$issues)) {
    message("  QA issues: ", paste(names(qa$issues), collapse = ", "))
  } else {
    message("  QA: clean (balanced, no unexpected NA, positive prices).")
  }
}

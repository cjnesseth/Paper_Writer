# ==============================================================================
# 02_tidy_panel.R -- assemble the analysis panel (real public data OR sample)
# ==============================================================================
# Prefers real tidy inputs from 01_fetch_* (data/raw/ -> joined here). If those
# are absent (e.g., no-internet dev environment), falls back to the SYNTHETIC
# sample panel from 02_make_sample_panel.R, with a loud warning. Downstream
# estimation (03-07) consumes data/tidy/panel_state_month.rds regardless, so the
# only thing that changes when real data arrive is the source -- not the API.
#
# Outcomes: retail ($/MWh), lmp ($/MWh), co2 (MM tons/month).
# Covariates: gas, hdd, cdd. Treatment flags: va, in_rggi_va, rggi_cont.
# Output: data/tidy/panel_state_month.{rds,csv}  (+ a `synthetic` column)
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

ALL_STATES <- c(TREATED_STATE, DONORS_NONRGGI_PJM, DONORS_CONT_RGGI)
REQUIRED_COLS <- c("state", "month", "retail", "lmp", "co2",
                   "gas", "hdd", "cdd", "va", "in_rggi_va", "rggi_cont")

real_inputs_present <- function() {
  # Real pipeline writes these tidy intermediates; check for the retail series
  # as the bellwether. Extend as 01_fetch_* are run.
  file.exists(file.path(DIRS$data_tidy, "eia_retail_state_month.rds"))
}

build_state_month_panel_real <- function() {
  # TODO(Phase 2, online): left-join tidy EIA / CEMS / PJM / controls on
  # (state, month); construct va / in_rggi_va / rggi_cont; coerce units.
  stop("Real tidy inputs found but the join is not implemented yet (needs online run).")
}

load_panel <- function() {
  if (real_inputs_present()) {
    message("[02_tidy_panel] Using REAL public-data inputs.")
    return(build_state_month_panel_real())
  }
  warning("[02_tidy_panel] No real inputs (offline?). Falling back to SYNTHETIC sample.")
  sample_rds <- file.path(DIRS$data_tidy, "panel_state_month_SAMPLE.rds")
  if (!file.exists(sample_rds)) {
    source(file.path(ROOT, "scripts", "R", "02_make_sample_panel.R"))
    saveRDS(make_sample_panel(), sample_rds)
  }
  readRDS(sample_rds)
}

qa_panel <- function(dt) {
  stopifnot(all(REQUIRED_COLS %in% names(dt)))
  issues <- list()
  miss <- setdiff(ALL_STATES, unique(dt$state))
  if (length(miss)) issues[["missing_states"]] <- miss
  na_cols <- names(which(colSums(is.na(dt)) > 0))
  if (length(na_cols)) issues[["cols_with_NA"]] <- na_cols
  if (any(dt$retail <= 0, na.rm = TRUE)) issues[["nonpos_retail"]] <- TRUE
  # balanced-panel check
  per <- dt[, .N, by = state]
  if (uniqueN(per$N) != 1L) issues[["unbalanced"]] <- TRUE
  list(
    n_rows = nrow(dt), n_states = uniqueN(dt$state),
    span = paste(format(min(dt$month)), "..", format(max(dt$month))),
    synthetic = isTRUE(dt$synthetic[1]),
    issues = issues
  )
}

if (sys.nframe() == 0) {
  panel <- load_panel()
  setorder(panel, state, month)
  saveRDS(panel, file.path(DIRS$data_tidy, "panel_state_month.rds"))
  fwrite(panel, file.path(DIRS$data_tidy, "panel_state_month.csv"))
  qa <- qa_panel(panel)
  message(sprintf("[02_tidy_panel] panel: %d rows, %d states, %s (synthetic=%s)",
                  qa$n_rows, qa$n_states, qa$span, qa$synthetic))
  if (length(qa$issues)) {
    message("  QA issues: ", paste(names(qa$issues), collapse = ", "))
  } else {
    message("  QA: clean (balanced, no NA, positive prices).")
  }
}

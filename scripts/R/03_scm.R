# ==============================================================================
# 03_scm.R -- Synthetic Control Method (PRIMARY estimator)
# ==============================================================================
# Package: tidysynth (requireNamespace guard -- install online).
# Builds a synthetic Virginia for each (outcome, event) and returns the fitted
# object plus gap series, donor weights, and significance (Fisher p-value from
# permutation). Figures/tables are rendered in 07_figures_tables.R.
#
# Windows (from EVENTS in 00_setup.R):
#   entry: pre 2018-01..2020-12 ; treatment_time = 2021-01
#   exit : pre 2021-01..2023-11 ; treatment_time = 2023-12
# Inference: tidysynth placebos (permutation) + (separately) conformal intervals
# per Cattaneo, Feng & Titiunik (2021) via the scpi package when available.
#
# Runs on data/tidy/panel_state_month.rds. If that panel is the SYNTHETIC sample,
# output is labeled SAMPLE and is NOT a manuscript finding.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

# Restrict to the estimation window for an event so tidysynth sees a clean
# pre/post split (entry: baseline+participation; exit: participation+post-exit).
event_window <- function(panel, event = c("entry", "exit")) {
  event <- match.arg(event)
  dt <- as.data.table(panel)
  if (event == "entry") dt[month < EVENTS$exit]        # drop post-exit
  else                  dt[month >= EVENTS$entry]      # drop pre-entry baseline
}

run_scm <- function(panel, outcome, event = c("entry", "exit"),
                    covariates = c("gas", "hdd", "cdd")) {
  event <- match.arg(event)
  if (!requireNamespace("tidysynth", quietly = TRUE))
    stop("Install tidysynth (online): install.packages('tidysynth')")
  if (!requireNamespace("rlang", quietly = TRUE))
    stop("Install rlang: install.packages('rlang')")

  dt <- event_window(panel, event)
  tt <- EVENTS[[event]]                                  # treatment time
  pre <- sort(unique(dt[month < tt, month]))             # pre-treatment periods

  fit <- tidysynth::synthetic_control(
    data        = dt,
    outcome     = !!rlang::sym(outcome),
    unit        = state,
    time        = month,
    i_unit      = TREATED_STATE,
    i_time      = tt,
    generate_placebos = TRUE
  )
  for (cv in covariates) {
    fit <- tidysynth::generate_predictor(
      fit, time_window = pre,
      !!rlang::sym(paste0("mean_", cv)) := mean(!!rlang::sym(cv), na.rm = TRUE)
    )
  }
  fit <- tidysynth::generate_weights(fit, optimization_window = pre)
  fit <- tidysynth::generate_control(fit)
  fit
}

scm_summary <- function(fit) {
  list(
    gaps    = tidysynth::grab_synthetic_control(fit, placebo = FALSE),
    weights = tidysynth::grab_unit_weights(fit),
    signif  = tidysynth::grab_significance(fit)   # Fisher p from placebos
  )
}

if (sys.nframe() == 0) {
  panel <- load_analysis_panel()               # real by default; RGGI_USE_SAMPLE=1 opts in
  tag <- result_tag(panel)                     # "" (real) or "_SAMPLE"
  for (ev in c("entry", "exit")) for (yv in c("retail", "lmp", "co2")) {
    res <- tryCatch(run_scm(panel, yv, ev), error = function(e) {
      message(sprintf("[03_scm] %s/%s skipped: %s", ev, yv, conditionMessage(e))); NULL })
    if (!is.null(res)) save_result(res, sprintf("scm_%s_%s%s", ev, yv, tag))
  }
  message("[03_scm] (", if (nzchar(tag)) "SAMPLE" else "REAL",
          ") done where tidysynth available.")
}

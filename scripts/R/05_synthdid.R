# ==============================================================================
# 05_synthdid.R -- Synthetic Difference-in-Differences (BRIDGE estimator)
# ==============================================================================
# Package: synthdid (requireNamespace guard).
#   remotes::install_github("synth-inference/synthdid")
# synthdid requires a block-treatment structure (treated unit absorbing after
# adoption), so we window each event to a clean adoption:
#   entry: 2018-01..(exit-1), treatment = VA from 2021-01 onward
#   exit : 2021-01..end,      treatment = VA from 2024-01 onward (out of RGGI)
# Reports point estimate + jackknife/placebo SE for each (outcome, event).
#
# Runs on data/tidy/panel_state_month.rds (SYNTHETIC sample -> labeled SAMPLE,
# not a manuscript finding).
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

# Build a long data.frame with a 0/1 absorbing treatment column for the event.
prep_block <- function(panel, outcome, event = c("entry", "exit")) {
  event <- match.arg(event)
  dt <- as.data.table(panel)
  if (event == "entry") {
    dt <- dt[month < EVENTS$exit]
    dt[, D := as.integer(state == TREATED_STATE & month >= EVENTS$entry)]
  } else {
    dt <- dt[month >= EVENTS$entry]
    dt[, D := as.integer(state == TREATED_STATE & month >= EVENTS$exit)]
  }
  dt[, .(state = as.character(state), month = as.integer(month),
         y = get(outcome), D)][order(state, month)]
}

run_synthdid <- function(panel, outcome, event = c("entry", "exit")) {
  event <- match.arg(event)
  if (!requireNamespace("synthdid", quietly = TRUE))
    stop("Install synthdid (online): remotes::install_github('synth-inference/synthdid')")
  df <- as.data.frame(prep_block(panel, outcome, event))
  pm <- synthdid::panel.matrices(df, unit = "state", time = "month",
                                 outcome = "y", treatment = "D")
  est <- synthdid::synthdid_estimate(pm$Y, pm$N0, pm$T0)
  se  <- tryCatch(sqrt(stats::vcov(est, method = "placebo")[1, 1]),
                  error = function(e) NA_real_)
  list(estimate = as.numeric(est), se = se, fit = est)
}

if (sys.nframe() == 0) {
  panel <- load_analysis_panel()               # real by default; RGGI_USE_SAMPLE=1 opts in
  tag <- result_tag(panel)                     # "" (real) or "_SAMPLE"
  for (ev in c("entry", "exit")) for (yv in c("retail", "lmp", "co2")) {
    res <- tryCatch(run_synthdid(panel, yv, ev), error = function(e) {
      message(sprintf("[05_synthdid] %s/%s skipped: %s", ev, yv, conditionMessage(e))); NULL })
    if (!is.null(res)) {
      save_result(res, sprintf("sdid_%s_%s%s", ev, yv, tag))
      message(sprintf("[05_synthdid] (%s) %s/%s: est=%+.3f se=%.3f",
                      if (nzchar(tag)) "SAMPLE" else "REAL", ev, yv, res$estimate, res$se))
    }
  }
}

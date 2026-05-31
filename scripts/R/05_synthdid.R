# ==============================================================================
# 05_synthdid.R -- Synthetic Difference-in-Differences (BRIDGE estimator)
# ==============================================================================
# Package: synthdid (Arkhangelsky et al. 2021).  NOT yet installed -- see README.
# Combines SCM unit reweighting with DiD double-differencing. Run for entry/exit
# on each outcome; report point estimates + placebo/jackknife SEs.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

run_synthdid <- function(panel, outcome, event = c("entry", "exit")) {
  event <- match.arg(event)
  if (!requireNamespace("synthdid", quietly = TRUE))
    stop("Install synthdid: remotes::install_github('synth-inference/synthdid')")
  # TODO(Phase 3): build (N x T) matrices; synthdid_estimate(); vcov via placebo.
  stop("Not implemented (Phase 3).")
}

if (sys.nframe() == 0) message("[05_synthdid] stub -- implement in Phase 3.")

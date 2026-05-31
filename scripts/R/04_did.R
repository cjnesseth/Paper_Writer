# ==============================================================================
# 04_did.R -- Event-study difference-in-differences (ROBUSTNESS)
# ==============================================================================
# Package: fixest (installed).  Implements Eq. (eq:eventstudy) in the paper:
#   Y_st = alpha_s + gamma_t + sum_{tau != -1} beta_tau * 1[s=VA] 1[t-t*=tau]
#          + X_st' delta + e_st
# SEs clustered at state; wild cluster bootstrap (fwildclusterboot or
# fixest's vcov) given few clusters. Run for entry and exit (reentry later).
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

run_event_study <- function(panel, outcome, event_date, controls = NULL,
                            leads = 12, lags = 12) {
  if (!requireNamespace("fixest", quietly = TRUE))
    stop("Install fixest: install.packages('fixest')")
  # TODO(Phase 3): construct relative-time dummies around event_date;
  #   fixest::feols(<outcome> ~ i(rel_time, treat, ref = -1) + controls |
  #                 state + month, cluster = ~state); return model + tidy coefs.
  stop("Not implemented (Phase 3).")
}

if (sys.nframe() == 0) message("[04_did] stub -- implement in Phase 3.")

# ==============================================================================
# 04_did.R -- Event-study difference-in-differences (ROBUSTNESS estimator)
# ==============================================================================
# Implements Eq. (eq:eventstudy):
#   Y_st = alpha_s + gamma_t + sum_{k != -1} beta_k 1[s=VA] 1[t-t*=k]
#          + X_st' delta + e_st
# using fixest (installed). Runs on data/tidy/panel_state_month.rds. In an offline
# dev environment that panel is the SYNTHETIC sample -> outputs are labeled SAMPLE
# and are for pipeline validation only (they must recover the injected effects:
# retail +$6/MWh when VA is in RGGI; emissions -12%). NOT manuscript findings.
#
# Inference caveat: with a single treated unit, cluster-robust SEs are not valid;
# the real pipeline uses SCM permutation + wild cluster bootstrap. Here we report
# point estimates to demonstrate recovery.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))
suppressPackageStartupMessages(library(fixest))

# Build relative-time event-study around a given event date, windowed to +/- win.
run_event_study <- function(panel, outcome, event_date, controls = c("gas","hdd","cdd"),
                            win = 18L) {
  dt <- as.data.table(panel)[, treat := as.integer(state == TREATED_STATE)]
  ev_idx <- function(d) (as.integer(format(d, "%Y")) * 12L + as.integer(format(d, "%m")))
  dt[, rel := ev_idx(month) - ev_idx(event_date)]
  dt <- dt[abs(rel) <= win]
  dt[, rel := factor(rel, levels = sort(unique(rel)))]
  rhs_ctrl <- if (length(controls)) paste("+", paste(controls, collapse = " + ")) else ""
  fml <- as.formula(sprintf("%s ~ i(rel, treat, ref = '-1') %s | state + month",
                            outcome, rhs_ctrl))
  feols(fml, data = dt, warn = FALSE, notes = FALSE)
}

# Average post-event dynamic effect (simple mean of post coefficients).
avg_post_effect <- function(model) {
  ct <- as.data.table(coeftable(model), keep.rownames = "term")
  post <- ct[grepl("rel::", term) & !grepl("rel::-", term)]
  mean(post$Estimate)
}

if (sys.nframe() == 0) {
  panel <- load_analysis_panel()               # real by default; RGGI_USE_SAMPLE=1 opts in
  tag <- result_tag(panel)                     # "" (real) or "_SAMPLE"
  is_synth <- nzchar(tag)
  truth <- list(entry = +6.0, exit = -6.0)  # injected retail effect (sample only)

  lines <- c(sprintf("DiD event study (%s data)", if (is_synth) "SAMPLE" else "REAL"),
             strrep("-", 40))
  for (ev in c("entry", "exit")) {
    m <- run_event_study(panel, "retail", EVENTS[[ev]])
    eff <- avg_post_effect(m)
    save_result(m, sprintf("did_%s_retail%s", ev, tag))
    lines <- c(lines, sprintf("%-6s retail: avg post effect = %+.2f $/MWh%s",
                              ev, eff,
                              if (is_synth) sprintf("  (injected truth %+.1f)", truth[[ev]]) else ""))
  }
  writeLines(lines, file.path(DIRS$results, sprintf("did_summary%s.txt", tag)))
  message(paste(lines, collapse = "\n"))
}

# ==============================================================================
# 03_scm.R -- Synthetic Control Method (PRIMARY estimator)
# ==============================================================================
# Package: tidysynth (preferred) or Synth.  NOT yet installed -- see README.
# Estimates synthetic Virginia for each event and outcome, with inference.
#   Entry window: pre = 2018-01..2020-12 ; post = 2021-01..2023-09
#   Exit  window: pre = 2021-01..2023-09 ; post = 2024-01..2026-06
# Inference: placebo/permutation (donor-as-treated) + conformal prediction
#            intervals (Cattaneo, Feng & Titiunik 2021).
# Saves fitted objects via save_result(); figures/tables built in 07.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

run_scm <- function(panel, outcome, event = c("entry", "exit"),
                    donors = c(DONORS_NONRGGI_PJM, DONORS_CONT_RGGI)) {
  event <- match.arg(event)
  if (!requireNamespace("tidysynth", quietly = TRUE))
    stop("Install tidysynth: install.packages('tidysynth')")
  # TODO(Phase 3): synthetic_control() %>% generate_predictor() %>%
  #   generate_weights() %>% generate_control(); return fit + gaps + placebos.
  stop("Not implemented (Phase 3).")
}

if (sys.nframe() == 0) message("[03_scm] stub -- implement in Phase 3.")

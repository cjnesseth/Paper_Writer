# ==============================================================================
# 00_setup.R -- packages, paths, and shared options for the RGGI pipeline
# ==============================================================================
# Source this at the top of every other script: source("scripts/R/00_setup.R")
# Reproducibility: package versions pinned via renv (renv::snapshot()).
# ==============================================================================

# --- Project root (works from repo root or scripts/R/) ------------------------
if (!nzchar(Sys.getenv("RGGI_ROOT"))) {
  root <- tryCatch(rprojroot::find_root(rprojroot::has_dir("scripts")),
                   error = function(e) getwd())
  Sys.setenv(RGGI_ROOT = root)
}
ROOT <- Sys.getenv("RGGI_ROOT")

# --- Directory layout ---------------------------------------------------------
DIRS <- list(
  data_raw  = file.path(ROOT, "data", "raw"),    # gitignored: large public pulls
  data_tidy = file.path(ROOT, "data", "tidy"),   # cached analysis-ready panels
  results   = file.path(ROOT, "data", "results"),# saved model objects (.rds)
  figures   = file.path(ROOT, "Figures"),        # .pdf figures for the manuscript
  tables    = file.path(ROOT, "Tables")          # .tex tables for the manuscript
)
invisible(lapply(DIRS, dir.create, recursive = TRUE, showWarnings = FALSE))

# --- Packages -----------------------------------------------------------------
# Estimation packages installed on first use in Phase 3 (see scripts/R/README.md):
#   tidysynth / Synth, synthdid, fect  -- not yet installed in this environment.
.pkgs_core <- c("data.table", "ggplot2", "modelsummary", "fixest")
.missing <- setdiff(.pkgs_core, rownames(installed.packages()))
if (length(.missing)) {
  message("Missing core packages: ", paste(.missing, collapse = ", "),
          "\nInstall with: install.packages(c(",
          paste(sprintf('\"%s\"', .missing), collapse = ", "), "))")
}
suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

# --- Analysis constants (single source of truth for the design) ---------------
TREATED_STATE <- "VA"

DONORS_NONRGGI_PJM <- c("WV", "OH", "PA", "KY", "IN", "NC", "TN")
DONORS_CONT_RGGI   <- c("MD", "DE", "NJ", "CT", "MA", "ME", "NH", "VT", "RI", "NY")

EVENTS <- list(
  entry   = as.Date("2021-01-01"),  # VA begins RGGI participation
  exit    = as.Date("2023-12-01"),  # last VA RGGI auction (formal exit)
  reentry = as.Date("2026-07-01")   # PROSPECTIVE -- future as of this draft
)

SAMPLE_START <- as.Date("2018-01-01")
SAMPLE_END   <- as.Date("2026-06-01")  # extend as data become available

# --- Plotting theme -----------------------------------------------------------
theme_set(theme_minimal(base_size = 11))

# --- Helpers ------------------------------------------------------------------
save_result <- function(obj, name) {
  saveRDS(obj, file.path(DIRS$results, paste0(name, ".rds")))
}
read_result <- function(name) {
  readRDS(file.path(DIRS$results, paste0(name, ".rds")))
}

message("[00_setup] ROOT = ", ROOT)

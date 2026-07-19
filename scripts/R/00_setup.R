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
  entry          = as.Date("2021-01-01"),  # VA begins RGGI participation
  exit           = as.Date("2023-12-01"),  # last VA RGGI auction (formal exit)
  reentry_signed = as.Date("2026-02-20"),  # HB 29 (Ch. 7, 2026 Acts) signed
  reentry_regs   = as.Date("2026-04-09"),  # DEQ final regs (9VAC5-140 Pt VIII)
  reentry        = as.Date("2026-07-01")   # compliance resumes; one-time 6-month
                                           # control period Jul-Dec 2026
                                           # (11.48M-ton half-year budget)
)
# Anticipation window for the re-entry design: reentry_signed .. reentry.
# Post-re-entry OUTCOME data lag (retail ~2-3 mo; CEMS quarterly): re-entry
# results remain prospective; pre-period is now locked (see Paper App. C).

SAMPLE_START <- as.Date("2018-01-01")
SAMPLE_END   <- as.Date("2026-06-01")  # explicit vintage constant (not Sys.Date());
                                       # per-series coverage recorded in VINTAGES.csv

# --- Plotting theme -----------------------------------------------------------
theme_set(theme_minimal(base_size = 11))

# --- Helpers ------------------------------------------------------------------
save_result <- function(obj, name) {
  saveRDS(obj, file.path(DIRS$results, paste0(name, ".rds")))
}
read_result <- function(name) {
  readRDS(file.path(DIRS$results, paste0(name, ".rds")))
}

# Download with cache. Re-pull when RGGI_REFRESH=1 (upstream sources update
# monthly/quarterly; a cache hit must be a choice, not a default forever).
cached_download <- function(url, filename, dest = DIRS$data_raw,
                            refresh = identical(Sys.getenv("RGGI_REFRESH"), "1")) {
  out <- file.path(dest, filename)
  if (file.exists(out) && !refresh) {
    message("[fetch] cached (set RGGI_REFRESH=1 to re-pull): ", out)
    return(out)
  }
  old_to <- options(timeout = max(600, getOption("timeout")))  # large bulk files
  on.exit(options(old_to), add = TRUE)
  ok <- tryCatch({
    status <- download.file(url, out, mode = "wb", quiet = TRUE)
    status == 0
  }, error = function(e) {
    message("[fetch] download failed: ", conditionMessage(e)); FALSE
  })
  if (!ok && file.exists(out)) unlink(out)   # never leave a partial file as cache
  if (ok) out else NULL
}

# Record data vintages for replication: one row per (source, access date).
log_vintage <- function(source, url, coverage,
                        path = file.path(DIRS$data_raw, "VINTAGES.csv")) {
  row <- data.table(source = source, url = url, accessed = format(Sys.Date()),
                    coverage = coverage)
  if (file.exists(path)) {
    prev <- fread(path, colClasses = "character")
    prev <- prev[!(source == row$source & accessed == row$accessed)]
    row <- rbind(prev, row, fill = TRUE)
  }
  fwrite(row, path)
  invisible(row)
}

# Load the analysis panel for estimation scripts (03-05).
# Default: the REAL panel; refuses to run if it is missing or synthetic.
# Sample mode (pipeline validation only): set RGGI_USE_SAMPLE=1 -> loads the
# synthetic harness; callers must suffix outputs with result_tag(panel).
load_analysis_panel <- function() {
  sample_mode <- identical(Sys.getenv("RGGI_USE_SAMPLE"), "1")
  f <- file.path(DIRS$data_tidy,
                 if (sample_mode) "panel_state_month_SAMPLE.rds"
                 else             "panel_state_month.rds")
  if (!file.exists(f)) {
    stop("Panel not found: ", f,
         if (sample_mode) "\nRun: Rscript scripts/R/02_make_sample_panel.R"
         else "\nRun the fetchers (01_*) then: Rscript scripts/R/02_tidy_panel.R")
  }
  panel <- readRDS(f)
  if (!sample_mode && isTRUE(panel$synthetic[1])) {
    stop("panel_state_month.rds contains SYNTHETIC data. Delete it and rebuild ",
         "from real inputs via 02_tidy_panel.R (sample runs use RGGI_USE_SAMPLE=1).")
  }
  setattr(panel, "sample_mode", sample_mode)
  panel
}

# Suffix for result/figure/table names: "" for real data, "_SAMPLE" otherwise.
result_tag <- function(panel) {
  if (isTRUE(attr(panel, "sample_mode")) || isTRUE(panel$synthetic[1])) "_SAMPLE" else ""
}

message("[00_setup] ROOT = ", ROOT)

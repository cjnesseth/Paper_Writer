# ==============================================================================
# run_all.R -- one-command rebuild: fetch -> tidy -> (estimate) -> figures/tables
# ==============================================================================
# Usage: Rscript scripts/R/run_all.R          (cached downloads)
#        RGGI_REFRESH=1 Rscript scripts/R/run_all.R   (force re-pull upstream)
# Stops on the first error. Estimation scripts (03-05) run only when their
# packages are installed (they skip gracefully otherwise); 06 is a Phase-4 stub.
# Writes a run log + sessionInfo() to quality_reports/session_logs/.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

SCRIPTS <- c(
  "01_fetch_eia.R",
  "01_fetch_rggi.R",
  "01_fetch_weather_econ.R",
  "01_fetch_cems.R",
  "01_fetch_pjm.R",       # messages + skips without PJM_API_KEY
  "02_tidy_panel.R",
  "03_scm.R",             # skips outcomes gracefully if tidysynth missing
  "04_did.R",
  "05_synthdid.R",        # skips gracefully if synthdid missing
  "06_robustness.R",      # Phase-4 stub
  "07_figures_tables.R"
)

log_dir <- file.path(ROOT, "quality_reports", "session_logs")
log_file <- file.path(log_dir, sprintf("run_all_%s.log", format(Sys.Date())))
con <- file(log_file, open = "wt")
writeLines(sprintf("run_all started %s", format(Sys.time())), con)

for (s in SCRIPTS) {
  message("\n========== ", s, " ==========")
  writeLines(sprintf("[%s] %s", format(Sys.time(), "%H:%M:%S"), s), con)
  status <- system2("Rscript", file.path(ROOT, "scripts", "R", s))
  if (status != 0) {
    writeLines(sprintf("FAILED: %s (exit %d)", s, status), con)
    close(con)
    stop("run_all: ", s, " failed (exit ", status, "). See ", log_file)
  }
}

writeLines(c(sprintf("run_all finished %s", format(Sys.time())), "",
             capture.output(sessionInfo())), con)
close(con)
message("\n[run_all] complete. Log: ", log_file)

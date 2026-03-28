# =============================================================================
# 05_results_baseline.R
# Baseline SFE results: solve symmetric ODE for 3 benchmark years,
# compute Lerner indices, and print results table.
#
# Usage:
#   Rscript Analysis/R/05_results_baseline.R
#
# Expected output: one row per benchmark year with p_star, lerner, and
# comparison to actual clearing price.
# =============================================================================

# Resolve paths relative to this script's location
script_dir <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) "Analysis/R")
})
source(file.path(script_dir, "04_calibrate.R"))
source(file.path(script_dir, "02_sfe_symmetric.R"))

cat("=============================================================\n")
cat("  Baseline SFE Results: Symmetric K=3, ACR=150 $/MW-day\n")
cat("=============================================================\n\n")

# --- Calibration ---
cal_list <- calibrate_all(K = 3, acr = ACR_PLACEHOLDER)
print_calibration_summary(cal_list)

# --- Solve ODE for each benchmark year ---
results <- vector("list", length(cal_list))
names(results) <- names(cal_list)

for (yr in names(cal_list)) {
  cal <- cal_list[[yr]]
  cat(sprintf("Solving ODE for %s ... ", yr))

  res <- tryCatch(
    sfe_summary(cal, K = cal$K),
    error = function(e) {
      cat(sprintf("FAILED: %s\n", e$message))
      NULL
    }
  )

  if (!is.null(res)) {
    cat(sprintf("done. p* = %.2f $/MW-day\n", res$p_star))
    results[[yr]] <- res
  }
}

# --- Results table ---
cat("\n")
cat(strrep("=", 80), "\n")
cat(sprintf("%-10s  %-8s  %-10s  %-10s  %-10s  %-10s  %-8s\n",
            "Year", "Design", "p* ($)", "p_actual ($)", "Lerner", "q_bar (MW)", "note"))
cat(strrep("-", 80), "\n")

for (yr in names(results)) {
  res <- results[[yr]]
  if (is.null(res)) {
    cat(sprintf("%-10s  FAILED\n", yr))
    next
  }
  cat(sprintf("%-10s  %-8s  %-10.2f  %-10.2f  %-10.4f  %-10.1f  %-8s\n",
              yr,
              cal_list[[yr]]$vp$design,
              res$p_star,
              res$p_actual,
              res$lerner,
              res$q_bar,
              substr(res$note, 1, 18)))
}
cat(strrep("=", 80), "\n\n")

# --- Interpretation ---
cat("Notes:\n")
cat("  - p*       : SFE equilibrium clearing price ($/MW-day)\n")
cat("  - p_actual : Observed BRA clearing price ($/MW-day)\n")
cat("  - Lerner   : (p* - ACR) / p*  [ACR = ", ACR_PLACEHOLDER, "$/MW-day]\n")
cat("  - Benchmark years: 2023/24 (low, old VRR), 2025/26 (spike, old),\n")
cat("                     2026/27 (at-cap, new VRR)\n\n")

# --- Save solution objects for downstream scripts (comparative statics) ---
baseline_results <- results
saveRDS(baseline_results, file = file.path(script_dir, "../../Data/cleaned/baseline_results.rds"))
cat("Saved baseline_results.rds to Data/cleaned/\n")

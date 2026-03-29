# =============================================================================
# 08_cost_sensitivity.R
# Cost parameter (c) sensitivity analysis for the symmetric SFE model.
#
# Varies c (marginal cost / ACR) over {100, 125, 150, 175, 200} $/MW-day
# at K = 3, for all three benchmark years. Prints a LaTeX table (Table 5b)
# for insertion into results.tex after tab:K_sensitivity.
#
# Usage:
#   Rscript Analysis/R/08_cost_sensitivity.R
#
# Note on at-cap years:
#   For 2026/27 with K=3, the Holmberg boundary condition forces p* = p_bar
#   (the VRR Point(a) cap) regardless of c, so p* is invariant to c but
#   the Lerner index L = (p* - c) / p* varies.
# =============================================================================

script_dir <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) "Analysis/R")
})
source(file.path(script_dir, "04_calibrate.R"))
source(file.path(script_dir, "02_sfe_symmetric.R"))

# --- Parameters ---
COST_VALS   <- c(100, 125, 150, 175, 200)   # $/MW-day
K_BASELINE  <- 3
YEARS       <- BENCHMARK_YEARS               # from 04_calibrate.R

cat("Cost sensitivity analysis: K =", K_BASELINE, "\n")
cat("c values:", paste(COST_VALS, collapse = ", "), "$/MW-day\n\n")

# --- Load calibration data once ---
df_cal <- load_calibration_data()

# --- Compute results grid ---
rows <- vector("list", length(COST_VALS) * length(YEARS))
idx  <- 1L
for (c_val in COST_VALS) {
  for (yr in YEARS) {
    cal <- calibrate_year(yr, df = df_cal, K = K_BASELINE, acr = c_val)
    res <- tryCatch(
      sfe_summary(cal, K = K_BASELINE),
      error = function(e) {
        warning(sprintf("ODE failed for c=%d, %s: %s", c_val, yr, e$message))
        NULL
      }
    )
    if (!is.null(res)) {
      rows[[idx]] <- data.frame(
        c      = c_val,
        year   = yr,
        p_star = round(res$p_star, 0),
        lerner = round(res$lerner, 2),
        note   = res$note,
        stringsAsFactors = FALSE
      )
    }
    idx <- idx + 1L
  }
}

sens <- do.call(rbind, rows[!sapply(rows, is.null)])

# --- Print raw results ---
cat(sprintf("%-6s  %-10s  %-8s  %-8s  %s\n", "c", "year", "p*", "L", "note"))
cat(strrep("-", 60), "\n")
for (i in seq_len(nrow(sens))) {
  cat(sprintf("%-6d  %-10s  %-8.0f  %-8.2f  %s\n",
              sens$c[i], sens$year[i], sens$p_star[i], sens$lerner[i], sens$note[i]))
}
cat("\n")

# --- Generate LaTeX table ---
cat("% -----------------------------------------------------------------------\n")
cat("% Table 5b: Cost Sensitivity (paste into results.tex after tab:K_sensitivity)\n")
cat("% -----------------------------------------------------------------------\n")
cat("\\begin{table}[ht]\n")
cat("  \\centering\n")
cat("  \\caption{Equilibrium Price and Price-Cost Margin by Cost Assumption ($K = 3$)}\n")
cat("  \\label{tab:cost_sensitivity}\n")
cat("  \\begin{tabular}{l cc cc cc}\n")
cat("    \\hline\\hline\n")
cat("    & \\multicolumn{2}{c}{2023/24 (Old VRR)}\n")
cat("    & \\multicolumn{2}{c}{2025/26 (Old VRR)}\n")
cat("    & \\multicolumn{2}{c}{2026/27 (New VRR)} \\\\\n")
cat("    \\cmidrule(lr){2-3}\\cmidrule(lr){4-5}\\cmidrule(lr){6-7}\n")
cat("    $c$ (\\$/MW-day) & $p^*$ & $L$ & $p^*$ & $L$ & $p^*$ & $L$ \\\\\n")
cat("    \\hline\n")

for (c_val in COST_VALS) {
  row_data <- sens[sens$c == c_val, ]
  cells <- character(0)
  for (yr in YEARS) {
    r <- row_data[row_data$year == yr, ]
    if (nrow(r) == 0) {
      cells <- c(cells, "---", "---")
    } else {
      p_str <- sprintf("\\$%d", r$p_star)
      l_str <- sprintf("%.2f", r$lerner)
      cells <- c(cells, p_str, l_str)
    }
  }
  cat(sprintf("    \\$%d & %s \\\\\n", c_val,
              paste(cells, collapse = " & ")))
}

cat("    \\hline\\hline\n")
cat("  \\end{tabular}\n")
cat("  \\smallskip\n\n")
cat("  \\noindent\\footnotesize\n")
cat("  \\textit{Notes:} $p^*$ is the SFE equilibrium price (\\$/MW-day); $L = (p^* - c)/p^*$.\n")
cat("  $K = 3$ throughout. Baseline calibration uses $c = \\$150$/MW-day (Table~\\ref{tab:baseline}).\n")
cat("  For 2026/27, the Holmberg boundary condition is active for all $c$ values shown, so\n")
cat("  $p^*$ equals the VRR Point~(a) cap (\\$329/MW-day) in all rows; only the Lerner index varies.\n")
cat("\\end{table}\n")

# --- Save RDS ---
out_dir <- file.path(script_dir, "../../Data/cleaned")
saveRDS(sens, file.path(out_dir, "cost_sensitivity_results.rds"))
cat("\nSaved cost_sensitivity_results.rds to Data/cleaned/\n")

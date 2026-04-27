# =============================================================================
# Exploration: Add 2024/25 as fourth benchmark year
# Date: 2026-03-31
#
# Question: Does the SFE model produce sensible results for 2024/25 despite
# the 0.8-month lead time? The auction mechanism is structurally the same.
# =============================================================================

set.seed(20260331)

# --- Source solver infrastructure ---
# Use absolute path to Analysis/R; assign .here globally before each source
# so the internal .here <- local({...}) fallback doesn't break path resolution
ar <- normalizePath("/home/chris/projects/Paper_Writer/Analysis/R")
.here <- ar; source(file.path(ar, "01_vrr_demand.R"))
.here <- ar; source(file.path(ar, "02_sfe_symmetric.R"))

# --- Load data ---
DATA_PATH <- "/home/chris/projects/Paper_Writer/Data/cleaned/calibration_master.csv"
ACR       <- 150  # $/MW-day

df <- read.csv(DATA_PATH, stringsAsFactors = FALSE)
df_rto <- df[df$lda == "RTO", ]

# --- All years with RSI data ---
ALL_YEARS <- c("2023/24", "2024/25", "2025/26", "2026/27")

cat("=============================================================\n")
cat("  Exploration: SFE with 2024/25 included\n")
cat("  K=3, ACR=150 $/MW-day\n")
cat("=============================================================\n\n")

# --- Calibrate and solve each year ---
results <- list()

for (yr in ALL_YEARS) {
  row <- df_rto[df_rto$delivery_year == yr, ]
  if (nrow(row) == 0) { cat(sprintf("  %s: NO DATA\n", yr)); next }
  if (nrow(row) > 1) row <- row[1, ]

  # VRR parameters
  vp <- make_vrr_params(row)

  # Market structure from RSI_3
  total_supply <- row$mw_cleared
  rel_req      <- row$reliability_req_mw
  rsi_3        <- row$rsi_3

  Q_top3   <- total_supply - rsi_3 * rel_req
  q_bar    <- Q_top3 / 3
  Q_fringe <- total_supply - Q_top3

  cat(sprintf("--- %s (design=%s, lead=%.1f mo) ---\n", yr, vp$design, row$lead_time_months))
  cat(sprintf("    RSI_3=%.2f  q_bar=%.0f MW  Q_fringe=%.0f MW  cap_margin=%.1f%%\n",
              rsi_3, q_bar, Q_fringe, row$capacity_margin * 100))

  # Solve ODE
  sol <- solve_sfe_sym(vp, K = 3, c = ACR, q_bar = q_bar)
  eq  <- equilibrium_price(sol, vp, K = 3, Q_fringe = Q_fringe, c_fringe = ACR)

  p_star <- eq$p_star
  lerner <- (p_star - ACR) / p_star

  cat(sprintf("    p*=%.2f  p_actual=%.2f  Lerner=%.4f  %s\n\n",
              p_star, row$clearing_price, lerner, eq$note))

  results[[yr]] <- list(
    year       = yr,
    design     = vp$design,
    lead_time  = row$lead_time_months,
    p_bar      = vp$pa,
    p_star     = p_star,
    p_actual   = row$clearing_price,
    lerner     = lerner,
    q_bar      = q_bar,
    Q_fringe   = Q_fringe,
    rsi_3      = rsi_3,
    cap_margin = row$capacity_margin,
    note       = eq$note
  )
}

# --- Summary table ---
cat("\n")
cat(strrep("=", 95), "\n")
cat(sprintf("%-10s  %-6s  %-6s  %-10s  %-10s  %-10s  %-8s  %-8s  %-18s\n",
            "Year", "Design", "Lead", "p_bar($)", "p*($)", "p_act($)", "Lerner", "CapMgn", "Note"))
cat(strrep("-", 95), "\n")
for (r in results) {
  cat(sprintf("%-10s  %-6s  %4.1fm  %-10.2f  %-10.2f  %-10.2f  %-8.4f  %5.1f%%  %-18s\n",
              r$year, r$design, r$lead_time, r$p_bar, r$p_star,
              r$p_actual, r$lerner, r$cap_margin * 100, substr(r$note, 1, 18)))
}
cat(strrep("=", 95), "\n")

cat("\nKey comparison:\n")
cat("  2023/24 vs 2024/25: Both old-design, both heavily mitigated in practice.\n")
cat("  If p* is similar, 2024/25 adds a confirming data point.\n")
cat("  If p* differs, the VRR parameters (Net CONE, slopes) drive the difference.\n")

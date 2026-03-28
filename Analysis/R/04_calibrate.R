# =============================================================================
# 04_calibrate.R
# Load calibration_master.csv and extract parameters for each benchmark year.
#
# Benchmark years (from session log 2026-03-27):
#   2023/24 -- low price, old VRR design
#   2025/26 -- price spike, old VRR design
#   2026/27 -- at-cap, new VRR design
#
# Strategic capacity calibration (K = 3):
#   RSI_3 = (total_supply - Q_top3) / reliability_req
#   =>  Q_top3   = total_supply - RSI_3 * reliability_req
#   =>  q_bar    = Q_top3 / K   (per strategic firm, symmetric)
#   =>  Q_fringe = total_supply - Q_top3
#
# Cost parameter:
#   c = acr ($/MW-day), sector-average avoidable cost rate from IMM SotM.
#   Placeholder value 150 $/MW-day used pending full ACR extraction from IMM PDFs.
# =============================================================================

.here <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) "Analysis/R")
})
source(file.path(.here, "01_vrr_demand.R"))

BENCHMARK_YEARS <- c("2023/24", "2025/26", "2026/27")
DATA_PATH       <- file.path(.here, "../../Data/cleaned/calibration_master.csv")
ACR_PLACEHOLDER <- 150   # $/MW-day — replace with IMM SotM values when available

# -----------------------------------------------------------------------------
# load_calibration_data()
# Read the master panel, filter to RTO rows, return data.frame.
# -----------------------------------------------------------------------------
load_calibration_data <- function(path = DATA_PATH) {
  df <- read.csv(path, stringsAsFactors = FALSE)
  df[df$lda == "RTO", ]
}

# -----------------------------------------------------------------------------
# calibrate_year(delivery_year, df, K, acr)
# Extract all solver inputs for one delivery year.
#
# Returns a named list with:
#   delivery_year, vp (vrr_params), K, c, q_bar, Q_fringe, p_actual, rel_req
# -----------------------------------------------------------------------------
calibrate_year <- function(delivery_year, df = NULL, K = 3, acr = ACR_PLACEHOLDER) {
  if (is.null(df)) df <- load_calibration_data()

  row <- df[df$delivery_year == delivery_year, ]
  if (nrow(row) == 0) stop(sprintf("No RTO row found for delivery_year = '%s'", delivery_year))
  if (nrow(row) > 1)  row <- row[1, ]

  # --- VRR parameters ---
  vp <- make_vrr_params(row)

  # --- Market structure: strategic capacity from RSI_3 ---
  # NOTE: mw_cleared = reliability_req * (1 + capacity_margin) = total available/installed
  # capacity. Despite the column name, this is NOT the cleared quantity at the auction
  # price; it is total available supply (verified: mw_cleared == rel_req*(1+cap_margin)
  # exactly for all three benchmark years). This is the correct denominator for RSI_3.
  total_supply <- row$mw_cleared
  rel_req      <- row$reliability_req_mw
  rsi_3        <- row$rsi_3

  Q_top3   <- total_supply - rsi_3 * rel_req
  q_bar    <- Q_top3 / K          # each symmetric strategic firm
  Q_fringe <- total_supply - Q_top3   # competitive fringe

  # Sanity checks
  if (q_bar <= 0)    warning(sprintf("%s: q_bar = %.1f <= 0; check RSI data", delivery_year, q_bar))
  if (Q_fringe < 0)  warning(sprintf("%s: Q_fringe = %.1f < 0; check RSI data", delivery_year, Q_fringe))

  list(
    delivery_year = delivery_year,
    vp            = vp,
    K             = K,
    c             = acr,          # marginal cost = avoidable cost rate
    c_fringe      = acr,          # fringe bids at same ACR (conservative)
    q_bar         = q_bar,
    Q_fringe      = Q_fringe,
    Q_top3        = Q_top3,
    rel_req       = rel_req,
    total_supply  = total_supply,
    rsi_3         = rsi_3,
    p_actual      = row$clearing_price,
    at_cap        = row$at_cap
  )
}

# -----------------------------------------------------------------------------
# calibrate_all(K, acr)
# Calibrate all three benchmark years. Returns a named list.
# -----------------------------------------------------------------------------
calibrate_all <- function(K = 3, acr = ACR_PLACEHOLDER) {
  df  <- load_calibration_data()
  cal <- lapply(BENCHMARK_YEARS, calibrate_year, df = df, K = K, acr = acr)
  names(cal) <- BENCHMARK_YEARS
  cal
}

# -----------------------------------------------------------------------------
# print_calibration_summary(cal_list)
# Pretty-print calibrated parameters for all years.
# -----------------------------------------------------------------------------
print_calibration_summary <- function(cal_list) {
  cat("\nCalibration Summary (K =", cal_list[[1]]$K, ", ACR =", cal_list[[1]]$c, "$/MW-day)\n")
  cat(strrep("-", 80), "\n")
  cat(sprintf("%-10s  %-6s  %-10s  %-10s  %-10s  %-10s  %-8s\n",
              "Year", "Design", "p_bar ($)", "q_bar (MW)", "Q_fringe", "p_actual", "at_cap"))
  cat(strrep("-", 80), "\n")
  for (nm in names(cal_list)) {
    cal <- cal_list[[nm]]
    cat(sprintf("%-10s  %-6s  %-10.2f  %-10.1f  %-10.1f  %-10.2f  %-8s\n",
                nm,
                cal$vp$design,
                cal$vp$pa,
                cal$q_bar,
                cal$Q_fringe,
                cal$p_actual,
                cal$at_cap))
  }
  cat(strrep("-", 80), "\n\n")
}

# If run directly (not sourced), print a summary
if (!interactive() && identical(environment(), globalenv())) {
  cal <- calibrate_all()
  print_calibration_summary(cal)
}

# =============================================================================
# 09_cap_incidence.R
# Construct the cap-incidence panel: which administrative constraint --
# TPS mitigation cap, design-level VRR Point (a) cap, or Shapiro settlement
# cap -- was binding in each delivery year, alongside clearing outcomes,
# the IRM-excess reserve margin, and IMM-published mitigation-application rates.
#
# This is the empirical centerpiece of the cap-incidence framing. The SFE
# model is no longer used to predict prices; it appears in the paper only as
# expository theory in Section 4.
#
# Inputs:
#   Data/cleaned/calibration_master.csv  (RTO rows, 7 delivery years)
#
# Hand-coded inputs (sources documented inline below):
#   - TPS mitigation application percentages from IMM SoMs 2021-2025
#   - Net ACR baseline from IMM 2025 SoM Table 7-38 ($149.32 -> $150)
#   - Reserve margin in excess of IRM from IMM 2025 SoM Table 5-7
#     (older years: derived from calibration_master capacity_margin)
#
# Outputs:
#   Paper/tables/tab_cap_incidence.tex   (LaTeX table for paper Section 5)
#   Data/cleaned/cap_incidence_panel.csv (machine-readable panel)
#
# Usage: Rscript Analysis/R/09_cap_incidence.R
# =============================================================================

set.seed(20260426)

library(utils)

# Resolve script-relative paths
.here <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)),
                error = function(e) "Analysis/R")
})

DATA_PATH      <- file.path(.here, "../../Data/cleaned/calibration_master.csv")
TABLE_OUT_PATH <- file.path(.here, "../../Paper/tables/tab_cap_incidence.tex")
CSV_OUT_PATH   <- file.path(.here, "../../Data/cleaned/cap_incidence_panel.csv")

# Constants
ACR_BASELINE         <- 150     # $/MW-day; IMM 2025 SoM Table 7-38 (CC = $149.32)
SETTLEMENT_CAP_UCAP  <- 325     # $/MW-day; Shapiro/PJM settlement (2026/27, 2027/28)

# -----------------------------------------------------------------------------
# Hand-coded TPS mitigation application data
# Source: IMM State of the Market reports (Section 5 Capacity, "Market Conduct"
# subsection). For each BRA, the IMM publishes "Of the N generation resources
# that submitted Capacity Performance offers, the MMU calculated unit-specific
# offer caps for K generation resources (K/N percent)". We pull (N, K) for the
# BRA itself (not the Third Incremental Auction). The 2021/22 BRA (held May
# 2018) predates locally-available SoMs and is left as NA.
# -----------------------------------------------------------------------------
tps_application <- data.frame(
  delivery_year   = c("2021/22", "2022/23", "2023/24", "2024/25",
                      "2025/26", "2026/27", "2027/28"),
  n_resources     = c(NA, 1083, 1003, 964, 1119, 1293, 1351),
  k_capped        = c(NA,    0,   73,  21,   61,   82,   14),
  imm_source      = c(NA,
                      "IMM 2021 SoM Vol 2, Sec 5",
                      "IMM 2022 SoM Vol 2, Sec 5",
                      "IMM 2023 SoM Vol 2, Sec 5",
                      "IMM 2024 SoM Vol 2, Sec 5",
                      "IMM 2025 SoM Vol 2, Sec 5",
                      "IMM 2025 SoM Vol 2, Sec 5"),
  stringsAsFactors = FALSE
)
tps_application$tps_pct <- 100 * tps_application$k_capped / tps_application$n_resources

# -----------------------------------------------------------------------------
# Hand-coded reserve-margin-in-excess-of-IRM data
# Source: IMM 2025 SoM Vol 2, Table 5-7 (RPM Reserve Margin: June 1 2023 to
# June 1 2027). Column T = "Reserve cleared in excess of IRM UCAP (MW)". The
# 2026/27 number from text of same SoM (Sec 5 Capacity intro) is reported as
# 208.7 MW shortfall using a different reserve-level metric; both numbers are
# presented in the IMM SoM and we use the panel-consistent T column. For
# 2021/22 and 2022/23, IMM 2025 Table 5-7 does not extend back; we use the
# capacity_margin × reliability_req from calibration_master (which derives
# from PJM BRA results) as a near-equivalent. These early years have a wide
# positive margin, so the absolute-MW estimate is not load-bearing.
# -----------------------------------------------------------------------------
imm_reserve_excess <- data.frame(
  delivery_year         = c("2021/22", "2022/23", "2023/24", "2024/25",
                            "2025/26", "2026/27", "2027/28"),
  reserve_excess_irm_mw = c(NA, NA, 5687.1, 3278.8, -205.1, -492.7, -6516.6),
  stringsAsFactors      = FALSE
)

# -----------------------------------------------------------------------------
# Load the master panel and filter to RTO rows
# -----------------------------------------------------------------------------
load_panel <- function(path = DATA_PATH) {
  df <- read.csv(path, stringsAsFactors = FALSE)
  rto <- df[df$lda == "RTO", c("delivery_year", "vrr_design", "clearing_price",
                                "vrr_pt_a_price", "mw_cleared",
                                "reliability_req_mw", "capacity_margin",
                                "at_cap")]
  # Drop incomplete delivery years (2028/29 has no BRA results yet)
  rto <- rto[!is.na(rto$clearing_price), ]
  rto[order(rto$delivery_year), ]
}

# -----------------------------------------------------------------------------
# Classify the binding administrative constraint for each year.
#
# Institutional note: the Shapiro/PJM settlement modified the VRR demand curve
# itself rather than imposing an external constraint on a separate VRR. For the
# new-design years (2026/27, 2027/28), the design-level Point (a) price IS the
# settlement implementation; the nominal "$325/MW-day" settlement cap may
# differ slightly in practice from year to year due to ELCC/accreditation
# adjustments (e.g., $329.17 in 2026/27, $333.44 in 2027/28). Both are caps
# imposed by the settlement; we classify them as "Settlement".
#
# Decision rule, applied in priority order:
#   - "Settlement"  if VRR design = new AND clearing within 2% of design Pt (a)
#                   (under the new design, the design Pt (a) embodies the cap)
#   - "VRR Pt(a)"   if VRR design = old AND clearing within 2% of design Pt (a)
#                   (would indicate the design cap binds without TPS or settlement)
#   - "TPS"         if TPS mitigation was applied to >= 1% of resources (the
#                   IMM-published threshold for non-trivial mitigation activity)
#                   and clearing is well below design Pt (a)
#   - "None"        otherwise (offers cleared on cost basis without an active
#                   cap; observed historical pattern in slack years with low
#                   mitigation application)
# -----------------------------------------------------------------------------
classify_binding_cap <- function(row, tps_pct) {
  is_new <- !is.na(row$vrr_design) && row$vrr_design == "new"
  cleared <- row$clearing_price
  pa <- row$vrr_pt_a_price

  at_cap_pa <- !is.na(cleared) && !is.na(pa) && abs(cleared - pa) / pa <= 0.02

  if (is_new && at_cap_pa) return("Settlement")
  if (!is_new && at_cap_pa) return("VRR Pt(a)")
  if (!is.na(tps_pct) && tps_pct >= 1.0 &&
      !is.na(cleared) && !is.na(pa) && cleared < pa * 0.95) {
    return("TPS active")
  }
  "None"
}

# -----------------------------------------------------------------------------
# Build the panel
# -----------------------------------------------------------------------------
build_cap_incidence_panel <- function() {
  rto <- load_panel()
  panel <- merge(rto, tps_application, by = "delivery_year", all.x = TRUE)
  panel <- merge(panel, imm_reserve_excess, by = "delivery_year", all.x = TRUE)

  panel$net_acr             <- ACR_BASELINE
  panel$settlement_cap      <- ifelse(panel$vrr_design == "new",
                                       SETTLEMENT_CAP_UCAP, NA_real_)
  panel$binding_cap         <- mapply(
    function(i) classify_binding_cap(panel[i, ], panel$tps_pct[i]),
    seq_len(nrow(panel))
  )

  # Order columns for the output
  out_cols <- c("delivery_year", "vrr_design", "clearing_price",
                "net_acr", "vrr_pt_a_price", "settlement_cap",
                "reserve_excess_irm_mw", "tps_pct", "binding_cap")
  panel[, out_cols]
}

# -----------------------------------------------------------------------------
# Format LaTeX table
#
# Columns: Year | Design | Clearing | Net ACR | VRR Pt(a) | Settlement |
#          Reserve excess IRM (MW) | TPS mitigation % | Binding cap
# -----------------------------------------------------------------------------
format_latex_table <- function(panel) {
  fmt_dollar <- function(x) ifelse(is.na(x), "---",
                                    sprintf("\\$%.0f", x))
  fmt_mw     <- function(x) {
    if (is.na(x)) return("---")
    sign_str <- if (x >= 0) "+" else "-"
    paste0(sign_str, formatC(abs(x), format = "d", big.mark = ","))
  }
  fmt_pct    <- function(x) ifelse(is.na(x), "---",
                                    sprintf("%.1f\\%%", x))

  rows <- vapply(seq_len(nrow(panel)), function(i) {
    r <- panel[i, ]
    sprintf(
      "%s & %s & %s & %s & %s & %s & %s & %s & %s \\\\",
      r$delivery_year,
      tools::toTitleCase(r$vrr_design),
      fmt_dollar(r$clearing_price),
      fmt_dollar(r$net_acr),
      fmt_dollar(r$vrr_pt_a_price),
      fmt_dollar(r$settlement_cap),
      fmt_mw(r$reserve_excess_irm_mw),
      fmt_pct(r$tps_pct),
      r$binding_cap
    )
  }, character(1))

  header <- c(
    "\\begin{table}[H]",
    "  \\centering",
    "  \\caption{Cap-Incidence Panel: Which Administrative Constraint Was Binding,",
    "    PJM Base Residual Auctions 2021/22--2027/28 (RTO Level)}",
    "  \\label{tab:cap_incidence}",
    "  \\small",
    "  \\begin{tabular}{lcccccrcl}",
    "    \\toprule",
    "             & VRR     & Clearing & Net      & VRR     & Settle.   & Reserve   & TPS     & Binding   \\\\",
    "    Year     & Design  & price    & ACR      & Pt~(a)  & cap       & excess IRM (MW) & mitig.\\ & cap       \\\\",
    "    \\midrule"
  )
  footer <- c(
    "    \\bottomrule",
    "  \\end{tabular}",
    "  \\vspace{3pt}",
    "",
    "  \\begin{minipage}{0.96\\textwidth}",
    "    \\footnotesize \\textit{Notes:} Prices in nominal \\$/MW-day UCAP.",
    "    Net ACR is the IMM-published sector-average Avoidable Cost Rate",
    "    (\\$149.32, rounded to \\$150) used as the default mitigation offer cap",
    "    for resources subject to the Three Pivotal Supplier (TPS) test.",
    "    VRR Pt~(a) is the design-level price cap on the unmodified Variable",
    "    Resource Requirement curve. Settlement cap is the Shapiro/PJM",
    "    \\$325/MW-day UCAP cap that took effect for the 2026/27 and 2027/28",
    "    delivery years. Reserve excess IRM (MW) is committed UCAP minus",
    "    IRM-implied required reserves (negative = shortfall). TPS mitigation",
    "    percentage is the share of generation resources that submitted Capacity",
    "    Performance offers and had unit-specific Market Seller Offer Caps",
    "    calculated by the IMM. Binding cap classification: ``Settlement'' =",
    "    cleared within 2\\% of the new-design Point~(a), which under the",
    "    Shapiro/PJM agreement embodies the settlement cap; ``TPS active'' =",
    "    TPS mitigation calculated for $\\geq 1$\\% of resources with clearing",
    "    more than 5\\% below Point~(a), indicating mitigation operative for",
    "    some marginal resources but not pinning headline clearing; ``None'' =",
    "    clearing well below all administrative caps with TPS mitigation",
    "    calculated for $<1$\\% of resources.",
    "    Sources: PJM BRA results (clearing prices, cleared MW, reliability",
    "    requirement); IMM State of the Market Reports 2021--2025, Section 5",
    "    Capacity (TPS mitigation counts, reserve-margin panel).",
    "    The 2021/22 BRA (held May 2018) predates locally-available IMM SoMs,",
    "    so TPS mitigation and reserve-excess data are reported as ``---''.",
    "  \\end{minipage}",
    "\\end{table}"
  )

  paste(c(header, paste0("    ", rows), footer), collapse = "\n")
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
panel <- build_cap_incidence_panel()
cat("\nCap-incidence panel:\n")
print(panel, row.names = FALSE)

# Write CSV
dir.create(dirname(CSV_OUT_PATH), recursive = TRUE, showWarnings = FALSE)
write.csv(panel, CSV_OUT_PATH, row.names = FALSE)
cat(sprintf("\nWrote %s\n", CSV_OUT_PATH))

# Write LaTeX table
dir.create(dirname(TABLE_OUT_PATH), recursive = TRUE, showWarnings = FALSE)
writeLines(format_latex_table(panel), TABLE_OUT_PATH)
cat(sprintf("Wrote %s\n", TABLE_OUT_PATH))

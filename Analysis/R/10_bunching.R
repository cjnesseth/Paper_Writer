# =============================================================================
# 10_bunching.R
# Aggregate bunching diagnostic: distribution of offer-cap categories across
# delivery years, derived from the IMM State of the Market Reports
# (Table 5-18 in the 2025 SoM, Table 5-14/5-16 equivalents in prior SoMs).
#
# The question this addresses: "Do offers cluster near the binding cap?"
# Without unit-level offer-price data (released by PJM with a 3-year lag, so
# 2026/27 and 2027/28 unit-level data will not be public until 2029-2030),
# the most direct evidence available is the IMM-published offer-cap-category
# distribution. This shows where each generation resource sits in the
# offer-mitigation regime: Default ACR cap (offer = unit's avoidable cost),
# unit-specific calculated cap, uncapped planned, or price-taker (offer = $0).
#
# The diagnostic IS NOT a histogram of offer prices near the cap (which would
# require unit-level data). It IS a clean panel showing how the offer-cap
# composition shifted across regimes, which directly addresses the question
# of whether observed pricing reflects a regime change in the binding
# administrative constraint vs a behavioral shift in seller strategy.
#
# Hand-coded inputs (sources documented inline below):
#   IMM SoM 2021 (Table 5-13/5-14)  -> 2022/23 BRA
#   IMM SoM 2022 (Table 5-14)        -> 2023/24 BRA
#   IMM SoM 2023 (Table 5-14)        -> 2024/25 BRA
#   IMM SoM 2024 (Table 5-16)        -> 2025/26 BRA
#   IMM SoM 2025 (Table 5-18)        -> 2026/27 and 2027/28 BRAs
#
# Outputs:
#   Figures/fig_bunching.pdf              (stacked bar by delivery year)
#   Paper/tables/tab_bunching.tex         (LaTeX panel)
#   Data/cleaned/offer_structure_panel.csv
#
# Usage: Rscript Analysis/R/10_bunching.R
# =============================================================================

set.seed(20260426)

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
})

.here <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)),
                error = function(e) "Analysis/R")
})

FIG_OUT_PATH   <- file.path(.here, "../../Figures/fig_bunching.pdf")
TABLE_OUT_PATH <- file.path(.here, "../../Paper/tables/tab_bunching.tex")
CSV_OUT_PATH   <- file.path(.here, "../../Data/cleaned/offer_structure_panel.csv")

# Project palette (matches r-code-conventions.md)
primary_dark   <- "#2c3e50"
primary_blue   <- "#2980b9"
accent_gray    <- "#7f8c8d"
positive_green <- "#27ae60"
negative_red   <- "#c0392b"
highlight_orange <- "#e67e22"

# -----------------------------------------------------------------------------
# Hand-coded offer-cap distribution panel from IMM SoMs
#
# Categories collapsed for visualization:
#   Cost-cap (Default ACR or, for 2022/23, Net CONE x B which served the
#       same role under the old methodology -- the resource's cost-basis
#       offer ceiling).
#   Unit-specific cap calculated (the IMM headline "mitigation applied"
#       count: APIR ACR, non-APIR ACR, standalone CPQR, opportunity cost,
#       and combinations thereof).
#   Uncapped planned (Planned Generation Capacity Resources permitted to
#       offer above default cost basis).
#   Price taker (offer at $0; accepts clearing price).
#   Other (offer cap of 1.1x BRA clearing price elected; other minor
#       categories).
#
# The 2021/22 BRA (held May 2018) predates locally-available SoMs and is
# omitted from this diagnostic.
# -----------------------------------------------------------------------------
offer_panel <- data.frame(
  delivery_year      = c("2022/23", "2023/24", "2024/25", "2025/26",
                         "2026/27", "2027/28"),
  vrr_design         = c("Old", "Old", "Old", "Old", "New", "New"),
  total_resources    = c(1083, 1003, 964, 1119, 1293, 1351),
  cost_cap_n         = c(872,   612,  715,  729,  735,  929),  # Default ACR or Net CONE x B
  unit_specific_n    = c(0,      73,   21,   61,   82,   14),
  uncapped_planned_n = c(35,     17,   17,   25,   26,   45),
  price_taker_n      = c(132,   271,  205,  303,  450,  363),
  other_n            = c(44,     30,    6,    1,    0,    0),  # rounding; "1.1x BRA price" elected option, etc.
  imm_source         = c("IMM 2021 SoM Table 5-13",
                          "IMM 2022 SoM Table 5-14",
                          "IMM 2023 SoM Table 5-14",
                          "IMM 2024 SoM Table 5-16",
                          "IMM 2025 SoM Table 5-18",
                          "IMM 2025 SoM Table 5-18"),
  stringsAsFactors   = FALSE
)

# Compute percentages
for (col in c("cost_cap", "unit_specific", "uncapped_planned",
              "price_taker", "other")) {
  offer_panel[[paste0(col, "_pct")]] <-
    100 * offer_panel[[paste0(col, "_n")]] / offer_panel$total_resources
}

cat("\nOffer-structure panel (counts):\n")
print(offer_panel[, c("delivery_year", "vrr_design", "total_resources",
                      "cost_cap_n", "unit_specific_n", "uncapped_planned_n",
                      "price_taker_n", "other_n")], row.names = FALSE)
cat("\nOffer-structure panel (percentages):\n")
print(offer_panel[, c("delivery_year", "cost_cap_pct", "unit_specific_pct",
                      "uncapped_planned_pct", "price_taker_pct", "other_pct")],
      row.names = FALSE, digits = 2)

# -----------------------------------------------------------------------------
# Figure: stacked bar chart of offer-cap categories by delivery year
# -----------------------------------------------------------------------------
plot_data <- offer_panel %>%
  select(delivery_year, vrr_design,
         `Cost-basis cap`         = cost_cap_pct,
         `Unit-specific cap`      = unit_specific_pct,
         `Uncapped planned`       = uncapped_planned_pct,
         `Price taker`            = price_taker_pct,
         `Other`                  = other_pct) %>%
  pivot_longer(cols = -c(delivery_year, vrr_design),
               names_to = "category", values_to = "pct") %>%
  mutate(category = factor(category,
    levels = c("Price taker", "Cost-basis cap", "Unit-specific cap",
               "Uncapped planned", "Other")))

cap_palette <- c(
  "Price taker"       = accent_gray,
  "Cost-basis cap"    = primary_blue,
  "Unit-specific cap" = highlight_orange,
  "Uncapped planned"  = positive_green,
  "Other"             = "#bdc3c7"
)

theme_paper <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title       = element_text(face = "bold", size = base_size + 2),
      axis.title       = element_text(size = base_size),
      legend.position  = "bottom",
      panel.grid.minor = element_blank()
    )
}

p <- ggplot(plot_data, aes(x = delivery_year, y = pct, fill = category)) +
  geom_col(position = "stack", width = 0.7) +
  geom_text(
    data = plot_data %>% filter(category == "Cost-basis cap"),
    aes(label = sprintf("%.0f%%", pct), y = pct / 2),
    color = "white", size = 3.2, fontface = "bold"
  ) +
  geom_vline(xintercept = 4.5, linetype = "dashed", color = primary_dark) +
  annotate("text", x = 4.5, y = 105, label = "Settlement cap takes effect",
           hjust = 0.5, vjust = 0, size = 3, color = primary_dark) +
  scale_y_continuous(breaks = seq(0, 100, 20),
                     labels = function(x) paste0(x, "%"),
                     limits = c(0, 110)) +
  scale_fill_manual(values = cap_palette) +
  labs(
    x = "Delivery Year",
    y = "Share of generation resources offered",
    fill = "Offer-cap category"
  ) +
  theme_paper(base_size = 11)

dir.create(dirname(FIG_OUT_PATH), recursive = TRUE, showWarnings = FALSE)
ggsave(FIG_OUT_PATH, p, width = 6.5, height = 4.0, dpi = 300)
cat(sprintf("\nWrote %s\n", FIG_OUT_PATH))

# Save panel CSV
dir.create(dirname(CSV_OUT_PATH), recursive = TRUE, showWarnings = FALSE)
write.csv(offer_panel, CSV_OUT_PATH, row.names = FALSE)
cat(sprintf("Wrote %s\n", CSV_OUT_PATH))

# -----------------------------------------------------------------------------
# LaTeX table
# -----------------------------------------------------------------------------
fmt_pct <- function(x) sprintf("%.1f\\%%", x)
fmt_int <- function(x) formatC(x, format = "d", big.mark = ",")

rows <- vapply(seq_len(nrow(offer_panel)), function(i) {
  r <- offer_panel[i, ]
  sprintf(
    "%s & %s & %s & %s & %s & %s & %s & %s \\\\",
    r$delivery_year,
    r$vrr_design,
    fmt_int(r$total_resources),
    fmt_pct(r$price_taker_pct),
    fmt_pct(r$cost_cap_pct),
    fmt_pct(r$unit_specific_pct),
    fmt_pct(r$uncapped_planned_pct),
    fmt_pct(r$other_pct)
  )
}, character(1))

table_lines <- c(
  "\\begin{table}[H]",
  "  \\centering",
  "  \\caption{Aggregate Offer-Cap Distribution Across Delivery Years",
  "    (Generation Resources, RTO Level)}",
  "  \\label{tab:bunching}",
  "  \\small",
  "  \\begin{tabular}{lccccccc}",
  "    \\toprule",
  "          & VRR    & Total      & Price  & Cost-basis & Unit-spec.\\ & Uncapped & Other \\\\",
  "    Year  & Design & resources  & taker  & cap        & cap          & planned  &       \\\\",
  "    \\midrule",
  paste0("    ", rows),
  "    \\bottomrule",
  "  \\end{tabular}",
  "  \\vspace{3pt}",
  "",
  "  \\begin{minipage}{0.96\\textwidth}",
  "    \\footnotesize \\textit{Notes:} Each cell reports the share of generation",
  "    resources submitting Capacity Performance offers in that BRA that fall in",
  "    the indicated offer-cap category. ``Price taker'' = offer at \\$0,",
  "    accepting clearing price. ``Cost-basis cap'' = Default ACR (or, for the",
  "    2022/23 BRA under the old methodology, Net CONE~$\\times$~B), the",
  "    resource's cost-basis offer ceiling. ``Unit-specific cap'' = IMM-calculated",
  "    cap above the default (APIR ACR, non-APIR ACR, standalone CPQR,",
  "    opportunity cost, or combinations); this is the headline ``TPS mitigation''",
  "    count of Section~\\ref{sec:cap_incidence}. ``Uncapped planned'' = Planned",
  "    Generation Capacity Resources permitted to offer above the default cost",
  "    basis. ``Other'' includes the offer-cap option of 1.1$\\times$ BRA clearing",
  "    price (available under old methodology only) and minor combinations.",
  "    The 2021/22 BRA (held May 2018) predates locally-available IMM SoMs and is",
  "    omitted. Sources: IMM State of the Market Reports 2021--2025, Section~5",
  "    Capacity, Tables 5-13/5-14/5-16/5-18 in the respective annual volumes.",
  "  \\end{minipage}",
  "\\end{table}"
)

dir.create(dirname(TABLE_OUT_PATH), recursive = TRUE, showWarnings = FALSE)
writeLines(table_lines, TABLE_OUT_PATH)
cat(sprintf("Wrote %s\n", TABLE_OUT_PATH))

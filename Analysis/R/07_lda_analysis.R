# =============================================================================
# 07_lda_analysis.R
# LDA-level SFE analysis: calibrate and solve symmetric SFE for each
# Locational Deliverability Area (LDA) in the three benchmark years.
#
# Calibration strategy (CETL-based, distinct from RTO RSI-3 approach):
#   Q_fringe = cetl_mw        -- import capacity is the competitive fringe
#   q_bar    = (rel_req - cetl_mw) / K  -- strategic sellers cover local gap
#   c        = acr ($/MW-day) -- same ACR floor as RTO calibration
#
# Benchmark years: 2023/24 (old VRR), 2025/26 (old VRR), 2026/27 (new VRR)
#
# Outputs:
#   Data/cleaned/lda_results.rds   -- full panel of LDA-year results
#   Figures/fig05_lda_lerner.pdf   -- Lerner by LDA, grouped by year
#   Figures/fig06_cetl_scatter.pdf -- import penetration vs Lerner scatter
# =============================================================================

library(ggplot2)
library(dplyr)
library(tidyr)

set.seed(20260328)

.here <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) "Analysis/R")
})

source(file.path(.here, "01_vrr_demand.R"))
source(file.path(.here, "02_sfe_symmetric.R"))

# --- Paths ---
DATA_PATH  <- file.path(.here, "../../Data/cleaned/calibration_master.csv")
FIG_DIR    <- file.path(.here, "../../Figures")
DATA_OUT   <- file.path(.here, "../../Data/cleaned")

BENCHMARK_YEARS <- c("2023/24", "2025/26", "2026/27")
ACR             <- 150    # $/MW-day -- CC technology-average from 2025 IMM SotM
K_BASE          <- 3      # baseline strategic sellers (TPS threshold)

# --- Visual identity (matches 06_comparative_statics.R palette) ---
primary_dark     <- "#2c3e50"
primary_blue     <- "#2980b9"
accent_gray      <- "#7f8c8d"
positive_green   <- "#27ae60"
negative_red     <- "#c0392b"
highlight_orange <- "#e67e22"

YEAR_COLORS <- c("2023/24" = primary_blue,
                 "2025/26" = highlight_orange,
                 "2026/27" = negative_red)

theme_paper <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title   = element_text(face = "bold", size = base_size + 2),
      axis.title   = element_text(size = base_size),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

# =============================================================================
# calibrate_lda(row, K, acr)
# Extract solver inputs for one LDA-year row using CETL-based market structure.
# Returns NULL if data are insufficient or q_bar <= 0.
# =============================================================================
calibrate_lda <- function(row, K = K_BASE, acr = ACR) {
  cetl    <- suppressWarnings(as.numeric(row$cetl_mw))
  rel_req <- suppressWarnings(as.numeric(row$reliability_req_mw))

  # Skip RTO (no CETL) or rows with missing/invalid data
  if (is.na(cetl) || is.na(rel_req)) return(NULL)

  # Skip LDAs where CETL alone meets or exceeds reliability requirement
  # (imports cover everything; no room for strategic sellers)
  q_bar <- (rel_req - cetl) / K
  if (q_bar <= 0) return(NULL)

  vp <- tryCatch(make_vrr_params(row), error = function(e) NULL)
  if (is.null(vp)) return(NULL)

  list(
    delivery_year = as.character(row$delivery_year),
    lda           = as.character(row$lda),
    vp            = vp,
    K             = K,
    c             = acr,
    c_fringe      = acr,
    q_bar         = q_bar,
    Q_fringe      = cetl,
    rel_req       = rel_req,
    cetl          = cetl,
    import_ratio  = cetl / rel_req,
    p_actual      = suppressWarnings(as.numeric(row$clearing_price))
  )
}

# =============================================================================
# solve_lda(cal)
# Run ODE + equilibrium finder for one calibrated LDA.
# Returns a one-row data.frame of summary results.
# =============================================================================
solve_lda <- function(cal) {
  res <- tryCatch({
    sol <- solve_sfe_sym(
      vp    = cal$vp,
      K     = cal$K,
      c     = cal$c,
      q_bar = cal$q_bar,
      p_min = cal$c + 1
    )
    equilibrium_price(sol, cal$vp, cal$K, cal$Q_fringe, cal$c_fringe)
  }, error = function(e) {
    list(p_star = NA_real_, note = paste("error:", conditionMessage(e)))
  })

  lerner <- if (!is.na(res$p_star) && res$p_star > 0) {
    (res$p_star - cal$c) / res$p_star
  } else {
    NA_real_
  }

  data.frame(
    delivery_year = cal$delivery_year,
    lda           = cal$lda,
    design        = cal$vp$design,
    p_bar         = cal$vp$pa,
    q_bar         = cal$q_bar,
    Q_fringe      = cal$Q_fringe,
    import_ratio  = cal$import_ratio,
    rel_req       = cal$rel_req,
    K             = cal$K,
    p_star        = res$p_star,
    p_actual      = cal$p_actual,
    lerner        = lerner,
    note          = res$note,
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# Main: load data, calibrate all LDA-year pairs, solve, collect results
# =============================================================================

cat("Loading calibration data...\n")
df_all <- read.csv(DATA_PATH, stringsAsFactors = FALSE)
df_bm  <- df_all[df_all$delivery_year %in% BENCHMARK_YEARS & df_all$lda != "RTO", ]

cat(sprintf("Panel: %d LDA-year rows across %d benchmark years\n",
            nrow(df_bm), length(BENCHMARK_YEARS)))

# Calibrate
cat("Calibrating LDA market structures...\n")
cal_list <- lapply(seq_len(nrow(df_bm)), function(i) calibrate_lda(df_bm[i, ]))
cal_list <- Filter(Negate(is.null), cal_list)
cat(sprintf("  %d LDA-year cells with valid calibrations\n", length(cal_list)))

# Solve
cat("Solving SFE equilibria...\n")
results_list <- lapply(cal_list, solve_lda)
results      <- do.call(rbind, results_list)
results$at_cap <- results$p_star >= (results$p_bar - 0.5)  # within $0.50 of cap

# --- Summary to console ---
cat("\nLDA Results (K =", K_BASE, ", ACR =", ACR, "$/MW-day)\n")
cat(strrep("-", 90), "\n")
cat(sprintf("%-8s  %-14s  %-8s  %-8s  %-8s  %-8s  %-8s  %-6s\n",
            "Year", "LDA", "Design", "p_bar", "p*", "p_actual", "Lerner", "Note"))
cat(strrep("-", 90), "\n")
for (i in seq_len(nrow(results))) {
  r <- results[i, ]
  cat(sprintf("%-8s  %-14s  %-8s  %-8.2f  %-8.2f  %-8.2f  %-8.3f  %s\n",
              r$delivery_year, r$lda, r$design,
              r$p_bar, r$p_star, r$p_actual, r$lerner, r$note))
}
cat(strrep("-", 90), "\n\n")

# --- Save RDS ---
saveRDS(results, file.path(DATA_OUT, "lda_results.rds"))
cat("Saved: Data/cleaned/lda_results.rds\n")

# =============================================================================
# Figure 5: Lerner index by LDA, grouped bar chart
# =============================================================================

# Select LDAs present in all 3 benchmark years with valid Lerner values
lda_counts <- results %>%
  filter(!is.na(lerner)) %>%
  group_by(lda) %>%
  summarise(n_years = n_distinct(delivery_year), .groups = "drop") %>%
  filter(n_years == length(BENCHMARK_YEARS))

plot_df5 <- results %>%
  filter(lda %in% lda_counts$lda, !is.na(lerner))

# Order LDAs by 2026/27 Lerner, descending
lda_order <- plot_df5 %>%
  filter(delivery_year == "2026/27") %>%
  arrange(desc(lerner)) %>%
  pull(lda)

# Fall back to 2025/26 order for any LDA missing 2026/27
missing_lda <- setdiff(unique(plot_df5$lda), lda_order)
if (length(missing_lda) > 0) {
  supplement <- plot_df5 %>%
    filter(lda %in% missing_lda, delivery_year == "2025/26") %>%
    arrange(desc(lerner)) %>%
    pull(lda)
  lda_order <- c(lda_order, supplement)
}

plot_df5$lda <- factor(plot_df5$lda, levels = lda_order)
plot_df5$delivery_year <- factor(plot_df5$delivery_year, levels = BENCHMARK_YEARS)

fig5 <- ggplot(plot_df5, aes(x = lda, y = lerner, fill = delivery_year)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.65) +
  geom_hline(yintercept = 0, linewidth = 0.4, linetype = "dashed", colour = accent_gray) +
  scale_fill_manual(values = YEAR_COLORS, name = "Delivery Year") +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.01),
                     limits = c(0, 0.75), expand = expansion(mult = c(0, 0.05))) +
  labs(
    title = "SFE Lerner Index by LDA (K = 3, ACR = $150/MW-day)",
    x = NULL,
    y = "Lerner Index (p* - c) / p*"
  ) +
  theme_paper() +
  theme(
    axis.text.x  = element_text(angle = 35, hjust = 1, size = 9),
    legend.title = element_text(size = 10)
  )

ggsave(file.path(FIG_DIR, "fig05_lda_lerner.pdf"),
       fig5, width = 6.5, height = 4.5, dpi = 300)
cat("Saved: Figures/fig05_lda_lerner.pdf\n")

# =============================================================================
# Figure 6: Import penetration ratio vs Lerner index
# =============================================================================

plot_df6 <- results %>%
  filter(!is.na(lerner), !is.na(import_ratio)) %>%
  mutate(delivery_year = factor(delivery_year, levels = BENCHMARK_YEARS),
         design        = factor(design, levels = c("old", "new", "new_4pt"),
                                labels = c("Old (3-pt)", "New (2-pt)", "New (4-pt)")))

fig6 <- ggplot(plot_df6,
               aes(x = import_ratio, y = lerner,
                   colour = delivery_year, shape = design)) +
  geom_point(size = 2.5, alpha = 0.85) +
  geom_smooth(aes(group = delivery_year, colour = delivery_year, shape = NULL),
              method = "lm", se = FALSE, linewidth = 0.6, linetype = "dashed") +
  geom_hline(yintercept = 0, linewidth = 0.4, colour = accent_gray) +
  scale_colour_manual(values = YEAR_COLORS, name = "Delivery Year") +
  scale_shape_manual(values = c(16, 17, 15), name = "VRR Design") +
  scale_x_continuous(labels = scales::label_percent(accuracy = 1),
                     limits = c(0, 1), expand = expansion(mult = c(0.02, 0.02))) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.01),
                     limits = c(0, 0.75), expand = expansion(mult = c(0, 0.05))) +
  labs(
    title = "Import Penetration and Market Power by LDA",
    x = "Import Penetration (CETL / Reliability Requirement)",
    y = "Lerner Index (p* - c) / p*"
  ) +
  theme_paper()

ggsave(file.path(FIG_DIR, "fig06_cetl_scatter.pdf"),
       fig6, width = 6.5, height = 4.5, dpi = 300)
cat("Saved: Figures/fig06_cetl_scatter.pdf\n")

# =============================================================================
# LaTeX table: Lerner by LDA and benchmark year
# =============================================================================

# Pivot to wide: rows = LDA, cols = (design, lerner) for each year
tbl <- results %>%
  filter(!is.na(lerner)) %>%
  select(lda, delivery_year, design, lerner, at_cap) %>%
  mutate(
    cell = sprintf("%.2f%s", lerner, ifelse(at_cap, "$^{\\dag}$", ""))
  ) %>%
  select(lda, delivery_year, cell) %>%
  pivot_wider(names_from = delivery_year, values_from = cell, values_fill = "--")

# Sort by 2026/27 Lerner (descending); numeric sort, not cell string
sort_key <- results %>%
  filter(delivery_year == "2026/27", !is.na(lerner)) %>%
  select(lda, lerner) %>%
  arrange(desc(lerner))

# Include all LDAs; unsorted ones go at end
lda_sorted <- c(sort_key$lda,
                setdiff(unique(results$lda), sort_key$lda))
tbl <- tbl[match(lda_sorted, tbl$lda), ]
tbl <- tbl[!is.na(tbl$lda), ]

# Ensure column order
year_cols <- intersect(BENCHMARK_YEARS, colnames(tbl))
tbl <- tbl[, c("lda", year_cols)]

# Write LaTeX table
tex_lines <- c(
  "% Auto-generated by 07_lda_analysis.R -- do not edit",
  "\\begin{table}[ht]",
  "  \\centering",
  "  \\caption{SFE Lerner Index by LDA and Benchmark Year ($K = 3$, $c = \\$150$/MW-day)}",
  "  \\label{tab:lda_lerner}",
  "  \\begin{tabular}{lccc}",
  "    \\hline\\hline",
  "    LDA & 2023/24 & 2025/26 & 2026/27 \\\\",
  "    \\hline"
)

for (i in seq_len(nrow(tbl))) {
  r <- tbl[i, ]
  vals <- sapply(year_cols, function(y) if (!is.null(r[[y]]) && !is.na(r[[y]])) r[[y]] else "--")
  tex_lines <- c(tex_lines,
    sprintf("    %s & %s & %s & %s \\\\",
            r$lda, vals[1], vals[2], vals[3]))
}

tex_lines <- c(tex_lines,
  "    \\hline\\hline",
  "  \\end{tabular}",
  "  \\smallskip",
  "",
  "  \\noindent\\footnotesize",
  "  \\textit{Notes:} $K = 3$ strategic sellers per LDA. $c = \\$150$/MW-day (CC technology-average ACR,",
  "  2025 IMM SotM). Market structure calibrated using $\\bar{Q}_f = \\text{CETL}$ (competitive imports)",
  "  and $\\bar{q} = (\\text{rel.~req.} - \\text{CETL})/K$ (strategic sellers cover local gap).",
  "  $^{\\dag}$~Market clears at or within \\$0.50 of the VRR price cap.",
  "\\end{table}"
)

dir.create(file.path(.here, "../../Paper/tables"), showWarnings = FALSE, recursive = TRUE)
writeLines(tex_lines, file.path(.here, "../../Paper/tables/tab_lda_lerner.tex"))
cat("Saved: Paper/tables/tab_lda_lerner.tex\n")

cat("\nDone.\n")

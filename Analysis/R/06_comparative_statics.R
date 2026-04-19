# =============================================================================
# 06_comparative_statics.R
# Four comparative statics:
#   CS1. Vary K (number of strategic sellers): K = 2 to 10
#   CS2. Vary VRR slope: ±50% of baseline slope
#   CS3. Vary fringe supply (CETL proxy): ±30% of baseline Q_fringe
#
# Produces four figures saved to Figures/ and an RDS for downstream use.
# =============================================================================

set.seed(20260328)

script_dir <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) "Analysis/R")
})
source(file.path(script_dir, "04_calibrate.R"))
source(file.path(script_dir, "02_sfe_symmetric.R"))

suppressPackageStartupMessages(library(ggplot2))

# --- Output directory ---
fig_dir <- file.path(script_dir, "../../Figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

# --- Paper visual theme ---
primary_dark     <- "#2c3e50"
primary_blue     <- "#2980b9"
accent_gray      <- "#7f8c8d"
positive_green   <- "#27ae60"
negative_red     <- "#c0392b"
highlight_orange <- "#e67e22"

theme_paper <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title    = element_text(face = "bold", size = base_size + 2),
      axis.title    = element_text(size = base_size),
      legend.position = "bottom",
      panel.grid.minor = element_blank(),
      panel.border  = element_rect(colour = "grey70", fill = NA, linewidth = 0.4)
    )
}

YEAR_COLORS <- c(
  "2021/22" = "#1a5276",     # dark navy
  "2022/23" = "#5dade2",     # light blue
  "2023/24" = "#27ae60",     # dark green
  "2024/25" = "#f5b041",     # light amber
  "2025/26" = "#c0392b",     # dark red
  "2026/27" = "#e67e22",     # light orange
  "2027/28" = "#2c3e50"      # dark charcoal
)
YEAR_SHAPES <- c("2021/22" = 0, "2022/23" = 1, "2023/24" = 2,
                 "2024/25" = 6, "2025/26" = 17, "2026/27" = 15, "2027/28" = 8)

cal_list <- calibrate_all(K = 3, acr = ACR_BASELINE)

cat("Running comparative statics...\n\n")

# =============================================================================
# CS1: Supply function curves — plot s(p) vs. p for K=3, all three years
# =============================================================================
cat("CS1: Supply function plots...\n")

sf_rows <- lapply(names(cal_list), function(yr) {
  cal <- cal_list[[yr]]
  sol <- solve_sfe_sym(cal$vp, K = 3, c = cal$c, q_bar = cal$q_bar, p_min = cal$c + 1)
  cbind(sol, year = yr, stringsAsFactors = FALSE)
})
sf_df <- do.call(rbind, sf_rows)

# Also compute VRR demand curves for reference
vrr_rows <- lapply(names(cal_list), function(yr) {
  cal  <- cal_list[[yr]]
  vp   <- cal$vp
  p_seq <- seq(cal$c + 1, vp$pa, length.out = 500)
  d_seq <- sapply(p_seq, vrr_demand_scalar, vp = vp)
  data.frame(p = p_seq, d = d_seq, year = yr, stringsAsFactors = FALSE)
})
vrr_df <- do.call(rbind, vrr_rows)

p_cs1 <- ggplot() +
  geom_line(data = sf_df,  aes(x = s / 1000, y = p, color = year, linetype = "SFE s(p)"), size = 0.8) +
  geom_line(data = vrr_df, aes(x = d / 1000, y = p, color = year, linetype = "VRR D(p)"), size = 0.6, alpha = 0.5) +
  scale_color_manual(values = YEAR_COLORS, name = "Delivery year") +
  scale_linetype_manual(values = c("SFE s(p)" = "solid", "VRR D(p)" = "dashed"), name = NULL) +
  labs(
    title    = "Symmetric SFE Supply Functions and VRR Demand",
    subtitle = "K = 3 strategic sellers, ACR = $150/MW-day",
    x        = "Capacity (GW)",
    y        = "Price ($/MW-day)"
  ) +
  theme_paper()

ggsave(file.path(fig_dir, "fig01_supply_functions.pdf"),
       p_cs1, width = 6.5, height = 4.5, dpi = 300)
cat("  Saved fig01_supply_functions.pdf\n")

# =============================================================================
# CS2: Vary K from 2 to 10 — p* and Lerner index
# =============================================================================
cat("CS2: K sensitivity...\n")

K_seq <- 2:10
cs2_rows <- lapply(names(cal_list), function(yr) {
  cal <- cal_list[[yr]]
  lapply(K_seq, function(K) {
    cal_k <- cal; cal_k$K <- K
    # q_bar fixed (structural capacity), only K changes in ODE
    res <- tryCatch(sfe_summary(cal_k, K = K), error = function(e) NULL)
    if (is.null(res)) return(NULL)
    data.frame(year = yr, K = K, p_star = res$p_star, lerner = res$lerner,
               note = res$note, stringsAsFactors = FALSE)
  })
})
cs2_df <- do.call(rbind, do.call(c, cs2_rows))
cs2_df <- cs2_df[!is.na(cs2_df$K), ]

# Mark at-cap outcomes
cs2_df$at_cap <- grepl("cap", cs2_df$note)

p_cs2a <- ggplot(cs2_df, aes(x = K, y = p_star, color = year, shape = year)) +
  geom_line(size = 0.8) +
  geom_point(size = 2.5) +
  geom_point(data = cs2_df[cs2_df$at_cap, ], aes(x = K, y = p_star),
             shape = 8, size = 3, color = accent_gray) +
  scale_color_manual(values = YEAR_COLORS, name = "Delivery year") +
  scale_shape_manual(values = YEAR_SHAPES, name = "Delivery year") +
  labs(
    title    = "Equilibrium Price vs. Number of Strategic Sellers",
    subtitle = "Star markers = cleared at price cap",
    x        = "Number of strategic sellers (K)",
    y        = "Equilibrium price ($/MW-day)"
  ) +
  theme_paper()

p_cs2b <- ggplot(cs2_df, aes(x = K, y = lerner, color = year, shape = year)) +
  geom_line(size = 0.8) +
  geom_point(size = 2.5) +
  scale_color_manual(values = YEAR_COLORS, name = "Delivery year") +
  scale_shape_manual(values = YEAR_SHAPES, name = "Delivery year") +
  scale_x_continuous(
    breaks   = 2:10,
    sec.axis = sec_axis(
      transform = ~ 10000 / .x,
      name   = "HHI (= 10,000 / K)",
      breaks = 10000 / (2:10),
      labels = as.character(round(10000 / (2:10)))
    )
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Lerner Index vs. Number of Strategic Sellers",
    x     = "Number of strategic sellers (K)",
    y     = "Lerner index (p* - c) / p*"
  ) +
  theme_paper()

ggsave(file.path(fig_dir, "fig02a_K_price.pdf"),  p_cs2a, width = 6.5, height = 4.5, dpi = 300)
ggsave(file.path(fig_dir, "fig02b_K_lerner.pdf"), p_cs2b, width = 6.5, height = 4.5, dpi = 300)
cat("  Saved fig02a_K_price.pdf, fig02b_K_lerner.pdf\n")

# =============================================================================
# CS3: Vary VRR slope — multiply slope by factor f ∈ [0.5, 2.0]
# Only applies to the sloped segment between pa and pb (or pa and pf).
# =============================================================================
cat("CS3: VRR slope sensitivity...\n")

slope_factors <- seq(0.5, 2.0, by = 0.1)

cs3_rows <- lapply(names(cal_list), function(yr) {
  cal <- cal_list[[yr]]
  lapply(slope_factors, function(f) {
    vp_new <- cal$vp
    # Scale qb toward qa to steepen/flatten the slope:
    # slope ∝ (qb - qa) → multiply by f
    if (vp_new$design == "old") {
      qb_delta <- f * (vp_new$qb - vp_new$qa)
      vp_new$qb <- vp_new$qa + qb_delta
      vp_new$qc <- vp_new$qb + f * (cal$vp$qc - cal$vp$qb)
    } else {
      qb_delta  <- f * (vp_new$qb - vp_new$qa)
      vp_new$qb <- vp_new$qa + qb_delta
    }
    cal_new      <- cal
    cal_new$vp   <- vp_new
    res <- tryCatch(sfe_summary(cal_new, K = 3), error = function(e) NULL)
    if (is.null(res)) return(NULL)
    data.frame(year = yr, slope_factor = f, p_star = res$p_star,
               lerner = res$lerner, note = res$note, stringsAsFactors = FALSE)
  })
})
cs3_df <- do.call(rbind, do.call(c, cs3_rows))
cs3_df <- cs3_df[!is.null(cs3_df$p_star) & !is.na(cs3_df$p_star), ]

p_cs3 <- ggplot(cs3_df, aes(x = slope_factor, y = lerner, color = year, shape = year)) +
  geom_line(size = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 1, linetype = "dashed", color = accent_gray, size = 0.5) +
  scale_color_manual(values = YEAR_COLORS, name = "Delivery year") +
  scale_shape_manual(values = YEAR_SHAPES, name = "Delivery year") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title    = "Lerner Index vs. VRR Slope Scaling Factor",
    subtitle = "1.0 = baseline slope; <1 = flatter VRR; >1 = steeper VRR",
    x        = "VRR slope scaling factor",
    y        = "Lerner index"
  ) +
  theme_paper()

ggsave(file.path(fig_dir, "fig03_vrr_slope.pdf"), p_cs3, width = 6.5, height = 4.5, dpi = 300)
cat("  Saved fig03_vrr_slope.pdf\n")

# =============================================================================
# CS4: Vary fringe supply Q_fringe (proxy for import/CETL capacity)
# =============================================================================
cat("CS4: Fringe supply (CETL) sensitivity...\n")

fringe_factors <- seq(0.7, 1.5, by = 0.05)

cs4_rows <- lapply(names(cal_list), function(yr) {
  cal <- cal_list[[yr]]
  lapply(fringe_factors, function(f) {
    cal_new          <- cal
    cal_new$Q_fringe <- f * cal$Q_fringe
    res <- tryCatch(sfe_summary(cal_new, K = 3), error = function(e) NULL)
    if (is.null(res)) return(NULL)
    data.frame(year = yr, fringe_factor = f, p_star = res$p_star,
               lerner = res$lerner, note = res$note, stringsAsFactors = FALSE)
  })
})
cs4_df <- do.call(rbind, do.call(c, cs4_rows))
cs4_df <- cs4_df[!is.null(cs4_df$p_star) & !is.na(cs4_df$p_star), ]

p_cs4 <- ggplot(cs4_df, aes(x = fringe_factor, y = lerner, color = year, shape = year)) +
  geom_line(size = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 1, linetype = "dashed", color = accent_gray, size = 0.5) +
  scale_color_manual(values = YEAR_COLORS, name = "Delivery year") +
  scale_shape_manual(values = YEAR_SHAPES, name = "Delivery year") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title    = "Lerner Index vs. Fringe Supply (Import Capacity Proxy)",
    subtitle = "1.0 = baseline fringe; >1 = more competitive imports",
    x        = "Fringe supply scaling factor",
    y        = "Lerner index"
  ) +
  theme_paper()

ggsave(file.path(fig_dir, "fig04_fringe.pdf"), p_cs4, width = 6.5, height = 4.5, dpi = 300)
cat("  Saved fig04_fringe.pdf\n")

# =============================================================================
# Save all comparative statics data for results.tex
# =============================================================================
cs_results <- list(
  supply_functions = sf_df,
  vrr_curves       = vrr_df,
  K_sensitivity    = cs2_df,
  slope_sensitivity = cs3_df,
  fringe_sensitivity = cs4_df,
  calibration      = cal_list
)
saveRDS(cs_results, file.path(script_dir, "../../Data/cleaned/cs_results.rds"))

cat("\nAll comparative statics complete. Figures saved to Figures/\n")
cat("Data saved to Data/cleaned/cs_results.rds\n\n")

# --- Print summary table for results.tex ---
cat("=== K sensitivity summary (for Table in results.tex) ===\n")
for (yr in names(cal_list)) {
  cat(sprintf("\n%s:\n", yr))
  sub_df <- cs2_df[cs2_df$year == yr & cs2_df$K %in% c(2,3,4,5,7,10), ]
  for (i in seq_len(nrow(sub_df))) {
    cat(sprintf("  K=%d  p*=%.1f  L=%.3f  %s\n",
                sub_df$K[i], sub_df$p_star[i], sub_df$lerner[i],
                ifelse(sub_df$at_cap[i], "[AT CAP]", "")))
  }
}

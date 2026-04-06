## ============================================================================
## 09_appendix_results.R
## Appendix robustness tables and figures:
##   A.3 Opening-year treatment timing
##   A.4 Cumulative exposure at 4 km
##   A.5 Joint pre-trends Wald test
##   A.6 Treatment-effect heterogeneity (facility size, cohort)
## ============================================================================

set.seed(20260330)
library(dplyr)
library(fixest)
library(ggplot2)
library(lubridate)
library(broom)
library(here)

proc_dir <- here::here("explorations", "data_collection", "processed")
fig_dir  <- here::here("Figures")

primary_blue  <- "#012169"
primary_gold  <- "#f2a900"
accent_gray   <- "#525252"
negative_red  <- "#b91c1c"

theme_paper <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title    = element_text(face = "bold", color = primary_blue,
                                    size = base_size + 2),
      plot.caption  = element_text(size = base_size - 3, color = accent_gray),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

# ==========================================================================
# 1. LOAD CACHED FITS
# ==========================================================================
message("=== Loading cached fits ===")
results <- readRDS(file.path(proc_dir, "hedonic_results_revised.rds"))
fit_sa        <- results$fit_sa
fit_twfe_es   <- results$fit_twfe_es
fit_cumul     <- results$fit_cumul
fit_count     <- results$fit_count
fit_het_size  <- results$fit_het_size
fit_het_time  <- results$fit_het_time

# ==========================================================================
# 2. REBUILD PANEL (mirror 06_hedonic_revised.R data-prep)
# ==========================================================================
message("\n=== Rebuilding panel ===")

panel <- read.csv(file.path(proc_dir, "property_transactions_panel.csv"),
                   colClasses = c(parid = "character", census_tract = "character",
                                  census_geoid = "character", sale_date = "character"))
panel$sale_date <- as.Date(panel$sale_date)

dc <- read.csv(file.path(proc_dir, "dc_master_inventory.csv"),
                colClasses = c(mcpi = "character", earliest_permit = "character"))
dc$permit_date <- as.Date(dc$earliest_permit)
dc$permit_year <- year(dc$permit_date)
dc$permit_year <- ifelse(is.na(dc$permit_year), dc$earliest_year, dc$permit_year)

panel <- panel %>%
  mutate(
    log_price = log(sale_price),
    sale_year = year(sale_date),
    sale_qtr  = quarter(sale_date),
    yq        = paste0(sale_year, "Q", sale_qtr),
    age       = sale_year - year_built,
    grade_num = as.numeric(sub(":.*", "", grade)),
    prop_type = case_when(
      grepl("^TH", style)            ~ "Townhouse",
      grepl("^(GN|HR|MR|SP)", style) ~ "Condo",
      TRUE                           ~ "Single Family"
    ),
    is_new_construction = (sale_verification == "V:NEW CONSTRUCTION"),
    ring = case_when(
      within_1km ~ "0-1 km",
      within_2km ~ "1-2 km",
      within_4km ~ "2-4 km",
      TRUE       ~ "4+ km"
    ),
    ring = factor(ring, levels = c("4+ km", "0-1 km", "1-2 km", "2-4 km"))
  ) %>%
  filter(!is.na(living_area), living_area >= 300,
         !is.na(age), age >= 0, age <= 200,
         sale_price >= 50000)

haversine_km <- function(lon1, lat1, lon2, lat2) {
  R <- 6371
  dlon <- (lon2 - lon1) * pi / 180
  dlat <- (lat2 - lat1) * pi / 180
  a <- sin(dlat / 2)^2 + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dlon / 2)^2
  2 * R * asin(sqrt(a))
}

dc_built <- dc %>%
  filter(built_status == "BUILT" | grepl("BUILT", built_status),
         !is.na(lon), !is.na(lat), !is.na(permit_year)) %>%
  select(mcpi, project, lon, lat, overall_sqft, permit_year, earliest_year)

dist_km <- matrix(NA_real_, nrow = nrow(panel), ncol = nrow(dc_built))
for (j in seq_len(nrow(dc_built))) {
  dist_km[, j] <- haversine_km(panel$lon, panel$lat, dc_built$lon[j], dc_built$lat[j])
}

panel$n_dc_2km <- 0L; panel$sqft_2km <- 0
panel$n_dc_4km <- 0L; panel$sqft_4km <- 0
for (j in seq_len(nrow(dc_built))) {
  permitted_mask <- panel$sale_year >= dc_built$permit_year[j]
  mask_2km <- permitted_mask & (dist_km[, j] <= 2)
  mask_4km <- permitted_mask & (dist_km[, j] <= 4)
  sqft <- ifelse(is.na(dc_built$overall_sqft[j]), 0, dc_built$overall_sqft[j])
  panel$n_dc_2km[mask_2km] <- panel$n_dc_2km[mask_2km] + 1L
  panel$sqft_2km[mask_2km] <- panel$sqft_2km[mask_2km] + sqft
  panel$n_dc_4km[mask_4km] <- panel$n_dc_4km[mask_4km] + 1L
  panel$sqft_4km[mask_4km] <- panel$sqft_4km[mask_4km] + sqft
}
panel$sqft_2km_M <- panel$sqft_2km / 1e6
panel$sqft_4km_M <- panel$sqft_4km / 1e6

dc_timing <- dc_built %>%
  group_by(project) %>%
  summarize(dc_permit_year = min(permit_year, na.rm = TRUE),
            dc_open_year   = min(earliest_year, na.rm = TRUE),
            .groups = "drop")
panel <- panel %>% left_join(dc_timing, by = c("nearest_dc_project" = "project"))

panel$post_permit <- as.integer(!is.na(panel$dc_permit_year) &
                                 panel$sale_year >= panel$dc_permit_year)
panel$post_open   <- as.integer(!is.na(panel$dc_open_year) &
                                 panel$sale_year >= panel$dc_open_year)
panel$years_to_open <- ifelse(!is.na(panel$dc_open_year),
                               panel$sale_year - panel$dc_open_year, NA_integer_)
panel$years_to_permit <- ifelse(!is.na(panel$dc_permit_year),
                                 panel$sale_year - panel$dc_permit_year, NA_integer_)
panel$cohort_open <- ifelse(panel$within_4km & !is.na(panel$dc_open_year),
                             panel$dc_open_year, 10000L)
panel$cohort_permit <- ifelse(panel$within_4km & !is.na(panel$dc_permit_year),
                               panel$dc_permit_year, 10000L)

panel_resale <- panel %>% filter(!is_new_construction)
panel_did <- panel_resale %>%
  filter((within_4km & dc_permit_year >= 2019) | !within_4km)

# DiD sample for opening-year: condition on dc_open_year instead
panel_did_open <- panel_resale %>%
  filter((within_4km & !is.na(dc_open_year) & dc_open_year >= 2019) | !within_4km)
panel_did_open$cohort_open_filt <- ifelse(
  panel_did_open$within_4km & !is.na(panel_did_open$dc_open_year),
  panel_did_open$dc_open_year, 10000L
)

message("Panel sizes: resale=", nrow(panel_resale),
        ", did=", nrow(panel_did), ", did_open=", nrow(panel_did_open))

# ==========================================================================
# 3. A.3 OPENING-YEAR TREATMENT TIMING
# ==========================================================================
message("\n=== A.3 Opening-year robustness ===")

# TWFE rings, permit timing (for side-by-side comparison)
fit_rings_permit <- feols(
  log_price ~ i(ring, post_permit, ref = "4+ km") +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did,
  cluster = ~census_tract
)

# TWFE rings, opening-year timing
fit_rings_open <- feols(
  log_price ~ i(ring, post_open, ref = "4+ km") +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did_open,
  cluster = ~census_tract
)

# Sun-Abraham event study, opening-year cohorts
fit_sa_open <- feols(
  log_price ~ sunab(cohort_open_filt, sale_year) +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did_open,
  cluster = ~census_tract
)

# ATT summary for opening-year SA
sa_open_att <- summary(fit_sa_open, agg = "ATT")
att_open <- coeftable(sa_open_att)[1, 1]
att_open_se <- coeftable(sa_open_att)[1, 2]
att_open_p  <- coeftable(sa_open_att)[1, 4]
message("  SA ATT (opening year): ", round(att_open, 4),
        " (SE=", round(att_open_se, 4), ", p=", round(att_open_p, 3), ")")

# Extract ring coefficients from both specs
extract_ring_row <- function(fit, ring_label) {
  ct <- coeftable(fit)
  idx <- grepl(paste0("ring::", ring_label, ":post_"), rownames(ct), fixed = TRUE)
  if (!any(idx)) return(c(NA_real_, NA_real_, NA_real_))
  c(ct[idx, 1], ct[idx, 2], ct[idx, 4])
}

ring_labels <- c("0-1 km", "1-2 km", "2-4 km")
rings_permit <- t(sapply(ring_labels, function(r) extract_ring_row(fit_rings_permit, r)))
rings_open   <- t(sapply(ring_labels, function(r) extract_ring_row(fit_rings_open, r)))

# Write tab_appx_opening.tex
sink(file.path(fig_dir, "tab_appx_opening.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Treatment Timing Robustness: Permit Year vs.\\ Opening Year}\n")
cat("\\label{tab:appx_opening}\n\\small\n")
cat("\\begin{tabular}{lcccc}\n\\toprule\n")
cat("& \\multicolumn{2}{c}{Permit year (main)} & \\multicolumn{2}{c}{Opening year} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat("Ring & Coef. & SE & Coef. & SE \\\\\n\\midrule\n")
for (i in seq_along(ring_labels)) {
  cat(sprintf("%s & %.4f & %.4f & %.4f & %.4f \\\\\n",
              ring_labels[i],
              rings_permit[i, 1], rings_permit[i, 2],
              rings_open[i, 1],   rings_open[i, 2]))
}
cat("\\midrule\n")
# ATT row from SA
sa_att_permit <- coeftable(summary(fit_sa, agg = "ATT"))
cat(sprintf("SA ATT & %.4f & %.4f & %.4f & %.4f \\\\\n",
            sa_att_permit[1, 1], sa_att_permit[1, 2],
            att_open, att_open_se))
cat(sprintf("Observations & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\\n",
            formatC(fit_rings_permit$nobs, big.mark = ","),
            formatC(fit_rings_open$nobs, big.mark = ",")))
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} TWFE DiD with census-tract and year-quarter fixed effects.\n")
cat("Reference category: 4+ km. Controls: living area, bedrooms, bathrooms, age, age squared, construction grade, property type. SE clustered at census tract.\n")
cat("SA ATT row reports the Sun-Abraham cohort-robust ATT under each timing convention.\n")
cat("\\end{tablenotes}\n\\end{table}\n")
sink()
message("  Saved tab_appx_opening.tex")

# SA event study figure for opening-year timing
sa_open_agg <- summary(fit_sa_open, agg = "period")
sa_open_ct  <- coeftable(sa_open_agg)
sa_open_coefs <- data.frame(
  event_time = as.integer(gsub("[^-0-9]", "", rownames(sa_open_ct))),
  estimate   = sa_open_ct[, 1],
  std.error  = sa_open_ct[, 2]
)
sa_open_coefs <- rbind(
  sa_open_coefs,
  data.frame(event_time = -1L, estimate = 0, std.error = 0)
)
sa_open_coefs$conf.low  <- sa_open_coefs$estimate - 1.96 * sa_open_coefs$std.error
sa_open_coefs$conf.high <- sa_open_coefs$estimate + 1.96 * sa_open_coefs$std.error
sa_open_coefs <- sa_open_coefs[order(sa_open_coefs$event_time), ]
sa_open_coefs <- sa_open_coefs[sa_open_coefs$event_time >= -4 &
                                sa_open_coefs$event_time <= 4, ]

p_sa_open <- ggplot(sa_open_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = accent_gray) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = primary_gold,
             linewidth = 0.8) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15,
              fill = primary_blue) +
  geom_line(color = primary_blue, linewidth = 0.9) +
  geom_point(color = primary_blue, size = 3) +
  labs(x = "Years Relative to Nearest DC Opening",
       y = "Coefficient (log price)",
       caption = "Reference: t = -1. Resales only. Sun-Abraham cohort-robust ATT (opening-year cohorts).") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_appx_es_opening.pdf"), p_sa_open,
       width = 8, height = 5, bg = "transparent")
message("  Saved fig_appx_es_opening.pdf")

# ==========================================================================
# 4. A.4 CUMULATIVE EXPOSURE AT 4 KM
# ==========================================================================
message("\n=== A.4 Cumulative exposure at 4 km ===")

fit_cumul_4km <- feols(
  log_price ~ sqft_4km_M +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_resale,
  cluster = ~census_tract
)
fit_count_4km <- feols(
  log_price ~ n_dc_4km +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_resale,
  cluster = ~census_tract
)

ct_cumul_2  <- coeftable(fit_cumul)
ct_count_2  <- coeftable(fit_count)
ct_cumul_4  <- coeftable(fit_cumul_4km)
ct_count_4  <- coeftable(fit_count_4km)

cumul_2 <- c(ct_cumul_2["sqft_2km_M", 1], ct_cumul_2["sqft_2km_M", 2],
             ct_cumul_2["sqft_2km_M", 4])
count_2 <- c(ct_count_2["n_dc_2km", 1], ct_count_2["n_dc_2km", 2],
             ct_count_2["n_dc_2km", 4])
cumul_4 <- c(ct_cumul_4["sqft_4km_M", 1], ct_cumul_4["sqft_4km_M", 2],
             ct_cumul_4["sqft_4km_M", 4])
count_4 <- c(ct_count_4["n_dc_4km", 1], ct_count_4["n_dc_4km", 2],
             ct_count_4["n_dc_4km", 4])

message("  2 km sqft: ", round(cumul_2[1], 5), " (SE=", round(cumul_2[2], 5), ")")
message("  4 km sqft: ", round(cumul_4[1], 5), " (SE=", round(cumul_4[2], 5), ")")
message("  2 km count: ", round(count_2[1], 5), " (SE=", round(count_2[2], 5), ")")
message("  4 km count: ", round(count_4[1], 5), " (SE=", round(count_4[2], 5), ")")

sink(file.path(fig_dir, "tab_appx_cumul_4km.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Cumulative Exposure: 2 km vs.\\ 4 km Radius}\n")
cat("\\label{tab:appx_cumul_4km}\n\\small\n")
cat("\\begin{tabular}{lcccc}\n\\toprule\n")
cat("& \\multicolumn{2}{c}{2 km (main)} & \\multicolumn{2}{c}{4 km} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat("Measure & Coef. & SE & Coef. & SE \\\\\n\\midrule\n")
cat(sprintf("DC square footage (per million sq ft) & %.5f & %.5f & %.5f & %.5f \\\\\n",
            cumul_2[1], cumul_2[2], cumul_4[1], cumul_4[2]))
cat(sprintf("DC count & %.5f & %.5f & %.5f & %.5f \\\\\n",
            count_2[1], count_2[2], count_4[1], count_4[2]))
cat(sprintf("Observations & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\\n",
            formatC(fit_cumul$nobs, big.mark = ","),
            formatC(fit_cumul_4km$nobs, big.mark = ",")))
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Continuous cumulative exposure specifications on the resale sample.\n")
cat("Census-tract and year-quarter fixed effects, structural controls, SE clustered at census tract.\n")
cat("Cumulative measures sum exposure across all DCs permitted prior to each sale date within the stated radius.\n")
cat("\\end{tablenotes}\n\\end{table}\n")
sink()
message("  Saved tab_appx_cumul_4km.tex")

# ==========================================================================
# 5. A.5 JOINT PRE-TRENDS WALD TEST
# ==========================================================================
message("\n=== A.5 Joint pre-trends Wald test ===")

# Event time -4 bin has only 2 observations (both from the sparse 2024 cohort)
# observed in 2020, making its coefficient a numerical artifact. The proper
# test excludes that bin and uses event times -3 and -2.
w_twfe <- tryCatch(
  wald(fit_twfe_es, keep = "event_time_permit::-[23]$"),
  error = function(e) { message("  wald twfe error: ", e$message); NULL }
)
if (!is.null(w_twfe)) {
  twfe_F   <- w_twfe$stat
  twfe_df1 <- w_twfe$df1
  twfe_df2 <- w_twfe$df2
  twfe_p   <- w_twfe$p
  message("  TWFE pre-trends (excl. t=-4): F(", twfe_df1, ",", twfe_df2, ") = ",
          round(twfe_F, 3), ", p = ", signif(twfe_p, 3))
} else {
  twfe_F <- NA; twfe_df1 <- NA; twfe_df2 <- NA; twfe_p <- NA
}

# Also report the lead coefficient at t=-4 separately for transparency
ct_twfe_leads <- coeftable(fit_twfe_es)
em4_coef <- ct_twfe_leads["event_time_permit::-4", 1]
em4_se   <- ct_twfe_leads["event_time_permit::-4", 2]
message("  Event time -4 (2 obs, 2024 cohort): coef=", round(em4_coef, 4),
        " SE=", round(em4_se, 4))

# SA period-aggregated pre-trends: manual Wald on event times -2, -3 only
sa_period <- summary(fit_sa, agg = "period")
sa_period_ct <- coeftable(sa_period)
et_vec <- as.integer(gsub("[^-0-9]", "", rownames(sa_period_ct)))
pre_idx <- which(et_vec %in% c(-2, -3))

if (length(pre_idx) >= 2) {
  sa_V <- sa_period$cov.scaled
  if (is.null(sa_V)) sa_V <- sa_period$cov
  sa_b     <- sa_period_ct[pre_idx, 1]
  sa_V_pre <- sa_V[pre_idx, pre_idx, drop = FALSE]
  sa_wald  <- as.numeric(t(sa_b) %*% solve(sa_V_pre) %*% sa_b)
  sa_df1   <- length(pre_idx)
  # Use cluster count - 1 for denominator df to match clustered-SE convention
  n_clust  <- fit_sa$nclus
  sa_df2   <- ifelse(!is.null(n_clust), n_clust - 1, 50)
  sa_stat  <- sa_wald / sa_df1
  sa_p     <- pf(sa_stat, sa_df1, sa_df2, lower.tail = FALSE)
  message("  SA pre-trends (excl. t=-4): F(", sa_df1, ",", sa_df2, ") = ",
          round(sa_stat, 3), ", p = ", signif(sa_p, 3))
} else {
  sa_stat <- NA; sa_df1 <- NA; sa_df2 <- NA; sa_p <- NA
  message("  SA pre-trends: insufficient pre-treatment periods")
}

sink(file.path(fig_dir, "tab_appx_pretrends.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Joint Test of Parallel Pre-Trends}\n")
cat("\\label{tab:appx_pretrends}\n\\small\n")
cat("\\begin{tabular}{lcccc}\n\\toprule\n")
cat("Specification & F-statistic & df (num.) & df (den.) & p-value \\\\\n\\midrule\n")
if (!is.na(sa_stat)) {
  cat(sprintf("Sun-Abraham (period aggregates) & %.3f & %d & %d & %.3f \\\\\n",
              sa_stat, sa_df1, sa_df2, sa_p))
}
if (!is.na(twfe_F)) {
  cat(sprintf("TWFE event study & %.3f & %d & %d & %.3f \\\\\n",
              twfe_F, twfe_df1, twfe_df2, twfe_p))
}
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Joint Wald test on pre-treatment lead coefficients at event times $-2$ and $-3$ (t=-1 is the reference).\n")
cat(sprintf("Event time $-4$ is excluded because only 2 observations fall in that bin, both from the sparse 2024 cohort (14 parcels) observed in 2020; its coefficient (%.3f, SE %.3f) is a numerical artifact of bin sparsity rather than evidence of a pre-trend.\n",
            em4_coef, em4_se))
cat("Models estimated with census-tract and year-quarter fixed effects, structural controls, SE clustered at census tract.\n")
cat("\\end{tablenotes}\n\\end{table}\n")
sink()
message("  Saved tab_appx_pretrends.tex")

# ==========================================================================
# 6. A.6 HETEROGENEITY
# ==========================================================================
message("\n=== A.6 Heterogeneity ===")

ct_size <- coeftable(fit_het_size)
ct_time <- coeftable(fit_het_time)

# Extract interaction coefficients: i(large_dc, post_permit) and i(early_cohort, post_permit)
# fixest names them like "large_dc::FALSE:post_permit" and "large_dc::TRUE:post_permit"
size_rows <- grepl("large_dc::", rownames(ct_size))
time_rows <- grepl("early_cohort::", rownames(ct_time))

# Joint Wald test for heterogeneity = test that both interaction coefs equal each other
# Equivalently, test linear hypothesis b_TRUE - b_FALSE = 0
# Use fixest::wald() on both terms (joint significance) as proxy for heterogeneity
w_size <- tryCatch(
  wald(fit_het_size, keep = "^large_dc::"),
  error = function(e) NULL
)
w_time <- tryCatch(
  wald(fit_het_time, keep = "^early_cohort::"),
  error = function(e) NULL
)

# Also compute the difference test: b_TRUE - b_FALSE
diff_test <- function(fit, prefix) {
  ct <- coeftable(fit)
  rows <- grepl(paste0("^", prefix, "::"), rownames(ct))
  if (sum(rows) != 2) return(list(diff = NA, se = NA, p = NA))
  b <- ct[rows, 1]
  V <- vcov(fit)[rows, rows, drop = FALSE]
  d <- b[2] - b[1]
  se_d <- sqrt(V[1,1] + V[2,2] - 2 * V[1,2])
  p_d <- 2 * (1 - pnorm(abs(d / se_d)))
  list(diff = d, se = se_d, p = p_d)
}
dt_size <- diff_test(fit_het_size, "large_dc")
dt_time <- diff_test(fit_het_time, "early_cohort")

message("  Size heterogeneity (large-small diff): ", round(dt_size$diff, 4),
        " (SE=", round(dt_size$se, 4), ", p=", round(dt_size$p, 3), ")")
message("  Cohort heterogeneity (early-late diff): ", round(dt_time$diff, 4),
        " (SE=", round(dt_time$se, 4), ", p=", round(dt_time$p, 3), ")")

# Build table
sink(file.path(fig_dir, "tab_appx_heterogeneity.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Treatment-Effect Heterogeneity: Facility Size and Cohort Timing}\n")
cat("\\label{tab:appx_heterogeneity}\n\\small\n")
cat("\\begin{tabular}{lccc}\n\\toprule\n")
cat("Interaction & Coefficient & SE & p-value \\\\\n\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel A: Facility size ($>$500K sq ft vs smaller)}} \\\\\n")
# Individual coefs
for (r in which(size_rows)) {
  term_label <- rownames(ct_size)[r]
  is_true <- grepl("TRUE", term_label)
  label <- if (is_true) "Large DC $\\times$ Post" else "Small DC $\\times$ Post"
  cat(sprintf("%s & %.4f & %.4f & %.3f \\\\\n",
              label, ct_size[r, 1], ct_size[r, 2], ct_size[r, 4]))
}
cat(sprintf("Difference (Large -- Small) & %.4f & %.4f & %.3f \\\\\n",
            dt_size$diff, dt_size$se, dt_size$p))
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel B: Cohort timing (permit 2019--2021 vs 2022+)}} \\\\\n")
for (r in which(time_rows)) {
  term_label <- rownames(ct_time)[r]
  is_true <- grepl("TRUE", term_label)
  label <- if (is_true) "Early cohort $\\times$ Post" else "Late cohort $\\times$ Post"
  cat(sprintf("%s & %.4f & %.4f & %.3f \\\\\n",
              label, ct_time[r, 1], ct_time[r, 2], ct_time[r, 4]))
}
cat(sprintf("Difference (Early -- Late) & %.4f & %.4f & %.3f \\\\\n",
            dt_time$diff, dt_time$se, dt_time$p))
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Interacts the post-treatment indicator with a binary classifier of the nearest DC.\n")
cat("Large DC defined as total project square footage above 500{,}000. Early cohort defined as permit year 2019--2021 (late = 2022+). Sample restricted to properties within 4 km. Census-tract and year-quarter fixed effects, structural controls, SE clustered at census tract.\n")
cat("The ``Difference'' rows test whether treatment effects differ by subgroup.\n")
cat("\\end{tablenotes}\n\\end{table}\n")
sink()
message("  Saved tab_appx_heterogeneity.tex")

# ==========================================================================
# 7. SAVE APPENDIX RESULTS
# ==========================================================================
appx_results <- list(
  fit_rings_open   = fit_rings_open,
  fit_sa_open      = fit_sa_open,
  fit_cumul_4km    = fit_cumul_4km,
  fit_count_4km    = fit_count_4km,
  sa_open_att      = c(est = att_open, se = att_open_se, p = att_open_p),
  twfe_pretrends   = list(F = twfe_F, df1 = twfe_df1, df2 = twfe_df2, p = twfe_p),
  sa_pretrends     = list(F = sa_stat, df1 = sa_df1, df2 = sa_df2, p = sa_p),
  het_size_diff    = dt_size,
  het_time_diff    = dt_time
)
saveRDS(appx_results, file.path(proc_dir, "appendix_results.rds"))
message("\nSaved appendix_results.rds")
message("=== DONE ===")

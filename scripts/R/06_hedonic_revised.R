## ============================================================================
## 06_hedonic_revised.R
## Revised Hedonic DiD: Sun-Abraham, Cumulative Exposure, Permit Timing
## Addresses reviewer feedback on overclaiming, staggered DiD, exposure
## ============================================================================

set.seed(20260330)
library(dplyr)
library(fixest)
library(ggplot2)
library(lubridate)
library(broom)

proc_dir <- here::here("explorations", "data_collection", "processed")
fig_dir  <- here::here("Figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

primary_blue  <- "#012169"
primary_gold  <- "#f2a900"
accent_gray   <- "#525252"

theme_paper <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", color = primary_blue, size = base_size + 2),
      plot.caption = element_text(size = base_size - 3, color = accent_gray),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

# ==========================================================================
# 1. LOAD AND PREPARE DATA
# ==========================================================================
message("=== Loading Data ===")

panel <- read.csv(file.path(proc_dir, "property_transactions_panel.csv"),
                   colClasses = c(parid = "character", census_tract = "character",
                                  census_geoid = "character", sale_date = "character"))
panel$sale_date <- as.Date(panel$sale_date)

dc <- read.csv(file.path(proc_dir, "dc_master_inventory.csv"),
                colClasses = c(mcpi = "character", earliest_permit = "character"))

# Parse permit year
dc$permit_date <- as.Date(dc$earliest_permit)
dc$permit_year <- year(dc$permit_date)
dc$permit_year <- ifelse(is.na(dc$permit_year), dc$earliest_year, dc$permit_year)

message("Panel: ", nrow(panel), " rows")
message("DCs with permit_year: ", sum(!is.na(dc$permit_year)), " / ", nrow(dc))

# --- Derived variables ---
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

message("After cleaning: ", nrow(panel))


# ==========================================================================
# 2. CUMULATIVE EXPOSURE (Step 1.1)
# ==========================================================================
message("\n=== Building Cumulative Exposure ===")

# Haversine distance function (vectorized over one point vs many)
haversine_km <- function(lon1, lat1, lon2, lat2) {
  R <- 6371
  dlon <- (lon2 - lon1) * pi / 180
  dlat <- (lat2 - lat1) * pi / 180
  a <- sin(dlat / 2)^2 + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dlon / 2)^2
  2 * R * asin(sqrt(a))
}

# Get built DC locations with capacity and timing
dc_built <- dc %>%
  filter(built_status == "BUILT" | grepl("BUILT", built_status),
         !is.na(lon), !is.na(lat), !is.na(permit_year)) %>%
  select(mcpi, project, lon, lat, overall_sqft, permit_year, earliest_year)

message("Built DCs for exposure: ", nrow(dc_built))

# Full distance matrix (km): rows = transactions, cols = DCs
message("Computing full distance matrix (", nrow(panel), " x ", nrow(dc_built), ")...")
dist_km <- matrix(NA_real_, nrow = nrow(panel), ncol = nrow(dc_built))
for (j in seq_len(nrow(dc_built))) {
  dist_km[, j] <- haversine_km(panel$lon, panel$lat, dc_built$lon[j], dc_built$lat[j])
}
message("  Done. Dimensions: ", nrow(dist_km), " x ", ncol(dist_km))

# Time-varying cumulative exposure for each transaction
message("Computing time-varying cumulative exposure...")
panel$n_dc_2km  <- 0L
panel$sqft_2km  <- 0
panel$n_dc_4km  <- 0L
panel$sqft_4km  <- 0

for (j in seq_len(nrow(dc_built))) {
  # Only count this DC if it was permitted before the sale year
  permitted_mask <- panel$sale_year >= dc_built$permit_year[j]
  within_2km     <- dist_km[, j] <= 2
  within_4km     <- dist_km[, j] <= 4

  mask_2km <- permitted_mask & within_2km
  mask_4km <- permitted_mask & within_4km

  sqft <- ifelse(is.na(dc_built$overall_sqft[j]), 0, dc_built$overall_sqft[j])
  panel$n_dc_2km[mask_2km]  <- panel$n_dc_2km[mask_2km] + 1L
  panel$sqft_2km[mask_2km]  <- panel$sqft_2km[mask_2km] + sqft
  panel$n_dc_4km[mask_4km]  <- panel$n_dc_4km[mask_4km] + 1L
  panel$sqft_4km[mask_4km]  <- panel$sqft_4km[mask_4km] + sqft
}

message("Cumulative exposure summary (2km):")
message("  n_dc_2km:  min=", min(panel$n_dc_2km), " median=", median(panel$n_dc_2km),
        " max=", max(panel$n_dc_2km))
message("  sqft_2km:  min=", min(panel$sqft_2km), " median=",
        format(median(panel$sqft_2km), big.mark = ","),
        " max=", format(max(panel$sqft_2km), big.mark = ","))

# Standardize for regression (per million sqft)
panel$sqft_2km_M <- panel$sqft_2km / 1e6
panel$sqft_4km_M <- panel$sqft_4km / 1e6


# ==========================================================================
# 3. TREATMENT TIMING (Step 1.2)
# ==========================================================================
message("\n=== Treatment Timing ===")

# Join permit_year and earliest_year of nearest DC
dc_timing <- dc_built %>%
  group_by(project) %>%
  summarize(
    dc_permit_year = min(permit_year, na.rm = TRUE),
    dc_open_year   = min(earliest_year, na.rm = TRUE),
    .groups = "drop"
  )

panel <- panel %>%
  left_join(dc_timing, by = c("nearest_dc_project" = "project"))

# Primary treatment: permit year
panel$post_permit <- as.integer(!is.na(panel$dc_permit_year) &
                                 panel$sale_year >= panel$dc_permit_year)
panel$years_to_permit <- ifelse(!is.na(panel$dc_permit_year),
                                 panel$sale_year - panel$dc_permit_year, NA_integer_)

# Secondary: opening year
panel$post_open <- as.integer(!is.na(panel$dc_open_year) &
                               panel$sale_year >= panel$dc_open_year)

# Cohort variable for Sun-Abraham: permit year of nearest DC
# Never-treated (>4km) get cohort = 10000 (effectively Inf)
panel$cohort_permit <- ifelse(panel$within_4km & !is.na(panel$dc_permit_year),
                               panel$dc_permit_year, 10000L)

message("Cohort distribution (permit year):")
print(table(panel$cohort_permit))


# ==========================================================================
# 4. DEFINE ANALYSIS SAMPLES
# ==========================================================================
message("\n=== Analysis Samples ===")

# Full sample (resales only, excluding new construction)
panel_resale <- panel %>% filter(!is_new_construction)
message("Resales only: ", nrow(panel_resale), " (dropped ",
        sum(panel$is_new_construction), " new construction)")

# DiD sample: properties near DCs permitted 2019+ (1yr pre-treatment in panel) + controls
panel_did <- panel_resale %>%
  filter(
    (within_4km & dc_permit_year >= 2019) |
    !within_4km
  )
message("DiD sample (permit 2019+): ", nrow(panel_did))

# Repeat-sales subsample
repeat_parids <- panel_did %>%
  count(parid) %>%
  filter(n >= 2) %>%
  pull(parid)
panel_repeat <- panel_did %>% filter(parid %in% repeat_parids)
message("Repeat-sales subsample: ", nrow(panel_repeat), " obs, ",
        length(repeat_parids), " parcels")


# ==========================================================================
# 5. SUN-ABRAHAM ESTIMATOR (Step 1.3)
# ==========================================================================
message("\n=== Sun-Abraham Event Study ===")

# SA event study using permit-year cohorts
fit_sa <- feols(
  log_price ~ sunab(cohort_permit, sale_year) +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did,
  cluster = ~census_tract
)
message("  SA done. N = ", fit_sa$nobs)
print(summary(fit_sa, agg = "ATT"))

# TWFE event study for comparison (permit timing)
panel_did$event_time_permit <- pmax(pmin(panel_did$years_to_permit, 4), -4)
panel_did_es <- panel_did %>% filter(!is.na(event_time_permit))

fit_twfe_es <- feols(
  log_price ~ i(event_time_permit, ref = -1) +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did_es,
  cluster = ~census_tract
)
message("  TWFE event study done. N = ", fit_twfe_es$nobs)


# ==========================================================================
# 6. CUMULATIVE EXPOSURE SPECIFICATION
# ==========================================================================
message("\n=== Cumulative Exposure Regressions ===")

# Dose-response: continuous sqft exposure
fit_cumul <- feols(
  log_price ~ sqft_2km_M +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_resale,
  cluster = ~census_tract
)
message("Cumulative (sqft_2km_M): coef = ", round(coef(fit_cumul)["sqft_2km_M"], 5),
        " se = ", round(sqrt(vcov(fit_cumul)["sqft_2km_M", "sqft_2km_M"]), 5))

# Count-based exposure
fit_count <- feols(
  log_price ~ n_dc_2km +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_resale,
  cluster = ~census_tract
)
message("Count (n_dc_2km): coef = ", round(coef(fit_count)["n_dc_2km"], 5),
        " se = ", round(sqrt(vcov(fit_count)["n_dc_2km", "n_dc_2km"]), 5))


# ==========================================================================
# 7. DiD WITH RINGS (TWFE, for comparison)
# ==========================================================================
message("\n=== TWFE DiD with Rings ===")

fit_did_rings <- feols(
  log_price ~ i(ring, post_permit, ref = "4+ km") +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did,
  cluster = ~census_tract
)
message("  TWFE rings done. N = ", fit_did_rings$nobs)
print(summary(fit_did_rings))


# ==========================================================================
# 8. REPEAT-SALES PARCEL FE
# ==========================================================================
message("\n=== Repeat-Sales Parcel FE ===")

fit_repeat <- tryCatch({
  feols(
    log_price ~ i(ring, post_permit, ref = "4+ km") +
      age + I(age^2) |
      parid + yq,
    data = panel_repeat,
    cluster = ~census_tract
  )
}, error = function(e) { message("  Error: ", e$message); NULL })

if (!is.null(fit_repeat)) {
  message("  Repeat-sales done. N = ", fit_repeat$nobs)
  print(summary(fit_repeat))
}


# ==========================================================================
# 9. SUBSAMPLE CHARACTERIZATION (Step 1.4)
# ==========================================================================
message("\n=== Repeat-Sales Balance Table ===")

panel_did$is_repeat <- panel_did$parid %in% repeat_parids

balance_vars <- c("sale_price", "living_area", "bedrooms", "baths", "age",
                  "dist_nearest_dc_km", "fair_market_total")

balance <- panel_did %>%
  group_by(is_repeat) %>%
  summarize(
    N = n(),
    across(all_of(balance_vars),
           list(mean = ~mean(.x, na.rm = TRUE),
                sd   = ~sd(.x, na.rm = TRUE)),
           .names = "{.col}_{.fn}"),
    pct_new_const = 100 * mean(sale_verification == "V:NEW CONSTRUCTION", na.rm = TRUE),
    pct_within_2km = 100 * mean(within_2km, na.rm = TRUE),
    .groups = "drop"
  )

# Write balance table
sink(file.path(fig_dir, "tab_balance_repeat.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Comparison of Repeat-Sales and Single-Sale Subsamples}\n")
cat("\\label{tab:balance}\n\\small\n")
cat("\\begin{tabular}{lcccc}\n\\toprule\n")
cat(" & \\multicolumn{2}{c}{Single-Sale} & \\multicolumn{2}{c}{Repeat-Sale} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat(" & Mean & SD & Mean & SD \\\\\n\\midrule\n")

single <- balance %>% filter(!is_repeat)
repeat_b <- balance %>% filter(is_repeat)
labels <- c("Sale Price (\\$)", "Living Area (sq ft)", "Bedrooms", "Bathrooms",
            "Age (years)", "Dist. to DC (km)", "Assessed Value (\\$)")
for (i in seq_along(balance_vars)) {
  v <- balance_vars[i]
  dig <- if (v %in% c("sale_price", "fair_market_total")) 0 else 1
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n",
    labels[i],
    formatC(single[[paste0(v, "_mean")]], format = "f", digits = dig, big.mark = ","),
    formatC(single[[paste0(v, "_sd")]], format = "f", digits = dig, big.mark = ","),
    formatC(repeat_b[[paste0(v, "_mean")]], format = "f", digits = dig, big.mark = ","),
    formatC(repeat_b[[paste0(v, "_sd")]], format = "f", digits = dig, big.mark = ",")))
}
cat(sprintf("\\%% New Construction & \\multicolumn{2}{c}{%.1f\\%%} & \\multicolumn{2}{c}{%.1f\\%%} \\\\\n",
    single$pct_new_const, repeat_b$pct_new_const))
cat(sprintf("\\%% Within 2 km of DC & \\multicolumn{2}{c}{%.1f\\%%} & \\multicolumn{2}{c}{%.1f\\%%} \\\\\n",
    single$pct_within_2km, repeat_b$pct_within_2km))
cat("\\midrule\n")
cat(sprintf("Observations & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\\n",
    formatC(single$N, big.mark = ","), formatC(repeat_b$N, big.mark = ",")))
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Repeat-sale parcels are those with two or more transactions\n")
cat("during 2020--2025. DiD subsample restricted to resales near DCs permitted 2019+.\n")
cat("\\end{tablenotes}\n\\end{table}\n")
sink()
message("Saved tab_balance_repeat.tex")


# ==========================================================================
# 10. HETEROGENEITY (Step 1.6)
# ==========================================================================
message("\n=== Treatment Effect Heterogeneity ===")

# By facility size: nearest DC > 500K sqft vs smaller
dc_size <- dc_built %>%
  group_by(project) %>%
  summarize(total_sqft = sum(overall_sqft, na.rm = TRUE), .groups = "drop")

panel_did <- panel_did %>%
  left_join(dc_size, by = c("nearest_dc_project" = "project")) %>%
  mutate(large_dc = total_sqft > 500000)

fit_het_size <- feols(
  log_price ~ i(large_dc, post_permit) +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did %>% filter(within_4km),
  cluster = ~census_tract
)
message("Heterogeneity by size done")

# By cohort timing: early (permit 2019-2021) vs late (2022+)
panel_did$early_cohort <- panel_did$dc_permit_year <= 2021
fit_het_time <- feols(
  log_price ~ i(early_cohort, post_permit) +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did %>% filter(within_4km),
  cluster = ~census_tract
)
message("Heterogeneity by timing done")


# ==========================================================================
# 11. FIGURES
# ==========================================================================
message("\n=== Generating Figures ===")

# --- Sun-Abraham event study ---
# Use fixest's native period aggregation (tidy() misparses sunab term names)
sa_agg <- summary(fit_sa, agg = "period")
sa_ct  <- coeftable(sa_agg)
sa_coefs <- data.frame(
  event_time = as.integer(gsub("[^-0-9]", "", rownames(sa_ct))),
  estimate   = sa_ct[, 1],
  std.error  = sa_ct[, 2],
  conf.low   = sa_ct[, 1] - 1.96 * sa_ct[, 2],
  conf.high  = sa_ct[, 1] + 1.96 * sa_ct[, 2]
)

# Add reference point and restrict to [-4, 4] to match TWFE window
sa_coefs <- rbind(
  sa_coefs,
  data.frame(event_time = -1L, estimate = 0, std.error = 0, conf.low = 0, conf.high = 0)
)
sa_coefs <- sa_coefs[order(sa_coefs$event_time), ]
sa_coefs <- sa_coefs[sa_coefs$event_time >= -4 & sa_coefs$event_time <= 4, ]

p_sa <- ggplot(sa_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = accent_gray) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = primary_gold, linewidth = 0.8) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15, fill = primary_blue) +
  geom_line(color = primary_blue, linewidth = 0.9) +
  geom_point(color = primary_blue, size = 3) +
  labs(x = "Years Relative to Nearest DC Permit",
       y = "Coefficient (log price)",
       caption = "Reference: t = -1. Resales only. Cohort-robust ATT (Sun & Abraham 2021).") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_event_study_sa.pdf"), p_sa, width = 8, height = 5)
message("Saved fig_event_study_sa.pdf")

# --- TWFE event study (permit timing) for comparison ---
twfe_coefs <- tidy(fit_twfe_es, conf.int = TRUE) %>%
  filter(grepl("event_time_permit", term)) %>%
  mutate(event_time = as.integer(gsub(".*::", "", term))) %>%
  bind_rows(
    data.frame(event_time = -1L, estimate = 0, conf.low = 0, conf.high = 0,
               term = "ref", std.error = 0, statistic = 0, p.value = 1)
  ) %>%
  arrange(event_time)

p_twfe <- ggplot(twfe_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = accent_gray) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = primary_gold, linewidth = 0.8) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15, fill = "#b91c1c") +
  geom_line(color = "#b91c1c", linewidth = 0.9) +
  geom_point(color = "#b91c1c", size = 3) +
  labs(title = "TWFE Event Study: Permit Date Treatment",
       x = "Years Relative to Nearest DC Permit",
       y = "Coefficient (log price)",
       caption = "Reference: t = -1. Resales only. Standard TWFE for comparison.") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_event_study_permit.pdf"), p_twfe, width = 8, height = 5)
message("Saved fig_event_study_permit.pdf")

# --- Cumulative exposure dose-response ---
# Bin sqft_2km and plot mean log_price residuals
panel_resale$sqft_bin <- cut(panel_resale$sqft_2km_M,
                              breaks = c(-0.01, 0, 0.5, 1, 2, 3, 5, 10, Inf),
                              labels = c("0", "0-0.5", "0.5-1", "1-2", "2-3", "3-5", "5-10", "10+"))

dose_data <- panel_resale %>%
  filter(!is.na(sqft_bin)) %>%
  group_by(sqft_bin) %>%
  summarize(
    n = n(),
    mean_log_price = mean(log_price),
    se = sd(log_price) / sqrt(n()),
    .groups = "drop"
  )

p_dose <- ggplot(dose_data, aes(x = sqft_bin, y = mean_log_price)) +
  geom_col(fill = primary_blue, alpha = 0.7) +
  geom_errorbar(aes(ymin = mean_log_price - 1.96 * se,
                     ymax = mean_log_price + 1.96 * se),
                width = 0.2, color = accent_gray) +
  labs(title = "Mean Log Sale Price by Cumulative DC Exposure (2 km)",
       x = "Total DC Square Footage within 2 km (millions)",
       y = "Mean Log Price",
       caption = "Unconditional means with 95% CI. Resales only.") +
  theme_paper() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(fig_dir, "fig_cumulative_exposure.pdf"), p_dose, width = 8, height = 5)
message("Saved fig_cumulative_exposure.pdf")


# ==========================================================================
# 12. INCIDENCE TABLE
# ==========================================================================
message("\n=== Incidence Table ===")

bc <- read.csv(file.path(proc_dir, "benefit_cost_summary.csv"))
n_unique_1km <- n_distinct(panel$parid[panel$within_1km])
n_unique_2km <- n_distinct(panel$parid[panel$within_2km])

sink(file.path(fig_dir, "tab_incidence.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Distributional Incidence of Data Center Development}\n")
cat("\\label{tab:incidence}\n\\small\n")
cat("\\begin{tabular}{llccc}\n\\toprule\n")
cat("Channel & Who Bears It & Amount (\\$) & Type & Affected Pop. \\\\\n\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Benefits}} \\\\\n")
cat(sprintf("Tax savings (upper bound) & Loudoun homeowners & %s/yr & Flow & ${\\sim}$130,000 hh \\\\\n",
    formatC(bc$value[bc$variable == "annual_tax_savings_2025"], format = "f", digits = 0, big.mark = ",")))
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Costs}} \\\\\n")
cat(sprintf("Electricity (low est.) & Dominion residential & %s/yr & Flow & ${\\sim}$2.36M customers \\\\\n",
    formatC(bc$value[bc$variable == "jlarc_elec_cost_low_annual"], format = "f", digits = 0, big.mark = ",")))
cat(sprintf("Electricity (high est.) & Dominion residential & %s/yr & Flow & ${\\sim}$2.36M customers \\\\\n",
    formatC(bc$value[bc$variable == "jlarc_elec_cost_high_annual"], format = "f", digits = 0, big.mark = ",")))

# Property value effects from ring specifications
coefs_rings <- tidy(fit_did_rings)
pv_1_2km <- coefs_rings$estimate[grepl("1-2 km", coefs_rings$term)]
if (length(pv_1_2km) > 0) {
  dollar_01 <- formatC(round(abs(coefs_rings$estimate[grepl("0-1 km", coefs_rings$term)][1]) * 738730),
                        format = "f", digits = 0, big.mark = ",")
  dollar_12 <- formatC(round(abs(pv_1_2km[1]) * 738730),
                        format = "f", digits = 0, big.mark = ",")
  cat(sprintf("Property value (0--1 km) & Proximate homeowners & %s & Capitalized & ${\\sim}$%s parcels \\\\\n",
      dollar_01, formatC(n_unique_1km, big.mark = ",")))
  cat(sprintf("Property value (1--2 km) & Proximate homeowners & %s & Capitalized & ${\\sim}$%s parcels \\\\\n",
      dollar_12, formatC(n_unique_2km, big.mark = ",")))
}
cat("Cumulative exposure & --- & 0 & --- & --- \\\\\n")
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Tax savings are an upper-bound estimate assuming the 2012\n")
cat("rate (\\$1.145/\\$100) would have persisted absent data center revenue.\n")
cat("Electricity costs from JLARC (2024) range.\n")
cat("Property value amounts from ring specifications applied to median assessed value\n")
cat("(\\$738,730); the preferred cumulative exposure specification yields null effects.\n")
cat("Parcel counts are unique parcels transacted 2020--2025.\n")
cat("Populations differ across channels: tax savings accrue to Loudoun homeowners;\n")
cat("electricity costs are distributed across Dominion's statewide service territory;\n")
cat("property value effects, if real, are spatially concentrated.\n")
cat("\\end{tablenotes}\n\\end{table}\n")
sink()
message("Saved tab_incidence.tex")


# ==========================================================================
# 13. SAVE ALL RESULTS
# ==========================================================================
message("\n=== Saving Results ===")

results <- list(
  fit_sa         = fit_sa,
  fit_twfe_es    = fit_twfe_es,
  fit_did_rings  = fit_did_rings,
  fit_cumul      = fit_cumul,
  fit_count      = fit_count,
  fit_repeat     = fit_repeat,
  fit_het_size   = fit_het_size,
  fit_het_time   = fit_het_time,
  sa_coefs       = sa_coefs,
  twfe_coefs     = twfe_coefs,
  balance        = balance,
  panel_nrow     = nrow(panel),
  did_nrow       = nrow(panel_did),
  resale_nrow    = nrow(panel_resale),
  repeat_nrow    = nrow(panel_repeat)
)
saveRDS(results, file.path(proc_dir, "hedonic_results_revised.rds"))
message("Saved hedonic_results_revised.rds")

# Print key results summary
message("\n============================================================")
message("REVISED RESULTS SUMMARY")
message("============================================================")
message("\nSun-Abraham ATT:")
print(summary(fit_sa, agg = "ATT"))
message("\nCumulative exposure (sqft per M within 2km):")
cat("  Coefficient:", round(coef(fit_cumul)["sqft_2km_M"], 5), "\n")
cat("  SE:", round(sqrt(vcov(fit_cumul)["sqft_2km_M", "sqft_2km_M"]), 5), "\n")
message("\nTWFE DiD rings (permit timing):")
print(tidy(fit_did_rings) %>% filter(grepl("ring", term)) %>%
        select(term, estimate, std.error, p.value))
if (!is.null(fit_repeat)) {
  message("\nRepeat-sales parcel FE:")
  print(tidy(fit_repeat) %>% filter(grepl("ring", term)) %>%
          select(term, estimate, std.error, p.value))
}

message("\n=== DONE ===")

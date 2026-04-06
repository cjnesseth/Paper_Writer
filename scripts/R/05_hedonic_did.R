## ============================================================================
## 05_hedonic_did.R
## Hedonic DiD Analysis: Data Center Proximity and Property Values
## Loudoun County, VA (2020-2025)
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

# Emory palette
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
message("Panel: ", nrow(panel), " rows")

dc <- read.csv(file.path(proc_dir, "dc_master_inventory.csv"),
                colClasses = c(mcpi = "character"))
message("DC inventory: ", nrow(dc), " parcels")

# --- Treatment timing: join DC earliest_year to panel ---
# Aggregate DC inventory to project-level earliest year
dc_timing <- dc %>%
  filter(!is.na(earliest_year)) %>%
  group_by(project) %>%
  summarize(dc_open_year = min(earliest_year, na.rm = TRUE), .groups = "drop")

panel <- panel %>%
  left_join(dc_timing, by = c("nearest_dc_project" = "project"))

message("Panel with DC timing: ", sum(!is.na(panel$dc_open_year)), " / ", nrow(panel),
        " have DC open year")

# --- Derived variables ---
panel <- panel %>%
  mutate(
    log_price = log(sale_price),
    sale_year = year(sale_date),
    sale_qtr  = quarter(sale_date),
    yq        = paste0(sale_year, "Q", sale_qtr),
    age       = sale_year - year_built,
    # Parse grade: extract leading numeric (e.g., "5.0:GOOD" -> 5.0)
    grade_num = as.numeric(sub(":.*", "", grade)),
    # Property type from style
    prop_type = case_when(
      grepl("^TH", style)                          ~ "Townhouse",
      grepl("^(GN|HR|MR|SP)", style)               ~ "Condo",
      TRUE                                          ~ "Single Family"
    ),
    # Treatment ring as ordered factor
    ring = case_when(
      within_1km ~ "0-1 km",
      within_2km ~ "1-2 km",
      within_4km ~ "2-4 km",
      TRUE       ~ "4+ km"
    ),
    ring = factor(ring, levels = c("4+ km", "0-1 km", "1-2 km", "2-4 km")),
    # Post indicator: sale occurs after nearest DC opened
    post = as.integer(!is.na(dc_open_year) & sale_year >= dc_open_year),
    # Event time: years relative to nearest DC opening
    years_to_treat = ifelse(!is.na(dc_open_year), sale_year - dc_open_year, NA_integer_),
    # Capped event time for event study
    event_time = pmax(pmin(years_to_treat, 3), -3)
  ) %>%
  # Drop implausible structural values
  filter(
    !is.na(living_area), living_area >= 300,
    !is.na(age), age >= 0, age <= 200,
    sale_price >= 50000
  )

message("After cleaning: ", nrow(panel), " rows")
message("Property types: ")
print(table(panel$prop_type))
message("Rings: ")
print(table(panel$ring))

# --- Subset for staggered DiD: only DCs opening 2021+ ---
# These have pre-treatment observations in the panel
panel_did <- panel %>%
  filter(
    (dc_open_year >= 2021 & within_4km) |  # treated: near a 2021+ DC
    !within_4km                             # control: 4+ km from any DC
  )

message("\nDiD subsample (2021+ DCs + controls): ", nrow(panel_did))
message("  Treated (within 4km of 2021+ DC): ",
        sum(panel_did$within_4km), " | Control: ", sum(!panel_did$within_4km))


# ==========================================================================
# 2. DESCRIPTIVE STATISTICS
# ==========================================================================
message("\n=== Descriptive Statistics ===")

desc_vars <- c("sale_price", "living_area", "bedrooms", "baths", "age",
               "dist_nearest_dc_km", "fair_market_total")

desc_table <- panel %>%
  group_by(within_4km) %>%
  summarize(
    N = n(),
    across(all_of(desc_vars),
           list(mean = ~mean(.x, na.rm = TRUE),
                sd   = ~sd(.x, na.rm = TRUE),
                med  = ~median(.x, na.rm = TRUE)),
           .names = "{.col}_{.fn}"),
    .groups = "drop"
  )

# Write LaTeX table
sink(file.path(fig_dir, "tab_descriptive.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Residential Property Sales, 2020--2025}\n")
cat("\\label{tab:descriptive}\n")
cat("\\small\n")
cat("\\begin{tabular}{lrrrrrr}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{3}{c}{Within 4 km of DC} & \\multicolumn{3}{c}{Beyond 4 km} \\\\\n")
cat("\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}\n")
cat("Variable & Mean & SD & Median & Mean & SD & Median \\\\\n")
cat("\\midrule\n")

treated <- desc_table %>% filter(within_4km == TRUE)
control <- desc_table %>% filter(within_4km == FALSE)

labels <- c("Sale Price (\\$)", "Living Area (sq ft)", "Bedrooms", "Bathrooms",
            "Age (years)", "Distance to DC (km)", "Assessed Value (\\$)")
for (i in seq_along(desc_vars)) {
  v <- desc_vars[i]
  fmt <- if (v %in% c("sale_price", "fair_market_total")) ",.0f" else ".1f"
  cat(sprintf("%s & %s & %s & %s & %s & %s & %s \\\\\n",
    labels[i],
    formatC(treated[[paste0(v, "_mean")]], format = "f", digits = ifelse(v %in% c("sale_price","fair_market_total"), 0, 1), big.mark = ","),
    formatC(treated[[paste0(v, "_sd")]], format = "f", digits = ifelse(v %in% c("sale_price","fair_market_total"), 0, 1), big.mark = ","),
    formatC(treated[[paste0(v, "_med")]], format = "f", digits = ifelse(v %in% c("sale_price","fair_market_total"), 0, 1), big.mark = ","),
    formatC(control[[paste0(v, "_mean")]], format = "f", digits = ifelse(v %in% c("sale_price","fair_market_total"), 0, 1), big.mark = ","),
    formatC(control[[paste0(v, "_sd")]], format = "f", digits = ifelse(v %in% c("sale_price","fair_market_total"), 0, 1), big.mark = ","),
    formatC(control[[paste0(v, "_med")]], format = "f", digits = ifelse(v %in% c("sale_price","fair_market_total"), 0, 1), big.mark = ",")
  ))
}

cat("\\midrule\n")
cat(sprintf("Observations & \\multicolumn{3}{c}{%s} & \\multicolumn{3}{c}{%s} \\\\\n",
    formatC(treated$N, big.mark = ","), formatC(control$N, big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Arm's-length residential sales in Loudoun County, VA.\n")
cat("Treatment threshold is 4 km from the nearest data center.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
message("Saved tab_descriptive.tex")


# ==========================================================================
# 3. DESCRIPTIVE FIGURES
# ==========================================================================
message("\n=== Descriptive Figures ===")

# --- Fig 1: Distance distribution ---
p_dist <- ggplot(panel, aes(x = dist_nearest_dc_km)) +
  geom_histogram(binwidth = 0.5, fill = primary_blue, alpha = 0.7, color = "white") +
  geom_vline(xintercept = c(1, 2, 4), linetype = "dashed", color = primary_gold, linewidth = 0.8) +
  annotate("text", x = c(1, 2, 4), y = Inf, label = c("1 km", "2 km", "4 km"),
           vjust = 2, hjust = -0.1, color = primary_gold, fontface = "bold", size = 3.5) +
  labs(title = "Distance to Nearest Data Center",
       x = "Distance (km)", y = "Number of Sales") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_distance_hist.pdf"), p_dist, width = 8, height = 5)
message("Saved fig_distance_hist.pdf")

# --- Fig 2: DC construction timeline ---
dc_timeline <- dc %>%
  filter(!is.na(earliest_year), built_status == "BUILT") %>%
  count(earliest_year) %>%
  mutate(in_panel = earliest_year >= 2020)

p_timeline <- ggplot(dc_timeline, aes(x = earliest_year, y = n, fill = in_panel)) +
  geom_col(alpha = 0.85) +
  scale_fill_manual(values = c("FALSE" = accent_gray, "TRUE" = primary_blue),
                    labels = c("Pre-panel (before 2020)", "Panel period (2020-2025)"),
                    name = "") +
  labs(title = "Data Center Construction Timeline",
       x = "Year Opened", y = "Number of Data Centers") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_dc_timeline.pdf"), p_timeline, width = 8, height = 5)
message("Saved fig_dc_timeline.pdf")

# --- Fig 3: Price trends by ring (visual parallel trends) ---
price_trends <- panel %>%
  group_by(sale_year, ring) %>%
  summarize(median_price = median(sale_price) / 1000, .groups = "drop")

p_trends <- ggplot(price_trends, aes(x = sale_year, y = median_price, color = ring)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("0-1 km" = "#b91c1c", "1-2 km" = primary_gold,
                                 "2-4 km" = accent_gray, "4+ km" = primary_blue),
                     name = "Distance Ring") +
  labs(x = "Year", y = "Median Price ($000s)") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_price_trends.pdf"), p_trends, width = 8, height = 5)
message("Saved fig_price_trends.pdf")

# --- Fig 4: Tax revenue trajectory ---
rev <- read.csv(file.path(proc_dir, "tax_revenue_timeseries.csv"))
p_rev <- ggplot(rev, aes(x = year, y = dc_revenue_total_M)) +
  geom_col(fill = primary_blue, alpha = 0.8) +
  geom_text(aes(label = paste0("$", dc_revenue_total_M, "M")),
            vjust = -0.5, size = 3, color = accent_gray) +
  labs(title = "Loudoun County Data Center Tax Revenue",
       x = "Fiscal Year", y = "Total DC Revenue ($M)") +
  theme_paper() +
  theme(panel.grid.major.x = element_blank())
ggsave(file.path(fig_dir, "fig_tax_revenue.pdf"), p_rev, width = 9, height = 5)
message("Saved fig_tax_revenue.pdf")

# --- Fig 5: Benefit-cost comparison ---
bc <- read.csv(file.path(proc_dir, "benefit_cost_summary.csv"))
bc_plot <- data.frame(
  category = c("Tax Savings\n(annual)", "Electricity Cost\n(low)", "Electricity Cost\n(high)"),
  value = c(
    bc$value[bc$variable == "annual_tax_savings_2025"],
    bc$value[bc$variable == "jlarc_elec_cost_low_annual"],
    bc$value[bc$variable == "jlarc_elec_cost_high_annual"]
  ),
  type = c("Benefit", "Cost", "Cost")
)
bc_plot$category <- factor(bc_plot$category, levels = bc_plot$category)

p_bc <- ggplot(bc_plot, aes(x = category, y = value, fill = type)) +
  geom_col(alpha = 0.85, width = 0.6) +
  scale_fill_manual(values = c("Benefit" = "#15803d", "Cost" = "#b91c1c"), name = "") +
  geom_text(aes(label = paste0("$", formatC(value, big.mark = ","))),
            vjust = -0.5, size = 4) +
  labs(title = "Annual Per-Household: Tax Savings vs. Electricity Costs",
       x = "", y = "$/Household/Year") +
  theme_paper() +
  theme(panel.grid.major.x = element_blank())
ggsave(file.path(fig_dir, "fig_benefit_cost.pdf"), p_bc, width = 7, height = 5)
message("Saved fig_benefit_cost.pdf")


# ==========================================================================
# 4. REGRESSIONS
# ==========================================================================
message("\n=== Running Regressions ===")

# --- Specification 1: Cross-sectional hedonic ---
message("Spec 1: Cross-sectional hedonic...")
fit1 <- feols(
  log_price ~ i(ring, ref = "4+ km") +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel,
  cluster = ~census_tract
)
message("  Done. N = ", fit1$nobs)

# --- Specification 2: DiD with distance rings (2021+ DCs) ---
message("Spec 2: DiD with rings...")
fit2 <- feols(
  log_price ~ i(ring, post, ref = "4+ km") +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_did,
  cluster = ~census_tract
)
message("  Done. N = ", fit2$nobs)

# --- Specification 3: Event study (2021+ DCs, within 4km only + controls) ---
message("Spec 3: Event study...")
panel_es <- panel_did %>%
  filter(!is.na(event_time))

fit3 <- feols(
  log_price ~ i(event_time, ref = -1) +
    living_area + bedrooms + baths + age + I(age^2) +
    grade_num + I(prop_type) |
    census_tract + yq,
  data = panel_es,
  cluster = ~census_tract
)
message("  Done. N = ", fit3$nobs)

# --- Specification 4: Repeat-sales parcel FE ---
message("Spec 4: Repeat-sales parcel FE...")
repeat_parids <- panel_did %>%
  count(parid) %>%
  filter(n >= 2) %>%
  pull(parid)

panel_repeat <- panel_did %>% filter(parid %in% repeat_parids)
message("  Repeat-sales subsample: ", nrow(panel_repeat), " obs, ",
        length(repeat_parids), " parcels")

fit4 <- tryCatch({
  feols(
    log_price ~ i(ring, post, ref = "4+ km") +
      age + I(age^2) |
      parid + yq,
    data = panel_repeat,
    cluster = ~census_tract
  )
}, error = function(e) {
  message("  Parcel FE failed: ", e$message)
  NULL
})
if (!is.null(fit4)) message("  Done. N = ", fit4$nobs)

# Print results
message("\n=== RESULTS ===\n")
message("--- Specification 1: Cross-sectional ---")
print(summary(fit1))

message("\n--- Specification 2: DiD with rings ---")
print(summary(fit2))

message("\n--- Specification 3: Event study ---")
print(summary(fit3))

if (!is.null(fit4)) {
  message("\n--- Specification 4: Repeat-sales ---")
  print(summary(fit4))
}


# ==========================================================================
# 5. REGRESSION FIGURES
# ==========================================================================
message("\n=== Regression Figures ===")

# --- Event study plot ---
es_coefs <- tidy(fit3, conf.int = TRUE) %>%
  filter(grepl("event_time", term)) %>%
  mutate(event_time = as.integer(gsub(".*::", "", term))) %>%
  bind_rows(data.frame(event_time = -1L, estimate = 0, conf.low = 0, conf.high = 0,
                        term = "ref", std.error = 0, statistic = 0, p.value = 1)) %>%
  arrange(event_time)

p_es <- ggplot(es_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = accent_gray) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = primary_gold, linewidth = 0.8) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15, fill = primary_blue) +
  geom_line(color = primary_blue, linewidth = 0.9) +
  geom_point(color = primary_blue, size = 3) +
  scale_x_continuous(breaks = -3:3) +
  labs(title = "Event Study: Data Center Opening and Log Sale Price",
       x = "Years Relative to Data Center Opening",
       y = "Coefficient (log price)",
       caption = "Reference: t = -1. Shaded band = 95% CI. Sample: properties within 4 km of DCs opening 2021+.") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_event_study.pdf"), p_es, width = 8, height = 5)
message("Saved fig_event_study.pdf")

# --- DiD ring coefficient plot ---
did_coefs <- tidy(fit2, conf.int = TRUE) %>%
  filter(grepl("ring::", term) & grepl("post", term)) %>%
  mutate(
    ring_label = case_when(
      grepl("0-1 km", term) ~ "0-1 km",
      grepl("1-2 km", term) ~ "1-2 km",
      grepl("2-4 km", term) ~ "2-4 km"
    ),
    ring_label = factor(ring_label, levels = c("0-1 km", "1-2 km", "2-4 km"))
  )

p_did <- ggplot(did_coefs, aes(x = ring_label, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = accent_gray) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high),
                width = 0.15, color = primary_blue, linewidth = 0.9) +
  geom_point(color = primary_blue, size = 4) +
  labs(title = "DiD Treatment Effect by Distance from Data Center",
       x = "Distance Ring", y = "Coefficient (log price)",
       caption = "Control: properties > 4 km from any DC. Bars = 95% CI.") +
  theme_paper()
ggsave(file.path(fig_dir, "fig_did_rings.pdf"), p_did, width = 7, height = 5)
message("Saved fig_did_rings.pdf")


# ==========================================================================
# 6. REGRESSION TABLE (LaTeX)
# ==========================================================================
message("\n=== Regression Table ===")

# Build table manually for full control
make_coef_row <- function(label, fits, term_pattern) {
  vals <- sapply(fits, function(f) {
    if (is.null(f)) return(c("", ""))
    coefs <- tidy(f)
    match <- coefs[grepl(term_pattern, coefs$term), ]
    if (nrow(match) == 0) return(c("", ""))
    est <- sprintf("%.4f", match$estimate[1])
    se  <- sprintf("(%.4f)", match$std.error[1])
    stars <- ""
    if (match$p.value[1] < 0.01) stars <- "***"
    else if (match$p.value[1] < 0.05) stars <- "**"
    else if (match$p.value[1] < 0.1) stars <- "*"
    c(paste0(est, stars), se)
  })
  row1 <- paste0(label, " & ", paste(vals[1, ], collapse = " & "), " \\\\")
  row2 <- paste0(" & ", paste(vals[2, ], collapse = " & "), " \\\\")
  paste(row1, "\n", row2)
}

fits <- list(fit1, fit2, fit3, fit4)

sink(file.path(fig_dir, "tab_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{The Effect of Data Center Proximity on Residential Property Values}\n")
cat("\\label{tab:main}\n")
cat("\\small\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & Cross-Section & DiD Rings & Event Study & Repeat Sales \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Distance Ring Effects}} \\\\\n")
cat("[3pt]\n")

# Cross-section ring coefficients (Spec 1)
for (r in c("0-1 km", "1-2 km", "2-4 km")) {
  pattern <- gsub("-", ".", r)
  cat(make_coef_row(paste0("Ring: ", r), fits[1:2],
                     paste0("ring.*", gsub(" ", ".", r))), "\n[3pt]\n")
}

cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Event Study Coefficients}} \\\\\n")
cat("[3pt]\n")

# Event study coefficients (Spec 3)
for (t in c(-3, -2, 0, 1, 2, 3)) {
  label <- ifelse(t >= 0, paste0("t = +", t), paste0("t = ", t))
  cat(make_coef_row(label, fits[3:3],
                     paste0("event_time::", t, "$")), "\n[3pt]\n")
}

cat("\\midrule\n")
cat("Structural Controls & Yes & Yes & Yes & No \\\\\n")
cat("Census Tract FE & Yes & Yes & Yes & -- \\\\\n")
cat("Parcel FE & No & No & No & Yes \\\\\n")
cat("Year-Quarter FE & Yes & Yes & Yes & Yes \\\\\n")

# N and R2
cat("\\midrule\n")
for (i in 1:4) {
  if (i == 1) cat("Observations")
  cat(" & ")
  if (!is.null(fits[[i]])) {
    cat(formatC(fits[[i]]$nobs, big.mark = ","))
  }
}
cat(" \\\\\n")

for (i in 1:4) {
  if (i == 1) cat("R$^2$ (within)")
  cat(" & ")
  if (!is.null(fits[[i]])) {
    cat(sprintf("%.3f", fitstat(fits[[i]], "wr2")[[1]]))
  }
}
cat(" \\\\\n")

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Dependent variable is log sale price. ")
cat("Reference category: properties $>$4 km from nearest data center. ")
cat("Columns (1)--(3) use census tract fixed effects (74 tracts). ")
cat("Column (4) uses parcel fixed effects on the repeat-sales subsample. ")
cat("Standard errors clustered at the census tract level in parentheses. ")
cat("$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
message("Saved tab_main_results.tex")


# ==========================================================================
# 7. SAVE KEY RESULTS AS RDS
# ==========================================================================
message("\n=== Saving Results ===")

results <- list(
  fit_xsec = fit1,
  fit_did  = fit2,
  fit_es   = fit3,
  fit_repeat = fit4,
  panel_nrow = nrow(panel),
  did_nrow   = nrow(panel_did),
  es_coefs   = es_coefs,
  did_coefs  = did_coefs
)
saveRDS(results, file.path(proc_dir, "hedonic_results.rds"))
message("Saved hedonic_results.rds")

message("\n=== DONE ===")

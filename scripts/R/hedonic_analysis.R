# =============================================================================
# Hedonic Property Value Analysis: Data Center Externalities in Loudoun County, VA
# =============================================================================
# Purpose: Estimate the causal effect of data center proximity on residential
#          property values using a difference-in-differences design with
#          staggered treatment timing (following Jarvis 2025, JAERE).
#
# Design:  Within-Loudoun DiD. Treatment = proximity to a data center.
#          Control = properties farther away within the same county.
#          Timing variation exploited via staggered entry of data centers.
#
# Packages: tidyverse, sf, fixest, lubridate, broom, ggplot2
# Author:   [Your Name]
# Date:     2026-03-29
# =============================================================================

library(tidyverse)
library(sf)
library(fixest)
library(lubridate)
library(broom)
library(ggplot2)

# Fix random seed for any stochastic steps
set.seed(42)

# Log session info for reproducibility
writeLines(capture.output(sessionInfo()), "session_info.txt")


# =============================================================================
# SECTION 1: DATA LOADING AND CLEANING
# =============================================================================

# Load property transaction data from CSV.
# Expected columns:
#   parcel_id       : unique property identifier (character)
#   sale_date       : date of arm's-length sale (Date or "YYYY-MM-DD")
#   sale_price      : nominal USD sale price (numeric)
#   latitude        : WGS84 latitude (numeric)
#   longitude       : WGS84 longitude (numeric)
#   sq_ft           : above-grade living area in square feet (numeric)
#   bedrooms        : number of bedrooms (integer)
#   bathrooms       : number of bathrooms (numeric)
#   year_built      : year of original construction (integer)
#   property_type   : "single_family", "townhouse", or "condo" (character)
#   census_tract    : FIPS census tract code for SE clustering (character)
load_property_data <- function(path) {
	dat <- read_csv(path, show_col_types = FALSE) %>%
		# Keep only arm's-length residential transactions
		filter(
			sale_price > 0,
			property_type %in% c("single_family", "townhouse", "condo")
		) %>%
		mutate(
			sale_date  = as_date(sale_date),
			# Log price is the main outcome variable
			log_price  = log(sale_price),
			# Calendar year and quarter of sale
			sale_year  = year(sale_date),
			sale_qtr   = quarter(sale_date),
			# Age of structure at time of sale
			age        = sale_year - year_built
		) %>%
		# Drop implausible values (likely data entry errors)
		filter(
			sale_price >= 50000,
			sale_price <= 5e7,
			sq_ft      >= 300,
			age        >= 0,
			age        <= 150
		)
	return(dat)
}

# Convert a property data frame to an sf object.
# Uses WGS84 (EPSG 4326) by default; projected later for distance calcs.
properties_to_sf <- function(dat, crs = 4326) {
	dat_sf <- st_as_sf(dat, coords = c("longitude", "latitude"), crs = crs)
	return(dat_sf)
}

# Load data center locations and construction / announcement dates.
# Expected columns:
#   dc_id               : unique data center identifier (character)
#   name                : facility name (character)
#   latitude            : WGS84 latitude (numeric)
#   longitude           : WGS84 longitude (numeric)
#   construction_date   : date facility became operational (Date)
#   announcement_date   : date of first public permit/zoning filing (Date, may be NA)
#   sq_ft_facility      : facility footprint in sq ft (numeric, optional)
#   operator            : company name (character, optional)
load_datacenter_data <- function(path) {
	dc <- read_csv(path, show_col_types = FALSE) %>%
		mutate(
			construction_date = as_date(construction_date),
			announcement_date = as_date(announcement_date),
			# Prefer announcement date to capture anticipation effects;
			# fall back to construction date if announcement is missing.
			treatment_date    = coalesce(announcement_date, construction_date)
		)
	return(dc)
}


# =============================================================================
# SECTION 2: SPATIAL DISTANCE CALCULATIONS
# =============================================================================

# Calculate the straight-line distance (km) from each property to the nearest
# data center. Projects to Virginia State Plane South (EPSG 32147) which uses
# meters, enabling accurate planar distance measurement within the county.
calc_nearest_datacenter_dist <- function(properties_sf, dc_sf) {
	# Reproject both layers to a metric CRS
	prop_proj <- st_transform(properties_sf, crs = 32147)
	dc_proj   <- st_transform(dc_sf,         crs = 32147)

	# Full distance matrix: rows = properties, columns = data centers
	# Units are meters (from the projected CRS)
	dist_matrix <- st_distance(prop_proj, dc_proj)

	# For each property, find distance and index of the nearest data center
	nearest_dist_m <- apply(dist_matrix, 1, min)
	nearest_dc_idx <- apply(dist_matrix, 1, which.min)

	properties_sf <- properties_sf %>%
		mutate(
			dist_nearest_dc_km = as.numeric(nearest_dist_m) / 1000,
			nearest_dc_id      = dc_sf$dc_id[nearest_dc_idx]
		)
	return(properties_sf)
}

# Assign each property to a distance ring based on distance to nearest data
# center. The outermost ring (>4 km) serves as the control group.
# Thresholds in km; defaults follow Jarvis (2025) distance bands.
assign_treatment_rings <- function(dat, thresholds = c(1, 2, 4)) {
	dat <- dat %>%
		mutate(
			ring = case_when(
				dist_nearest_dc_km <= thresholds[1] ~ "ring_1km",
				dist_nearest_dc_km <= thresholds[2] ~ "ring_2km",
				dist_nearest_dc_km <= thresholds[3] ~ "ring_4km",
				TRUE                                  ~ "control"
			),
			# Binary treated indicator (within any treatment ring)
			treated = dist_nearest_dc_km <= thresholds[3]
		)
	return(dat)
}


# =============================================================================
# SECTION 3: MERGE TREATMENT TIMING
# =============================================================================

# Join each property to the treatment date of its nearest data center.
# This creates the staggered treatment structure: properties are "treated"
# at different calendar times depending on when their nearest data center opened.
# Properties with no data center within 4 km are never-treated controls.
merge_treatment_timing <- function(dat, dc) {
	dc_timing <- dc %>%
		select(nearest_dc_id = dc_id, treatment_date, construction_date)

	dat <- dat %>%
		left_join(dc_timing, by = "nearest_dc_id") %>%
		mutate(
			treatment_year = year(treatment_date),
			# Years relative to treatment: negative = pre-period, 0 = year of opening
			years_to_treat = sale_year - treatment_year
		)
	return(dat)
}


# =============================================================================
# SECTION 4: EVENT STUDY SPECIFICATION
# =============================================================================

# Event study: estimate log(price) by year relative to the data center opening.
# This tests for pre-trends (should be zero if parallel trends holds) and
# traces the dynamic treatment effect path post-opening.
#
# Specification:
#   log(price_it) = sum_k [ beta_k * 1(years_to_treat = k) ]
#                 + gamma * X_it + alpha_i + delta_t + epsilon_it
#
# where alpha_i = property FE, delta_t = year FE, X_it = time-varying controls.
# Reference category: k = -1 (one year before opening). Endpoints capped at +/-5
# to prevent sparse cells from inflating uncertainty.
#
# SE clustered at census tract level (or zip code as robustness).
run_event_study <- function(dat, cluster_var = "census_tract") {
	dat <- dat %>%
		mutate(
			# Cap event-time at +/-5 to handle sparse tails
			event_time = pmax(pmin(years_to_treat, 5), -5),
			event_time = as.character(event_time)
		) %>%
		# Drop properties with no assigned treatment date (pure controls)
		filter(!is.na(event_time))

	# i(event_time, ref = "-1") creates event-time dummies omitting t = -1.
	# Property FE (parcel_id) + year FE (sale_year) entered via | operator.
	formula_es <- log_price ~
		i(event_time, ref = "-1") +
		sq_ft + age + I(age^2) + bedrooms + bathrooms |
		parcel_id + sale_year

	fit_es <- feols(
		formula_es,
		data    = dat,
		cluster = as.formula(paste0("~", cluster_var))
	)
	return(fit_es)
}


# =============================================================================
# SECTION 5: DIFF-IN-DIFF WITH DISTANCE RINGS
# =============================================================================

# Static DiD: interacts distance-ring indicators with a post-treatment dummy.
# Identifies average treatment effect for each ring relative to the control group.
#
# Specification:
#   log(price_it) = sum_r [ beta_r * Ring_r * Post_it ]
#                 + gamma * X_it + alpha_i + delta_t + epsilon_it
#
# "Post" = 1 if sale year >= treatment year of the nearest data center.
# Control group: properties in the >4 km ring (never within 4 km of any DC).
run_did_rings <- function(dat, cluster_var = "census_tract") {
	dat <- dat %>%
		mutate(
			post = as.integer(sale_year >= treatment_year),
			ring = relevel(factor(ring), ref = "control")
		)

	# i(ring, post, ref = "control") interacts each ring with the post indicator
	formula_did <- log_price ~
		i(ring, post, ref = "control") +
		sq_ft + age + I(age^2) + bedrooms + bathrooms |
		parcel_id + sale_year

	fit_did <- feols(
		formula_did,
		data    = dat,
		cluster = as.formula(paste0("~", cluster_var))
	)
	return(fit_did)
}

# Robustness: run a separate binary DiD for each individual ring vs. control.
# Isolates the effect at each distance band without imposing functional form.
run_did_single_ring <- function(dat, ring_label, cluster_var = "census_tract") {
	dat_sub <- dat %>%
		filter(ring == ring_label | ring == "control") %>%
		mutate(
			treated = as.integer(ring == ring_label),
			post    = as.integer(sale_year >= treatment_year)
		)

	formula_bin <- log_price ~
		treated:post + sq_ft + age + I(age^2) + bedrooms + bathrooms |
		parcel_id + sale_year

	fit_bin <- feols(
		formula_bin,
		data    = dat_sub,
		cluster = as.formula(paste0("~", cluster_var))
	)
	return(fit_bin)
}


# =============================================================================
# SECTION 6: COEFFICIENT PLOTTING
# =============================================================================

# Plot event study coefficients with 95% confidence intervals.
# Adds a vertical line at t = -0.5 to mark the data center opening.
# Adds a horizontal dashed line at 0 as a reference.
plot_event_study <- function(
	fit_es,
	title = "Event Study: Data Center Effect on Log Home Prices"
) {
	coef_df <- tidy(fit_es, conf.int = TRUE) %>%
		filter(str_detect(term, "event_time")) %>%
		mutate(
			event_time = as.integer(str_extract(term, "-?[0-9]+"))
		) %>%
		# Add the omitted reference category t = -1 (effect = 0 by construction)
		bind_rows(
			tibble(event_time = -1L, estimate = 0, conf.low = 0, conf.high = 0)
		) %>%
		arrange(event_time)

	ggplot(coef_df, aes(x = event_time, y = estimate)) +
		geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
		geom_vline(xintercept = -0.5, linetype = "dotted", color = "steelblue", linewidth = 0.8) +
		geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15, fill = "steelblue") +
		geom_line(color = "steelblue", linewidth = 0.8) +
		geom_point(color = "steelblue", size = 2.5) +
		scale_x_continuous(breaks = -5:5) +
		labs(
			title   = title,
			x       = "Years Relative to Data Center Opening",
			y       = "Coefficient on Log Sale Price",
			caption = "Reference: t = -1. Shaded band = 95% CI. Dotted line = data center opening."
		) +
		theme_minimal(base_size = 12)
}

# Plot DiD ring coefficients as a dot-and-whisker chart.
# Each point is the estimated ATT for properties in that distance ring.
plot_did_rings <- function(
	fit_did,
	title = "DiD Treatment Effect by Distance Ring from Nearest Data Center"
) {
	coef_df <- tidy(fit_did, conf.int = TRUE) %>%
		filter(str_detect(term, "ring")) %>%
		mutate(
			ring_label = case_when(
				str_detect(term, "1km") ~ "0\u20131 km",
				str_detect(term, "2km") ~ "1\u20132 km",
				str_detect(term, "4km") ~ "2\u20134 km",
				TRUE                    ~ term
			),
			ring_label = factor(ring_label, levels = c("0\u20131 km", "1\u20132 km", "2\u20134 km"))
		)

	ggplot(coef_df, aes(x = ring_label, y = estimate)) +
		geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
		geom_errorbar(
			aes(ymin = conf.low, ymax = conf.high),
			width = 0.15, color = "steelblue", linewidth = 0.8
		) +
		geom_point(color = "steelblue", size = 3.5) +
		labs(
			title   = title,
			x       = "Distance Ring from Nearest Data Center",
			y       = "DiD Coefficient on Log Sale Price",
			caption = "Control: >4 km from any data center. Bars = 95% CI."
		) +
		theme_minimal(base_size = 12)
}


# =============================================================================
# SECTION 7: SIMULATION — TEST PIPELINE WITH SYNTHETIC DATA
# =============================================================================

# Generate synthetic property and data center data, run the full analysis,
# and verify that recovered estimates are in the right ballpark.
# The simulation plants a known treatment effect so we can check code logic.
#
# True effects (log price):
#   ring_1km (0-1 km):  -0.05  (5% price penalty near data centers)
#   ring_2km (1-2 km):  -0.02
#   ring_4km (2-4 km):   0.00  (attenuates to zero at 4 km)
simulate_and_test <- function(
	n_parcels        = 1500,
	n_datacenters    = 8,
	n_years          = 12,    # 2012-2023
	true_effect_1km  = -0.05,
	true_effect_2km  = -0.02,
	true_effect_4km  =  0.00,
	base_price       = 500000,
	verbose          = TRUE
) {
	set.seed(42)
	start_year <- 2012

	# --- Generate fake data center locations within Loudoun County bounding box ---
	# Loudoun County approx bounds: lat 38.85-39.18, lon -77.96 to -77.32
	dc_raw <- tibble(
		dc_id             = paste0("DC", sprintf("%02d", seq_len(n_datacenters))),
		name              = paste("Fake Data Center", seq_len(n_datacenters)),
		longitude         = runif(n_datacenters, -77.96, -77.32),
		latitude          = runif(n_datacenters,  38.85,  39.18),
		# Stagger openings across the study period
		construction_date = as_date("2012-01-01") +
			days(sort(sample(0:(n_years * 365 - 365), n_datacenters, replace = FALSE))),
		announcement_date = NA_Date_
	) %>%
		mutate(treatment_date = construction_date)

	dc_sf <- st_as_sf(dc_raw, coords = c("longitude", "latitude"), crs = 4326)

	# --- Generate fake property transactions ---
	# Each parcel has a fixed location and is sold 1-3 times over the panel
	parcel_lons <- runif(n_parcels, -77.96, -77.32)
	parcel_lats <- runif(n_parcels,  38.85,  39.18)

	sales_list <- vector("list", n_parcels)
	for (i in seq_len(n_parcels)) {
		n_sales    <- sample(1:3, 1)
		sale_years <- sample(start_year:(start_year + n_years - 1), n_sales, replace = FALSE)
		sales_list[[i]] <- tibble(
			parcel_id     = paste0("P", sprintf("%06d", i)),
			longitude     = parcel_lons[i],
			latitude      = parcel_lats[i],
			sale_year     = sale_years,
			year_built    = sample(1970:2015, 1),
			sq_ft         = rnorm(1, 2200, 500) %>% pmax(600),
			bedrooms      = sample(2:5, 1),
			bathrooms     = sample(1:4, 1),
			property_type = sample(
				c("single_family", "townhouse", "condo"),
				1, prob = c(0.6, 0.25, 0.15)
			),
			census_tract  = paste0("51107", sprintf("%06d", sample(1:30, 1)))
		)
	}

	properties_raw <- bind_rows(sales_list) %>%
		mutate(
			sale_date = as_date(paste0(
				sale_year, "-",
				sprintf("%02d", sample(1:12, n(), replace = TRUE)),
				"-15"
			)),
			age = sale_year - year_built
		)

	properties_sf <- properties_to_sf(properties_raw)

	# --- Calculate distances to nearest data center ---
	if (verbose) message("Calculating distances...")
	properties_sf <- calc_nearest_datacenter_dist(properties_sf, dc_sf)
	properties_sf <- assign_treatment_rings(properties_sf)

	# --- Merge treatment timing ---
	dat <- as_tibble(properties_sf) %>%
		select(-geometry) %>%
		merge_treatment_timing(dc_raw)

	# --- Construct simulated log prices with known treatment effects ---
	dat <- dat %>%
		mutate(
			post = as.integer(!is.na(treatment_year) & sale_year >= treatment_year),
			# Base log price driven by structural characteristics + noise
			log_price_base = log(base_price) +
				0.0003 * sq_ft +
				0.05   * bedrooms +
				-0.003 * age +
				rnorm(n(), 0, 0.15),
			# Plant true treatment effects by ring
			treatment_effect = case_when(
				ring == "ring_1km" & post == 1 ~ true_effect_1km,
				ring == "ring_2km" & post == 1 ~ true_effect_2km,
				ring == "ring_4km" & post == 1 ~ true_effect_4km,
				TRUE                            ~ 0
			),
			log_price  = log_price_base + treatment_effect,
			sale_price = exp(log_price)
		)

	if (verbose) {
		message("Simulation: ", nrow(dat), " transactions | ",
			n_datacenters, " data centers | ", n_years, " years")
		print(count(dat, ring))
	}

	# --- Run event study ---
	if (verbose) message("Running event study...")
	fit_es <- tryCatch(
		run_event_study(dat %>% filter(!is.na(years_to_treat))),
		error = function(e) { message("Event study error: ", e$message); NULL }
	)

	# --- Run DiD ring specification ---
	if (verbose) message("Running DiD ring specification...")
	fit_did <- tryCatch(
		run_did_rings(dat %>% filter(!is.na(treatment_year))),
		error = function(e) { message("DiD error: ", e$message); NULL }
	)

	# --- Report recovered estimates vs. true effects ---
	if (!is.null(fit_did) && verbose) {
		message("\nRecovered DiD coefficients (true: 1km=", true_effect_1km,
			", 2km=", true_effect_2km, ", 4km=", true_effect_4km, "):")
		tidy(fit_did) %>%
			filter(str_detect(term, "ring")) %>%
			select(term, estimate, std.error, p.value) %>%
			print()
	}

	# --- Save plots ---
	dir.create("figures", showWarnings = FALSE)
	if (!is.null(fit_es)) {
		ggsave("figures/sim_event_study.png",
			plot_event_study(fit_es, "Simulation: Event Study Check"),
			width = 8, height = 5, dpi = 150)
		if (verbose) message("Saved figures/sim_event_study.png")
	}
	if (!is.null(fit_did)) {
		ggsave("figures/sim_did_rings.png",
			plot_did_rings(fit_did, "Simulation: DiD Ring Coefficients"),
			width = 7, height = 5, dpi = 150)
		if (verbose) message("Saved figures/sim_did_rings.png")
	}

	return(invisible(list(data = dat, fit_es = fit_es, fit_did = fit_did)))
}


# =============================================================================
# SECTION 8: MAIN EXECUTION
# =============================================================================

# --- Run simulation to verify code logic ---
# (Comment out once real data are loaded)
sim_results <- simulate_and_test(verbose = TRUE)

# --- Real data pipeline (uncomment when data arrive) ---
# PROPERTIES_PATH  <- "data/loudoun_property_transactions.csv"
# DATACENTERS_PATH <- "data/loudoun_datacenters.csv"
# CLUSTER_VAR      <- "census_tract"   # or "zip_code" for robustness
#
# properties_raw  <- load_property_data(PROPERTIES_PATH)
# properties_sf   <- properties_to_sf(properties_raw)
# dc_raw          <- load_datacenter_data(DATACENTERS_PATH)
# dc_sf           <- st_as_sf(dc_raw, coords = c("longitude", "latitude"), crs = 4326)
# properties_sf   <- calc_nearest_datacenter_dist(properties_sf, dc_sf)
# properties_sf   <- assign_treatment_rings(properties_sf)
# dat             <- merge_treatment_timing(
#                     as_tibble(properties_sf) %>% select(-geometry), dc_raw)
#
# fit_es   <- run_event_study(dat,  cluster_var = CLUSTER_VAR)
# fit_did  <- run_did_rings(dat,    cluster_var = CLUSTER_VAR)
# fit_1km  <- run_did_single_ring(dat, "ring_1km", cluster_var = CLUSTER_VAR)
# fit_2km  <- run_did_single_ring(dat, "ring_2km", cluster_var = CLUSTER_VAR)
#
# ggsave("figures/event_study.png", plot_event_study(fit_es),  width = 8, height = 5, dpi = 300)
# ggsave("figures/did_rings.png",   plot_did_rings(fit_did),   width = 7, height = 5, dpi = 300)

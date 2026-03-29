# =============================================================================
# Back-of-Envelope: Electricity Rate Incidence from Data Center Load Growth
# =============================================================================
# Purpose: Estimate the annual per-household electricity cost increase
#          attributable to transmission and distribution (T&D) capital
#          expenditure driven by data center load growth in Dominion Energy
#          Virginia's service area.
#
# Method:  Top-down accounting from SCC rate case filings. NOT a regression.
#          Each input is a clearly labeled assumption; update from filings.
#
# Framework:
#   (1) Identify incremental T&D capex attributable to data center load growth.
#   (2) Annualize capex using capital recovery factor (CRF = WACC-based).
#   (3) Allocate incremental annual revenue requirement to residential customers
#       using their share of system load.
#   (4) Convert to $/kWh and $/year per average residential customer.
#
# Key sources to update inputs:
#   - Dominion IRP 2024/2025 (dominionenergy.com)
#   - SCC rate case dockets: scc.virginia.gov/caseSearch
#   - JLARC (2024) Data Centers in Virginia (jlarc.virginia.gov/pdfs/reports/Rpt598-2.pdf)
#   - EIA Form 861 (eia.gov/electricity/data/eia861)
#
# Author: [Your Name]
# Date:   2026-03-29
# =============================================================================

library(tidyverse)


# =============================================================================
# INPUTS: Update all values from SCC docket filings before reporting results.
# Each assumption is flagged with its source and the direction of uncertainty.
# =============================================================================

# --- Data center load parameters ---

# Incremental data center load requiring new T&D investment (MW).
# Dominion's 2024 IRP forecasts data-center-driven capex for 89 transmission
# projects. Use load growth over your study period (e.g., 2010-2024).
# Loudoun County: contracted DC capacity grew from ~500 MW (2015) to ~3,500 MW (2024).
# SOURCE: Dominion 2024 IRP; SCC case PUE-2022-00142 testimony.
# UNCERTAINTY: likely an underestimate if recent AI-driven growth is included.
dc_load_growth_mw <- 1000    # PLACEHOLDER: 1,000 MW incremental (update from IRP)

# T&D capital expenditure per MW of new data center load ($ million/MW).
# Dominion's 2024 IRP forecasts ~$22B data-center-driven costs over 15 years
# for a pipeline exceeding 10,000 MW of new load, implying ~$1.5-2M/MW for
# transmission. Distribution upgrade costs are additional.
# SOURCE: Dominion 2024 IRP; Virginia Mercury (Sep 2025).
# UNCERTAINTY: wide range depending on substation vs. long-haul transmission mix.
td_capex_per_mw_million <- 1.5   # PLACEHOLDER: $1.5M per MW (update from rate case)

# --- Utility cost-of-capital and amortization ---

# Weighted average cost of capital (WACC) approved by SCC for Dominion Virginia.
# Find in most recent base rate case order (SCC biennial review 2025).
# SOURCE: SCC order, SCC biennial review 2025.
wacc <- 0.075   # PLACEHOLDER: 7.5% (check current SCC-approved WACC)

# Useful life of T&D assets for rate-making purposes (years).
# Transmission lines: 40-50 years; substations: 30-40 years.
# SOURCE: Dominion depreciation study filed in rate cases.
asset_life_years <- 40   # PLACEHOLDER: 40-year amortization period

# --- Dominion Virginia service area parameters ---

# Total residential customers in Dominion Energy Virginia's service area.
# SOURCE: EIA Form 861, most recent year; Dominion Annual Report.
residential_customers <- 2_600_000   # PLACEHOLDER: ~2.6M (update from EIA Form 861)

# Residential share of total system load (energy, kWh basis).
# Data centers are large commercial customers; residential is a minority of load.
# In Virginia, residential load is roughly 30-38% of total utility sales.
# SOURCE: EIA Form 861; Dominion rate case Class Cost of Service Study.
residential_load_share <- 0.35   # PLACEHOLDER: 35% (update from Class Cost of Service)

# Average annual residential electricity consumption (kWh per customer).
# Virginia residential average is approximately 11,000-13,000 kWh/year.
# SOURCE: EIA Electric Power Monthly, Virginia state average.
avg_residential_kwh <- 12000   # PLACEHOLDER: 12,000 kWh/yr (update from EIA EPM)

# --- Loudoun County-specific parameters ---

# Loudoun County residential customers (subset of Dominion service area).
# SOURCE: Dominion rate case or Loudoun County utility data.
loudoun_residential_customers <- 130_000   # PLACEHOLDER: ~130K (update from Dominion)

# Share of total data center T&D investment attributable to Loudoun County load.
# Loudoun hosts ~half of NoVA data center capacity; most new T&D serving
# this load is concentrated in the Loudoun/Prince William corridor.
# SOURCE: Dominion IRP transmission project list; JLARC 2024 report.
loudoun_td_share <- 0.40   # PLACEHOLDER: 40% of T&D investment serves Loudoun load


# =============================================================================
# STEP 1: TOTAL INCREMENTAL T&D CAPITAL EXPENDITURE
# =============================================================================

# Total new T&D capex required to serve the incremental data center load
total_td_capex_million <- dc_load_growth_mw * td_capex_per_mw_million


# =============================================================================
# STEP 2: ANNUALIZE CAPEX AS INCREMENTAL REVENUE REQUIREMENT
# =============================================================================

# Capital Recovery Factor (CRF): converts a one-time capex to an equivalent
# annual payment over the asset's useful life, at the given WACC.
# Formula: CRF = r / (1 - (1 + r)^(-n))
crf <- wacc / (1 - (1 + wacc)^(-asset_life_years))

# Annual incremental revenue requirement to recover the T&D capex
annual_revenue_req_million <- total_td_capex_million * crf


# =============================================================================
# STEP 3: ALLOCATE TO RESIDENTIAL CUSTOMERS (SERVICE-AREA-WIDE)
# =============================================================================

# Residential customers bear their load-proportionate share of the
# incremental revenue requirement. This is the standard cost-causation approach.
residential_revenue_req_million <- annual_revenue_req_million * residential_load_share

# Annual per-residential-customer impact (Dominion service area average)
annual_per_customer_dollars <- (residential_revenue_req_million * 1e6) / residential_customers

# Rate impact in $/kWh
rate_impact_per_kwh <- annual_per_customer_dollars / avg_residential_kwh


# =============================================================================
# STEP 4: LOUDOUN COUNTY-SPECIFIC INCIDENCE
# =============================================================================

# Loudoun residents face the same per-customer rate impact as all Dominion
# residential customers (rates are uniform across the service area), but the
# T&D investments are concentrated near Loudoun. This calculates what share of
# the total T&D burden originates from Loudoun County data center load.
loudoun_td_capex_million    <- total_td_capex_million * loudoun_td_share
loudoun_annual_req_million  <- loudoun_td_capex_million * crf
loudoun_per_customer_dollars <- (loudoun_annual_req_million * 1e6) / residential_customers


# =============================================================================
# RESULTS
# =============================================================================

cat("=============================================================\n")
cat("  Electricity Rate Incidence: Back-of-Envelope Results\n")
cat("=============================================================\n\n")

cat(sprintf("INPUTS (update from SCC filings before reporting):\n"))
cat(sprintf("  Incremental DC load:           %,d MW\n",   dc_load_growth_mw))
cat(sprintf("  T&D capex per MW:              $%.1fM\n",   td_capex_per_mw_million))
cat(sprintf("  WACC (SCC-approved):           %.1f%%\n",   wacc * 100))
cat(sprintf("  Asset life:                    %d years\n", asset_life_years))
cat(sprintf("  Dominion residential customers:%,d\n",      residential_customers))
cat(sprintf("  Residential load share:        %.0f%%\n",   residential_load_share * 100))
cat(sprintf("  Avg residential use:           %,d kWh/yr\n\n", avg_residential_kwh))

cat(sprintf("RESULTS — Dominion Service Area:\n"))
cat(sprintf("  Total T&D capex:               $%.0fM\n",  total_td_capex_million))
cat(sprintf("  Capital recovery factor:       %.4f\n",    crf))
cat(sprintf("  Annual revenue requirement:    $%.1fM\n",  annual_revenue_req_million))
cat(sprintf("  Residential share (%.0f%% of load):$%.1fM/yr\n",
	residential_load_share * 100, residential_revenue_req_million))
cat(sprintf("  Per residential customer:      $%.2f/yr\n", annual_per_customer_dollars))
cat(sprintf("  Rate impact:                   $%.5f/kWh\n\n", rate_impact_per_kwh))

cat(sprintf("RESULTS — Loudoun County Attributable Share (%.0f%% of T&D):\n",
	loudoun_td_share * 100))
cat(sprintf("  Loudoun T&D capex:             $%.0fM\n",  loudoun_td_capex_million))
cat(sprintf("  Annual requirement:            $%.1fM/yr\n", loudoun_annual_req_million))
cat(sprintf("  Per Dominion residential cust: $%.2f/yr\n\n", loudoun_per_customer_dollars))

cat("NOTE: All inputs are placeholders. Update from:\n")
cat("  - Dominion 2024/2025 IRP (dominionenergy.com)\n")
cat("  - SCC dockets: scc.virginia.gov/caseSearch\n")
cat("  - JLARC 2024 report: jlarc.virginia.gov/pdfs/reports/Rpt598-2.pdf\n")
cat("  - EIA Form 861: eia.gov/electricity/data/eia861\n\n")


# =============================================================================
# SENSITIVITY ANALYSIS
# =============================================================================
# Vary key uncertain inputs across plausible ranges.
# This communicates parameter uncertainty without claiming false precision.

sensitivity <- expand_grid(
	dc_load_mw        = c(500, 1000, 2000, 3000),
	capex_per_mw      = c(1.0, 1.5, 2.5),
	res_share         = c(0.30, 0.35, 0.40)
) %>%
	mutate(
		td_capex         = dc_load_mw * capex_per_mw,
		annual_req       = td_capex * crf,
		res_req          = annual_req * res_share,
		per_cust_yr      = round((res_req * 1e6) / residential_customers, 2),
		per_kwh          = round(per_cust_yr / avg_residential_kwh, 5)
	) %>%
	select(
		`DC Load (MW)`    = dc_load_mw,
		`T&D $/MW (M)`    = capex_per_mw,
		`Res. Share`      = res_share,
		`$/Cust/Yr`       = per_cust_yr,
		`$/kWh`           = per_kwh
	)

cat("=============================================================\n")
cat("  Sensitivity Table: $/Residential Customer/Year\n")
cat("=============================================================\n")
print(sensitivity, n = Inf)

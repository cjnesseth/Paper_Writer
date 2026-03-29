# Plan: Analysis with Available Data

**Status:** DRAFT
**Date:** 2026-03-29

## Context

Property transaction data (sale prices) is not yet available, blocking the hedonic DiD regression. However, we have rich spatial data (135 DC parcels, 231 buildings, 132K county parcels, zoning, census tracts) plus the EIA 861 Dominion panel and JLARC fiscal data. This plan executes everything possible with current data across three analysis channels.

## Steps

### Step 1: Build DC Treatment Variable
**File:** `scripts/R/02_build_treatment.R`
**Output:** `explorations/data_collection/processed/dc_master_inventory.csv`

- Merge 135 DC parcels with 231 buildings on MCPI
- Clean `BP_ISSUE_DT` (epoch ms → Date; flag 6 NAs and 49 YEAR_BUILT=1000 placeholders)
- Compute parcel centroids (project to EPSG 32147, extract lon/lat)
- Assign Loudoun census tracts via spatial join
- Output: 135-row master inventory with mcpi, project, owner, lat, lon, earliest_permit_date, n_buildings, total_sqft, built_status, zoning, census_tract

### Step 2: Spatial Descriptive Analysis
**File:** `scripts/R/03_spatial_descriptives.R`
**Depends on:** Step 1 output

- Load 132K parcels shapefile + zoning layer
- Classify residential parcels by spatial join to zoning (R1, R2, R3, PDH*, CR*, JLMA* zones)
- Compute nearest-DC distance for each residential parcel (use `nngeo::st_nn`)
- Produce figures:
  - `Figures/fig_dc_map.png` — DC locations on county map with residential parcels
  - `Figures/fig_distance_histogram.png` — distance-to-nearest-DC distribution
  - `Figures/fig_dc_timeline.png` — permit timeline showing development acceleration

### Step 3: Electricity Rate Incidence
**File:** `scripts/R/electricity_rate_calc.R` (update existing)

- Replace 8 placeholder parameters with EIA 861 / JLARC values:
  - `dc_load_growth_mw` = 4,140 MW (JLARC)
  - `td_capex_per_mw` = $2.2M/MW ($22B / 10K MW from JLARC/Dominion IRP)
  - `residential_customers` = 2,357,519 (EIA 861 2023)
  - `residential_load_share` = 0.294 (computed from EIA 861)
  - `avg_residential_kwh` = 11,535 (EIA 861)
- Validate against JLARC benchmark ($14-37/month by 2040)
- Compute 15-year NPV at 3% discount rate
- Sensitivity heatmap: `Figures/fig_elec_sensitivity.png`

### Step 4: Tax Revenue Benefit Analysis
**File:** `scripts/R/04_tax_revenue_analysis.R`

- Build DC revenue time series (known points: $146M→$1.37B, 2016-2026)
- Compute per-household savings from RE rate reduction ($1.145→$0.805 per $100)
  - On $650K median home: ~$2,210/year savings
- Compute NPV of cumulative tax benefit (10-year, 3% discount)
- Compare NPV of tax benefit vs. electricity cost per household
- Figures:
  - `Figures/fig_dc_revenue_ts.png`
  - `Figures/fig_re_rate_trajectory.png`
  - `Figures/fig_npv_comparison.png`

### Step 5: Draft Paper Sections
**Location:** `explorations/paper_draft/`

- Section 1: Introduction (research question framed with data)
- Section 3: Data description (sources, sample, limitations)
- Section 4.2: Tax revenue analysis
- Section 4.3: Electricity rate incidence
- Section 5: Descriptive spatial analysis

## Verification

- Step 1: 135 rows output, 134 with building data, all with census tracts
- Step 2: Residential parcel count 80K-120K; distances spot-checked against Google Maps
- Step 3: Central estimate within or near JLARC $14-37/month range
- Step 4: Per-household savings ~$3,000-4,000/year (matches Loudoun County cited figures)
- All R scripts run without error; all figures saved to Figures/

## Sequencing

Step 1 → Steps 2, 3, 4 (parallel) → Step 5

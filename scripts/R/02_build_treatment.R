## ============================================================================
## 02_build_treatment.R
## Build master DC inventory: merge parcels + buildings, clean dates,
## compute centroids, assign census tracts
## ============================================================================

set.seed(20260329)
library(sf)
library(dplyr)
library(lubridate)

raw_dir  <- here::here("explorations", "data_collection", "raw")
out_dir  <- here::here("explorations", "data_collection", "processed")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# --- 1. Load data ---
message("Loading DC parcels...")
parcels <- st_read(file.path(raw_dir, "dc_existing_parcels.geojson"), quiet = TRUE)
message("  ", nrow(parcels), " parcels loaded")

message("Loading DC buildings...")
buildings <- st_read(file.path(raw_dir, "dc_existing_permitted_buildings.geojson"), quiet = TRUE)
message("  ", nrow(buildings), " buildings loaded")

message("Loading census tracts...")
tracts <- st_read(file.path(raw_dir, "census_tracts_va", "tl_2020_51_tract.shp"), quiet = TRUE)
loudoun_tracts <- tracts %>% filter(COUNTYFP == "107")
message("  ", nrow(loudoun_tracts), " Loudoun County tracts")

# --- 2. Clean building permit dates ---
clean_permit_dates <- function(epoch_ms) {
  dates <- as.Date(as.POSIXct(epoch_ms / 1000, origin = "1970-01-01", tz = "UTC"))
  # Flag implausible dates (before 1990 or after 2030)
  dates[!is.na(dates) & (dates < as.Date("1990-01-01") | dates > as.Date("2030-01-01"))] <- NA
  return(dates)
}

buildings <- buildings %>%
  mutate(
    permit_date = clean_permit_dates(BP_ISSUE_DT),
    year_built_clean = ifelse(YEAR_BUILT > 1900 & YEAR_BUILT < 2030, YEAR_BUILT, NA_real_)
  )

message("\nBuilding date summary:")
message("  Valid permit dates: ", sum(!is.na(buildings$permit_date)), " / ", nrow(buildings))
message("  Date range: ", min(buildings$permit_date, na.rm = TRUE), " to ",
        max(buildings$permit_date, na.rm = TRUE))
message("  Valid year_built: ", sum(!is.na(buildings$year_built_clean)), " / ", nrow(buildings))
message("  YEAR_BUILT=1000 (placeholder): ", sum(buildings$YEAR_BUILT == 1000, na.rm = TRUE))

# --- 3. Aggregate buildings to parcel level ---
bldg_agg <- buildings %>%
  st_drop_geometry() %>%
  group_by(AM_MCPI) %>%
  summarize(
    n_buildings            = n(),
    total_sqft             = sum(as.numeric(SQUARE_FEET), na.rm = TRUE),
    earliest_permit_date   = min(permit_date, na.rm = TRUE),
    latest_permit_date     = max(permit_date, na.rm = TRUE),
    earliest_year_built    = min(year_built_clean, na.rm = TRUE),
    n_built                = sum(BUILT_STATUS == "BUILT", na.rm = TRUE),
    n_under_construction   = sum(BUILT_STATUS == "UNDER CONSTRUCTION", na.rm = TRUE),
    addresses              = paste(unique(na.omit(AM_BASE_ADDRESS)), collapse = "; "),
    .groups = "drop"
  ) %>%
  # Fix Inf/-Inf from empty groups
  mutate(
    across(where(is.numeric), ~ ifelse(is.infinite(.), NA_real_, .)),
    earliest_permit_date = if_else(is.infinite(as.numeric(earliest_permit_date)),
                                   as.Date(NA), earliest_permit_date)
  )

message("\nAggregated to ", nrow(bldg_agg), " unique MCPIs from buildings")

# --- 4. Compute parcel centroids ---
# Project to Virginia State Plane South (meters) for accurate centroids
parcels_proj <- st_transform(parcels, 32147)
centroids_proj <- st_centroid(parcels_proj)
centroids_4326 <- st_transform(centroids_proj, 4326)

coords <- st_coordinates(centroids_4326)
parcels$lon <- coords[, 1]
parcels$lat <- coords[, 2]

# --- 5. Join parcels to building aggregates ---
inventory <- parcels %>%
  st_drop_geometry() %>%
  left_join(bldg_agg, by = c("PA_MCPI" = "AM_MCPI"))

message("\nJoin results:")
message("  Parcels with building data: ", sum(!is.na(inventory$n_buildings)), " / ", nrow(inventory))
message("  Parcels without building data: ", sum(is.na(inventory$n_buildings)))

# --- 6. Assign census tracts ---
centroids_sf <- st_as_sf(inventory, coords = c("lon", "lat"), crs = 4326)
centroids_sf <- st_transform(centroids_sf, st_crs(loudoun_tracts))
tract_join <- st_join(centroids_sf, loudoun_tracts %>% select(TRACTCE, GEOID), join = st_within)

inventory$census_tract <- tract_join$TRACTCE
inventory$census_geoid <- tract_join$GEOID

message("  Parcels with census tract: ", sum(!is.na(inventory$census_tract)), " / ", nrow(inventory))

# --- 7. Select and rename output columns ---
dc_inventory <- inventory %>%
  transmute(
    mcpi             = PA_MCPI,
    project          = Project,
    owner            = Owner,
    ownership_cat    = Ownership_Category,
    lon, lat,
    overall_sqft     = as.numeric(Overall_SQ_FT),
    built_status     = Built_Status,
    zoning           = ZONING,
    place_type       = PLACE_TYPE,
    policy_area      = POLICY_AREA,
    gis_acres        = PA_GIS_ACRE,
    n_buildings,
    total_bldg_sqft  = total_sqft,
    earliest_permit  = earliest_permit_date,
    latest_permit    = latest_permit_date,
    earliest_year    = earliest_year_built,
    n_built,
    n_under_construction,
    addresses,
    census_tract,
    census_geoid
  )

# --- 8. Save ---
out_file <- file.path(out_dir, "dc_master_inventory.csv")
write.csv(dc_inventory, out_file, row.names = FALSE)

message("\n=== DC Master Inventory ===")
message("Rows: ", nrow(dc_inventory))
message("Saved to: ", out_file)
message("\nSummary by built status:")
print(table(dc_inventory$built_status, useNA = "ifany"))
message("\nPermit date range: ", min(dc_inventory$earliest_permit, na.rm = TRUE),
        " to ", max(dc_inventory$latest_permit, na.rm = TRUE))
message("Total buildings: ", sum(dc_inventory$n_buildings, na.rm = TRUE))
message("Total building sqft: ", format(sum(dc_inventory$total_bldg_sqft, na.rm = TRUE), big.mark = ","))
message("\nZoning breakdown:")
print(sort(table(dc_inventory$zoning), decreasing = TRUE))

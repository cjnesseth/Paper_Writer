## ============================================================================
## 04_build_transaction_panel.R
## Build analysis-ready property transaction panel (no sf dependency):
##   1. Stack sales reports 2020-2025 (harmonize column names)
##   2. Apply arm's-length filter
##   3. Merge with residential dwelling data (structural controls)
##   4. Merge with assessed values
##   5. Merge with parcel GIS for coordinates (via GeoJSON + jsonlite)
##   6. Compute distance to nearest data center (Haversine)
##   7. Output panel
## ============================================================================

set.seed(20260329)
library(readxl)
library(dplyr)

raw_dir  <- here::here("explorations", "data_collection", "raw")
proc_dir <- here::here("explorations", "data_collection", "processed")
dir.create(proc_dir, recursive = TRUE, showWarnings = FALSE)

# ==========================================================================
# HELPER: Haversine distance in meters
# ==========================================================================
haversine_m <- function(lon1, lat1, lon2, lat2) {
  R <- 6371000
  dlon <- (lon2 - lon1) * pi / 180
  dlat <- (lat2 - lat1) * pi / 180
  a <- sin(dlat / 2)^2 + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dlon / 2)^2
  2 * R * asin(sqrt(a))
}

# ==========================================================================
# 1. LOAD AND HARMONIZE SALES REPORTS
# ==========================================================================
message("=== Loading Sales Reports ===")

read_sales_2020 <- function(path) {
  d <- read_excel(path, sheet = 1, skip = 4,
                  col_names = c("row_num", "instrument", "parid", "tax_map",
                                "state_class", "sale_date_serial", "sale_price",
                                "sale_code", "mail1", "mail2", "mail3",
                                "city", "state", "zip", "zip2", "country",
                                "grantor", "grantee", "zoning", "occ",
                                "group", "com_sfla", "election_dist",
                                "res_sfla", "sale_type", "billing_dist",
                                "legal2", "legal3", "legal1", "acres",
                                "prop_address", "prop_city", "prop_zip"),
                  col_types = "text")
  d %>%
    filter(!is.na(parid), parid != "PIN") %>%
    transmute(
      parid,
      sale_date = as.Date(as.numeric(sale_date_serial), origin = "1899-12-30"),
      sale_price = as.numeric(sale_price),
      sale_verification = sale_code,
      sale_type,
      state_class,
      source_year = 2020L
    )
}

read_sales_2021 <- function(path) {
  # 2021 has 33 cols with different layout than 2020; NO sale_type column
  # Actual layout from row 2: #, INSTRUNO, PARID, TAX_MAP, State Class,
  #   Sale Date, PRICE, Sale Code, ADDRTYPE, Mailing1-3, CITYNAME, STATEID,
  #   ZIP1, ZIP2, COUNTRY, Grantor, Grantee, Zoning, Occupancy, Group,
  #   Election District, Billing District, LEGAL1, LEGAL3, LEGAL2, ACRES,
  #   PROPERTY_ADDRESS, PROPERTY_CITY, PROPERTY_ZIP, USER29, LUC
  d <- read_excel(path, sheet = 1, skip = 1,
                  col_names = c("row_num", "instrument", "parid", "tax_map",
                                "state_class", "sale_date_serial", "sale_price",
                                "sale_code", "addr_type", "mail1", "mail2",
                                "mail3", "city", "state", "zip", "zip2",
                                "country", "grantor", "grantee", "zoning",
                                "occ", "group", "election_dist", "billing_dist",
                                "legal1", "legal3", "legal2", "acres",
                                "prop_address", "prop_city", "prop_zip",
                                "user29", "luc"),
                  col_types = "text")
  d %>%
    filter(!is.na(parid), parid != "PARID") %>%
    transmute(
      parid,
      sale_date = as.Date(as.numeric(sale_date_serial), origin = "1899-12-30"),
      sale_price = as.numeric(sale_price),
      sale_verification = sale_code,
      sale_type = NA_character_,  # 2021 file has no sale_type column
      state_class,
      source_year = 2021L
    )
}

read_sales_clean <- function(path, year) {
  d <- read_excel(path, sheet = 1)
  d %>%
    transmute(
      parid = PARID,
      sale_date = as.Date(`RECORD DATE`),
      sale_price = as.numeric(PRICE),
      sale_verification = `SALE VERIFICATION`,
      sale_type = `SALE TYPE`,
      state_class = NA_character_,
      source_year = as.integer(year)
    )
}

sales_list <- list()
sales_list[["2020"]] <- read_sales_2020(file.path(raw_dir, "sales_2020.xlsx"))
message("  2020: ", nrow(sales_list[["2020"]]), " rows")

sales_list[["2021"]] <- read_sales_2021(file.path(raw_dir, "sales_2021.xlsx"))
message("  2021: ", nrow(sales_list[["2021"]]), " rows")

for (yr in 2022:2025) {
  f <- file.path(raw_dir, sprintf("sales_%d.xlsx", yr))
  if (file.exists(f)) {
    sales_list[[as.character(yr)]] <- read_sales_clean(f, yr)
    message("  ", yr, ": ", nrow(sales_list[[as.character(yr)]]), " rows")
  }
}

sales_raw <- bind_rows(sales_list)
message("\nTotal raw sales: ", nrow(sales_raw))
message("Date range: ", min(sales_raw$sale_date, na.rm = TRUE),
        " to ", max(sales_raw$sale_date, na.rm = TRUE))

# ==========================================================================
# 2. ARM'S-LENGTH FILTER
# ==========================================================================
message("\n=== Applying Arm's-Length Filter ===")

market_codes <- c("1:MARKET SALE", "V:NEW CONSTRUCTION",
                  "5:MARKET MULTI-PARCEL SALE", "2:MARKET LAND SALE")

sales_filtered <- sales_raw %>%
  filter(
    sale_verification %in% market_codes,
    sale_price > 10000,
    !is.na(sale_date)
  )
message("After sale code filter: ", nrow(sales_filtered),
        " (dropped ", nrow(sales_raw) - nrow(sales_filtered), ")")

# Keep Land & Building only (where field is available)
sales_hedonic <- sales_filtered %>%
  filter(is.na(sale_type) | grepl("Land & Building", sale_type))
message("After Land & Building filter: ", nrow(sales_hedonic),
        " (dropped ", nrow(sales_filtered) - nrow(sales_hedonic), ")")

# ==========================================================================
# 3. MERGE WITH RESIDENTIAL DWELLING DATA
# ==========================================================================
message("\n=== Merging Residential Dwelling Data ===")

dwelling <- read_excel(file.path(raw_dir, "residential_dwelling_2026.xlsx"), sheet = 1)
dwelling_clean <- dwelling %>%
  transmute(
    parid = PARID,
    style = STYLE,
    year_built = as.integer(YRBLT),
    stories = STORIES,
    living_area = as.numeric(`Living Area`),
    bedrooms = as.integer(Bedrooms),
    baths = as.numeric(Baths),
    half_baths = as.integer(`Half Bath`),
    grade = GRADE,
    condition = Condition,
    ext_wall = EXTWALL,
    bsmt = BSMT,
    fin_bsmt_area = as.numeric(FINBSMTAREA),
    heat = HEAT
  )

# Keep first record per PARID (primary dwelling card)
dwelling_dedup <- dwelling_clean %>%
  group_by(parid) %>%
  slice(1) %>%
  ungroup()

message("Dwelling records: ", nrow(dwelling_clean),
        " -> ", nrow(dwelling_dedup), " unique PARIDs")

sales_merged <- sales_hedonic %>%
  left_join(dwelling_dedup, by = "parid")

n_with_dwelling <- sum(!is.na(sales_merged$living_area))
message("Sales with dwelling data: ", n_with_dwelling, " / ", nrow(sales_merged),
        " (", round(100 * n_with_dwelling / nrow(sales_merged), 1), "%)")

# ==========================================================================
# 4. MERGE WITH ASSESSED VALUES
# ==========================================================================
message("\n=== Merging Assessed Values ===")

assessed <- read_excel(file.path(raw_dir, "assessed_values_2026.xlsx"), sheet = 1)
assessed_clean <- assessed %>%
  transmute(
    parid = PARID,
    assessed_class = CLASS,
    fair_market_land = as.numeric(`FAIR MARKET LAND`),
    fair_market_building = as.numeric(`FAIR MARKET BUILDING`),
    fair_market_total = as.numeric(`FAIR MARKET TOTAL`),
    taxable_value = as.numeric(`TAXABLE VALUE`)
  )

sales_merged <- sales_merged %>%
  left_join(assessed_clean, by = "parid")

n_with_assessed <- sum(!is.na(sales_merged$fair_market_total))
message("Sales with assessed value: ", n_with_assessed, " / ", nrow(sales_merged),
        " (", round(100 * n_with_assessed / nrow(sales_merged), 1), "%)")

# Filter to residential (assessed class 1 or 2, or state_class 1 or 2)
sales_residential <- sales_merged %>%
  filter(
    grepl("^1:|^2:", assessed_class) |
    (!is.na(state_class) & grepl("^1:|^2:", state_class))
  )
message("After residential filter: ", nrow(sales_residential),
        " (dropped ", nrow(sales_merged) - nrow(sales_residential), ")")

# ==========================================================================
# 5. MERGE WITH PARCEL COORDINATES (from shapefile centroids)
# ==========================================================================
message("\n=== Merging Parcel Coordinates ===")

# Centroids extracted from official parcel shapefile via extract_parcel_centroids.py
parcel_coords <- read.csv(file.path(proc_dir, "parcel_centroids.csv"),
                           colClasses = c(parid = "character",
                                          lon = "numeric",
                                          lat = "numeric"))
message("Parcel centroids loaded: ", nrow(parcel_coords))

# Direct join on exact PARID
sales_with_coords <- sales_residential %>%
  left_join(parcel_coords, by = "parid")

n_direct <- sum(!is.na(sales_with_coords$lon))
message("Direct PARID match: ", n_direct, " / ", nrow(sales_with_coords),
        " (", round(100 * n_direct / nrow(sales_with_coords), 1), "%)")

# Fallback: match unit-level PARIDs to parent parcel (first 9 digits + "000")
if (n_direct < nrow(sales_with_coords)) {
  parent_coords <- parcel_coords %>%
    mutate(parent9 = substr(parid, 1, 9)) %>%
    group_by(parent9) %>%
    slice(1) %>%
    ungroup() %>%
    select(parent9, parent_lon = lon, parent_lat = lat)

  sales_with_coords <- sales_with_coords %>%
    mutate(parent9 = substr(parid, 1, 9)) %>%
    left_join(parent_coords, by = "parent9") %>%
    mutate(
      lon = ifelse(is.na(lon), parent_lon, lon),
      lat = ifelse(is.na(lat), parent_lat, lat)
    ) %>%
    select(-parent9, -parent_lon, -parent_lat)

  n_with_parent <- sum(!is.na(sales_with_coords$lon))
  message("After parent-parcel fallback: ", n_with_parent, " / ", nrow(sales_with_coords),
          " (", round(100 * n_with_parent / nrow(sales_with_coords), 1), "%)")
}

n_with_coords <- sum(!is.na(sales_with_coords$lon))
message("Final coordinate match: ", n_with_coords, " / ", nrow(sales_with_coords),
        " (", round(100 * n_with_coords / nrow(sales_with_coords), 1), "%)")

# ==========================================================================
# 6. COMPUTE DISTANCE TO NEAREST DATA CENTER (Haversine)
# ==========================================================================
message("\n=== Computing Distance to Nearest Data Center ===")

dc_inv <- read.csv(file.path(proc_dir, "dc_master_inventory.csv"),
                    stringsAsFactors = FALSE)
dc_built <- dc_inv %>%
  filter(built_status == "BUILT", !is.na(lon), !is.na(lat))
message("Built DCs with coordinates: ", nrow(dc_built))

sales_geo <- sales_with_coords %>% filter(!is.na(lon), !is.na(lat))

if (nrow(sales_geo) > 0 && nrow(dc_built) > 0) {
  message("Computing distances for ", nrow(sales_geo), " sales...")

  # Vectorized distance computation
  dc_lons <- dc_built$lon
  dc_lats <- dc_built$lat

  min_dist_m <- numeric(nrow(sales_geo))
  nearest_idx <- integer(nrow(sales_geo))

  for (i in seq_len(nrow(sales_geo))) {
    dists <- haversine_m(sales_geo$lon[i], sales_geo$lat[i], dc_lons, dc_lats)
    min_dist_m[i] <- min(dists)
    nearest_idx[i] <- which.min(dists)
  }

  sales_geo$dist_nearest_dc_m <- min_dist_m
  sales_geo$dist_nearest_dc_km <- min_dist_m / 1000
  sales_geo$nearest_dc_project <- dc_built$project[nearest_idx]

  sales_geo$within_1km <- sales_geo$dist_nearest_dc_km <= 1
  sales_geo$within_2km <- sales_geo$dist_nearest_dc_km <= 2
  sales_geo$within_4km <- sales_geo$dist_nearest_dc_km <= 4

  message("Distance summary (km):")
  message("  Min: ", round(min(sales_geo$dist_nearest_dc_km), 2))
  message("  Median: ", round(median(sales_geo$dist_nearest_dc_km), 2))
  message("  Max: ", round(max(sales_geo$dist_nearest_dc_km), 2))
  message("  Within 1km: ", sum(sales_geo$within_1km))
  message("  Within 2km: ", sum(sales_geo$within_2km))
  message("  Within 4km: ", sum(sales_geo$within_4km))
} else {
  message("Skipping distance computation (no geocoded sales or no DCs)")
  sales_geo <- sales_with_coords
}

# ==========================================================================
# 7. SAVE OUTPUT
# ==========================================================================
message("\n=== Saving Panel ===")

out_file <- file.path(proc_dir, "property_transactions_panel.csv")
write.csv(sales_geo, out_file, row.names = FALSE)

message("\n========================================")
message("PROPERTY TRANSACTION PANEL SUMMARY")
message("========================================")
message("Total arm's-length residential sales: ", nrow(sales_geo))
message("Date range: ", min(sales_geo$sale_date, na.rm = TRUE),
        " to ", max(sales_geo$sale_date, na.rm = TRUE))
message("Unique parcels: ", n_distinct(sales_geo$parid))
message("Median sale price: $", format(median(sales_geo$sale_price, na.rm = TRUE), big.mark = ","))

if ("living_area" %in% names(sales_geo)) {
  message("With structural controls: ",
          sum(!is.na(sales_geo$living_area)), " / ", nrow(sales_geo))
}
if ("lon" %in% names(sales_geo)) {
  message("With coordinates: ",
          sum(!is.na(sales_geo$lon)), " / ", nrow(sales_geo))
}
if ("within_1km" %in% names(sales_geo)) {
  message("Within 1km of DC: ", sum(sales_geo$within_1km, na.rm = TRUE))
  message("Within 2km of DC: ", sum(sales_geo$within_2km, na.rm = TRUE))
  message("Within 4km of DC: ", sum(sales_geo$within_4km, na.rm = TRUE))
}

message("\nSaved to: ", out_file)
message("File size: ", format(file.size(out_file), big.mark = ","), " bytes")

message("\nSales by year:")
print(table(sales_geo$source_year))

# ==============================================================================
# 01_fetch_cems.R -- monthly state power-sector CO2 (PUBLIC)
# ==============================================================================
# Primary (keyed, NOT yet available): EPA CAMPD / CEMS measured CO2 -- requires
#   EPA_CAMPD_API_KEY (free signup at campd.epa.gov). Implement when a key exists.
# Keyless fallback (ACTIVE): EIA-923 fuel consumption x EPA/EIA emission factors.
#   Form EIA-923 "Page 1 Generation and Fuel Data" reports monthly fuel consumed
#   for electricity (Elec_MMBtu) by plant and fuel; multiplying by per-fuel CO2
#   factors gives estimated combustion CO2. Standard public proxy; documented in
#   the Data appendix and labeled co2_source = "eia923_derived" throughout.
#   https://www.eia.gov/electricity/data/eia923/  (f923_YYYY.zip, no key)
# Output: data/raw/f923_YYYY.zip; data/tidy/emissions_state_month.rds
#         (state, month, co2 [million metric tons], co2_source)
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

# current year lives under /xls/; completed years move to /archive/xls/
EIA923_URL         <- "https://www.eia.gov/electricity/data/eia923/xls/f923_%d.zip"
EIA923_ARCHIVE_URL <- "https://www.eia.gov/electricity/data/eia923/archive/xls/f923_%d.zip"

eia923_url <- function(yr) {
  sprintf(if (yr >= year(SAMPLE_END)) EIA923_URL else EIA923_ARCHIVE_URL, yr)
}

# CO2 factors, kg per MMBtu, by EIA AER/MER fuel type code (EIA MER Table A.3 /
# EPA emission factor hub; coal = electric-power average across ranks).
# Non-combustion, biogenic, and unidentified fuels carry zero here (biomass CO2
# is excluded from RGGI compliance accounting as well).
CO2_KG_PER_MMBTU <- c(
  COL = 95.52,   # coal (electric power average)
  WC  = 93.28,   # waste coal
  NG  = 53.07,   # natural gas
  PEL = 74.14,   # petroleum liquids (MER aggregate)
  DFO = 73.16,   # distillate fuel oil
  RFO = 78.79,   # residual fuel oil
  KER = 72.31,   # kerosene
  WOO = 74.14,   # waste/other oil (petroleum-liquids factor)
  PC  = 102.12,  # petroleum coke
  OOG = 59.00,   # other gases (blast furnace etc., approximate)
  MLG = 0,       # landfill gas (biogenic)
  ORW = 0, WWW = 0, OTH = 0  # other renewables / wood / unidentified
)

fetch_eia923_year <- function(yr) {
  zip_path <- cached_download(eia923_url(yr), sprintf("f923_%d.zip", yr))
  if (is.null(zip_path)) return(NULL)
  files <- tryCatch(unzip(zip_path, list = TRUE)$Name, error = function(e) {
    message("[01_fetch_cems] corrupt zip (deleting; re-run to re-fetch): ", zip_path)
    unlink(zip_path); NULL })
  if (is.null(files)) return(NULL)
  xlsx <- grep("2_3_4_5.*\\.xlsx$", files, value = TRUE)
  if (!length(xlsx)) { message("[01_fetch_cems] no schedules xlsx in ", zip_path); return(NULL) }
  xlsx <- sort(xlsx, decreasing = TRUE)[1]           # prefer latest revision
  exdir <- file.path(DIRS$data_raw, "eia923_extracted")
  unzip(zip_path, files = xlsx, exdir = exdir, overwrite = TRUE)
  file.path(exdir, xlsx)
}

tidy_eia923_co2 <- function(xlsx, yr) {
  if (!requireNamespace("readxl", quietly = TRUE)) stop("install.packages('readxl')")
  raw <- suppressMessages(readxl::read_excel(
    xlsx, sheet = "Page 1 Generation and Fuel Data", skip = 5,
    .name_repair = "unique", guess_max = 20000))
  dt <- as.data.table(raw)
  setnames(dt, names(dt), gsub("[\r\n]+", " ", names(dt)))
  sc <- grep("^Plant State", names(dt), value = TRUE)[1]
  fc <- grep("^(MER|AER) Fuel Type", names(dt), value = TRUE)[1]  # AER pre-2022
  mcols <- grep("^Elec_MMBtu", names(dt), value = TRUE)
  if (any(is.na(c(sc, fc))) || length(mcols) != 12L)
    stop("[01_fetch_cems] unexpected 923 layout in ", basename(xlsx))
  long <- melt(dt[, c(sc, fc, mcols), with = FALSE],
               id.vars = c(sc, fc), variable.name = "mon_name",
               value.name = "mmbtu", variable.factor = FALSE)
  setnames(long, c(sc, fc), c("state", "fuel"))
  long[, mmbtu := suppressWarnings(as.numeric(mmbtu))]
  long[, mon := match(sub("^Elec_MMBtu ", "", mon_name), month.name)]
  long <- long[!is.na(mmbtu) & !is.na(mon) & nchar(state) == 2]
  long[, co2_kg := mmbtu * fifelse(fuel %in% names(CO2_KG_PER_MMBTU),
                                   CO2_KG_PER_MMBTU[fuel], 0)]
  out <- long[, .(co2 = sum(co2_kg) / 1e9),            # kg -> million metric tons
              by = .(state = toupper(state),
                     month = as.Date(sprintf("%04d-%02d-01", yr, mon)))]
  out[]
}

fetch_emissions <- function(years = seq(year(SAMPLE_START), year(SAMPLE_END))) {
  if (nzchar(Sys.getenv("EPA_CAMPD_API_KEY")))
    message("[01_fetch_cems] EPA_CAMPD_API_KEY detected but CAMPD path not yet ",
            "implemented; using EIA-923 derived series. (TODO: prefer CEMS.)")
  res <- list()
  for (yr in years) {
    xlsx <- fetch_eia923_year(yr)
    if (is.null(xlsx)) next
    res[[as.character(yr)]] <- tryCatch(tidy_eia923_co2(xlsx, yr), error = function(e) {
      message("[01_fetch_cems] ", yr, " failed: ", conditionMessage(e)); NULL })
  }
  res <- Filter(Negate(is.null), res)
  if (!length(res)) return(NULL)
  out <- rbindlist(res)
  # trailing months of the current year are structural zeros in the workbook,
  # not observations -- drop all-zero state-months at the sample edge.
  totals <- out[, .(tot = sum(co2)), by = month]
  out <- out[month %in% totals[tot > 0, month]]
  out <- out[month >= SAMPLE_START & month <= SAMPLE_END]
  out[, co2_source := "eia923_derived"]
  setorder(out, state, month)
  out[]
}

if (sys.nframe() == 0) {
  em <- fetch_emissions()
  if (!is.null(em)) {
    saveRDS(em, file.path(DIRS$data_tidy, "emissions_state_month.rds"))
    log_vintage("eia923_derived_co2", eia923_url(year(SAMPLE_END)),
                sprintf("%s..%s", format(min(em$month)), format(max(em$month))))
    message(sprintf("[01_fetch_cems] emissions: %d rows, %d states, %s..%s (eia923_derived)",
                    nrow(em), uniqueN(em$state),
                    format(min(em$month)), format(max(em$month))))
  }
}

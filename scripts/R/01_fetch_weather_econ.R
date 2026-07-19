# ==============================================================================
# 01_fetch_weather_econ.R -- weather, gas prices, economic controls, SCC (PUBLIC)
# ==============================================================================
# Keyless sources implemented here:
#   * HDD/CDD: NOAA CPC population-weighted state degree days (daily text files,
#     one per year; summed to state-month).
#     https://ftp.cpc.ncep.noaa.gov/htdocs/degree_days/weighted/daily_data/
#   * Natural gas: Henry Hub spot (FRED series DHHNGSP, keyless fredgraph CSV;
#     daily -> monthly mean). EIA API v2 (EIA_API_KEY) remains a keyed alternative.
# Still manual / deferred:
#   * Dominion rider: PUBLIC Virginia SCC dockets -> data/raw/scc_rider.csv
#     (manual entry; record docket numbers). Template written below.
#   * BEA/Census annual controls: deferred (annual; not blocking monthly panel).
# Output: data/tidy/degree_days_state_month.rds, data/tidy/gas_price_month.rds
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

CPC_BASE <- "https://ftp.cpc.ncep.noaa.gov/htdocs/degree_days/weighted/daily_data"
FRED_GAS_URL <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=DHHNGSP"

# Parse one CPC daily file (pipe-delimited: 3 header lines, then Region|YYYYMMDD...)
# into (state, month, value) with value = monthly sum of daily degree days.
parse_cpc_file <- function(path) {
  lines <- readLines(path, warn = FALSE)
  hdr_i <- grep("^Region\\|", lines)[1]
  cols <- strsplit(lines[hdr_i], "|", fixed = TRUE)[[1]]
  dates <- as.Date(cols[-1], format = "%Y%m%d")
  body <- strsplit(lines[(hdr_i + 1):length(lines)], "|", fixed = TRUE)
  body <- body[lengths(body) == length(cols)]
  dt <- rbindlist(lapply(body, function(r) {
    data.table(state = r[1], date = dates,
               value = suppressWarnings(as.numeric(r[-1])))
  }))
  dt[!is.na(value),
     .(value = sum(value)),
     by = .(state, month = as.Date(format(date, "%Y-%m-01")))]
}

fetch_degree_days <- function(years = seq(year(SAMPLE_START), year(SAMPLE_END))) {
  res <- list()
  for (yr in years) for (kind in c("Heating", "Cooling")) {
    url <- sprintf("%s/%d/StatesCONUS.%s.txt", CPC_BASE, yr, kind)
    f <- cached_download(url, sprintf("cpc_%s_%d.txt", tolower(kind), yr))
    if (is.null(f)) next
    dd <- parse_cpc_file(f)
    dd[, kind := kind]
    res[[paste(yr, kind)]] <- dd
  }
  if (!length(res)) return(NULL)
  dd <- rbindlist(res)
  out <- dcast(dd, state + month ~ kind, value.var = "value")
  setnames(out, c("Heating", "Cooling"), c("hdd", "cdd"))
  out <- out[month >= SAMPLE_START & month <= SAMPLE_END]
  setorder(out, state, month)
  out[]
}

fetch_gas_prices <- function() {
  f <- cached_download(FRED_GAS_URL, "fred_henry_hub_daily.csv")
  if (is.null(f)) return(NULL)
  daily <- fread(f)
  setnames(daily, c("date", "gas"))
  daily <- daily[, .(date = as.Date(date), gas = suppressWarnings(as.numeric(gas)))]
  out <- daily[!is.na(gas),
               .(gas = mean(gas)),
               by = .(month = as.Date(format(date, "%Y-%m-01")))]
  out <- out[month >= SAMPLE_START & month <= SAMPLE_END]
  setorder(out, month)
  out[]
}

fetch_econ_controls <- function(...) {
  stop("Deferred: BEA/Census annual controls (not blocking the monthly panel).")
}

# Dominion rider: enter PUBLIC SCC docket values into a small versioned CSV.
# (No Dominion internal data.) Values added manually from public filings.
write_scc_rider_template <- function(path = file.path(DIRS$data_raw, "scc_rider.csv")) {
  if (file.exists(path)) return(invisible(path))
  template <- data.table(
    effective_date = as.Date(character()),
    rider_dollar_per_month = numeric(),
    docket = character(),
    source_url = character()
  )
  fwrite(template, path)
  message("Wrote SCC rider template: ", path)
  invisible(path)
}

if (sys.nframe() == 0) {
  dd <- tryCatch(fetch_degree_days(), error = function(e) {
    message("[01_fetch_weather_econ] degree days failed: ", conditionMessage(e)); NULL })
  if (!is.null(dd)) {
    saveRDS(dd, file.path(DIRS$data_tidy, "degree_days_state_month.rds"))
    log_vintage("noaa_cpc_degree_days", CPC_BASE,
                sprintf("%s..%s", format(min(dd$month)), format(max(dd$month))))
    message(sprintf("[01_fetch_weather_econ] degree days: %d rows, %d states, %s..%s",
                    nrow(dd), uniqueN(dd$state),
                    format(min(dd$month)), format(max(dd$month))))
  }
  gas <- tryCatch(fetch_gas_prices(), error = function(e) {
    message("[01_fetch_weather_econ] gas failed: ", conditionMessage(e)); NULL })
  if (!is.null(gas)) {
    saveRDS(gas, file.path(DIRS$data_tidy, "gas_price_month.rds"))
    log_vintage("fred_henry_hub", FRED_GAS_URL,
                sprintf("%s..%s", format(min(gas$month)), format(max(gas$month))))
    message(sprintf("[01_fetch_weather_econ] gas: %d months, %s..%s",
                    nrow(gas), format(min(gas$month)), format(max(gas$month))))
  }
  write_scc_rider_template()
}

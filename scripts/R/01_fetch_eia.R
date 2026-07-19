# ==============================================================================
# 01_fetch_eia.R -- retail electricity prices from EIA Form 861M (PUBLIC, no key)
# ==============================================================================
# Source (no API key): EIA-861M "Sales and Revenue" workbook.
#   https://www.eia.gov/electricity/data/eia861m/xls/sales_revenue.xlsx
# Produces a state-month residential retail price series in $/MWh
# (861M reports cents/kWh; cents/kWh * 10 = $/MWh).
# Output: data/raw/eia_861m_sales_revenue.xlsx
#         data/tidy/eia_retail_state_month.rds  (state, month, retail $/MWh, sector)
# Offline-graceful: messages and returns NULL on failure.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

EIA_861M_URL <- "https://www.eia.gov/electricity/data/eia861m/xls/sales_revenue.xlsx"

download_eia_861m <- function(url = EIA_861M_URL) {
  cached_download(url, "eia_861m_sales_revenue.xlsx")
}

# Parse the 861M workbook into a tidy residential retail-price series.
tidy_eia_861m <- function(xlsx) {
  if (!requireNamespace("readxl", quietly = TRUE)) stop("install.packages('readxl')")
  sheets <- readxl::excel_sheets(xlsx)
  # data sheet is typically the first non-cover sheet; header spans 2-3 rows.
  sh <- sheets[which(grepl("monthly|sales|revenue|county|data", tolower(sheets)))[1]]
  if (is.na(sh)) sh <- sheets[1]
  raw <- suppressMessages(readxl::read_excel(xlsx, sheet = sh, skip = 2,
                                             .name_repair = "unique"))
  dt <- as.data.table(raw)
  setnames(dt, names(dt), make.unique(tolower(gsub("[^a-z0-9]+", "_",
                                                   tolower(names(dt))))))
  # locate Year, Month, State columns and the FIRST 'price' column (Residential).
  yc <- grep("^year", names(dt), value = TRUE)[1]
  mc <- grep("^month", names(dt), value = TRUE)[1]
  sc <- grep("^state", names(dt), value = TRUE)[1]
  # residential price: first price-like column ("Price" pre-2026 vintages;
  # "Cents/kWh" from the Jun-2026 workbook redesign)
  pc <- grep("price|cents_kwh", names(dt), value = TRUE)[1]
  if (any(is.na(c(yc, mc, sc, pc))))
    stop("[01_fetch_eia] could not locate Year/Month/State/Price columns; inspect ", sh)
  out <- dt[, .(state = toupper(trimws(get(sc))),
                year  = suppressWarnings(as.integer(get(yc))),
                mon   = suppressWarnings(as.integer(get(mc))),
                price_cents = suppressWarnings(as.numeric(get(pc))))]
  out <- out[!is.na(year) & !is.na(mon) & nchar(state) == 2]
  out[, month := as.Date(sprintf("%04d-%02d-01", year, mon))]
  out[, retail := price_cents * 10]                    # cents/kWh -> $/MWh
  out <- out[month >= SAMPLE_START & month <= SAMPLE_END,
             .(state, month, retail, sector = "residential")]
  setorder(out, state, month)
  out[]
}

if (sys.nframe() == 0) {
  x <- download_eia_861m()
  if (!is.null(x)) {
    tidy <- tryCatch(tidy_eia_861m(x), error = function(e) {
      message(conditionMessage(e)); NULL })
    if (!is.null(tidy)) {
      saveRDS(tidy, file.path(DIRS$data_tidy, "eia_retail_state_month.rds"))
      log_vintage("eia_861m_retail", EIA_861M_URL,
                  sprintf("%s..%s", format(min(tidy$month)), format(max(tidy$month))))
      message(sprintf("[01_fetch_eia] tidy retail: %d rows, %d states, %s..%s",
                      nrow(tidy), uniqueN(tidy$state),
                      format(min(tidy$month)), format(max(tidy$month))))
    }
  }
}

# ==============================================================================
# 01_fetch_rggi.R -- allowance auction prices & volumes (PUBLIC, no key)
# ==============================================================================
# Source: RGGI Inc. "Allowance Prices and Volumes" table (HTML; no data file is
# published, so we parse the table with rvest).
#   https://www.rggi.org/auctions/auction-results/prices-volumes
# One row per auction (quarterly): number, date, quantities, clearing price,
# proceeds. Feeds the Sec. 4 carbon-adder series pi_allow, the anticipation
# figure (Auction 72, Jun 2026 = first post-HB29 auction), and treatment
# intensity. Output: data/raw/rggi_prices_volumes.html (archived page),
#                    data/tidy/allowance_price_auction.rds
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

RGGI_PV_URL <- "https://www.rggi.org/auctions/auction-results/prices-volumes"

fetch_rggi_auctions <- function(url = RGGI_PV_URL) {
  if (!requireNamespace("rvest", quietly = TRUE)) stop("install.packages('rvest')")
  html_path <- cached_download(url, "rggi_prices_volumes.html")
  if (is.null(html_path)) return(NULL)
  page <- rvest::read_html(html_path)
  tabs <- rvest::html_table(page)
  # the prices-volumes table is the one with a Clearing Price column
  tab <- Filter(function(t) any(grepl("Clearing", names(t), ignore.case = TRUE)), tabs)
  if (!length(tab)) stop("[01_fetch_rggi] no Clearing Price table found; page layout changed?")
  dt <- as.data.table(tab[[1]])
  setnames(dt, names(dt), gsub("[^a-z0-9]+", "_", tolower(trimws(names(dt)))))
  num <- function(x) suppressWarnings(as.numeric(gsub("[$,]", "", x)))
  out <- dt[, .(
    auction        = suppressWarnings(as.integer(gsub("\\D", "", auction))),
    date           = as.Date(date, tryFormats = c("%Y-%m-%d", "%m/%d/%Y", "%B %d, %Y")),
    qty_offered    = num(quantity_offered),
    ccr_sold       = num(ccr_sold),
    qty_sold       = num(quantity_sold),
    clearing_price = num(clearing_price),
    proceeds       = num(total_proceeds)
  )]
  out <- out[!is.na(date) & !is.na(clearing_price)]
  setorder(out, date)
  out[]
}

if (sys.nframe() == 0) {
  auctions <- tryCatch(fetch_rggi_auctions(), error = function(e) {
    message("[01_fetch_rggi] failed: ", conditionMessage(e)); NULL })
  if (!is.null(auctions)) {
    saveRDS(auctions, file.path(DIRS$data_tidy, "allowance_price_auction.rds"))
    log_vintage("rggi_auctions", RGGI_PV_URL,
                sprintf("auctions %d-%d (%s..%s)",
                        min(auctions$auction, na.rm = TRUE),
                        max(auctions$auction, na.rm = TRUE),
                        format(min(auctions$date)), format(max(auctions$date))))
    message(sprintf("[01_fetch_rggi] %d auctions, %s..%s; latest clearing price $%.2f",
                    nrow(auctions), format(min(auctions$date)),
                    format(max(auctions$date)), last(auctions$clearing_price)))
  }
}

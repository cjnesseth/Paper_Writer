## ============================================================================
## 03_inspect_county_data.R
## Inspect downloaded Loudoun County data files: column names, row counts,
## sample values, and join key identification
## ============================================================================

library(readxl)
library(dplyr)
library(readr)

raw_dir <- here::here("explorations", "data_collection", "raw")

cat("=============================================================\n")
cat("LOUDOUN COUNTY DATA INSPECTION REPORT\n")
cat("=============================================================\n\n")

# --- 1. Sales Reports ---
cat("=== REAL PROPERTY SALES REPORTS ===\n\n")
sales_files <- sort(list.files(raw_dir, pattern = "^sales_\\d{4}\\.xlsx$", full.names = TRUE))

for (f in sales_files) {
  year <- gsub(".*sales_(\\d{4})\\.xlsx", "\\1", f)
  cat(sprintf("--- %s (sales_%s.xlsx) ---\n", year, year))

  # Try reading; some files may have multiple sheets
  sheets <- excel_sheets(f)
  cat("  Sheets:", paste(sheets, collapse = ", "), "\n")

  dat <- tryCatch(
    read_excel(f, sheet = 1, guess_max = 5000),
    error = function(e) {
      cat("  ERROR reading:", e$message, "\n")
      return(NULL)
    }
  )

  if (!is.null(dat)) {
    cat("  Rows:", nrow(dat), " Cols:", ncol(dat), "\n")
    cat("  Columns:", paste(names(dat), collapse = ", "), "\n")
    cat("  First 3 rows:\n")
    print(head(dat, 3))
    cat("\n")
  }
}

# --- 2. Assessed Values ---
cat("\n=== 2026 ASSESSED VALUES ===\n\n")
av_file <- file.path(raw_dir, "assessed_values_2026.xlsx")
sheets <- excel_sheets(av_file)
cat("Sheets:", paste(sheets, collapse = ", "), "\n")
av <- tryCatch(read_excel(av_file, sheet = 1, guess_max = 5000), error = function(e) NULL)
if (!is.null(av)) {
  cat("Rows:", nrow(av), " Cols:", ncol(av), "\n")
  cat("Columns:", paste(names(av), collapse = ", "), "\n")
  cat("First 3 rows:\n")
  print(head(av, 3))
}

# --- 3. Residential Dwelling Data ---
cat("\n=== 2026 RESIDENTIAL DWELLING DATA ===\n\n")
rd_file <- file.path(raw_dir, "residential_dwelling_2026.xlsx")
sheets <- excel_sheets(rd_file)
cat("Sheets:", paste(sheets, collapse = ", "), "\n")
rd <- tryCatch(read_excel(rd_file, sheet = 1, guess_max = 5000), error = function(e) NULL)
if (!is.null(rd)) {
  cat("Rows:", nrow(rd), " Cols:", ncol(rd), "\n")
  cat("Columns:", paste(names(rd), collapse = ", "), "\n")
  cat("First 3 rows:\n")
  print(head(rd, 3))
}

# --- 4. Commercial Dwelling Data ---
cat("\n=== 2026 COMMERCIAL DWELLING DATA ===\n\n")
cd_file <- file.path(raw_dir, "commercial_dwelling_2026.xlsx")
sheets <- excel_sheets(cd_file)
cat("Sheets:", paste(sheets, collapse = ", "), "\n")
cd <- tryCatch(read_excel(cd_file, sheet = 1, guess_max = 5000), error = function(e) NULL)
if (!is.null(cd)) {
  cat("Rows:", nrow(cd), " Cols:", ncol(cd), "\n")
  cat("Columns:", paste(names(cd), collapse = ", "), "\n")
  cat("First 3 rows:\n")
  print(head(cd, 3))
}

# --- 5. Owner Legal Address ---
cat("\n=== 2026 OWNER LEGAL ADDRESS DATA ===\n\n")
ol_file <- file.path(raw_dir, "owner_legal_address_2026.xlsx")
sheets <- excel_sheets(ol_file)
cat("Sheets:", paste(sheets, collapse = ", "), "\n")
ol <- tryCatch(read_excel(ol_file, sheet = 1, guess_max = 5000), error = function(e) NULL)
if (!is.null(ol)) {
  cat("Rows:", nrow(ol), " Cols:", ncol(ol), "\n")
  cat("Columns:", paste(names(ol), collapse = ", "), "\n")
  cat("First 3 rows:\n")
  print(head(ol, 3))
}

# --- 6. Treasurer CSV ---
cat("\n=== TREASURER REAL ESTATE DATA ===\n\n")
tr_file <- file.path(raw_dir, "treasurer_real_estate.csv")
# Check first few lines to understand format
cat("First 5 lines of CSV:\n")
writeLines(readLines(tr_file, n = 5))
cat("\n")

tr <- tryCatch(
  read_csv(tr_file, n_max = 100, show_col_types = FALSE),
  error = function(e) {
    cat("  CSV read error, trying with different delimiter...\n")
    tryCatch(
      read_delim(tr_file, delim = "|", n_max = 100, show_col_types = FALSE),
      error = function(e2) {
        cat("  ERROR:", e2$message, "\n")
        NULL
      }
    )
  }
)

if (!is.null(tr)) {
  cat("Rows (first 100):", nrow(tr), " Cols:", ncol(tr), "\n")
  cat("Columns:", paste(names(tr), collapse = ", "), "\n")
  cat("First 3 rows:\n")
  print(head(tr, 3))
}

# --- 7. Treasurer Layout Guide ---
cat("\n=== TREASURER LAYOUT GUIDE ===\n\n")
tl_file <- file.path(raw_dir, "treasurer_layout.xlsx")
tl <- tryCatch(read_excel(tl_file, sheet = 1), error = function(e) NULL)
if (!is.null(tl)) {
  cat("Layout fields:\n")
  print(tl, n = 50)
}

# --- 8. Join Key Analysis ---
cat("\n=============================================================\n")
cat("JOIN KEY ANALYSIS\n")
cat("=============================================================\n\n")

# Check what ID fields exist across datasets
cat("Potential join keys across datasets:\n\n")

if (!is.null(av)) {
  id_cols_av <- names(av)[grepl("(?i)(pin|gpin|parid|parcel|mcpi|id|map)", names(av))]
  cat("  Assessed Values ID cols:", paste(id_cols_av, collapse = ", "), "\n")
  if (length(id_cols_av) > 0) {
    cat("    Sample values:", paste(head(av[[id_cols_av[1]]], 3), collapse = ", "), "\n")
  }
}

if (!is.null(rd)) {
  id_cols_rd <- names(rd)[grepl("(?i)(pin|gpin|parid|parcel|mcpi|id|map)", names(rd))]
  cat("  Residential Dwelling ID cols:", paste(id_cols_rd, collapse = ", "), "\n")
  if (length(id_cols_rd) > 0) {
    cat("    Sample values:", paste(head(rd[[id_cols_rd[1]]], 3), collapse = ", "), "\n")
  }
}

if (length(sales_files) > 0) {
  s1 <- tryCatch(read_excel(sales_files[1], sheet = 1, guess_max = 1000), error = function(e) NULL)
  if (!is.null(s1)) {
    id_cols_s <- names(s1)[grepl("(?i)(pin|gpin|parid|parcel|mcpi|id|map)", names(s1))]
    cat("  Sales Report ID cols:", paste(id_cols_s, collapse = ", "), "\n")
    if (length(id_cols_s) > 0) {
      cat("    Sample values:", paste(head(s1[[id_cols_s[1]]], 3), collapse = ", "), "\n")
    }
  }
}

cat("\nDone.\n")

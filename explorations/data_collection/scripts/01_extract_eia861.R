## ============================================================================
## 01_extract_eia861.R
## Extract Dominion Energy Virginia data from EIA Form 861 annual files
## Columns: year, residential_revenue_1000usd, residential_sales_mwh,
##          residential_customers
## ============================================================================

library(readxl)
library(dplyr)

raw_dir <- here::here("explorations", "data_collection", "raw")
out_dir <- here::here("explorations", "data_collection", "processed")

# EIA 861 Sales_Ult_Cust files have 3 header rows then data
# Columns: 1=Year, 2=Utility_Number, 3=Utility_Name, 4=Part, 5=Service_Type,
#          6=Data_Type, 7=State, 8=Ownership, 9=BA_Code,
#          10=Res_Revenue_1000$, 11=Res_Sales_MWh, 12=Res_Customers,
#          13=Com_Revenue, 14=Com_Sales, 15=Com_Customers,
#          16=Ind_Revenue, 17=Ind_Sales, 18=Ind_Customers,
#          19=Trans_Revenue, 20=Trans_Sales, 21=Trans_Customers,
#          22=Total_Revenue, 23=Total_Sales, 24=Total_Customers

col_names <- c("year", "utility_number", "utility_name", "part",
               "service_type", "data_type", "state", "ownership", "ba_code",
               "res_revenue_1000usd", "res_sales_mwh", "res_customers",
               "com_revenue_1000usd", "com_sales_mwh", "com_customers",
               "ind_revenue_1000usd", "ind_sales_mwh", "ind_customers",
               "trans_revenue_1000usd", "trans_sales_mwh", "trans_customers",
               "total_revenue_1000usd", "total_sales_mwh", "total_customers")

extract_year <- function(yr) {
  # Find the sales file
  dirs <- list.dirs(raw_dir, recursive = FALSE)
  sales_file <- NULL
  for (d in dirs) {
    f <- file.path(d, paste0("Sales_Ult_Cust_", yr, ".xlsx"))
    if (file.exists(f)) { sales_file <- f; break }
  }
  if (is.null(sales_file)) {
    message("  ", yr, ": file not found")
    return(NULL)
  }

  df <- read_excel(sales_file, skip = 3, col_names = FALSE,
                   col_types = "text")
  names(df) <- col_names[seq_len(ncol(df))]

  # Dominion = "Virginia Electric & Power Co" = utility 19876
  dom <- df %>%
    filter(utility_number == "19876",
           state == "VA")

  if (nrow(dom) == 0) {
    message("  ", yr, ": no Dominion VA records")
    return(NULL)
  }

  # Aggregate across parts/service types
  out <- dom %>%
    mutate(across(matches("revenue|sales|customers"), as.numeric)) %>%
    summarize(
      year = yr,
      utility_name = first(utility_name),
      n_rows = n(),
      res_revenue_1000usd  = sum(res_revenue_1000usd, na.rm = TRUE),
      res_sales_mwh        = sum(res_sales_mwh, na.rm = TRUE),
      res_customers         = sum(res_customers, na.rm = TRUE),
      com_revenue_1000usd  = sum(com_revenue_1000usd, na.rm = TRUE),
      com_sales_mwh        = sum(com_sales_mwh, na.rm = TRUE),
      com_customers        = sum(com_customers, na.rm = TRUE),
      ind_revenue_1000usd  = sum(ind_revenue_1000usd, na.rm = TRUE),
      ind_sales_mwh        = sum(ind_sales_mwh, na.rm = TRUE),
      ind_customers        = sum(ind_customers, na.rm = TRUE),
      total_revenue_1000usd = sum(total_revenue_1000usd, na.rm = TRUE),
      total_sales_mwh      = sum(total_sales_mwh, na.rm = TRUE),
      total_customers      = sum(total_customers, na.rm = TRUE)
    )

  message("  ", yr, ": OK (", out$n_rows, " rows, ",
          format(out$res_customers, big.mark = ","), " residential customers)")
  return(out)
}

message("Extracting Dominion Energy Virginia from EIA 861...")
results <- lapply(2015:2023, function(y) {
  tryCatch(extract_year(y), error = function(e) {
    message("  ", y, " ERROR: ", e$message)
    NULL
  })
})

panel <- bind_rows(results)

# Compute derived variables
panel <- panel %>%
  mutate(
    res_avg_price_cents_kwh = (res_revenue_1000usd * 1000) /
                               (res_sales_mwh * 1000) * 100,
    res_avg_usage_kwh       = (res_sales_mwh * 1000) / res_customers,
    res_avg_bill_usd        = (res_revenue_1000usd * 1000) / res_customers / 12
  )

# Save
out_file <- file.path(out_dir, "dominion_eia861_panel.csv")
write.csv(panel, out_file, row.names = FALSE)
message("\nSaved ", nrow(panel), " years to: ", out_file)

# Print key columns
panel %>%
  select(year, res_customers, res_sales_mwh, res_revenue_1000usd,
         res_avg_price_cents_kwh, res_avg_bill_usd,
         total_sales_mwh, total_customers) %>%
  print(n = Inf)

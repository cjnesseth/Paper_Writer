# Data Collection: Loudoun County Data Center Study

## Structure
- `raw/` — Downloaded source files (gitignored; re-download via checklist)
- `processed/` — Cleaned extracts ready for analysis
- `scripts/` — R scripts for data extraction and processing
- `output/` — Analysis outputs

## Processed Datasets
| File | Source | Description |
|------|--------|-------------|
| `property_transactions_panel.csv` | Loudoun Commissioner of Revenue (2020-2025) | 36,162 arm's-length residential sales with structural controls, coordinates, DC distances |
| `parcel_centroids.csv` | Loudoun County parcel shapefile | 131,021 parcel centroids (WGS84 lat/lon) |
| `dc_master_inventory.csv` | Loudoun County GIS | 135 DC parcels with permit dates, zoning, centroids |
| `dc_centroids.geojson` | Derived from dc_master_inventory | 101 built DC locations as GeoJSON points |
| `dc_permit_timeline.csv` | Derived | DC construction by year |
| `jlarc_data_extract.csv` | JLARC Report 598 (Dec 2024) | 60+ quantitative data points on VA data centers |
| `dominion_eia861_panel.csv` | EIA Form 861 (2015-2023) | Dominion Energy VA: customers, sales, revenue by class |
| `va_tax_rates_2024.csv` | VA Dept of Taxation TY2024 | County tax rates: RE, TPP, M&T for key localities |
| `tax_revenue_timeseries.csv` | BOS FGOEDC, JLARC, county FAQ, news | DC tax revenue by year (total + BPP component); 8 of 14 rows from official sources |
| `dc_assessed_values_timeseries.csv` | FGOEDC Oct 2020 + Jul 2021 | Computer equipment BPP assessed values 2012-2021 ($0.66B to $10.48B) |
| `tax_savings_per_household.csv` | Derived | Residential tax savings from DC revenue |
| `electricity_rate_results.csv` | Derived from JLARC + IRP | Electricity rate incidence estimates |
| `benefit_cost_summary.csv` | Derived | NPV per household: tax benefit vs electricity cost |

## Transaction Panel Details
- **Years:** 2020-2025 (6 years)
- **Filter:** Market sales + new construction, land & building, price > $10K, residential classes 1-2
- **Structural controls:** Living area, bedrooms, baths, year built, grade, condition, basement (from 2026 dwelling data)
- **Assessed values:** Fair market land + building + total, taxable value (2026 assessment)
- **Coordinates:** 99.7% matched via parcel shapefile centroids (direct + parent-parcel fallback)
- **DC distance:** Haversine to nearest of 101 built DCs; treatment rings at 1km, 2km, 4km

## Raw Data Sources (re-download)
- Loudoun sales reports: https://www.loudoun.gov/649/Public-Real-Estate-Reports (2020-2025 XLSX)
- Loudoun assessment data: https://www.loudoun.gov/DocumentCenter/View/212731 (2026)
- Loudoun dwelling data: https://www.loudoun.gov/DocumentCenter/View/212734 (2026)
- Loudoun parcel shapefile: https://geohub-loudoungis.opendata.arcgis.com/ (parcels layer)
- Treasurer CSV: https://interwapp22.loudoun.gov/TreasurerPublicFiles/public/
- JLARC 2024: https://jlarc.virginia.gov/pdfs/reports/Rpt598-2.pdf
- EIA 861: https://www.eia.gov/electricity/data/eia861/
- Census tracts: https://www2.census.gov/geo/tiger/TIGER2020/TRACT/tl_2020_51_tract.zip
- VA tax rates: https://www.tax.virginia.gov/local-tax-rates

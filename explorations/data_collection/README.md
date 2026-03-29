# Data Collection: Loudoun County Data Center Study

## Structure
- `raw/` — Downloaded source files (gitignored; re-download via checklist)
- `processed/` — Cleaned extracts ready for analysis
- `scripts/` — R scripts for data extraction and processing
- `output/` — Analysis outputs

## Processed Datasets
| File | Source | Description |
|------|--------|-------------|
| `jlarc_data_extract.csv` | JLARC Report 598 (Dec 2024) | 60+ quantitative data points on VA data centers |
| `dominion_eia861_panel.csv` | EIA Form 861 (2015-2023) | Dominion Energy VA: customers, sales, revenue by class |
| `va_tax_rates_2024.csv` | VA Dept of Taxation TY2024 | County tax rates: RE, TPP, M&T for key localities |

## Raw Data Sources (re-download)
- JLARC 2024: https://jlarc.virginia.gov/pdfs/reports/Rpt598-2.pdf
- EIA 861: https://www.eia.gov/electricity/data/eia861/
- Census tracts: https://www2.census.gov/geo/tiger/TIGER2020/TRACT/tl_2020_51_tract.zip
- VA tax rates: https://www.tax.virginia.gov/local-tax-rates

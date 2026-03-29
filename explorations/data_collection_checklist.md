# Data Collection Checklist: Loudoun County Data Center Study

**Project:** Political Economy of Data Center Development in Loudoun County, VA
**Last Updated:** 2026-03-29

---

## Overview

Each entry lists the data source, what to request or download, key variables to extract, acquisition method, estimated time, and notes on feasibility. Sources are ordered by priority within each category.

---

## 1. Data Center Locations and Treatment Dates

### 1a. Northern Virginia Regional Commission (NVRC) Data Center Inventory
- **URL:** https://www.novaregion.org
- **What to request:** Geospatial layer of data center locations built or permitted through August 2024 (same dataset used by Waters & Clower 2025)
- **Key variables:** address, lat/lon, construction/permit date, facility sq ft, MW capacity, operator name
- **Method:** Email NVRC (info@novaregion.org); Waters & Clower obtained this; cite them as a precedent
- **Time:** 1–3 days
- **Notes:** Most complete compiled source for NoVA; may need to supplement with county permit records for exact opening dates

### 1b. Loudoun County Building Permits / Certificate of Occupancy Records
- **URL:** https://www.loudoun.gov (permit search portal)
- **What to request:** Commercial building permits for data center facilities (NAICS 518210); certificates of occupancy
- **Key variables:** permit issue date, CO date, address, sq ft, project cost, zoning district
- **Method:** Online permit search; bulk records may require FOIA to loudounfoia@loudoun.gov
- **Time:** 1–3 weeks (FOIA)
- **Notes:** Permit date = construction start; CO date = opening. Both matter for defining treatment timing. Announcement/zoning application date best for capturing anticipation effects (search BOS minutes)

### 1c. Data Center Map / Baxtel (cross-reference)
- **URL:** https://www.datacentermap.com / https://baxtel.com/data-center/northern-virginia
- **What to extract:** Name, address, operator, MW capacity, year opened, status
- **Method:** Manual inspection or paid API
- **Time:** 1–2 days
- **Notes:** Less reliable for exact dates; use as inventory checklist to cross-reference against NVRC and county records

### 1d. Loudoun County Board of Supervisors — Zoning/Rezoning Applications
- **URL:** https://www.loudoun.gov/2093/Board-of-Supervisors (meeting minutes/agendas)
- **What to search:** Rezoning applications for data center campuses by address or applicant name, 2000–2024
- **Key variables:** application date, BOS vote date, approval/denial, conditions
- **Method:** Keyword search in online minutes archive for "data center," "PDIP," applicant names (AWS, Microsoft, QTS, etc.)
- **Time:** 2–4 days
- **Notes:** Application date is the best proxy for "announcement" treatment date

---

## 2. Property Transaction Data

### 2a. Zillow ZTRAX (preferred — if available via university license)
- **Contact:** University library or research data services office
- **What to request:** Loudoun County FIPS 51107 — transaction file + assessor file
- **Key variables:** transaction date, sale price, arm's-length flag, parcel ID (APN), property type
- **Method:** University license; arrives as bulk fixed-width files; R package `ztrax` or manual parsing
- **Time:** 1–2 weeks (license approval)
- **Notes:** Most comprehensive transaction database; includes repeat-sale identifiers

### 2b. Loudoun County Circuit Court Land Records
- **URL:** https://www.loudoun.gov/2230/Land-Records
- **What to request:** All recorded deeds for residential parcels, 2000–2024
- **Key variables:** grantor, grantee, sale price (consideration), instrument date, parcel ID (GPIN), legal description
- **Method:** Free public search at LandRecords.net (Virginia statewide); bulk download may require in-person request or FOIA
- **Time:** 1–5 days depending on bulk access
- **Notes:** Deeds record nominal sale price; apply arm's-length filter (exclude bank/family/foreclosure sales)

### 2c. CoreLogic / ATTOM Data Solutions (commercial alternative)
- **Method:** University subscription or purchased dataset
- **Notes:** Strong arm's-length flag and structural characteristics; good ZTRAX substitute

### 2d. BrightMLS (via broker partnership)
- **Notes:** Used by Waters & Clower (2025) for their 2023 cross-section; excellent structural characteristics; requires MLS member access or research partnership with a local brokerage

---

## 3. Property Characteristics (Assessor Data)

### 3a. Loudoun County Real Estate Assessment Data
- **URL:** https://data.loudoun.gov (Open Data portal)
- **What to download:** Annual assessment rolls, 2000–2024
- **Key variables:** GPIN (parcel ID), situs address, assessed value (land + improvement), sq ft above grade, bedrooms, bathrooms, year built, property class, zoning code, acreage
- **Method:** Annual CSV files downloadable from Open Data portal; some years may require FOIA
- **Time:** 1 day (online) or 1–2 weeks (FOIA for older years)
- **Notes:** Assessments ≠ sale prices; use for structural characteristics to merge onto transaction records using GPIN as key

### 3b. Loudoun County GIS Parcel Layer
- **URL:** https://gis.loudoun.gov
- **What to download:** Residential parcel shapefile with GPIN, address, zoning, acreage, land use class
- **Method:** Free GIS download
- **Time:** 1 hour
- **Notes:** Use parcel centroid coordinates for distance calculations; merge to assessor data on GPIN

---

## 4. Tax Revenue Data (Benefits Side)

### 4a. Loudoun County Commissioner of Revenue — BPP Tax Records
- **URL:** https://www.loudoun.gov/606/Commissioner-of-Revenue
- **What to request:**
  - Business Personal Property (BPP) tax assessment rolls for data center operators, FY2000–FY2024
  - Real property tax assessments for data center parcels (by GPIN), same period
  - Annual BPP tax levy summaries by property class
- **Key variables:** taxpayer name, GPIN (real property) or account number (BPP), assessed value, applicable rate, tax levy
- **Method:** FOIA required for individual records; aggregate annual data may be in budget documents
- **FOIA contact:** loudounfoia@loudoun.gov
- **Time:** 2–4 weeks
- **Notes:** BPP on data center servers/equipment is the larger revenue source and depreciates rapidly; assessments reset on acquisition. Known operators: Amazon Web Services, Microsoft, Google, Meta, Equinix, QTS, CyrusOne, Iron Mountain, NTT

### 4b. Loudoun County Annual Budget and ACFR
- **URL:** https://www.loudoun.gov/2264/Budget
- **What to extract:** Total real property tax revenue, BPP tax revenue, total general fund revenue, year-over-year data, any data-center-specific line items
- **Method:** Free public documents — download Annual Adopted Budget and Annual Comprehensive Financial Report (ACFR) for FY2000–FY2024
- **Time:** 1–2 days
- **Notes:** Budget narrative often explicitly discusses data center contributions; check Superintendent of Finance transmittal letters and capital program documents

### 4c. Virginia Department of Taxation — Local Tax Rates
- **URL:** https://www.tax.virginia.gov/local-tax-rates
- **What to extract:** Loudoun County real property rate and BPP rate by year
- **Method:** Free annual report download
- **Time:** 1 hour

---

## 5. Spatial / GIS Data

### 5a. Census Tract Boundaries (SE Clustering)
- **URL:** https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html
- **What to download:** Census tract TIGER/Line shapefiles for Loudoun County (FIPS 51107), decennial years 2000 and 2010 plus 2020
- **Method:** Free public download
- **Time:** 1 hour
- **Notes:** Assign census tract IDs to each property for standard error clustering; use year-appropriate boundaries

### 5b. Loudoun County Zoning Districts
- **URL:** https://gis.loudoun.gov
- **What to download:** Zoning district boundary shapefile; overlay zones
- **Method:** Free GIS download
- **Time:** 1 hour
- **Notes:** Identify which parcels are zoned PD-IP, PDC, or other data-center-permissible zones; useful for robustness checks (e.g., exclude residentially-zoned parcels abutting industrial zones)

---

## 6. Electricity / Rate Case Data (Costs Side)

### 6a. Virginia SCC Rate Case Dockets — Dominion Energy Virginia
- **URL:** https://www.scc.virginia.gov/caseSearch
- **Relevant dockets:**
  - PUE-2022-00142 (2022 biennial rate review)
  - PUE-2025-XXXXX (2025 biennial review — search for current docket)
  - Search: "Dominion Energy Virginia" + "transmission" or "data center" or "large load"
- **What to extract:** T&D capital expenditure schedule by project; load growth forecasts by customer class; Class Cost of Service study; revenue requirement by class; testimony on data center load growth and cost causation
- **Method:** Public docket; download all utility testimony and exhibits; SCC Staff testimony
- **Time:** 3–5 days

### 6b. Dominion Energy Virginia Integrated Resource Plan (IRP)
- **URL:** https://www.dominionenergy.com/our-company/making-energy/our-power-grid/our-energy-plan
- **What to extract:** Data center load projections (MW by year), T&D investment plans by project, county-level contracted load, 89 data-center-driven transmission projects listed in 2024 IRP
- **Method:** Annual public document; 2024 IRP is key
- **Time:** 1–2 days
- **Notes:** 2024 IRP explicitly attributes ~$22B in costs over 15 years to data center load growth; use for electricity incidence inputs

### 6c. JLARC (2024) — Data Centers in Virginia
- **URL:** https://jlarc.virginia.gov/pdfs/reports/Rpt598-2.pdf
- **What to extract:** Data center load figures (4,140 MW NoVA); tax revenue estimates; ratepayer impact discussion; electricity demand forecast
- **Method:** Free PDF download
- **Time:** 2–3 hours to read
- **Notes:** Comprehensive December 2024 legislative audit; cites that data centers generate $700M in local tax revenue to Loudoun (31% of budget); key academic-quality secondary source

### 6d. EIA Form 861 — Annual Electric Power Industry Report
- **URL:** https://www.eia.gov/electricity/data/eia861/
- **What to extract:** Dominion Virginia: residential customers, sales (kWh), revenue, by year 2000–2023
- **Key variables:** residential_cnt, residential_kwh, residential_rev (to compute $/kWh)
- **Method:** Free public Excel download (annual files)
- **Time:** 1–2 hours

---

## Summary Table

| Dataset | Priority | Method | Est. Time | Notes |
|---------|----------|--------|-----------|-------|
| NVRC data center inventory | **High** | Email NVRC | 1–3 days | Core treatment variable |
| Loudoun parcel GIS layer | **High** | Free download | 1 hr | Spatial merge base |
| Loudoun assessment rolls | **High** | Open data portal | 1 day | Property characteristics |
| Census tract boundaries | **High** | Free download | 1 hr | SE clustering |
| ZTRAX transactions | **High** | University license | 1–2 wks | Core outcome variable |
| Commissioner of Revenue (BPP) | **High** | FOIA | 2–4 wks | Benefits: BPP tax data |
| Annual Budget / ACFR | **High** | Free download | 1–2 days | Aggregate tax revenue |
| JLARC 2024 report | **High** | Free PDF | 2–3 hrs | Key secondary source |
| Loudoun permit / BOS records | **Medium** | Download + FOIA | 1–3 wks | Exact treatment dates |
| SCC rate case dockets | **Medium** | Public docket | 3–5 days | Electricity incidence inputs |
| Dominion IRP 2024 | **Medium** | Free download | 1–2 days | Load forecasts, capex |
| EIA Form 861 | **Medium** | Free download | 1–2 hrs | Customer count, $/kWh |
| Land records / deed data | **Medium** | Court records | 1–5 days | Alt. to ZTRAX |
| Zoning district boundaries | **Low** | Free GIS | 1 hr | Robustness checks |
| BOS meeting minutes | **Low** | Keyword search | 2–4 days | Announcement dates, context |

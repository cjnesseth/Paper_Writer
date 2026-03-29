"""
03b_electricity_rate_calc.py
Electricity rate incidence from data center T&D capex.
Updated with real EIA 861 and JLARC values (replaces R script placeholders).
"""

import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "explorations" / "data_collection" / "processed"

# === INPUTS (sourced from EIA 861 panel and JLARC 2024) ===

# --- Data center load (JLARC 2024, p.7) ---
dc_load_mw = 4140  # Northern Virginia operational capacity (MW)
# Note: Loudoun is ~50% of this, but T&D costs are shared across Dominion system

# --- T&D capex (JLARC 2024, p.iii; Dominion 2024 IRP) ---
# $22B over 15 years for data-center-driven infrastructure
# Covers ~10,000+ MW pipeline → ~$2.2M/MW
# Conservative: use only the $22B figure, not full $50.1B Dominion capex
total_dc_td_capex_B = 22.0  # $billion
capex_horizon_years = 15

# --- Cost of capital (SCC biennial review) ---
wacc = 0.075  # Dominion Energy Virginia weighted average cost of capital
asset_life_years = 40  # T&D asset depreciation life

# --- Dominion VA residential (EIA Form 861, 2023) ---
residential_customers = 2_357_519
residential_sales_mwh = 27_195_517
total_sales_mwh = 92_590_790  # includes commercial + industrial
residential_load_share = residential_sales_mwh / total_sales_mwh  # 0.294
avg_residential_kwh = (residential_sales_mwh * 1000) / residential_customers  # Not needed, MWh→kWh

# --- Loudoun specific ---
loudoun_residential_customers = 130_000
loudoun_dc_share = 0.50  # Loudoun = ~50% of NoVA DC capacity

print("=" * 65)
print("ELECTRICITY RATE INCIDENCE FROM DATA CENTER T&D CAPEX")
print("=" * 65)

print("\n--- INPUTS ---")
print(f"  DC load (NoVA):              {dc_load_mw:,} MW")
print(f"  Total DC-driven T&D capex:   ${total_dc_td_capex_B:.1f}B over {capex_horizon_years} years")
print(f"  Implied capex/MW:            ${total_dc_td_capex_B*1000/dc_load_mw:.1f}M/MW")
print(f"  WACC:                        {wacc:.1%}")
print(f"  Asset life:                  {asset_life_years} years")
print(f"  Residential customers:       {residential_customers:,} (EIA 861 2023)")
print(f"  Residential load share:      {residential_load_share:.1%} (EIA 861 2023)")
print(f"  Avg residential usage:       {residential_sales_mwh/residential_customers*1000:.0f} kWh/year")

# === CALCULATION ===

# Step 1: Capital recovery factor
crf = wacc / (1 - (1 + wacc) ** (-asset_life_years))
print(f"\n--- CALCULATION ---")
print(f"  Capital recovery factor:     {crf:.4f}")

# Step 2: Annual revenue requirement from DC T&D capex
annual_rev_req_M = (total_dc_td_capex_B * 1000) * crf
print(f"  Annual revenue requirement:  ${annual_rev_req_M:,.0f}M")

# Step 3: Residential share of annual cost
residential_annual_M = annual_rev_req_M * residential_load_share
print(f"  Residential allocation:      ${residential_annual_M:,.0f}M ({residential_load_share:.1%} of total)")

# Step 4: Per-customer impact
annual_per_customer = (residential_annual_M * 1_000_000) / residential_customers
monthly_per_customer = annual_per_customer / 12
rate_impact_per_kwh = annual_per_customer / (residential_sales_mwh / residential_customers * 1000)

print(f"\n--- SERVICE-AREA-WIDE IMPACT ---")
print(f"  Annual cost per household:   ${annual_per_customer:,.0f}")
print(f"  Monthly cost per household:  ${monthly_per_customer:,.0f}")
print(f"  Rate impact:                 {rate_impact_per_kwh*100:.2f} ¢/kWh")
print(f"  (on base of ~13.9 ¢/kWh → {rate_impact_per_kwh/0.139*100:.1f}% increase)")

# === JLARC VALIDATION ===
jlarc_low_monthly = 14
jlarc_high_monthly = 37
print(f"\n--- JLARC VALIDATION ---")
print(f"  JLARC estimate (by 2040):    ${jlarc_low_monthly}-${jlarc_high_monthly}/month")
print(f"  Our estimate (current):      ${monthly_per_customer:,.0f}/month")
print(f"  Note: JLARC includes generation + T&D; ours is T&D only.")
print(f"  Note: JLARC projects to 2040 with continued load growth;")
print(f"        ours uses current $22B capex commitment.")
if monthly_per_customer < jlarc_low_monthly:
    print(f"  → Our T&D-only estimate is below JLARC's low end, as expected")
    print(f"    (JLARC includes generation costs which roughly double the impact)")
elif monthly_per_customer <= jlarc_high_monthly:
    print(f"  → Our estimate is within the JLARC range")
else:
    print(f"  → Our estimate exceeds JLARC high end — check assumptions")

# === LOUDOUN-SPECIFIC BURDEN ===
# Loudoun residents bear both service-area-wide costs AND are
# disproportionately near the load driving T&D investment
print(f"\n--- LOUDOUN COUNTY PERSPECTIVE ---")
print(f"  Loudoun residential customers:  {loudoun_residential_customers:,}")
print(f"  Service-area cost (same):       ${annual_per_customer:,.0f}/year")
print(f"  Loudoun DC share of NoVA:       {loudoun_dc_share:.0%}")
# Note: all Dominion residential customers pay the same rate,
# so Loudoun residents pay the same per-customer amount as others.
# The distributional issue is that the costs are driven by DCs in Loudoun
# but shared across all 2.36M customers.
loudoun_total_cost = annual_per_customer * loudoun_residential_customers
dominion_total_cost = annual_per_customer * residential_customers
print(f"  Loudoun aggregate annual cost:  ${loudoun_total_cost/1e6:,.1f}M")
print(f"  Dominion-wide aggregate:        ${dominion_total_cost/1e6:,.1f}M")
print(f"  Loudoun share of cost burden:   {loudoun_total_cost/dominion_total_cost:.1%}")
print(f"  Loudoun share of DC capacity:   ~{loudoun_dc_share:.0%}")

# === SENSITIVITY ANALYSIS ===
print(f"\n--- SENSITIVITY ANALYSIS ---")
print(f"  Annual cost per household under different assumptions:")
print(f"  {'Capex ($B)':<14} {'Load Share':<14} {'$/yr/HH':<12} {'$/mo/HH'}")
print(f"  {'-'*52}")

sensitivity_results = []
for capex_B in [15, 22, 30, 40]:
    for load_share in [0.25, 0.294, 0.35]:
        annual_rr = (capex_B * 1000) * crf
        res_rr = annual_rr * load_share
        per_cust = (res_rr * 1_000_000) / residential_customers
        per_mo = per_cust / 12
        print(f"  ${capex_B:<13} {load_share:<14.1%} ${per_cust:>8,.0f}    ${per_mo:>6,.0f}")
        sensitivity_results.append({
            "capex_B": capex_B,
            "load_share": load_share,
            "annual_per_hh": round(per_cust),
            "monthly_per_hh": round(per_mo),
        })

# === NPV (for comparison with tax benefit) ===
print(f"\n--- 15-YEAR NPV ---")
discount = 0.03
npv_15 = sum(annual_per_customer / ((1 + discount) ** t) for t in range(15))
print(f"  NPV of electricity cost per HH (15yr, {discount:.0%}): ${npv_15:,.0f}")

# === SAVE ===
with open(OUT / "electricity_rate_results.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["variable", "value", "unit"])
    writer.writerow(["dc_load_mw", dc_load_mw, "MW"])
    writer.writerow(["total_dc_td_capex_B", total_dc_td_capex_B, "USD_billion"])
    writer.writerow(["crf", round(crf, 4), ""])
    writer.writerow(["annual_rev_req_M", round(annual_rev_req_M), "USD_million"])
    writer.writerow(["residential_load_share", round(residential_load_share, 3), "fraction"])
    writer.writerow(["annual_per_customer", round(annual_per_customer), "USD"])
    writer.writerow(["monthly_per_customer", round(monthly_per_customer), "USD"])
    writer.writerow(["rate_impact_cents_kwh", round(rate_impact_per_kwh * 100, 2), "cents"])
    writer.writerow(["npv_15yr_per_hh", round(npv_15), "USD"])

with open(OUT / "electricity_sensitivity.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["capex_B", "load_share", "annual_per_hh", "monthly_per_hh"])
    writer.writeheader()
    writer.writerows(sensitivity_results)

print(f"\nSaved: electricity_rate_results.csv, electricity_sensitivity.csv")

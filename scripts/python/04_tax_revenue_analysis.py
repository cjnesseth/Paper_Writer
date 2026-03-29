"""
04_tax_revenue_analysis.py
Tax revenue benefit analysis: DC revenue time series, per-household
tax savings from RE rate reductions, NPV comparison with electricity costs.
"""

import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "explorations" / "data_collection" / "processed"
OUT.mkdir(parents=True, exist_ok=True)


# === A. Data Center Tax Revenue Time Series ===
# Sources: Loudoun County budgets, JLARC 2024, NetChoice 2024
dc_revenue = [
    {"year": 2016, "dc_revenue_M": 146, "source": "Loudoun County 2024"},
    {"year": 2017, "dc_revenue_M": 200, "source": "interpolated"},
    {"year": 2018, "dc_revenue_M": 250, "source": "interpolated"},
    {"year": 2019, "dc_revenue_M": 290, "source": "interpolated"},
    {"year": 2020, "dc_revenue_M": 330, "source": "Loudoun County 2024"},
    {"year": 2021, "dc_revenue_M": 480, "source": "interpolated"},
    {"year": 2022, "dc_revenue_M": 663, "source": "Loudoun County 2024"},
    {"year": 2023, "dc_revenue_M": 733, "source": "JLARC 2024"},
    {"year": 2024, "dc_revenue_M": 870, "source": "interpolated"},
    {"year": 2025, "dc_revenue_M": 1000, "source": "Loudoun County 2024"},
    {"year": 2026, "dc_revenue_M": 1370, "source": "NetChoice/Loudoun proj."},
]

# === B. Residential Tax Rate Trajectory ===
# Source: Loudoun County adopted budgets; background_draft.md
# Rate per $100 of assessed value
re_rates = [
    {"year": 2012, "re_rate": 1.145},
    {"year": 2013, "re_rate": 1.135},
    {"year": 2014, "re_rate": 1.125},
    {"year": 2015, "re_rate": 1.110},
    {"year": 2016, "re_rate": 1.085},
    {"year": 2017, "re_rate": 1.045},
    {"year": 2018, "re_rate": 1.035},
    {"year": 2019, "re_rate": 0.980},
    {"year": 2020, "re_rate": 0.940},
    {"year": 2021, "re_rate": 0.890},
    {"year": 2022, "re_rate": 0.870},
    {"year": 2023, "re_rate": 0.865},
    {"year": 2024, "re_rate": 0.840},
    {"year": 2025, "re_rate": 0.805},
]

# === C. Parameters ===
MEDIAN_HOME_VALUE = 650_000  # 2024 approx; source: Zillow/Redfin Loudoun County
LOUDOUN_RESIDENTIAL_UNITS = 130_000  # approx; from Dominion/Census
DISCOUNT_RATE = 0.03  # real discount rate for NPV
COUNTERFACTUAL_RE_RATE = 1.145  # 2012 rate as proxy for no-DC counterfactual
# Alternative: compute what rate would need to be to replace DC revenue

print("=" * 60)
print("TAX REVENUE BENEFIT ANALYSIS")
print("Loudoun County Data Center Study")
print("=" * 60)

# === D. DC Revenue Time Series ===
print("\n--- D.1: Data Center Tax Revenue Time Series ---")
print(f"  {'Year':<6} {'DC Revenue ($M)':<18} {'Source'}")
print(f"  {'-'*50}")
for r in dc_revenue:
    print(f"  {r['year']:<6} ${r['dc_revenue_M']:>8,.0f}M        {r['source']}")

# === E. Per-Household Tax Savings ===
print(f"\n--- D.2: Per-Household Tax Savings from RE Rate Reduction ---")
print(f"  Median home value: ${MEDIAN_HOME_VALUE:,.0f}")
print(f"  Counterfactual RE rate (no DCs): ${COUNTERFACTUAL_RE_RATE:.3f} / $100")
print()
print(f"  {'Year':<6} {'Actual Rate':<13} {'Savings/yr':<12} {'Cumulative'}")
print(f"  {'-'*45}")

cumulative_savings = 0
annual_savings_list = []
for r in re_rates:
    rate_diff = COUNTERFACTUAL_RE_RATE - r["re_rate"]
    annual_savings = (MEDIAN_HOME_VALUE / 100) * rate_diff
    cumulative_savings += annual_savings
    annual_savings_list.append({
        "year": r["year"],
        "re_rate": r["re_rate"],
        "rate_diff": rate_diff,
        "annual_savings": annual_savings,
        "cumulative_savings": cumulative_savings,
    })
    print(f"  {r['year']:<6} ${r['re_rate']:.3f}/100    ${annual_savings:>8,.0f}    ${cumulative_savings:>10,.0f}")

# === F. NPV of Tax Benefit ===
print(f"\n--- D.3: NPV of Tax Benefit (2012-2025, {DISCOUNT_RATE:.0%} discount rate) ---")
npv_tax = 0
for i, s in enumerate(annual_savings_list):
    npv_tax += s["annual_savings"] / ((1 + DISCOUNT_RATE) ** i)

print(f"  NPV of cumulative RE tax savings per household: ${npv_tax:,.0f}")
print(f"  Undiscounted cumulative savings: ${cumulative_savings:,.0f}")

# Most recent year annual savings
latest = annual_savings_list[-1]
print(f"\n  Current (2025) annual savings per household: ${latest['annual_savings']:,.0f}")
print(f"  Rate reduction: ${COUNTERFACTUAL_RE_RATE:.3f} → ${latest['re_rate']:.3f} (${latest['rate_diff']:.3f} per $100)")

# === G. County-wide benefit ===
print(f"\n--- D.4: County-Wide Tax Benefit ---")
county_annual = latest["annual_savings"] * LOUDOUN_RESIDENTIAL_UNITS
print(f"  Residential units: {LOUDOUN_RESIDENTIAL_UNITS:,}")
print(f"  County-wide annual residential savings: ${county_annual:,.0f}")
print(f"  DC revenue (2025): ${dc_revenue[-2]['dc_revenue_M']:,.0f}M")

# === H. Comparison with Electricity Cost ===
# Load JLARC estimates
print(f"\n--- D.5: Benefit vs. Cost Comparison (per household per year) ---")
jlarc_elec_low = 14 * 12   # $14/month = $168/year
jlarc_elec_high = 37 * 12  # $37/month = $444/year

print(f"  TAX BENEFIT (annual, 2025):     ${latest['annual_savings']:>8,.0f}")
print(f"  ELECTRICITY COST (JLARC low):   ${jlarc_elec_low:>8,.0f}  ($14/mo by 2040)")
print(f"  ELECTRICITY COST (JLARC high):  ${jlarc_elec_high:>8,.0f}  ($37/mo by 2040)")
print()
net_low = latest["annual_savings"] - jlarc_elec_low
net_high = latest["annual_savings"] - jlarc_elec_high
print(f"  NET BENEFIT (low elec cost):    ${net_low:>8,.0f}")
print(f"  NET BENEFIT (high elec cost):   ${net_high:>8,.0f}")
print()
if net_low > 0 and net_high > 0:
    print("  → Tax benefits EXCEED electricity costs across the JLARC range")
elif net_low > 0 and net_high < 0:
    print("  → Tax benefits exceed low-end electricity costs but not high-end")
    print(f"    Breakeven monthly electricity increase: ${latest['annual_savings']/12:,.0f}/mo")
else:
    print("  → Electricity costs EXCEED tax benefits")

# === I. NPV Comparison (15-year horizon) ===
print(f"\n--- D.6: 15-Year NPV Comparison ---")
npv_tax_15 = sum(latest["annual_savings"] / ((1 + DISCOUNT_RATE) ** t) for t in range(15))
npv_elec_low_15 = sum(jlarc_elec_low / ((1 + DISCOUNT_RATE) ** t) for t in range(15))
npv_elec_high_15 = sum(jlarc_elec_high / ((1 + DISCOUNT_RATE) ** t) for t in range(15))

print(f"  NPV tax benefit (at 2025 rate):  ${npv_tax_15:>10,.0f}")
print(f"  NPV electricity cost (low):      ${npv_elec_low_15:>10,.0f}")
print(f"  NPV electricity cost (high):     ${npv_elec_high_15:>10,.0f}")
print(f"  NPV net benefit (low elec):      ${npv_tax_15 - npv_elec_low_15:>10,.0f}")
print(f"  NPV net benefit (high elec):     ${npv_tax_15 - npv_elec_high_15:>10,.0f}")

# === J. Save results ===
with open(OUT / "tax_revenue_timeseries.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["year", "dc_revenue_M", "source"])
    writer.writeheader()
    writer.writerows(dc_revenue)

with open(OUT / "tax_savings_per_household.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["year", "re_rate", "rate_diff",
                                           "annual_savings", "cumulative_savings"])
    writer.writeheader()
    writer.writerows(annual_savings_list)

summary = {
    "npv_tax_benefit_per_hh_2012_2025": round(npv_tax),
    "npv_tax_benefit_per_hh_15yr": round(npv_tax_15),
    "annual_tax_savings_2025": round(latest["annual_savings"]),
    "jlarc_elec_cost_low_annual": jlarc_elec_low,
    "jlarc_elec_cost_high_annual": jlarc_elec_high,
    "npv_elec_cost_low_15yr": round(npv_elec_low_15),
    "npv_elec_cost_high_15yr": round(npv_elec_high_15),
    "net_benefit_low_annual": round(net_low),
    "net_benefit_high_annual": round(net_high),
    "median_home_value": MEDIAN_HOME_VALUE,
    "counterfactual_re_rate": COUNTERFACTUAL_RE_RATE,
    "discount_rate": DISCOUNT_RATE,
}
with open(OUT / "benefit_cost_summary.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["variable", "value"])
    for k, v in summary.items():
        writer.writerow([k, v])

print(f"\nSaved: tax_revenue_timeseries.csv, tax_savings_per_household.csv, benefit_cost_summary.csv")

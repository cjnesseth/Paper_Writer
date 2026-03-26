"""
04_compile_master.py
Join all cleaned datasets into a single calibration master panel.

Inputs:
  Data/cleaned/vrr_params.csv        (from 01_parse_planning_params.py)
  Data/cleaned/bra_clearing.csv      (from 02_parse_bra_results.py)
  Data/cleaned/market_structure.csv  (from 03_parse_imm_hhi.py)

Output:
  Data/cleaned/calibration_master.csv

Panel: 7 delivery years × ~15 LDAs (unbalanced — DOM enters 2025/26)
"""

import sys
from pathlib import Path

import pandas as pd

CLEANED_DIR = Path("Data/cleaned")

# ---------------------------------------------------------------------------
# Load inputs
# ---------------------------------------------------------------------------

vrr = pd.read_csv(CLEANED_DIR / "vrr_params.csv")
bra = pd.read_csv(CLEANED_DIR / "bra_clearing.csv")
mkt = pd.read_csv(CLEANED_DIR / "market_structure.csv")

# ---------------------------------------------------------------------------
# BRA lead-time metadata
# (from data_inventory.md; 2021/22 date from Excel file metadata)
# ---------------------------------------------------------------------------

lead_time = pd.DataFrame({
    "delivery_year": [
        "2021/22", "2022/23", "2023/24", "2024/25",
        "2025/26", "2026/27", "2027/28", "2028/29",
    ],
    "bra_date_approx": pd.to_datetime([
        "2018-05-03",
        "2021-05-17",
        "2022-07-01",
        "2024-05-08",
        "2024-08-05",
        "2025-07-25",
        "2026-01-05",
        "2026-03-20",
    ]),
    "delivery_start": pd.to_datetime([
        "2021-06-01",
        "2022-06-01",
        "2023-06-01",
        "2024-06-01",
        "2025-06-01",
        "2026-06-01",
        "2027-06-01",
        "2028-06-01",
    ]),
})
lead_time["lead_time_months"] = (
    (lead_time["delivery_start"] - lead_time["bra_date_approx"])
    .dt.days / 30.44
).round(1)

# ---------------------------------------------------------------------------
# Join
# ---------------------------------------------------------------------------

master = (
    vrr
    .merge(
        bra[["delivery_year", "lda", "clearing_price", "mw_cleared"]],
        on=["delivery_year", "lda"],
        how="left",
    )
    .merge(
        mkt[["delivery_year", "lda", "rsi_1", "rsi_1_05", "n_participants", "n_pivotal"]],
        on=["delivery_year", "lda"],
        how="left",
    )
    .merge(
        lead_time[["delivery_year", "bra_date_approx", "lead_time_months"]],
        on="delivery_year",
        how="left",
    )
)

# ---------------------------------------------------------------------------
# Derived variables
# ---------------------------------------------------------------------------

# Markup ratio: clearing price relative to Net CONE
master["price_net_cone_ratio"] = master["clearing_price"] / master["net_cone"]

# VRR slope: (Pt(b) price – Pt(a) price) / (Pt(b) MW – Pt(a) MW)
# Negative value = downward-sloping demand in (MW, price) space
denom = master["vrr_pt_b_mw"] - master["vrr_pt_a_mw"]
master["vrr_slope"] = (
    (master["vrr_pt_b_price"] - master["vrr_pt_a_price"]) / denom
).where(denom.notna() & (denom != 0))

# Capacity margin: (MW cleared – reliability requirement) / reliability requirement
master["capacity_margin"] = (
    (master["mw_cleared"] - master["reliability_req_mw"]) / master["reliability_req_mw"]
).where(master["reliability_req_mw"].notna() & (master["reliability_req_mw"] > 0))

# Flag: auction cleared at or within $1 of VRR Point (a) cap
master["at_cap"] = (
    (master["clearing_price"] - master["vrr_pt_a_price"]).abs() < 1.0
).where(master["clearing_price"].notna() & master["vrr_pt_a_price"].notna())

# ---------------------------------------------------------------------------
# Column ordering
# ---------------------------------------------------------------------------

col_order = [
    "delivery_year", "lda", "vrr_design",
    "bra_date_approx", "lead_time_months",
    # VRR parameters
    "net_cone", "cetl_mw", "reliability_req_mw",
    "vrr_pt_a_price", "vrr_pt_b_price", "vrr_pt_c_price", "vrr_pt_d_price",
    "vrr_pt_a_mw",    "vrr_pt_b_mw",    "vrr_pt_c_mw",    "vrr_pt_d_mw",
    "vrr_slope",
    # Auction outcomes
    "clearing_price", "mw_cleared",
    "price_net_cone_ratio", "capacity_margin", "at_cap",
    # Market structure (RSI/TPS from IMM Section 5)
    "rsi_1", "rsi_1_05", "n_participants", "n_pivotal",
]
# Keep only columns that exist (some may be missing if upstream scripts failed)
col_order = [c for c in col_order if c in master.columns]
master = master[col_order].sort_values(["delivery_year", "lda"]).reset_index(drop=True)

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

print("\n=== Calibration Master Summary ===")
print(f"Rows: {len(master)}")
print(f"Delivery years: {', '.join(master['delivery_year'].unique())}")
print(f"LDAs: {', '.join(sorted(master['lda'].unique()))}")

print("\nRTO panel (key variables):")
rto = master[master["lda"] == "RTO"][[
    "delivery_year", "vrr_design", "net_cone",
    "clearing_price", "price_net_cone_ratio", "lead_time_months", "at_cap"
]]
print(rto.to_string(index=False))

n_miss_price = master["clearing_price"].isna().sum()
n_miss_rsi   = master["rsi_1"].isna().sum() if "rsi_1" in master.columns else len(master)
if n_miss_price:
    print(f"\nWARNING: {n_miss_price} rows missing clearing_price", file=sys.stderr)
if n_miss_rsi:
    print(f"NOTE: {n_miss_rsi} rows missing RSI (expected if PDF parsing incomplete)")

# ---------------------------------------------------------------------------
# Write
# ---------------------------------------------------------------------------

out = CLEANED_DIR / "calibration_master.csv"
master.to_csv(out, index=False)
print(f"\nWrote {len(master)} rows to {out}")

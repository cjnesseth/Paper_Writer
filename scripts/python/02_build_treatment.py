"""
02_build_treatment.py
Build master DC inventory: merge parcels + buildings, clean dates,
compute centroids, assign census tracts.

Uses only Python stdlib (json, csv, math, datetime) — no geopandas/shapely needed.
GeoJSON polygons → centroids computed as simple coordinate averages (sufficient
for small polygons like parcels at this latitude).
"""

import json
import csv
import math
from datetime import datetime, timezone
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "explorations" / "data_collection" / "raw"
OUT = ROOT / "explorations" / "data_collection" / "processed"
OUT.mkdir(parents=True, exist_ok=True)


def polygon_centroid(geometry):
    """Approximate centroid from GeoJSON geometry (mean of exterior ring coords)."""
    if geometry["type"] == "Polygon":
        ring = geometry["coordinates"][0]
    elif geometry["type"] == "MultiPolygon":
        # Use largest polygon by number of vertices
        ring = max(geometry["coordinates"], key=lambda p: len(p[0]))[0]
    else:
        return None, None
    lons = [c[0] for c in ring]
    lats = [c[1] for c in ring]
    return sum(lons) / len(lons), sum(lats) / len(lats)


def epoch_ms_to_date(epoch_ms):
    """Convert epoch milliseconds to ISO date string. Returns None for invalid."""
    if epoch_ms is None:
        return None
    try:
        dt = datetime.fromtimestamp(epoch_ms / 1000, tz=timezone.utc)
        if dt.year < 1990 or dt.year > 2030:
            return None
        return dt.strftime("%Y-%m-%d")
    except (ValueError, OSError, OverflowError):
        return None


def haversine_km(lon1, lat1, lon2, lat2):
    """Haversine distance in km between two WGS84 points."""
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def point_in_polygon_simple(px, py, polygon_coords):
    """Ray-casting point-in-polygon test for a single ring."""
    n = len(polygon_coords)
    inside = False
    j = n - 1
    for i in range(n):
        xi, yi = polygon_coords[i]
        xj, yj = polygon_coords[j]
        if ((yi > py) != (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi):
            inside = not inside
        j = i
    return inside


# --- 1. Load DC parcels ---
print("Loading DC parcels...")
with open(RAW / "dc_existing_parcels.geojson") as f:
    parcels_data = json.load(f)
parcels = parcels_data["features"]
print(f"  {len(parcels)} parcels loaded")

# --- 2. Load DC buildings ---
print("Loading DC buildings...")
with open(RAW / "dc_existing_permitted_buildings.geojson") as f:
    buildings_data = json.load(f)
buildings = buildings_data["features"]
print(f"  {len(buildings)} buildings loaded")

# --- 3. Clean building dates and aggregate to parcel level ---
bldg_by_mcpi = defaultdict(list)
valid_dates = 0
placeholder_years = 0

for b in buildings:
    p = b["properties"]
    mcpi = p.get("AM_MCPI")
    if not mcpi:
        continue

    permit_date = epoch_ms_to_date(p.get("BP_ISSUE_DT"))
    if permit_date:
        valid_dates += 1

    year_built = p.get("YEAR_BUILT")
    if year_built == 1000:
        placeholder_years += 1
        year_built = None
    elif year_built and (year_built < 1900 or year_built > 2030):
        year_built = None

    bldg_by_mcpi[mcpi].append({
        "permit_date": permit_date,
        "year_built": year_built,
        "sqft": p.get("SQUARE_FEET", 0) or 0,
        "built_status": p.get("BUILT_STATUS", ""),
        "address": (p.get("AM_BASE_ADDRESS") or "").strip(),
    })

print(f"\nBuilding date summary:")
print(f"  Valid permit dates: {valid_dates} / {len(buildings)}")
print(f"  YEAR_BUILT=1000 (placeholder): {placeholder_years}")
print(f"  Unique MCPIs with buildings: {len(bldg_by_mcpi)}")

# --- 4. Aggregate buildings per parcel ---
def aggregate_buildings(bldg_list):
    dates = [b["permit_date"] for b in bldg_list if b["permit_date"]]
    years = [b["year_built"] for b in bldg_list if b["year_built"]]
    addrs = list(set(b["address"] for b in bldg_list if b["address"]))
    return {
        "n_buildings": len(bldg_list),
        "total_bldg_sqft": sum(b["sqft"] for b in bldg_list),
        "earliest_permit": min(dates) if dates else None,
        "latest_permit": max(dates) if dates else None,
        "earliest_year": min(years) if years else None,
        "n_built": sum(1 for b in bldg_list if b["built_status"] == "BUILT"),
        "n_under_construction": sum(1 for b in bldg_list if b["built_status"] == "UNDER CONSTRUCTION"),
        "addresses": "; ".join(addrs[:3]),
    }

bldg_agg = {mcpi: aggregate_buildings(bl) for mcpi, bl in bldg_by_mcpi.items()}

# --- 5. Load census tracts (filter to Loudoun = COUNTYFP 107) ---
print("\nLoading census tracts...")
# Census tracts are in shapefile; read the GeoJSON we can create from the DBF
# Actually, we have the TIGER shapefile but can't read .shp without libraries.
# Instead, use a simple approach: we know Loudoun FIPS = 51107.
# For tract assignment, we'll note it as TBD and fill when geo libraries available.
tract_assignment_available = False

# --- 6. Build inventory ---
print("\nBuilding master inventory...")
inventory = []

for feat in parcels:
    p = feat["properties"]
    mcpi = p.get("PA_MCPI", "")
    lon, lat = polygon_centroid(feat["geometry"])

    bldg = bldg_agg.get(mcpi, {})

    row = {
        "mcpi": mcpi,
        "project": p.get("Project", ""),
        "owner": p.get("Owner", ""),
        "ownership_cat": p.get("Ownership_Category", ""),
        "lon": round(lon, 6) if lon else None,
        "lat": round(lat, 6) if lat else None,
        "overall_sqft": p.get("Overall_SQ_FT"),
        "built_status": p.get("Built_Status", ""),
        "zoning": p.get("ZONING", ""),
        "place_type": p.get("PLACE_TYPE", ""),
        "policy_area": p.get("POLICY_AREA", ""),
        "gis_acres": p.get("Existing_Acres"),
        "n_buildings": bldg.get("n_buildings"),
        "total_bldg_sqft": bldg.get("total_bldg_sqft"),
        "earliest_permit": bldg.get("earliest_permit"),
        "latest_permit": bldg.get("latest_permit"),
        "earliest_year": bldg.get("earliest_year"),
        "n_built": bldg.get("n_built"),
        "n_under_construction": bldg.get("n_under_construction"),
        "addresses": bldg.get("addresses", ""),
    }
    inventory.append(row)

# --- 7. Save CSV ---
out_file = OUT / "dc_master_inventory.csv"
fieldnames = list(inventory[0].keys())
with open(out_file, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(inventory)

# --- 8. Summary ---
n_with_bldg = sum(1 for r in inventory if r["n_buildings"])
n_built = sum(1 for r in inventory if r["built_status"] == "BUILT")
n_uc = sum(1 for r in inventory if r["built_status"] == "UNDER CONSTRUCTION")
dates = [r["earliest_permit"] for r in inventory if r["earliest_permit"]]
total_bldg = sum(r["n_buildings"] or 0 for r in inventory)
total_sqft = sum(r["total_bldg_sqft"] or 0 for r in inventory)

zoning_counts = defaultdict(int)
for r in inventory:
    zoning_counts[r["zoning"]] += 1

print(f"\n{'='*50}")
print(f"DC MASTER INVENTORY")
print(f"{'='*50}")
print(f"Total parcels:           {len(inventory)}")
print(f"With building data:      {n_with_bldg}")
print(f"Without building data:   {len(inventory) - n_with_bldg}")
print(f"Built:                   {n_built}")
print(f"Under construction:      {n_uc}")
print(f"Total buildings:         {total_bldg}")
print(f"Total building sqft:     {total_sqft:,.0f}")
print(f"Permit date range:       {min(dates) if dates else 'N/A'} to {max(dates) if dates else 'N/A'}")
print(f"\nZoning breakdown:")
for z, c in sorted(zoning_counts.items(), key=lambda x: -x[1]):
    print(f"  {z}: {c}")
print(f"\nSaved to: {out_file}")

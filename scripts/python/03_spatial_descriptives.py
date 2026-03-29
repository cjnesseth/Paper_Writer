"""
03_spatial_descriptives.py
Spatial descriptive analysis: classify residential parcels by zoning,
compute nearest-DC distances, produce summary statistics.

Note: Without matplotlib/geopandas, this outputs CSV summaries and
a GeoJSON for visualization in QGIS or online tools.
"""

import json
import csv
import math
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "explorations" / "data_collection" / "raw"
OUT = ROOT / "explorations" / "data_collection" / "processed"


def polygon_centroid(geometry):
    """Approximate centroid from GeoJSON polygon."""
    if geometry["type"] == "Polygon":
        ring = geometry["coordinates"][0]
    elif geometry["type"] == "MultiPolygon":
        ring = max(geometry["coordinates"], key=lambda p: len(p[0]))[0]
    else:
        return None, None
    lons = [c[0] for c in ring]
    lats = [c[1] for c in ring]
    return sum(lons) / len(lons), sum(lats) / len(lats)


def haversine_km(lon1, lat1, lon2, lat2):
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


# --- 1. Load DC inventory (centroids) ---
print("Loading DC inventory...")
dc_locs = []
with open(OUT / "dc_master_inventory.csv") as f:
    for row in csv.DictReader(f):
        if row["lon"] and row["lat"] and row["built_status"] == "BUILT":
            dc_locs.append({
                "mcpi": row["mcpi"],
                "lon": float(row["lon"]),
                "lat": float(row["lat"]),
                "project": row["project"],
                "earliest_permit": row["earliest_permit"],
            })
print(f"  {len(dc_locs)} built DC locations")

# --- 2. Load zoning layer ---
print("Loading zoning layer...")
with open(RAW / "loudoun_zoning_official.geojson") as f:
    zoning_data = json.load(f)

# Classify zone types
RESIDENTIAL_ZONES = {
    "A3", "A10", "AR1", "AR2",  # Agricultural/Rural residential
    "R1", "R1A", "R2", "R3", "RH",  # Residential
    "PDH3", "PDH4", "PDH6",  # Planned Development Housing
    "PDAAAR",  # PD Agricultural/Rural
    "CR1", "CR2", "CR3", "CR4",  # Compact Residential
    "JLMA1", "JLMA2", "JLMA3", "JLMA20",  # Joint Land Management Area
    "PDCH",  # PD Compact Housing
    "MRHI",  # Mixed Residential High Intensity
}
INDUSTRIAL_ZONES = {"IP", "GI", "PDIP", "PDGI", "CLI"}

zone_features = zoning_data["features"]
print(f"  {len(zone_features)} zoning polygons")

# Count zones
zone_counts = defaultdict(int)
for feat in zone_features:
    z = feat["properties"].get("ZO_ZONE", "")
    zone_counts[z] += 1

# Classify zones
res_zones = {z for z in zone_counts if z in RESIDENTIAL_ZONES}
ind_zones = {z for z in zone_counts if z in INDUSTRIAL_ZONES}
print(f"  Residential zone types: {len(res_zones)} ({sum(zone_counts[z] for z in res_zones)} polygons)")
print(f"  Industrial zone types: {len(ind_zones)} ({sum(zone_counts[z] for z in ind_zones)} polygons)")

# Build spatial index: for each zoning polygon, store centroid + zone type
# (Full point-in-polygon on 132K parcels x 1263 zones is too slow without spatial index)
# Instead, we'll classify the 132K parcels using the by-right DC parcels as industrial proxy

# --- 3. Compute distances from DC parcels to all other DC parcels ---
# (This characterizes DC clustering)
print("\nComputing DC clustering distances...")
dc_distances = []
for i, d1 in enumerate(dc_locs):
    for j, d2 in enumerate(dc_locs):
        if i < j:
            dist = haversine_km(d1["lon"], d1["lat"], d2["lon"], d2["lat"])
            dc_distances.append(dist)

dc_distances.sort()
n_dc = len(dc_locs)
print(f"  {n_dc} built DCs")
print(f"  Median inter-DC distance: {dc_distances[len(dc_distances)//2]:.2f} km")
print(f"  Mean inter-DC distance: {sum(dc_distances)/len(dc_distances):.2f} km")
print(f"  Min inter-DC distance: {dc_distances[0]:.3f} km")
print(f"  Max inter-DC distance: {dc_distances[-1]:.2f} km")

# --- 4. Load by-right DC parcels to identify industrial-zoned areas ---
print("\nLoading by-right DC parcels (industrial proxy)...")
with open(RAW / "dc_byright_parcels.geojson") as f:
    byright_data = json.load(f)
byright_feats = byright_data["features"]
print(f"  {len(byright_feats)} by-right DC parcels")

# Get industrial parcel centroids
industrial_centroids = []
for feat in byright_feats:
    geom = feat.get("geometry")
    if geom is None:
        continue
    lon, lat = polygon_centroid(geom)
    if lon and lat:
        industrial_centroids.append((lon, lat))

# --- 5. Estimate residential exposure using full county parcels ---
# We can't read .shp without libraries, but we have the 14K parcel GeoJSON
# Actually, the 14K was from a different endpoint. Let's use a different approach:
# compute distance from each DC to the county's residential bounding box grid

# Instead: characterize the DC footprint relative to the county
# Use known facts: Loudoun has ~130K residential customers
# DC parcels are concentrated in eastern Loudoun (Data Center Alley)

# Compute bounding box of all DCs
dc_lons = [d["lon"] for d in dc_locs]
dc_lats = [d["lat"] for d in dc_locs]
print(f"\nDC geographic footprint:")
print(f"  Longitude range: {min(dc_lons):.4f} to {max(dc_lons):.4f}")
print(f"  Latitude range:  {min(dc_lats):.4f} to {max(dc_lats):.4f}")
print(f"  E-W span: {haversine_km(min(dc_lons), sum(dc_lats)/len(dc_lats), max(dc_lons), sum(dc_lats)/len(dc_lats)):.1f} km")
print(f"  N-S span: {haversine_km(sum(dc_lons)/len(dc_lons), min(dc_lats), sum(dc_lons)/len(dc_lons), max(dc_lats)):.1f} km")

# --- 6. DC permit timeline analysis ---
print("\nDC permit timeline:")
permits_by_year = defaultdict(int)
sqft_by_year = defaultdict(int)

with open(OUT / "dc_master_inventory.csv") as f:
    for row in csv.DictReader(f):
        ep = row.get("earliest_permit", "")
        if ep and ep != "":
            year = int(ep[:4])
            permits_by_year[year] += 1
            sqft = int(float(row.get("total_bldg_sqft") or 0))
            sqft_by_year[year] += sqft

print(f"  {'Year':<6} {'Parcels':<10} {'Bldg SqFt':<15}")
print(f"  {'-'*31}")
cumulative_parcels = 0
cumulative_sqft = 0
for year in sorted(permits_by_year.keys()):
    cumulative_parcels += permits_by_year[year]
    cumulative_sqft += sqft_by_year[year]
    print(f"  {year:<6} {permits_by_year[year]:<10} {sqft_by_year[year]:>12,}")
print(f"  {'-'*31}")
print(f"  {'Total':<6} {cumulative_parcels:<10} {cumulative_sqft:>12,}")

# --- 7. Distance ring analysis ---
# For each DC, compute distance to nearest other DC (clustering measure)
print("\n\nNearest-neighbor distances between DCs:")
nn_dists = []
for i, d1 in enumerate(dc_locs):
    min_dist = float("inf")
    for j, d2 in enumerate(dc_locs):
        if i != j:
            dist = haversine_km(d1["lon"], d1["lat"], d2["lon"], d2["lat"])
            if dist < min_dist:
                min_dist = dist
    nn_dists.append(min_dist)

nn_dists.sort()
print(f"  Min nearest-neighbor: {nn_dists[0]:.3f} km")
print(f"  Median nearest-neighbor: {nn_dists[len(nn_dists)//2]:.3f} km")
print(f"  Mean nearest-neighbor: {sum(nn_dists)/len(nn_dists):.3f} km")
print(f"  Max nearest-neighbor: {nn_dists[-1]:.3f} km")
print(f"  DCs within 0.5 km of another DC: {sum(1 for d in nn_dists if d < 0.5)}")
print(f"  DCs within 1.0 km of another DC: {sum(1 for d in nn_dists if d < 1.0)}")
print(f"  DCs within 2.0 km of another DC: {sum(1 for d in nn_dists if d < 2.0)}")

# --- 8. Save DC centroids as GeoJSON for mapping ---
dc_geojson = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": {"type": "Point", "coordinates": [d["lon"], d["lat"]]},
            "properties": {
                "mcpi": d["mcpi"],
                "project": d["project"],
                "earliest_permit": d["earliest_permit"],
            }
        }
        for d in dc_locs
    ]
}
with open(OUT / "dc_centroids.geojson", "w") as f:
    json.dump(dc_geojson, f)

# --- 9. Save timeline data ---
with open(OUT / "dc_permit_timeline.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["year", "n_parcels", "total_bldg_sqft", "cumulative_parcels", "cumulative_sqft"])
    cum_p, cum_s = 0, 0
    for year in sorted(permits_by_year.keys()):
        cum_p += permits_by_year[year]
        cum_s += sqft_by_year[year]
        writer.writerow([year, permits_by_year[year], sqft_by_year[year], cum_p, cum_s])

print(f"\nSaved dc_centroids.geojson and dc_permit_timeline.csv to {OUT}")

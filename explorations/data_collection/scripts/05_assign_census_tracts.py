"""
Assign census tracts to property transactions via point-in-polygon.
Reads tract shapefile (TIGER/Line 2020) and panel CSV.
Pure stdlib — no external dependencies.
"""
import struct
import csv
import os
import math

BASE = os.path.join(os.path.dirname(__file__), "..")
RAW_DIR = os.path.join(BASE, "raw")
PROC_DIR = os.path.join(BASE, "processed")
TRACT_DIR = os.path.join(RAW_DIR, "census_tracts_va")


# ── Inverse Lambert Conformal Conic (VA State Plane North) ──────────────

def inverse_lcc(x_ft, y_ft):
    """Convert VA State Plane North (NAD83 HARN, US ft) to WGS84."""
    a = 6378137.0
    f = 1.0 / 298.257222101
    e = math.sqrt(2 * f - f * f)
    lat0 = math.radians(37.0 + 40.0 / 60)
    lon0 = math.radians(-78.5)
    sp1 = math.radians(38.0 + 2.0 / 60)
    sp2 = math.radians(39.0 + 12.0 / 60)
    FE, FN = 11482916.667, 6561666.667
    ft_to_m = 0.3048006096012192
    x = (x_ft - FE) * ft_to_m
    y = (y_ft - FN) * ft_to_m

    def m_func(lat):
        return math.cos(lat) / math.sqrt(1 - e * e * math.sin(lat) ** 2)

    def t_func(lat):
        es = e * math.sin(lat)
        return math.tan(math.pi / 4 - lat / 2) / ((1 - es) / (1 + es)) ** (e / 2)

    m1, m2 = m_func(sp1), m_func(sp2)
    t0, t1, t2 = t_func(lat0), t_func(sp1), t_func(sp2)
    n = (math.log(m1) - math.log(m2)) / (math.log(t1) - math.log(t2))
    F = m1 / (n * t1 ** n)
    rho0 = a * F * t0 ** n
    rho = math.copysign(math.sqrt(x * x + (rho0 - y) ** 2), n)
    theta = math.atan2(x, rho0 - y)
    t = (rho / (a * F)) ** (1.0 / n)
    lon = theta / n + lon0
    lat = math.pi / 2 - 2 * math.atan(t)
    for _ in range(10):
        es = e * math.sin(lat)
        lat_new = math.pi / 2 - 2 * math.atan(t * ((1 - es) / (1 + es)) ** (e / 2))
        if abs(lat_new - lat) < 1e-12:
            break
        lat = lat_new
    return math.degrees(lat), math.degrees(lon)


# ── Shapefile readers ───────────────────────────────────────────────────

def read_dbf(dbf_path, columns):
    """Read specified columns from a DBF file."""
    with open(dbf_path, "rb") as f:
        f.read(4)
        num_records = struct.unpack("<I", f.read(4))[0]
        header_size = struct.unpack("<H", f.read(2))[0]
        record_size = struct.unpack("<H", f.read(2))[0]
        f.read(20)

        fields = []
        while True:
            fd = f.read(32)
            if fd[0:1] == b"\r":
                break
            name = fd[:11].split(b"\x00")[0].decode("ascii")
            fsize = fd[16]
            fields.append((name, fsize))

        # Build offset map for requested columns
        col_map = {}
        offset = 1
        for name, fsize in fields:
            if name in columns:
                col_map[name] = (offset, fsize)
            offset += fsize

        f.seek(header_size)
        results = {c: [] for c in columns}
        for _ in range(num_records):
            record = f.read(record_size)
            for col in columns:
                off, sz = col_map[col]
                val = record[off:off + sz].decode("ascii", errors="replace").strip()
                results[col].append(val)

    return results, num_records


def read_shp_polygons(shp_path, need_convert=False):
    """Read polygon rings from a shapefile. Returns list of lists of (lon, lat) tuples."""
    polygons = []
    with open(shp_path, "rb") as f:
        file_code = struct.unpack(">I", f.read(4))[0]
        f.read(20)
        file_length = struct.unpack(">I", f.read(4))[0] * 2
        f.read(4)  # version
        shape_type = struct.unpack("<I", f.read(4))[0]
        f.read(64)  # file bbox

        while f.tell() < file_length:
            try:
                struct.unpack(">I", f.read(4))  # rec_num
                content_len = struct.unpack(">I", f.read(4))[0] * 2
            except struct.error:
                break
            start = f.tell()
            rec_type = struct.unpack("<I", f.read(4))[0]

            if rec_type == 0:
                polygons.append([])
            elif rec_type in (5, 15, 25):
                f.read(32)  # bbox
                num_parts = struct.unpack("<I", f.read(4))[0]
                num_points = struct.unpack("<I", f.read(4))[0]
                parts = [struct.unpack("<I", f.read(4))[0] for _ in range(num_parts)]
                points = []
                for _ in range(num_points):
                    x, y = struct.unpack("<2d", f.read(16))
                    if need_convert:
                        lat, lon = inverse_lcc(x, y)
                        points.append((lon, lat))
                    else:
                        points.append((x, y))

                rings = []
                for j in range(num_parts):
                    start_idx = parts[j]
                    end_idx = parts[j + 1] if j + 1 < num_parts else num_points
                    rings.append(points[start_idx:end_idx])
                polygons.append(rings)
            else:
                polygons.append([])
            f.seek(start + content_len)

    return polygons


# ── Point-in-polygon (ray casting) ─────────────────────────────────────

def point_in_ring(px, py, ring):
    """Ray-casting algorithm for point-in-polygon."""
    n = len(ring)
    inside = False
    j = n - 1
    for i in range(n):
        xi, yi = ring[i]
        xj, yj = ring[j]
        if ((yi > py) != (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi):
            inside = not inside
        j = i
    return inside


def point_in_polygon(px, py, rings):
    """Check if point is in polygon (first ring = exterior, rest = holes)."""
    if not rings:
        return False
    if not point_in_ring(px, py, rings[0]):
        return False
    for hole in rings[1:]:
        if point_in_ring(px, py, hole):
            return False
    return True


# ── Main ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # 1. Read tract shapefile
    prj_path = os.path.join(TRACT_DIR, "tl_2020_51_tract.prj")
    with open(prj_path) as f:
        prj = f.read()
    need_convert = "StatePlane" in prj or "Lambert" in prj
    print(f"Tract CRS needs conversion: {need_convert}")
    # TIGER/Line uses NAD83 (geographic coords, degrees) — no conversion needed
    need_convert = False

    print("Reading tract attributes...")
    attrs, n_tracts = read_dbf(
        os.path.join(TRACT_DIR, "tl_2020_51_tract.dbf"),
        ["STATEFP", "COUNTYFP", "TRACTCE", "GEOID"]
    )

    print("Reading tract polygons...")
    polygons = read_shp_polygons(
        os.path.join(TRACT_DIR, "tl_2020_51_tract.shp"),
        need_convert=need_convert
    )
    print(f"  {n_tracts} tracts, {len(polygons)} polygons")

    # Filter to Loudoun County (FIPS 107)
    loudoun_indices = [i for i in range(n_tracts) if attrs["COUNTYFP"][i] == "107"]
    print(f"  {len(loudoun_indices)} Loudoun County tracts")

    # Build bounding boxes for quick filtering
    tract_data = []
    for idx in loudoun_indices:
        rings = polygons[idx]
        if not rings:
            continue
        all_x = [p[0] for ring in rings for p in ring]
        all_y = [p[1] for ring in rings for p in ring]
        bbox = (min(all_x), min(all_y), max(all_x), max(all_y))
        tract_data.append({
            "tractce": attrs["TRACTCE"][idx],
            "geoid": attrs["GEOID"][idx],
            "rings": rings,
            "bbox": bbox
        })

    # 2. Read panel
    print("\nReading transaction panel...")
    panel_path = os.path.join(PROC_DIR, "property_transactions_panel.csv")
    with open(panel_path) as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    print(f"  {len(rows)} transactions")

    # 3. Assign tracts
    print("Assigning census tracts...")
    assigned = 0
    for row in rows:
        lon = float(row["lon"]) if row["lon"] else None
        lat = float(row["lat"]) if row["lat"] else None
        row["census_tract"] = ""
        row["census_geoid"] = ""

        if lon is None or lat is None:
            continue

        for td in tract_data:
            bx = td["bbox"]
            if lon < bx[0] or lon > bx[2] or lat < bx[1] or lat > bx[3]:
                continue
            if point_in_polygon(lon, lat, td["rings"]):
                row["census_tract"] = td["tractce"]
                row["census_geoid"] = td["geoid"]
                assigned += 1
                break

    print(f"  Assigned: {assigned} / {len(rows)} ({100*assigned/len(rows):.1f}%)")
    print(f"  Unique tracts: {len(set(r['census_tract'] for r in rows if r['census_tract']))}")

    # 4. Write updated panel
    out_path = panel_path  # overwrite
    fieldnames = list(rows[0].keys())
    with open(out_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"\nSaved to {out_path}")

"""
Extract parcel centroids from Loudoun County shapefile.
Reads .shp (geometry) and .dbf (attributes) directly using struct.
Converts from VA State Plane North (NAD83 HARN, US ft) to WGS84 lat/lon.
No external dependencies required (pure stdlib).
"""
import struct
import csv
import os
import math

RAW_DIR = os.path.join(os.path.dirname(__file__), "..", "raw", "loudoun_parcels_shp")
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "processed")

def read_dbf_column(dbf_path, col_name):
    """Read a single column from a DBF file."""
    with open(dbf_path, "rb") as f:
        version = struct.unpack("B", f.read(1))[0]
        f.read(3)  # date
        num_records = struct.unpack("<I", f.read(4))[0]
        header_size = struct.unpack("<H", f.read(2))[0]
        record_size = struct.unpack("<H", f.read(2))[0]
        f.read(20)  # reserved

        # Read field descriptors
        fields = []
        while True:
            field_data = f.read(32)
            if field_data[0:1] == b"\r":
                break
            name = field_data[:11].split(b"\x00")[0].decode("ascii")
            ftype = chr(field_data[11])
            fsize = field_data[16]
            fields.append((name, ftype, fsize))

        # Find target column
        target_idx = None
        offset_before = 1  # deletion flag byte
        target_size = 0
        for i, (name, ftype, fsize) in enumerate(fields):
            if name == col_name:
                target_idx = i
                target_size = fsize
                break
            offset_before += fsize

        if target_idx is None:
            raise ValueError(f"Column {col_name} not found. Available: {[f[0] for f in fields]}")

        # Read records
        f.seek(header_size)
        values = []
        for _ in range(num_records):
            record = f.read(record_size)
            val = record[offset_before:offset_before + target_size].decode("ascii", errors="replace").strip()
            values.append(val)

    return values


def read_shp_centroids(shp_path):
    """Read polygon bounding box centroids from a .shp file."""
    centroids = []
    with open(shp_path, "rb") as f:
        # File header (100 bytes)
        file_code = struct.unpack(">I", f.read(4))[0]
        assert file_code == 9994, f"Not a shapefile: {file_code}"
        f.read(20)  # unused
        file_length = struct.unpack(">I", f.read(4))[0] * 2  # in bytes
        version = struct.unpack("<I", f.read(4))[0]
        shape_type = struct.unpack("<I", f.read(4))[0]
        # Bounding box
        f.read(64)  # skip file-level bbox

        # Read records
        while f.tell() < file_length:
            try:
                rec_num = struct.unpack(">I", f.read(4))[0]
                content_len = struct.unpack(">I", f.read(4))[0] * 2
            except struct.error:
                break

            start_pos = f.tell()
            rec_shape_type = struct.unpack("<I", f.read(4))[0]

            if rec_shape_type == 0:
                # Null shape
                centroids.append((None, None))
            elif rec_shape_type in (5, 15, 25):
                # Polygon, PolygonZ, PolygonM
                # Bounding box: xmin, ymin, xmax, ymax
                bbox = struct.unpack("<4d", f.read(32))
                xmin, ymin, xmax, ymax = bbox
                cx = (xmin + xmax) / 2
                cy = (ymin + ymax) / 2
                centroids.append((cx, cy))
            else:
                centroids.append((None, None))

            # Skip to next record
            f.seek(start_pos + content_len)

    return centroids


def inverse_lcc(x_ft, y_ft):
    """Convert VA State Plane North (NAD83 HARN, US ft) to WGS84 lat/lon."""
    a = 6378137.0
    f = 1.0 / 298.257222101
    e = math.sqrt(2 * f - f * f)

    lat0 = math.radians(37.0 + 40.0 / 60)
    lon0 = math.radians(-78.5)
    sp1 = math.radians(38.0 + 2.0 / 60)
    sp2 = math.radians(39.0 + 12.0 / 60)
    FE = 11482916.667
    FN = 6561666.667
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


if __name__ == "__main__":
    dbf_path = os.path.join(RAW_DIR, "Loudoun_Parcels.dbf")
    shp_path = os.path.join(RAW_DIR, "Loudoun_Parcels.shp")

    print(f"Reading PA_MCPI from {dbf_path}...")
    mcpi_values = read_dbf_column(dbf_path, "PA_MCPI")
    print(f"  {len(mcpi_values)} records")

    print(f"Reading centroids from {shp_path}...")
    centroids = read_shp_centroids(shp_path)
    print(f"  {len(centroids)} shapes")

    assert len(mcpi_values) == len(centroids), \
        f"Record count mismatch: {len(mcpi_values)} vs {len(centroids)}"

    # Convert to WGS84 and write CSV
    out_path = os.path.join(OUT_DIR, "parcel_centroids.csv")
    n_valid = 0
    n_converted = 0
    with open(out_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["parid", "lon", "lat"])
        for mcpi, (cx, cy) in zip(mcpi_values, centroids):
            if mcpi and mcpi.strip() and cx is not None:
                lat_wgs, lon_wgs = inverse_lcc(cx, cy)
                # Sanity check: Loudoun County bounds
                if 38.8 < lat_wgs < 39.35 and -77.8 < lon_wgs < -77.2:
                    writer.writerow([mcpi.strip(), f"{lon_wgs:.8f}", f"{lat_wgs:.8f}"])
                    n_valid += 1
                else:
                    n_converted += 1  # converted but outside bounds

    print(f"\nSaved {n_valid} parcel centroids to {out_path}")
    print(f"Skipped {len(mcpi_values) - n_valid} ({len(mcpi_values) - n_valid - n_converted} missing ID/geom, {n_converted} outside county bounds)")

    # Quick validation
    import random
    with open(out_path) as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    samples = random.sample(rows, min(5, len(rows)))
    print("\nSample records:")
    for r in samples:
        print(f"  {r['parid']}: ({r['lon']}, {r['lat']})")

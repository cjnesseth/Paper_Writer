#!/usr/bin/env bash
# =============================================================================
# 02_download_county_data.sh
# Download Loudoun County property sales, assessment, and tax data
# =============================================================================
set -euo pipefail

RAW_DIR="$(cd "$(dirname "$0")/../raw" && pwd)"
echo "Downloading to: $RAW_DIR"

# --- Real Property Sales Reports (XLSX) ---
echo ""
echo "=== Real Property Sales Reports ==="
declare -A SALES_IDS=(
    [2020]=162688
    [2021]=164604
    [2022]=168667
    [2023]=177682
    [2024]=190095
    [2025]=212992
)

for year in "${!SALES_IDS[@]}"; do
    id="${SALES_IDS[$year]}"
    outfile="$RAW_DIR/sales_${year}.xlsx"
    if [ -f "$outfile" ]; then
        echo "  [skip] sales_${year}.xlsx already exists"
    else
        echo "  [download] sales_${year}.xlsx (DocumentCenter/View/${id})"
        curl -sL "https://www.loudoun.gov/DocumentCenter/View/${id}" -o "$outfile"
        echo "    -> $(du -h "$outfile" | cut -f1)"
    fi
done

# --- 2026 Assessment & Dwelling Data (XLSX) ---
echo ""
echo "=== 2026 Assessment & Dwelling Data ==="
declare -A ASSESS_IDS=(
    [assessed_values_2026]=212731
    [residential_dwelling_2026]=212734
    [commercial_dwelling_2026]=212732
    [owner_legal_address_2026]=212733
)

for name in "${!ASSESS_IDS[@]}"; do
    id="${ASSESS_IDS[$name]}"
    outfile="$RAW_DIR/${name}.xlsx"
    if [ -f "$outfile" ]; then
        echo "  [skip] ${name}.xlsx already exists"
    else
        echo "  [download] ${name}.xlsx (DocumentCenter/View/${id})"
        curl -sL "https://www.loudoun.gov/DocumentCenter/View/${id}" -o "$outfile"
        echo "    -> $(du -h "$outfile" | cut -f1)"
    fi
done

# --- Treasurer Bulk CSV ---
echo ""
echo "=== Treasurer Real Estate Data ==="
TREAS_CSV="OutstandingRealEstate_022026_includesDelinquentAmts_GoodThru_06052026.CSV"
TREAS_LAYOUT="LAYOUT_REAL_ESTATE_PAYMENTS_PUBLIC_SHARE_022026.xlsx"
TREAS_BASE="https://interwapp22.loudoun.gov/TreasurerPublicFiles/public"

if [ -f "$RAW_DIR/treasurer_real_estate.csv" ]; then
    echo "  [skip] treasurer_real_estate.csv already exists"
else
    echo "  [download] treasurer_real_estate.csv"
    curl -sL "${TREAS_BASE}/${TREAS_CSV}" -o "$RAW_DIR/treasurer_real_estate.csv"
    echo "    -> $(du -h "$RAW_DIR/treasurer_real_estate.csv" | cut -f1)"
fi

if [ -f "$RAW_DIR/treasurer_layout.xlsx" ]; then
    echo "  [skip] treasurer_layout.xlsx already exists"
else
    echo "  [download] treasurer_layout.xlsx"
    curl -sL "${TREAS_BASE}/${TREAS_LAYOUT}" -o "$RAW_DIR/treasurer_layout.xlsx"
    echo "    -> $(du -h "$RAW_DIR/treasurer_layout.xlsx" | cut -f1)"
fi

echo ""
echo "=== Download Complete ==="
echo "Files in $RAW_DIR:"
ls -lh "$RAW_DIR"/sales_*.xlsx "$RAW_DIR"/assessed_*.xlsx "$RAW_DIR"/residential_*.xlsx \
       "$RAW_DIR"/commercial_*.xlsx "$RAW_DIR"/owner_*.xlsx \
       "$RAW_DIR"/treasurer_*.csv "$RAW_DIR"/treasurer_*.xlsx 2>/dev/null || true

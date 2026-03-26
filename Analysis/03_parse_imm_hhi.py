"""
03_parse_imm_hhi.py
Extract RSI (Residual Supply Index) and pivotal-supplier counts from the
PJM IMM State of the Market reports (Vol 2, Section 5 Capacity Market).

The IMM capacity section reports the Three Pivotal Supplier (TPS) / RSI test
results by LDA — not HHI.  This script extracts those tables.

Input:  Data/raw/imm_reports/*.pdf   (pdfplumber)
Output: Data/cleaned/market_structure.csv
        Data/cleaned/imm_parse_diagnostics.txt

Columns extracted per BRA per LDA:
  rsi_1          RSI at 3-supplier threshold (1.0)
  rsi_1_05       RSI at 3-supplier threshold (1.05)
  n_participants Total market participants
  n_pivotal      Failed-RSI participants (= pivotal suppliers)

Report-to-BRA mapping:
  2020 SotM Vol 2 → 2021/22 BRA
  2021 SotM Vol 2 → 2022/23 BRA
  2022 SotM Vol 2 → 2023/24 BRA (and retrospective 2022/23)
  2023 SotM Vol 2 → no BRA held (gap year); RSI for active delivery years
  2024 SotM Vol 2 → 2024/25 BRA + 2025/26 BRA
  2025 SotM Vol 2 → 2026/27 BRA + 2027/28 BRA

NOTE: PDF parsing is inherently fragile.  Always compare output against
the printed report before using numbers in the paper.
"""

import re
import sys
from pathlib import Path

import pdfplumber
import pandas as pd

RAW_DIR     = Path("Data/raw/imm_reports")
CLEANED_DIR = Path("Data/cleaned")
CLEANED_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# File manifest
# ---------------------------------------------------------------------------

FILE_MAP = [
    (2020, "2020-som-pjm-vol2.pdf"),
    (2021, "2021-som-pjm-vol2.pdf"),
    (2022, "2022-som-pjm-vol2.pdf"),
    (2023, "2023-som-pjm-vol2.pdf"),
    (2024, "2024-som-pjm-vol2.pdf"),
    (2025, "2025-som-pjm-vol2.pdf"),
]

# BRA years that we want to pull out of each report
TARGET_BRAS = {
    2020: ["2021/22"],
    2021: ["2022/23"],
    2022: ["2022/23", "2023/24"],
    2023: ["2023/24", "2024/25"],   # gap year — BRAs from prior/next
    2024: ["2024/25", "2025/26"],
    2025: ["2026/27", "2027/28"],
}

# Regex to match BRA headings in the RSI table
# e.g. "2022/2023 Base Residual Auction" or "2022/2023 RPM Base Residual Auction"
BRA_HEADING_RE = re.compile(
    r"(\d{4})/(\d{4})\s+(?:RPM\s+)?Base\s+Residual\s+Auction",
    re.IGNORECASE,
)

# Normalize "2022/2023" → "2022/23"
def norm_year(y1, y2):
    return f"{y1}/{y2[-2:]}"

# Regex for an RSI data row:
# LDA_NAME  rsi_1  rsi_1.05  total_participants  failed_participants
# e.g.  "RTO 0.81 0.73 130 130"
LDA_TOKEN = (
    r"(?:RTO|MAAC|SWMAAC|EMAAC|PSEG(?:\s+North)?|PS(?:\s+North)?|"
    r"DPL(?:\s+South)?|ATSI(?:-CLEVELAND|-Cleveland)?|DEOK|AEP|DAY(?:TON)?|"
    r"APS|EKPC|DOM|BGE|ComEd|COMED|JCPL|PL)"
)
RSI_ROW_RE = re.compile(
    rf"^({LDA_TOKEN})\s+"           # LDA name
    r"(-?\d+\.\d+)\s+"             # RSI_1
    r"(-?\d+\.\d+)\s+"             # RSI_1.05
    r"(\d+)\s+"                     # total participants
    r"(\d+)\s*$",                   # failed (pivotal) participants
    re.IGNORECASE,
)

# ---------------------------------------------------------------------------
# Find Section 5 (Capacity Market) pages
# ---------------------------------------------------------------------------

def find_section5_pages(pdf):
    """Return list of page indices whose header says 'Section 5 Capacity'."""
    pages = []
    for i, page in enumerate(pdf.pages):
        text = page.extract_text() or ""
        first_line = text.strip().split("\n")[0] if text.strip() else ""
        if re.search(r"(?i)section\s+5\s+capacity", first_line):
            pages.append(i)
    return pages


# ---------------------------------------------------------------------------
# Parse RSI table from text
# ---------------------------------------------------------------------------

def parse_rsi_table(text_lines):
    """
    Parse the RSI results table from a list of text lines.
    Returns list of dicts: {delivery_year, lda, rsi_1, rsi_1_05,
                            n_participants, n_pivotal}
    Only collects Base Residual Auction rows (not Incremental Auctions).
    """
    records = []
    current_bra  = None
    in_bra_block = False

    for line in text_lines:
        line = line.strip()
        if not line:
            continue

        # Check for BRA heading
        m_bra = BRA_HEADING_RE.search(line)
        if m_bra:
            current_bra  = norm_year(m_bra.group(1), m_bra.group(2))
            in_bra_block = True
            continue

        # Check for Incremental Auction heading — stop collecting for this BRA
        if re.search(r"(?i)Incremental\s+Auction", line) and current_bra:
            in_bra_block = False
            continue

        # Collect RSI data rows while in a BRA block
        if in_bra_block and current_bra:
            m = RSI_ROW_RE.match(line)
            if m:
                records.append({
                    "delivery_year":  current_bra,
                    "lda":            m.group(1).strip(),
                    "rsi_1":          float(m.group(2)),
                    "rsi_1_05":       float(m.group(3)),
                    "n_participants": int(m.group(4)),
                    "n_pivotal":      int(m.group(5)),
                })

    return records


# ---------------------------------------------------------------------------
# Parse one report
# ---------------------------------------------------------------------------

def parse_report(cal_year, filename):
    path = RAW_DIR / filename
    if not path.exists():
        print(f"  MISSING: {path}", file=sys.stderr)
        return [], f"=== {filename} ===\nFILE NOT FOUND"

    diag = [f"=== {filename} (calendar year {cal_year}) ==="]

    try:
        pdf = pdfplumber.open(path)
    except Exception as e:
        msg = f"ERROR opening PDF: {e}"
        print(f"  {msg}", file=sys.stderr)
        return [], "\n".join(diag + [msg])

    diag.append(f"Total pages: {len(pdf.pages)}")

    sec5_pages = find_section5_pages(pdf)
    diag.append(f"Section 5 page indices: {sec5_pages[:5]}{'...' if len(sec5_pages) > 5 else ''}")

    if not sec5_pages:
        msg = "WARNING: No Section 5 pages found"
        print(f"  {msg}", file=sys.stderr)
        pdf.close()
        return [], "\n".join(diag + [msg])

    # Extract text from all Section 5 pages
    all_lines = []
    for pg_idx in sec5_pages:
        text = pdf.pages[pg_idx].extract_text() or ""
        all_lines.extend(text.split("\n"))

    pdf.close()

    diag.append(f"Section 5 total lines: {len(all_lines)}")
    # Show first 10 non-empty lines
    diag.append("--- First 10 non-empty Section 5 lines ---")
    shown = 0
    for line in all_lines:
        if line.strip():
            diag.append(f"  {line.strip()}")
            shown += 1
            if shown >= 10:
                break

    records = parse_rsi_table(all_lines)
    diag.append(f"RSI rows extracted: {len(records)}")

    # Filter to target BRAs for this report year
    targets = TARGET_BRAS.get(cal_year, [])
    records = [r for r in records if r["delivery_year"] in targets]
    diag.append(f"Rows after filtering to target BRAs {targets}: {len(records)}")

    for r in records:
        r["calendar_year"] = cal_year

    return records, "\n".join(diag)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

all_records = []
all_diag    = []

for cal_year, filename in FILE_MAP:
    print(f"Parsing {cal_year} SotM …")
    records, diag = parse_report(cal_year, filename)
    all_records.extend(records)
    all_diag.append(diag)
    print(f"  → {len(records)} rows")

df = pd.DataFrame(all_records) if all_records else pd.DataFrame(
    columns=["delivery_year", "calendar_year", "lda",
             "rsi_1", "rsi_1_05", "n_participants", "n_pivotal"]
)

if df.empty:
    print("\nWARNING: market_structure.csv is empty — PDF parsing needs manual review",
          file=sys.stderr)
else:
    print(f"\nExtracted {len(df)} rows across "
          f"{df['delivery_year'].nunique()} delivery years")
    print(df[["delivery_year", "lda", "rsi_1", "n_pivotal"]].to_string(index=False))

out = CLEANED_DIR / "market_structure.csv"
df.to_csv(out, index=False)
print(f"\nWrote {len(df)} rows to {out}")

diag_out = CLEANED_DIR / "imm_parse_diagnostics.txt"
diag_out.write_text("\n\n".join(all_diag))
print(f"Diagnostics written to {diag_out}")
print("\nIMPORTANT: Compare output against IMM reports before using in paper.")

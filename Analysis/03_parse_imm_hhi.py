"""
03_parse_imm_hhi.py  (v2 — pdfplumber, page-targeted)
Extract RSI (Residual Supply Index) results from PJM IMM State of the Market
reports (Vol 2, Section 5 Capacity Market).

The IMM reports the Three Pivotal Supplier (TPS) / RSI test by LDA, not HHI.

Input:  Data/raw/imm_reports/*.pdf
Output: Data/cleaned/market_structure.csv
        Data/cleaned/imm_parse_diagnostics.txt

Columns per BRA per LDA:
  rsi_1          Residual Supply Index for 1 supplier (threshold 1.05)
  rsi_3          Residual Supply Index for 3 suppliers
  n_participants Total market participants in the relevant market
  n_pivotal      Participants who failed the RSI_3 test (= pivotal)

Strategy:
  Scan each PDF for the page containing both "RSI results" and a BRA heading
  with actual numeric data rows.  Grab that page + the next one (in case the
  table spans), then parse line by line.  The two-column PDF layout means some
  rows have trailing text from the adjacent column — the regex captures the
  first 5 tokens and ignores the rest.

Report-to-BRA mapping used here (non-overlapping):
  2022 SotM Vol 2 → 2022/23 BRA  (Table 5-9, page 336)
  2025 SotM Vol 2 → 2023/24 through 2027/28 BRAs  (Table 5-11, page 346)
  All others: skipped (no target BRAs assigned)

NOTE: Compare output against IMM reports before using numbers in the paper.
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
# Which BRA delivery years to pull from each report year (non-overlapping)
# ---------------------------------------------------------------------------

TARGET_BRAS = {
    2020: [],
    2021: [],
    2022: ["2021/22", "2022/23"],
    2023: [],
    2024: [],
    2025: ["2023/24", "2024/25", "2025/26", "2026/27", "2027/28"],
}

FILE_MAP = [
    (2020, "2020-som-pjm-vol2.pdf"),
    (2021, "2021-som-pjm-vol2.pdf"),
    (2022, "2022-som-pjm-vol2.pdf"),
    (2023, "2023-som-pjm-vol2.pdf"),
    (2024, "2024-som-pjm-vol2.pdf"),
    (2025, "2025-som-pjm-vol2.pdf"),
]

# ---------------------------------------------------------------------------
# Patterns
# ---------------------------------------------------------------------------

BRA_HEADING_RE = re.compile(
    r"(\d{4})/(\d{4})\s+(?:RPM\s+)?Base\s+Residual\s+Auction",
    re.IGNORECASE,
)

IA_HEADING_RE = re.compile(
    r"(?:First|Second|Third|Incremental)\s+(?:Incremental\s+)?Auction",
    re.IGNORECASE,
)

# LDA names as they appear in the RSI table (covers all years in the panel)
LDA_TOKEN = (
    r"(?:RTO|MAAC|SWMAAC|EMAAC|PSEG(?:\s+North)?|PS(?:\s+North)?|"
    r"DPL(?:\s+South)?|ATSI(?:-CLEVELAND|-Cleveland)?|DEOK|AEP|DAY(?:TON)?|"
    r"APS|EKPC|DOM(?:inion)?|BGE|ComEd|COMED|JCPL|PL)"
)

# Capture the 5 data tokens; do NOT anchor to end-of-line because the 2022 SOM
# two-column layout leaves trailing text from the adjacent column on some rows.
RSI_ROW_RE = re.compile(
    rf"^({LDA_TOKEN})\s+"   # LDA name
    r"(-?\d+\.\d+)\s+"      # rsi_1
    r"(-?\d+\.\d+)\s+"      # rsi_3
    r"(\d+)\s+"              # total participants
    r"(\d+)",                # failed (pivotal) participants
    re.IGNORECASE,
)


def norm_year(y1, y2):
    """'2022', '2023' → '2022/23'"""
    return f"{y1}/{y2[-2:]}"


# ---------------------------------------------------------------------------
# Page finder
# ---------------------------------------------------------------------------

def find_rsi_table_page(pdf):
    """
    Scan all pages for the one containing the BRA RSI results table.
    Returns (page_index, combined_text) where combined_text is that page
    plus the following page (in case the table spans a page break).
    Returns (None, '') if not found.
    """
    for i, page in enumerate(pdf.pages):
        text = page.extract_text() or ""
        # Must contain the table title AND at least one numeric data row
        if (re.search(r"RSI results", text, re.IGNORECASE)
                and re.search(r"Base Residual Auction", text, re.IGNORECASE)
                and re.search(r"\d+\.\d+\s+\d+\.\d+\s+\d+\s+\d+", text)):
            next_text = ""
            if i + 1 < len(pdf.pages):
                next_text = pdf.pages[i + 1].extract_text() or ""
            return i, text + "\n" + next_text
    return None, ""


# ---------------------------------------------------------------------------
# RSI table parser
# ---------------------------------------------------------------------------

def parse_rsi_table(text_lines):
    """
    Walk the RSI table line by line.
    Collects rows only within Base Residual Auction blocks;
    stops collecting when an Incremental Auction heading is encountered.
    Returns list of dicts.
    """
    records     = []
    current_bra = None
    in_bra      = False

    for line in text_lines:
        line = line.strip()
        if not line:
            continue

        # BRA heading → start collecting
        m = BRA_HEADING_RE.search(line)
        if m:
            current_bra = norm_year(m.group(1), m.group(2))
            in_bra      = True
            continue

        # Incremental Auction heading → stop collecting for current BRA
        if IA_HEADING_RE.search(line) and current_bra:
            in_bra = False
            continue

        if in_bra and current_bra:
            m = RSI_ROW_RE.match(line)
            if m:
                records.append({
                    "delivery_year":  current_bra,
                    "lda":            m.group(1).strip(),
                    "rsi_1":          float(m.group(2)),
                    "rsi_3":          float(m.group(3)),
                    "n_participants": int(m.group(4)),
                    "n_pivotal":      int(m.group(5)),
                })

    return records


# ---------------------------------------------------------------------------
# Parse one report
# ---------------------------------------------------------------------------

def parse_report(cal_year, filename):
    targets = TARGET_BRAS.get(cal_year, [])
    diag    = [f"=== {filename} (calendar year {cal_year}) ==="]

    if not targets:
        diag.append("SKIPPED — no target BRAs assigned")
        return [], "\n".join(diag)

    path = RAW_DIR / filename
    if not path.exists():
        diag.append("FILE NOT FOUND")
        return [], "\n".join(diag)

    try:
        with pdfplumber.open(path) as pdf:
            diag.append(f"Total pages: {len(pdf.pages)}")

            pg_idx, combined = find_rsi_table_page(pdf)

            if pg_idx is None:
                diag.append("WARNING: RSI table page not found — verify manually")
                return [], "\n".join(diag)

            diag.append(f"RSI table found on page {pg_idx + 1}")

            records = parse_rsi_table(combined.split("\n"))
            diag.append(f"RSI rows parsed (all BRAs): {len(records)}")

            records = [r for r in records if r["delivery_year"] in targets]
            diag.append(f"Rows after filtering to {targets}: {len(records)}")

            for r in records:
                r["calendar_year"] = cal_year

            if records:
                diag.append("Extracted rows:")
                for r in records:
                    diag.append(
                        f"  {r['delivery_year']:8s}  {r['lda']:15s}"
                        f"  rsi_1={r['rsi_1']:.2f}  rsi_3={r['rsi_3']:.2f}"
                        f"  n={r['n_participants']}  pivotal={r['n_pivotal']}"
                    )

    except Exception as e:
        diag.append(f"ERROR: {e}")
        import traceback
        diag.append(traceback.format_exc())
        return [], "\n".join(diag)

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
             "rsi_1", "rsi_3", "n_participants", "n_pivotal"]
)

if df.empty:
    print("\nWARNING: market_structure.csv is empty — check diagnostics",
          file=sys.stderr)
else:
    df = df.sort_values(["delivery_year", "lda"]).reset_index(drop=True)
    print(f"\nExtracted {len(df)} rows across "
          f"{df['delivery_year'].nunique()} delivery years")
    print(df[["delivery_year", "lda", "rsi_1", "rsi_3", "n_pivotal"]].to_string(index=False))

out = CLEANED_DIR / "market_structure.csv"
df.to_csv(out, index=False)
print(f"\nWrote {len(df)} rows to {out}")

diag_out = CLEANED_DIR / "imm_parse_diagnostics.txt"
diag_out.write_text("\n\n".join(all_diag))
print(f"Diagnostics: {diag_out}")
print("\nIMPORTANT: Spot-check output against the printed IMM reports before use.")

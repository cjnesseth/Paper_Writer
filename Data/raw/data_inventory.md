# Data Inventory — IO Paper 2: Calibrated SFE Simulation of Market Power in PJM RPM
**Created:** 2026-03-24

---

## File Alignment Table

The **planning parameters date** is when PJM published the parameters; the BRA was held shortly after.
The **IMM annual report** is the calendar-year volume that covers the BRA analysis.

| Delivery Year | Params Date | BRA Held (approx) | Lead Time | RTO Clear ($/MW-d) | MW Cleared (RTO) | IMM Report | Planning Params File | BRA Results File |
|---|---|---|---|---|---|---|---|---|
| 2022/23 | 2021-05-17 | May 2021 | ~13 mo | $50.00 | 144,477 | 2021 SotM Vol 2 | 2022-2023-planning-period-parameters... | 2022-2023-base-residual-auction-results.xlsx |
| 2023/24 | 2022-06-21 | Jul 2022 | ~12 mo | $34.13 | 144,871 | 2022 SotM Vol 2 | 2023-2024-planning-period-parameters... | 2023-2024-base-residual-auction-results.xlsx |
| 2024/25 | 2024-05-08 | May 2024 | **~1 mo** | $28.92 | 147,477 | 2024 SotM Vol 2 | 2024-2025-rpm-bra-planning-parameters.xlsx | 2024-2025-base-residual-auction-results.xlsx |
| 2025/26 | 2024-08-05 | Aug 2024 | ~10 mo | $269.92 | 135,684 | 2024 SotM Vol 2 | 2025-2026-planning-period-parameters... | 2025-2026-base-residual-auction-results.xlsx |
| 2026/27 | 2025-07-25 | Jul 2025 | ~11 mo | $329.17 | 134,205 | 2025 SotM Vol 2 | 2026-2027-planning-period-parameters... | 2026-2027-bra-results.xlsx |
| 2027/28 | 2026-01-05 | Jan 2026 | ~17 mo | $333.44 | 134,478 | 2025 SotM Vol 2 | 2027-2028-planning-period-parameters... | 2027-2028-bra-results.xlsx |
| 2028/29 | 2026-03-20 | Mar 2026 | ~27 mo | — (incomplete) | — | Not yet covered | 2028-2029-planning-period-parameters... | — |

---

## IMM Report Coverage

| Report | Pages | Published | BRAs Covered | Notes |
|---|---|---|---|---|
| 2021-som-pjm-vol2.pdf | 732 | 2022-03-10 | 2022/23 BRA (May 2021) | |
| 2022-som-pjm-vol2.pdf | 798 | 2023-03-09 | 2023/24 BRA (Jul 2022) | |
| 2023-som-pjm-vol2.pdf | 816 | 2024-03-14 | **None** | Gap year — no BRA held in 2023; still has concentration/HHI data for active delivery years |
| 2024-som-pjm-vol2.pdf | 818 | 2025-03-13 | 2024/25 BRA (May 2024) + 2025/26 BRA (Aug 2024) | Two BRAs in one calendar year |
| 2025-som-pjm-vol2.pdf | 892 | 2026-03-12 | 2026/27 BRA (Jul 2025) + 2027/28 BRA (Jan 2026) | Two BRAs; 2027/28 barely made publication cutoff |

---

## Key Structural Features (flag in paper)

### 1. VRR Curve Redesign (FERC ER25-1357)
- **Old design (2022/23–2025/26):** 3-point piecewise-linear curve; floor = $0/MW-day
- **New design (2026/27 onward):** 4-point curve; explicit price floor ~$177–179/MW-day; cap = $256.75/MW-day (ICAP)
- The 2026/27 and 2027/28 auctions both cleared at exactly the VRR Point (a) price = the cap
- **Use as:** natural experiment for VRR slope comparative static (Section 5C)

### 2. Auction Lead Time Disruption
- PJM's BRA schedule was severely disrupted; lead times range from ~1 month to ~27 months across the panel
- 2024/25 BRA was held ~1 month before delivery (effectively a spot auction — catch-up from missed auction backlog)
- No auction held in calendar year 2023
- **Acknowledge in:** Institutional Background section; flag as limitation for forward-price interpretation

### 3. Panel for Calibration
- **Clean pairs (planning params + BRA results):** 6 delivery years (2022/23–2027/28)
- **Incomplete:** 2028/29 (VRR anchor prices missing)
- **Recommended calibration years:** pick 2–3 spanning both VRR designs and the price spike; e.g., 2023/24 (low price, old VRR), 2025/26 (price spike, old VRR), 2026/27 (at-cap, new VRR)

---

## Net CONE and VRR Point (a) by Delivery Year

| Delivery Year | Net CONE RTO ($/MW-d) | VRR Point (a) Price RTO ($/MW-d) | VRR Design | RTO Clearing Price |
|---|---|---|---|---|
| 2022/23 | $260.50 | $390.75 | Old (floor=$0) | $50.00 |
| 2023/24 | $274.96 | $412.44 | Old (floor=$0) | $34.13 |
| 2024/25 | $293.19 | $439.79 | Old (floor=$0) | $28.92 |
| 2025/26 | $228.81 | $451.61 | Old (floor=$0) | $269.92 |
| 2026/27 | $212.14 | $329.17 | **New (floor=$177)** | $329.17 ← at cap |
| 2027/28 | $242.52 | $333.44 | **New (floor=$179)** | $333.44 ← at cap |
| 2028/29 | — | — (incomplete) | New | — |

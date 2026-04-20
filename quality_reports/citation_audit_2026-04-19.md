# Citation Source-Fidelity Audit

**Date:** 2026-04-19
**Paper:** Calibrated SFE Simulation of Market Power in PJM Capacity Auctions
**Branch:** PJM-Paper
**Plan:** `/home/chris/.claude/plans/iridescent-snacking-firefly.md`

---

## Scope

- **59 citation instances** across 25 bib keys in 9 paper files, audited against local source PDFs where available.
- **44 PDF-verified** instances (14 keys with academic / official PDFs)
- **15 metadata-only** instances (11 keys without local PDFs — lighter plausibility check)
- **13 parallel agent runs** — 12 domain-reviewer agents (one per PDF) + 1 general-purpose metadata agent.

---

## Executive Summary

| Verdict | Count | Share |
|---|---|---|
| CORRECT | 13 | 22% |
| CORRECT_WITH_CAVEAT | 20 | 34% |
| OVERREACH | 10 | 17% |
| MISATTRIBUTED | 2 | 3% |
| WRONG_PAPER / partial | 1 | 2% |
| METADATA_ONLY_OK | 11 | 19% |
| METADATA_ONLY_DOUBT | 4 | 7% |
| WRONG_PAPER (outright) | 0 | 0% |
| **Total** | **59** | **100%** |

**Bottom line**: ~56% of citations are materially correct (CORRECT or CWC). ~22% have substantive problems needing action (OVERREACH / MISATTRIBUTED / WRONG_PAPER). The remaining 22% are unverified-but-plausible (METADATA).

**Three issues rise to CRITICAL severity** (affect calibration or core claims):

1. **`MonitoringAnalytics2025_sotm` at `calibration.tex:125`** — the cited "Table 7-38, $149.32/MW-day combined-cycle ACR" **does not exist** in the Q3 2025 SoM PDF (Section 7 tables stop at ~7-21); the calibration parameter $c = \$150$ cannot be verified from the available source. Bib entry also misdescribes the document (says "Annual Report, 2026" — actual file is Q3 2025 Quarterly, copyright 2025).
2. **`MonitoringAnalytics2025_sotm` at `calibration.tex:129`** — claim that "IMM identifies the combined-cycle ACR as the relevant benchmark" contradicts the Q3 2025 SoM, which explicitly recommends (p. 324, adopted 2025) that a **CT** (not CC) be the reference resource. OVERREACH that inverts the source.
3. **`PJM2025_settlement_slides` at `sec7_leadtime.tex:31`** — specific lead-time figures (0.8 / 10.2 / 16.8 months) are not in the slide deck. MISATTRIBUTED.

Plus one **serious bibliographic issue** to resolve regardless of paper edits:

- `MonitoringAnalytics2025_sotm` bib entry year should be **2025** (not 2026), `howpublished` should be **"Quarterly SoM Report"** (not "Annual Report") to match the file in `supporting_papers/`. If the author actually drew the $150/MW-day figure from the Annual SoM Volume 2 (a distinct document), that document needs its own bib entry and needs to be added to `supporting_papers/`.

**Also resolved**: pre-existing flag about `Joskow2007_capacity` — false alarm. The PDF filename suggests 2008 but the content is Joskow & Tirole (2007) RAND. No bib fix needed.

---

## Priority Issues (sorted by severity)

### CRITICAL — action required before submission

| # | Location | Key | Issue | Suggested action |
|---|---|---|---|---|
| C1 | `calibration.tex:125` | MonitoringAnalytics2025_sotm | Cited Table 7-38 & \$149.32 figure not in Q3 2025 SoM PDF. Calibration of $c = \$150$/MW-day cannot be verified from this source. | Identify the actual source of the \$149.32 figure (likely the 2024 Annual SoM Volume 2 or a BRA analysis report); add that document to bib and `supporting_papers/`; update the cite and the \citep page hint. |
| C2 | `calibration.tex:129` | MonitoringAnalytics2025_sotm | IMM recommends CT (not CC) as reference resource (p. 324, adopted 2025). Claim that "IMM identifies the combined-cycle ACR as the relevant benchmark" inverts the source. | Rephrase: keep combined-cycle as the paper's chosen proxy on independent grounds (e.g., CC's share of cleared capacity or CC's role in energy merit order), and acknowledge explicitly that the IMM's formal recommendation is CT. Move the CC-centrality claim off the IMM citation. |
| C3 | `sec7_leadtime.tex:31` | PJM2025_settlement_slides | Lead-time figures (0.8 / 10.2 / 16.8 months) are not in the slide deck; author's arithmetic from the RPM auction schedule. | Remove `\citep{PJM2025_settlement_slides}` from this sentence. Either cite no source (author arithmetic on public schedule), or add the PJM RPM Auction Schedule as a bib entry and cite that. |
| C4 | `Bibliography_base.bib` | MonitoringAnalytics2025_sotm | Bib entry says year 2026, "Annual Report"; actual file is Q3 2025 Quarterly, © 2025. | Correct `year = {2025}` and `howpublished = {Quarterly State of the Market Report, ...}`. If the Annual SoM is a separate intended source, split into two bib entries. |

### MAJOR — should fix before submission

| # | Location | Key | Issue | Suggested action |
|---|---|---|---|---|
| M1 | `literature.tex:10` | Klemperer1989_sfe | "Introduced by Klemperer" — Grossman (1981) and Hart (1985) preceded K&M in the no-uncertainty case; K&M introduced the demand-uncertainty SFE. | Credit Grossman 1981 for the concept; credit K&M for the uncertainty formalization. Or soften: "most associated with" / "formalized for demand-uncertainty settings by". |
| M2 | `model.tex:165` | Klemperer1989_sfe | Lower bound of SFE interval is **Bertrand**, not "competitive schedule" (the two coincide only under constant MC). Interval result requires **bounded support** — K&M prove uniqueness under unbounded support. | Rephrase: "bounded above by Cournot and below by Bertrand (which coincides with the competitive schedule under constant marginal cost, as here)." Add a note that K&M's uniqueness under unbounded support contrasts with the continuum result being used. |
| M3 | `literature.tex:14` | Klemperer1989_sfe | Same Bertrand-vs-competitive issue in the literature review statement. | Same fix; one-word change ("Bertrand" for "competitive"). |
| M4 | `model.tex:13` | Klemperer1989_sfe | "Complete-information" phrasing elides that K&M is constitutively about **demand uncertainty**. The paper's deterministic BRA departs from K&M's equilibrium concept — this should be acknowledged. | Either acknowledge the departure ("this formulation follows K&M; unlike K&M the VRR is deterministic, so I use their ODE as a selection device rather than as the equilibrium concept") or re-attribute to Green (1992) who is the actual deterministic-demand application. |
| M5 | `model.tex:203` | Green1992_british | "Backward integration from the boundary condition" is attributed to G&N, but the clean backward-integration-from-capacity technique is Holmberg 2008's contribution. G&N's approach is geometric (Fig 3–4). | Change to `\citep{Holmberg2008_unique_sfe}` or split credit: "the capacity-constrained intersection from \citet{Green1992_british}, formalized as a boundary condition by \citet{Holmberg2008_unique_sfe}". |
| M6 | `model.tex:174` | Holmberg2008_unique_sfe | Formal proposition box has subtle issues: (i) "demand is inelastic **above** the price cap" reads as inverted (Holmberg: zero above cap, inelastic below); (ii) missing strictly-convex-cost & $C'(\bar\varepsilon/N)<\bar p$ conditions. | Restate the proposition with the complete hypothesis set from Holmberg §2; add a line clarifying that Holmberg's proof is under demand uncertainty and the BRA borrows the terminal condition as a selection device. |
| M7 | `literature.tex:29` | Anderson2008_sfe_asymmetric | Called a "convergent iterative algorithm". A&H explicitly distinguish themselves from iterative methods (Baldick & Hogan, Day & Bunn); their method is a **discretization + NLP** scheme with grid-refinement convergence. | Replace "convergent iterative algorithm" with "discretization-based approximation scheme with provable convergence as the demand-shock grid is refined". |
| M8 | `sec6_allocative_cost.tex:18` | Anderson2005_sfe_pricecaps | A&X 2005 is a technical SFE existence/characterization paper under caps and contracts; it does NOT argue that caps reduce price informativeness for entrants. | Remove the cite, or replace with a source that actually makes this argument (Joskow 2008; Hogan 2005; Joskow & Tirole 2007). The sentence can stand on its own logic with no citation. |
| M9 | `model.tex:269` | Sioshansi2007_sfe_ercot | S&O explicitly model firms as **asymmetric** with firm-level calibration, and explicitly criticize size-symmetric modeling. Citing S&O to legitimize "symmetric firms + aggregate data" misrepresents what they did. | Swap for a genuinely symmetric-calibrated-SFE reference (Bolle 1992; Rudkevich-Duckworth-Rosen 1998; Holmberg). Or keep S&O but narrow the claim to "calibrated SFE from publicly available cost data" and drop the symmetry attribution. |
| M10 | `sec7_leadtime.tex:51` | Cramton2005_capacity | Claim attributes "auction prices inform decisions beyond direct construction" to C&S — but only retirement signaling is in the paper; demand response and bilateral contracting are treated as alternatives, and multi-year forward expectations are not discussed (C&S is a monthly ISO-NE design). | Narrow the cite to retirement signaling; cite other sources (IMM reports, Joskow) for DR / bilateral / forward. |
| M11 | `sec8_21billion.tex:98` | Cramton2005_capacity | Same issue as M10 — enumerated list of margins not all in C&S. | Same fix: narrow citation or restructure enumeration. |
| M12 | `sec6_allocative_cost.tex:24` | PJM2025_settlement_slides | "Investment adequacy mechanism rather than cost-reduction measure" is the author's interpretive framing — slides say "protects suppliers" without further articulating the investment-adequacy theory. | Separate the factual attribution ($175 floor exists, protects suppliers — per slides) from the interpretive attribution (author's reading of it as investment-adequacy). |
| M13 | `sec8_21billion.tex:17` | PJM2025_settlement_slides | Quoted phrase "over \$500/MW-Day" is from the Shapiro press release, not the slides. Slides visualize a ~\$500 pre-settlement Point (a) on Slide 7 but don't contain the quoted phrase. | Move the quote cite to `Shapiro2025_press_release`; cite slides only for the Point (a) visualization. |
| M14 | `introduction.tex:17` | Shapiro2025_press_release | Press release doesn't contain: Dec 30, 2024 date; "demand curve miscalibrated / cap too high / near-term entry" framing; \$269.92/MW-day clearing; "13 states" is paraphrased from "13 states PJM serves". Only "over 800 percent" and "65 million" are verbatim. | Add a citation to the FERC complaint docket itself for the date, legal theory, and \$269.92 clearing price. Keep Shapiro press release for the 800% and 65M figures. |
| M15 | `institutional.tex:162` | Shapiro2025_press_release | Technical remedy (1.5 × Net CONE, remove Gross CONE from Point (a)) is NOT in the press release. | Slides in the grouped cite cover this — OK if slides remain cited. If slides are dropped, the remedy needs a different source (complaint or settlement filing). |

### MINOR — optional polish

| # | Location | Key | Issue |
|---|---|---|---|
| m1 | `introduction.tex:38` (Klemperer + Green) | Klemperer1989_sfe / Green1992_british | "Integrated backward from the capacity-constrained boundary" is a modern synthesis. Consider splitting attribution so the backward-integration clause cites Holmberg. |
| m2 | `literature.tex:24` | Holmberg2008_unique_sfe | Drops "symmetric" qualifier from "unique symmetric SFE". Minor word add. |
| m3 | `literature.tex:20` | Green1992_british | Same backward-integration attribution issue as m1. |
| m4 | `literature.tex:56` | Cramton2005_capacity | "Primary function" overstates — C&S treat investment inducement as one of three co-equal goals. |
| m5 | `model.tex:153` | Green1992_british | G&N also do an n-firm "quintopoly" per Newbery 1991; "symmetric duopoly" slightly underrepresents G&N scope. Optional footnote. |
| m6 | `model.tex:155` | Anderson2008_sfe_asymmetric | A&H eq. (2) is the rearranged form closer to this paper's eq.; cite "(their equation 1, or the rearranged form in equation 2)". |
| m7 | `institutional.tex:166` | PJM2025_settlement_slides | "Markets and Operations Committee" should be "Markets Committee" (or "Special MC/TOA-AC"). |
| m8 | `introduction.tex:23` | PJM2025_settlement_slides | Jan 28, 2025 announcement date not in slides — add `Shapiro2025_press_release` to the cite group. |
| m9 | `sec8_21billion.tex:13` | Shapiro2025_press_release | Press release says "next two years"; paper quotes "next two delivery years". The word "delivery" is interpolated into a direct quote. Use brackets: "[delivery]" or drop the word. |
| m10 | `institutional.tex:96` | MonitoringAnalytics2025_sotm | IMM uses RSI ≤ 1 (weak); paper uses RSI < 1 (strict). Also, current offer cap is "net ACR" (net of other-market revenues); "ACR" is pedagogical shorthand. |
| m11 | `institutional.tex:96` | Bowring2013_pjm | Compound trigger "RSI₁ < 1 OR RSI₃ < 1" postdates Bowring 2013; OK because grouped with MonitoringAnalytics2025_sotm. |
| m12 | `literature.tex:44` | Bowring2013_pjm | "Designed to moderate extreme price volatility" is an interpretive gloss — Bowring says "adding elasticity" / "scarcity pricing integration". |
| m13 | `institutional.tex:35` | PJM_Manual20A | Net CONE is typically defined in Manual 18. Consider swapping cite or co-citing both manuals. |
| m14 | `sec9_policy_alternatives.tex:35` | FERC2025_ER25-1357 | "Steepening" attribution not verifiable from bib; the order mostly added horizontal cap/floor truncation. Soften language. |
| m15 | `sec9_policy_alternatives.tex:37` | FERC2025_ER25-1357 | Citing the order as authority for "further recalibration" is a stretch — order doesn't discuss further steps. Drop or reposition cite. |
| m16 | `literature.tex:51` | GlaeserLuttmer2003_rent | "In imperfectly competitive markets" generalizes G&L's housing-specific result. Soften to rent-control/housing framing. |

---

## Per-Citation Verdict Table (59 instances)

| # | File:line | Bib key | Cite form | Verdict | Severity |
|---|---|---|---|---|---|
| 1 | introduction.tex:17 | Shapiro2025_press_release | \citep | OVERREACH | MAJOR |
| 2 | introduction.tex:23 | PJM2025_settlement_slides | \citep | CORRECT_WITH_CAVEAT | MINOR |
| 3 | introduction.tex:38 | Klemperer1989_sfe | \citet | CORRECT_WITH_CAVEAT | MINOR |
| 4 | introduction.tex:38 | Green1992_british | \citet | CORRECT_WITH_CAVEAT | MINOR |
| 5 | introduction.tex:44 | Holmberg2008_unique_sfe | \citet | CORRECT | — |
| 6 | literature.tex:10 | Klemperer1989_sfe | \citet | OVERREACH | MAJOR |
| 7 | literature.tex:14 | Klemperer1989_sfe | \citeauthor | CORRECT_WITH_CAVEAT | MAJOR |
| 8 | literature.tex:20 | Green1992_british | \citet | CORRECT_WITH_CAVEAT | MINOR |
| 9 | literature.tex:24 | Holmberg2008_unique_sfe | \citet | CORRECT_WITH_CAVEAT | MINOR |
| 10 | literature.tex:29 | Anderson2008_sfe_asymmetric | \citet | MISATTRIBUTED | MAJOR |
| 11 | literature.tex:30 | Holmberg2007_asymmetric | \citet | METADATA_ONLY_OK | — |
| 12 | literature.tex:32 | Rudkevich1998_poolco | \citet | METADATA_ONLY_OK | — |
| 13 | literature.tex:41 | Joskow2007_capacity | \citep | CORRECT_WITH_CAVEAT | — |
| 14 | literature.tex:41 | Joskow2008_capacity_payments | \citep | CORRECT | — |
| 15 | literature.tex:44 | Bowring2013_pjm | \citep | CORRECT_WITH_CAVEAT | MINOR |
| 16 | literature.tex:48 | Weitzman1974_prices | \citet | METADATA_ONLY_OK | — |
| 17 | literature.tex:51 | GlaeserLuttmer2003_rent | \citet | METADATA_ONLY_DOUBT | MINOR |
| 18 | literature.tex:56 | Cramton2005_capacity | \citet | CORRECT_WITH_CAVEAT | MINOR |
| 19 | institutional.tex:18 | Bowring2013_pjm | \citep | CORRECT_WITH_CAVEAT | — |
| 20 | institutional.tex:18 | PJM_Manual18 | \citep | CORRECT_WITH_CAVEAT | — |
| 21 | institutional.tex:18 | Pfeifenberger2011_rpm | \citep | METADATA_ONLY_OK | — |
| 22 | institutional.tex:22 | PJM_Manual20A | \citep | METADATA_ONLY_OK | — |
| 23 | institutional.tex:28 | PJM_Manual18 | \citep | CORRECT | — |
| 24 | institutional.tex:35 | PJM_Manual20A | \citep | METADATA_ONLY_DOUBT | MINOR |
| 25 | institutional.tex:36 | FERC2025_ER25-1357 | \citep | METADATA_ONLY_OK | — |
| 26 | institutional.tex:96 | Bowring2013_pjm | \citep | CORRECT_WITH_CAVEAT | — |
| 27 | institutional.tex:96 | MonitoringAnalytics2025_sotm | \citep | CORRECT_WITH_CAVEAT | MINOR |
| 28 | institutional.tex:152 | PJM2025_settlement_slides | \citep | CORRECT | — |
| 29 | institutional.tex:162 | Shapiro2025_press_release | \citep | OVERREACH | MAJOR (OK if slides cover it) |
| 30 | institutional.tex:162 | PJM2025_settlement_slides | \citep | CORRECT | — |
| 31 | institutional.tex:166 | PJM2025_settlement_slides | \citep | CORRECT_WITH_CAVEAT | MINOR |
| 32 | institutional.tex:182 | PJM2025_settlement_slides | \citep | CORRECT | — |
| 33 | institutional.tex:189 | PJM2025_settlement_slides | \citep | CORRECT | — |
| 34 | institutional.tex:189 | FERC2025_ER25-1357 | \citep | METADATA_ONLY_OK | — |
| 35 | model.tex:13 | Klemperer1989_sfe | \citet | CORRECT_WITH_CAVEAT | MAJOR |
| 36 | model.tex:14 | Green1992_british | \citet | CORRECT | — |
| 37 | model.tex:153 | Green1992_british | \citet | CORRECT_WITH_CAVEAT | MINOR |
| 38 | model.tex:155 | Anderson2008_sfe_asymmetric | \citet | CORRECT_WITH_CAVEAT | MINOR |
| 39 | model.tex:165 | Klemperer1989_sfe | \citet | OVERREACH | MAJOR |
| 40 | model.tex:174 | Holmberg2008_unique_sfe | \citealt | CORRECT_WITH_CAVEAT | MAJOR |
| 41 | model.tex:198 | Holmberg2008_unique_sfe | \citeyear | CORRECT | — |
| 42 | model.tex:203 | Green1992_british | \citet | OVERREACH | MAJOR |
| 43 | model.tex:228 | Green1992_british | \citeauthor | CORRECT | — |
| 44 | model.tex:269 | Green1992_british | \citep | CORRECT | — |
| 45 | model.tex:269 | Sioshansi2007_sfe_ercot | \citep | OVERREACH | MAJOR |
| 46 | calibration.tex:125 | MonitoringAnalytics2025_sotm | \citep | WRONG_PAPER (partial) | **CRITICAL** |
| 47 | calibration.tex:129 | MonitoringAnalytics2025_sotm | \citep | OVERREACH | **CRITICAL** |
| 48 | calibration.tex:129 | MonitoringAnalytics2025_bra2627 | \citep | METADATA_ONLY_OK | — |
| 49 | sec6_allocative_cost.tex:18 | Anderson2005_sfe_pricecaps | \citep | OVERREACH | MAJOR |
| 50 | sec6_allocative_cost.tex:24 | PJM2025_settlement_slides | \citep | OVERREACH | MAJOR |
| 51 | sec7_leadtime.tex:31 | PJM2025_settlement_slides | \citep | MISATTRIBUTED | **CRITICAL** |
| 52 | sec7_leadtime.tex:51 | Cramton2005_capacity | \citet | OVERREACH | MAJOR |
| 53 | sec8_21billion.tex:13 | Shapiro2025_press_release | \citep | CORRECT_WITH_CAVEAT | MINOR |
| 54 | sec8_21billion.tex:17 | PJM2025_settlement_slides | \citep | WRONG_PAPER (quote) | MAJOR |
| 55 | sec8_21billion.tex:98 | Cramton2005_capacity | \citep | OVERREACH | MAJOR |
| 56 | sec9_policy_alternatives.tex:26 | PJM_RTEP | \citep | METADATA_ONLY_OK | — |
| 57 | sec9_policy_alternatives.tex:35 | FERC2025_ER25-1357 | \citep | METADATA_ONLY_DOUBT | MINOR |
| 58 | sec9_policy_alternatives.tex:37 | FERC2025_ER25-1357 | \citep | METADATA_ONLY_DOUBT | MINOR |
| 59 | sec9_policy_alternatives.tex:45 | FERC2023_order2023 | \citep | METADATA_ONLY_OK | — |
| — | sec9_policy_alternatives.tex:45 | FERC2024_order2023A | \citep | METADATA_ONLY_OK | — |

> Row numbering is sequential; two keys share line 45 (grouped cite).

---

## Findings by Source

### Klemperer & Meyer (1989) — 5 instances, 2 OVERREACH / 3 CWC
**Overall**: MODERATE fidelity. ODE characterization genuinely K&M; recurring issues around (a) "introduction" credit (Grossman 1981 preceded), (b) Bertrand-vs-competitive lower bound, (c) complete-info framing eliding K&M's constitutive demand uncertainty. Fixes are small word changes but several.

### Green & Newbery (1992) — 7 instances, 1 OVERREACH / 3 CWC / 3 CORRECT
**Overall**: GOOD. The core methodological-template attribution is solid. The recurring issue is attributing the modern "backward integration from capacity-tied boundary condition" technique to G&N — that specific formalization is Holmberg 2008. One clean `model.tex:203` fix resolves the main issue.

### Holmberg (2008) — 4 instances, 2 CORRECT / 2 CWC
**Overall**: GOOD. Introduction's attribution is exemplary — explicitly flags "stochastic markets" and the repurposing as a selection device. Formal proposition in model.tex needs hypothesis tightening (demand-inelasticity wording and cost conditions).

### Anderson & Hu (2008) — 2 instances, 1 MISATTRIBUTED / 1 CWC
**Overall**: The "convergent iterative algorithm" characterization is substantively wrong — A&H explicitly distinguish themselves from iterative methods. Single-word fix. Equation-number citation is essentially correct.

### Anderson & Xu (2005) — 1 instance, OVERREACH
**Overall**: The paper is about SFE existence under caps and contracts, not about informational effects of price caps on entrants. Remove or replace.

### Sioshansi & Oren (2007) — 1 instance, OVERREACH
**Overall**: S&O model firms as asymmetric with firm-level calibration; citing them to legitimize symmetric+aggregate modeling inverts what they did.

### Cramton & Stoft (2005) — 3 instances, 2 OVERREACH / 1 CWC
**Overall**: C&S do emphasize investment inducement, but not as "primary function" in hierarchical terms, and their discussion of auction-price-informed decisions covers retirement (directly) but not the enumerated list of margins the paper attributes to them. Narrow the cites or supplement with other sources.

### Joskow & Tirole (2007) + Joskow (2008) — 2 instances, 1 CORRECT / 1 CWC
**Overall**: GOOD. Joskow 2008 is the canonical "missing money" source. J&T 2007 provides the formal mechanism. Grouped cite works. Note: pre-existing bib-key-mismatch flag was a false alarm — PDF filename misleads; content matches bib entries.

### Bowring (2013) — 3 instances, all CWC
**Overall**: FINE. Institutional facts mostly supported; minor interpretive framing ("price volatility") and one modern rule formulation (RSI compound trigger) postdate the source, but grouped cites handle this.

### PJM Manual 18 — 2 instances, 1 CORRECT / 1 CWC
**Overall**: GOOD. Factual foundations of RPM and VRR well-supported.

### PJM 2025 Settlement Slides — 8 instances, 3 CORRECT / 2 CWC / 2 OVERREACH / 1 MISATTRIBUTED
**Overall**: MIXED. Slides are solid for settlement numerics ($325 cap, $175 floor, VRR shape). Problems: lead-time figures not in slides (CRITICAL), "investment adequacy" interpretive framing (author's gloss), quoted-phrase attribution (press release has the quote, not slides), committee-name typo.

### PJM IMM State of the Market — 3 instances, 1 CWC / 2 CRITICAL issues
**Overall**: MOST PROBLEMATIC SOURCE IN THE AUDIT. Bib entry mismatches the file; Table 7-38/\$149.32 citation cannot be verified; CC-as-benchmark claim contradicts the source's own CT recommendation.

### Shapiro 2025 Press Release — 3 instances, 1 OVERREACH / 1 CWC / 1 OVERREACH-OK
**Overall**: MODERATE. Press release cited for FERC complaint details it doesn't contain (Dec 30 date, legal framing, $269.92 clearing). Add FERC complaint as a separate bib entry for those facts.

### Metadata-only (11 keys, 15 instances)
- 11 OK (Holmberg 2007, Rudkevich 1998, Weitzman 1974, FERC 2023, FERC 2023-A, Pfeifenberger 2011, PJM Manual 20A for CETL, PJM RTEP, IMM BRA 2626/27, FERC ER25-1357 for three of four uses, PJM Manual 20A for CETL)
- 4 DOUBT:
  - `GlaeserLuttmer2003_rent` literature.tex:51 — "imperfectly competitive markets" too general
  - `PJM_Manual20A` institutional.tex:35 — Net CONE definition likely in Manual 18
  - `FERC2025_ER25-1357` sec9:35 — "steepening" claim unverified
  - `FERC2025_ER25-1357` sec9:37 — cite as authority for "further recalibration" stretches

---

## Bibliography Issues Uncovered

1. **`MonitoringAnalytics2025_sotm`** — year, howpublished, title all misaligned with the PDF in `supporting_papers/`. Likely need to (a) fix this entry to describe the Quarterly Q3 2025 doc, and/or (b) add a separate bib entry for the Annual SoM Volume 2 if that's the actual source of the calibration number.
2. **`Joskow2007_capacity`** — false-alarm flag resolved. Bib entry (Joskow & Tirole 2007 RAND) is correct; PDF filename "2008" is a Wiley indexing artifact. No action.
3. **`Shapiro2025_press_release`** — file named `Shapiro_Rationale.pdf` but content IS the Jan 28, 2025 press release. No bib fix, but consider renaming the file to match the bib key.
4. **Missing bib entry**: the FERC complaint itself (PA v. PJM, ~Dec 30 2024) is not in the bib but is cited implicitly via Shapiro press release for facts the press release doesn't contain. Add as separate entry.

---

## Coverage Summary

| Category | Count | Notes |
|---|---|---|
| Bib keys cited in paper | 25 | |
| Keys with local source PDF | 14 | fully PDF-verified |
| Keys without local PDF (academic) | 4 | metadata-only |
| Keys without local PDF (official docs) | 7 | metadata-only |
| Unused PDFs in `supporting_papers/` | 22 | 17 in bib but not cited in paper; 5 not even in bib |
| Citation instances audited | 59 | 44 PDF-verified + 15 metadata |
| Agent runs | 13 | 12 PDF + 1 metadata, all completed |

---

## Open Questions for the Author

1. **Calibration source**: Where does the \$149.32/MW-day combined-cycle ACR figure actually come from? If the 2024 Annual SoM Volume 2, that's a different document from the Q3 2025 Quarterly SoM currently in `supporting_papers/`. The Annual needs to be added and cited separately. (Affects `calibration.tex:125`.)
2. **FERC complaint**: Do you want to cite the FERC complaint (Docket EL25-46 or similar) directly for the Dec 30 filing date, the "demand curve miscalibrated" legal theory, and the \$269.92/MW-day clearing? The Shapiro press release doesn't contain any of these facts.
3. **Anderson & Xu citation**: If the informativeness argument is meant to be independently logical (not from a cited source), dropping the cite is clean. If authority is needed, Hogan 2005 / Joskow 2008 are stronger.
4. **Sioshansi & Oren**: Do you want a genuinely symmetric-calibrated-SFE precedent (Rudkevich-Duckworth-Rosen 1998 is already in your bib), or to reframe the S&O cite as about public-data calibration only?
5. **Klemperer "introduced by"**: Do you want to credit Grossman (1981) / Hart (1985) for the SFE concept, or keep the streamlined "introduced by Klemperer" framing and accept the historical inaccuracy? (The tension is readability vs. fidelity.)
6. **IMM CT-vs-CC recommendation**: Are you aware of the 2025-adopted IMM recommendation that CT (not CC) be the capacity-market reference resource? If yes, `calibration.tex:129` needs reframing to acknowledge the IMM's position while defending the CC-based calibration on other grounds. If not — worth reading Q3 2025 SoM p. 324 before finalizing the calibration section.

---

## Process Notes

- 13 parallel agents completed in roughly ~5 minutes wall time each; one Anderson2005 run hit an image-size limit and was retried with page-chunked reads.
- Total instance coverage: 59/59 ✓.
- Agent outputs were structured uniformly with verdict / evidence / assessment / suggested-fix, which made aggregation straightforward.
- Where bib metadata was itself wrong (MonitoringAnalytics2025_sotm), the audit exposed this as a side effect of attempting source verification.

---

## No edits made to paper files

This audit is read-only. Any fixes are the author's judgment call. A sensible next step is to triage the CRITICAL issues (C1–C4) in a new planning session, with MAJOR issues handled in a subsequent language pass.

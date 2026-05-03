# Session Log: 2026-05-02 -- 30-Page Laser-Focus Rewrite

**Status:** COMPLETED

## Objective

Rewrite the PJM capacity-auction paper to laser-focus on a single question — the consequences of suppressing capacity prices below the unconstrained equilibrium when the market clears below its reliability requirement — and bring length under 30 pages from the current 45.

The current 45-page draft accumulated three theses: an SFE methodological apparatus, a cap-incidence regime story, and a $21B reconciliation case study. The new spine connects standard price-cap theory (binding ceiling → shortage) to the empirical observation that both capped BRAs (2026/27, 2027/28) cleared below their reliability requirements.

## Approach

Per plan `quality_reports/plans/2026-05-02_30-page-laser-focus-rewrite.md`. Seven-section structure:

1. Introduction (rewrite, lead with puzzle)
2. Institutional Background (compress 6→2 pp)
3. A Price-Cap Lens on the Shapiro Settlement (new framing, ~1.5 pp)
4. Data and Calibration (compress 4→1 pp)
5. Cap-Incidence and the Emergence of Shortage (centerpiece + bunching absorbed)
6. Capped Auctions: Quantity Rationing in 2026/27 and 2027/28 (case studies)
7. Conclusion (theory–data + $21B paragraph + lead-time + welfare)

Two refinements user requested after initial plan: no standalone $21B section (one paragraph in conclusion), and no SFE derivation in body (cite Klemperer/Green/Holmberg). Both appendices deleted.

## Key Context

- **Branch:** `PJM-Paper` (ahead of `main`)
- **Title may change** to something like *Price Suppression and Reliability Shortfall in PJM's Capacity Market*; flagged for user confirmation
- **Files to delete:** `results.tex`, `bunching.tex`, `sec8_21billion.tex`, `appendix_derivations.tex`, `appendix_figures.tex`
- **Files to create:** `case_studies.tex`
- **No R re-runs** needed; figures stay on disk even when no longer referenced
- **Existing pivot artifacts** (Phase A/B/C content) are largely preserved — cap_incidence.tex, the case studies inside sec8_21billion.tex, and the bunching observation. The cuts are around them: SFE machinery, comparative statics, LDA breadth, $21B as a section

## Incremental Work Log

- **Session start:** Plan approved; work order set.
- **Structural pass:** `main.tex` reordered to drop bunching, sec8_21billion, results, both appendices; case_studies.tex stub added. First compile after restructure: 27 pp.
- **Model.tex rewrite:** 222 → 75 lines; SFE-by-reference with no derivation; binary regime indicator framing.
- **Calibration.tex slim:** 161 → 65 lines; cost-sensitivity bracketing prose dropped; K=3 justification preserved.
- **Cap_incidence.tex reframe:** Three-regimes subsection emphasized shortage-emergence; bunching paragraph absorbed; diagnostic subsection added.
- **Case_studies.tex built:** Extracted from sec8_21billion.tex; reframed around quantity-rationing channel; tab_capped_revenue inlined.
- **Institutional.tex compressed:** 273 → 175 lines; auction-primitives subsection dropped; VRR + Shapiro details preserved.
- **Five orphaned files deleted:** results.tex, bunching.tex, sec8_21billion.tex, appendix_derivations.tex, appendix_figures.tex.
- **Literature.tex trimmed:** Asymmetric SFE refs and method-detail sentence dropped; price-cap framing emphasized at close.
- **Introduction.tex rewrite:** Four-paragraph puzzle arc (Shapiro → textbook → empirical → roadmap).
- **Conclusion.tex rewrite:** Five-paragraph arc with $21B reconciliation in one paragraph (~150 words).
- **Title and abstract:** Updated to *Price Suppression and Reliability Shortfall in PJM's Capacity Market*; abstract rewritten around new spine.
- **`Preambles/header.tex`:** `pdftitle` updated.
- **Compile:** 21 pages clean. Quality score 100/100.
- **Domain + proofreading review:** Domain reviewer flagged B1 (cap-incidence diagnostic needs anchor or weakening), B2 (mechanical-not-independent caveat lost), M1 (2025/26 reserve flip is independent evidence), M2 (2026/27 19.7% increase needs explanation), M3 (K-sensitivity numerical anchor), M4 ($21B paragraph qualify to 2027/28). Proofreader flagged broken sentence in introduction:52-55, missing definitions for $\bar p$ and $q_b$, "procures" subject mismatch, "MW-Day" inconsistency, possessive-without-noun in calibration, predicate split in cap_incidence diagnostic.
- **Fixes applied:** model.tex now defines $q_b$ inline, defines $\bar p$ vs $\bar p_S$ explicitly, has K-sensitivity footnote (one number per K∈{3,4}), and ends with the mechanical-not-independent-test caveat. introduction.tex grammar fixed; shortfall denominators clarified. conclusion.tex MW-Day/MW-day, "procures"→"would have procured", $21B paragraph qualified to 2027/28. case_studies.tex 2026/27 LDA explanation added; "auction realized higher prices and procured adequate capacity" recast. institutional.tex $\bar p$/$\bar p_S$ defining sentence + tense fix + per/MW-day → /MW-day. calibration.tex possessive fix + IMM panel year clarification. cap_incidence.tex diagnostic predicate split repaired; 2025/26 reserve-flip timing argument made explicit.
- **Final compile:** 22 pages clean, 100/100, no undefined refs/cites.

## Round 2 (same date) — literature expansion, institutional expansion, no-subsection style

User feedback: literature review should absorb the SFE pedigree that left with the Model cut; identify missing sources; add more PJM detail (payment mechanism, options for non-clearing generators); style preference for no subsections.

- **Bibliography survey:** Identified 14 entries already in `Bibliography_base.bib` not yet cited; recommended adding the most relevant ones.
- **Literature expansion:** 3 → 4 paragraphs (~280 → ~720 words). New citations added: `Anderson2005_sfe_pricecaps` (canonical SFE-with-price-caps reference), `Hogan2005_energy_adequacy`, `Hobbs2007_rpm`, `Vasin2016_sfe_uniform`, `Wolfram1999_duopoly`, `Sweeting2007_market_power`, `Sioshansi2007_sfe_ercot`, `Baldick2004_linear_sfe`, `CramtonOckenfels2012_capacity`, `Cramton2007_uniform`, `Wolak2003_measuring`, `Borenstein2002_market_power`, `Bushnell2008_vertical`, `Vossler2009_price_caps`. Structure: SFE foundations + selection problem; SFE applied + price caps (Anderson-Xu the most direct antecedent); capacity-market design with PJM-specific RPM analysis; price controls and reliability with empirical market-power literature.
- **Institutional expansion:** 175 → ~270 lines. Added detail on payment mechanism for cleared resources (uniform LDA price, daily UCAP basis, monthly settlement, Capacity Performance obligation, performance bonus/penalty calibrated to Net CONE multiple); options for non-clearing generators (Incremental Auctions at -20/-10/-4 months, FRR Alternative for LSE bilateral procurement, energy-only opt-out, Notice of Deactivation, Reliability Must-Run designation); ELCC and CETL definitions; reference to Net CONE methodology.
- **Subsection removal:** Dropped `\subsection{}` commands from `model.tex`, `cap_incidence.tex`, `case_studies.tex`, `institutional.tex`. Preserved `\label{subsec:*}` commands as paragraph anchors so cross-refs from other files still resolve (to the parent section number). No prose damage—case studies separate visibly via topic sentences.
- **Final compile:** 26 pages clean, 100/100, no undefined refs/cites.

## Quality Scores

| Check | Result |
|-------|--------|
| Compile (3-pass) | Clean |
| Page count | 22 |
| Undefined references | 0 |
| Undefined citations | 0 |
| Quality score | 100/100 (Excellence) |

## Verification Results

| Check | Result | Status |
|-------|--------|--------|
| `pdflatex` 3-pass + `bibtex` | No errors | PASS |
| `pdfinfo Pages` | 22 | PASS (≤ 30 target) |
| `grep "Reference\\|Citation" main.log` | empty | PASS |
| `python3 scripts/quality_score.py Paper/main.tex` | 100/100 | PASS |
| Domain review | Critical fixes B1, B2 applied | PASS |
| Proofreading | High-priority items applied | PASS |

## Open Questions / Blockers

- [ ] Title is set to *Price Suppression and Reliability Shortfall in PJM's Capacity Market* — user should confirm or change.
- [ ] Some lower-priority proofreader items not applied (e.g., "Reserve excess IRM" terminology standardization, occasional "obtains" repetition, minor connective polish). These belong in a future polish pass.
- [ ] Domain reviewer suggested verifying the bib key `Klemperer1989_sfe` is the Klemperer–Meyer 1989 paper (not single-authored Klemperer); not yet checked against Bibliography_base.bib.

## Next Steps

- [ ] User review and title confirmation.
- [ ] Optional polish pass for remaining proofreader items.
- [ ] Commit when user approves.

## Follow-up Increments (2026-05-03)

- `0beb919` — recompiled and committed the user's manual edits across `main.tex`, `calibration.tex`, `cap_incidence.tex`, `case_studies.tex`, `conclusion.tex`, `institutional.tex`, `introduction.tex`, `literature.tex`, `model.tex`. 24 pages.
- `fb925b2` — rewrote the abstract on the puzzle / mechanism / strategy / findings template, expanding acronyms (UCAP, IMM, SFE, VRR) on first use except PJM.
- `00a59a9` — propagated the institutional headline-vs-operative cap clarification: `model.tex` now states `\bar p_S = $329.17` (2026/27) and `$333.44` (2027/28) instead of `$325`; `tab_cap_incidence` Settle. cap column updated to operative values with extended footnote pointing back to §3.
- `b1607ea` — merged sections 4+5 → "Framework and Calibration" and 6+7 → "Empirical Results" by demoting calibration and case_studies to subsections.
- `76614a5` — per user follow-up, dropped the introduced subsection headings; merged sections now have a single section heading each. Final flat structure is six sections (Introduction → Conclusion). Conclusion cross-ref to case studies now resolves to "Section 5".

PDF still 24 pages. All compiles clean (`pdflatex` 3-pass + `bibtex`, no errors, no undefined references).

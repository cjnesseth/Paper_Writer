# Plan: "Carbon Pricing in Reverse" — Full Empirical Paper (public data)

**Date:** 2026-05-30
**Status:** DRAFT (awaiting approval)
**Spec:** `quality_reports/specs/2026-05-30_rggi-paper.md`
**Source:** `master_supporting_docs/Paper_Outline.md`

---

## Approach

Author a **plain LaTeX article** (`Paper/rggi_carbon_pricing_reverse.tex`) compiled via the
repo's XeLaTeX workflow, with a strict **code/prose separation**: versioned R scripts do all
estimation and write tables (`.tex`) and figures (`.pdf`) to disk; the article `\input{}`s
tables and `\includegraphics` figures. Sequence: research-first (verify literature → bib),
then build a **public-data pipeline**, then **estimate** entry + exit effects (SCM primary;
event-study DiD + synthetic DiD robustness; leakage + asymmetry), then write the manuscript
around the generated tables/figures. **Re-entry (Jul 2026) is future** → pre-registered
design + placeholder results. **Public data only; no Dominion internal data; no SAS.** No
fabricated numbers — every reported figure traces to a script run on real data.

Each phase ends with verification (compile / pipeline runs) and a review gate (>= 90/100) per
the orchestrator protocol.

### Why plain LaTeX + separate R scripts (decided)
Lowest journal-submission friction: econ journals (JAERE/JEEM/Energy Econ) are LaTeX-centric
and want native source + an AEA-style replication package — both are first-class here. R
scripts → `.tex` tables (`modelsummary`/`fixest::etable`) + `.pdf` figures → `\input{}`/
`\includegraphics` keeps results fully reproducible without inlining heavy computation in the
document, and the script layer *is* the replication package. (Quarto was considered; rejected
for the camera-ready `.tex` friction at submission.)

---

## Phase 0 — Repo Setup for a Reproducible Paper

Files: `Paper/`, `Paper/rggi_carbon_pricing_reverse.tex`, `Preambles/header.tex`,
`scripts/R/`, `data/` (raw/tidy, gitignored as needed), `Figures/`, `Tables/`.

1. LaTeX article skeleton: article class, title/abstract/author placeholders, §1–§9 section
   headers from the outline, `\bibliography{../Bibliography_base.bib}` (natbib/biblatex econ
   author-year), notation/math macros (§4 carbon-adder model) in `Preambles/header.tex`.
   Wire `\input{../Tables/...}` and `\includegraphics{../Figures/...}` conventions.
2. `scripts/R/` layout: `00_setup.R` (packages, paths), `01_fetch_*.R` per source,
   `02_tidy_panel.R`, `03_scm.R`, `04_did.R`, `05_synthdid.R`, `06_robustness.R`,
   `07_figures_tables.R` (writes `.pdf` → `Figures/`, `.tex` → `Tables/`). `renv` (or
   documented lockfile) for reproducibility.
3. `data/` raw→tidy caching convention; `.gitignore` for large raw pulls; record access dates.
4. Verify toolchain: XeLaTeX + bibtex, R + key packages
   (`tidysynth`/`Synth`, `fixest`, `synthdid`, `did`, `fect`, `ggplot2`, `modelsummary`,
   data-pull libs).
5. Update CLAUDE.md "Current Project State" to note the paper is the active deliverable.

**Verify:** 3-pass XeLaTeX builds a PDF skeleton from the `.tex`; `Rscript scripts/R/00_setup.R`
runs clean.

## Phase 1 — Literature Review & Bibliography (research-first)

6. `/lit-review` across the four themes (RGGI/carbon-pricing empirics; pass-through/incidence;
   policy-reversal & asymmetry; SCM/DiD methodology).
7. Verify all ~31 outline references; flag working papers (Song–Hochman 2025; Yan 2021) and
   grey literature (TCR 2025; Analysis Group; NRDC); confirm status & exact citation form.
8. Populate `Bibliography_base.bib`; add any gap-filling citations the review surfaces.
9. `/validate-bib` clean.

**Verify:** all citation keys resolve; `/validate-bib` passes.

## Phase 2 — Public Data Pipeline

10. Implement `01_fetch_*.R` for each public source (EIA 861/861M; EPA CEMS via CAMPD; PJM
    Data Miner 2.0 LMPs; RGGI auction reports; NOAA HDD/CDD; EIA gas prices; BEA/Census
    controls; public SCC dockets for the Dominion rider).
11. `02_tidy_panel.R`: build the state-month panel (2018–2026) + PJM-zone panel; treatment =
    Virginia; donor pools (non-RGGI PJM: WV/OH/PA/KY/IN/NC/TN; continuous-RGGI: MD/DE/NJ/CT/
    MA/ME/NH/VT/RI/NY); covariates (gas, HDD/CDD, income, population, industrial load).
12. Data QA: coverage, missingness, unit checks; document vintages/access dates; cache tidy
    panel. Note any variable degraded by the no-Dominion constraint and the public proxy used.

**Verify:** pipeline runs end-to-end from fetch→tidy; panel passes QA checks. **Review:** `/review-r`.

## Phase 3 — Estimation: Entry + Exit Events

13. **SCM (primary)** `03_scm.R`: synthetic Virginia for entry (pre Jan2018–Dec2020) and exit
    (pre Jan2021–Sep2023) on retail price, wholesale LMP (DOM zone), emissions; placebo/
    permutation + conformal intervals (Cattaneo–Feng–Titiunik).
14. **Event-study DiD** `04_did.R` (`fixest`): dynamic $\beta_\tau$ with state + month FE and
    time-varying controls; wild cluster bootstrap SE; run for entry and exit.
15. **Synthetic DiD** `05_synthdid.R` as the SCM↔DiD bridge.
16. **Extensions:** wholesale PJM-zone analysis; leakage (VA-plant vs. PJM-wide emissions);
    formal **asymmetry test** $|\hat\beta^{exit}|=|\hat\beta^{entry}|$ (hysteresis).
17. `07_figures_tables.R`: SCM gap plots, event-study coefficient plots, placebo distributions
    (→ `Figures/*.pdf`), and formatted regression/SCM tables (→ `Tables/*.tex`) — consumed by
    the article via `\includegraphics` / `\input`.

**Verify:** scripts reproduce all objects; figures/tables write to disk. **Review:** `/review-r` +
`/review-paper` (econometric specification). **Gate >= 90.**

## Phase 4 — Robustness (§7) + Re-entry Design

18. Execute the §7 robustness table: alternative treatment dates (Jan2022 announcement / Jun2023
    board vote / Dec2023 last auction) & pre-trend tests; concurrent-shock controls (IRA/RPS,
    renewable capacity); gas-price-adjusted outcomes; data-center load controls & per-MWh
    outcomes; SUTVA/PJM-wide spillover bounds; rider mechanical-vs-equilibrium decomposition;
    fleet-composition (shares vs. levels).
19. **Re-entry (Jul 2026):** pre-register the design (treatment date, donors, estimands,
    inference) and create a placeholder results slot — clearly marked prospective.

**Verify:** robustness reproduces; **Review:** `/review-paper` + `/devils-advocate`. **Gate >= 90.**

## Phase 5 — Manuscript Prose (submission quality)

20. Write/finish §1 Intro (motivation, 4 RQs, 3 contributions), §2 Background (RGGI mechanics
    + Third Program Review; VA timeline; **public-SCC** rider context; data centers/IRA), §3
    Lit Review, §4 Theory (carbon-adder model + 5 predictions).
21. Write §5 Data, §6 Strategy (estimands, dates, donors, inference, extensions), §7 Threats.
22. Populate §8 Results by `\input`/`\includegraphics` of the generated entry + exit tables
    and figures; write §9 Interpretation (map results to the three scenarios: symmetric /
    asymmetric / leakage-dominates); re-entry as prospective.
23. Abstract + contribution paragraph finalized.

**Verify:** 3-pass XeLaTeX compile clean. **Review:** `/proofread` + `/review-paper`. **Gate >= 90.**

## Phase 6 — QA, Validation & Commit

24. Final `/validate-bib`; full `/proofread`; PDF overflow/layout check; reproducibility
    check (clean re-run: fetch → estimate → tables/figures → XeLaTeX compile).
25. Confirm >= 90/100; merge quality report (`templates/quality-report.md`).
26. `/commit` on `RGGI` → PR → merge.

---

## Files to Create / Modify

| File | Phase | Action |
|------|-------|--------|
| `Paper/rggi_carbon_pricing_reverse.tex` | 0,5 | Main manuscript (plain LaTeX article) |
| `Preambles/header.tex` | 0 | Article preamble + math macros |
| `Bibliography_base.bib` | 1 | Populate + verify |
| `scripts/R/00–07_*.R` | 0,2–4 | Data pipeline + estimation + figures/tables |
| `data/` (raw/tidy, cached) | 2 | Create; gitignore large raw pulls |
| `Figures/` (`.pdf`) | 2–4 | Result + illustrative figures |
| `Tables/` (`.tex`) | 3–4 | R-generated regression/SCM tables |
| `renv.lock` (or documented env) | 0 | Reproducibility |
| `CLAUDE.md` "Current Project State" | 0 | Note paper as active deliverable |
| `quality_reports/merges/…` | 6 | Quality report at merge |

## Verification (each phase)

- Compile: 3-pass XeLaTeX + bibtex on `Paper/rggi_carbon_pricing_reverse.tex` → PDF, no errors.
- Pipeline: scripts run fetch→tidy→estimate without manual steps; data vintages logged.
- Citations: `/validate-bib` clean.
- Review: `/review-r`, `/review-paper`, `/proofread`, `/devils-advocate`.
- Gate: >= 90/100 before advancing/merging.

## Risks & Notes

- **Data access friction (public-only):** PJM Data Miner / EPA CAMPD / EIA may need API keys
  or bulk downloads; some series lag. Mitigation: cache pulls, log vintages, document any
  series that can't be fully obtained and the public proxy used. **No-Dominion** means
  plant-operational detail beyond CEMS and exact rider internals are unavailable — use public
  SCC filings and CEMS; flag limitations in §2.3/§5.
- **No fabricated numbers** — hard integrity rule; unavailable → stated, not invented.
- **Re-entry is future** (Jul 2026): design only; never reported as observed.
- **Reference verification:** flag working papers / grey literature; don't overstate as peer-reviewed.
- **Inference with small N** of clusters/donors — rely on permutation + conformal + wild bootstrap.
- **Compute/runtime:** hourly CEMS/PJM aggregation can be heavy; aggregate to monthly early, cache.
- Orchestrator limits: max 5 review-fix rounds per gate; max 2 verification retries.

## Open Questions (non-blocking; defaults in spec)

1. Journal target now, for a template? (default: journal-agnostic)
2. Author/affiliation for the title block? (default: placeholders)
3. Outcome priority if data access is uneven — lead with retail prices, then emissions, then
   wholesale LMPs? (default: that order)
4. `renv` acceptable for environment pinning? (default: yes)

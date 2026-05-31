# Requirements Specification: "Carbon Pricing in Reverse" — RGGI Paper

**Date:** 2026-05-30
**Status:** DRAFT (awaiting approval)
**Source:** `master_supporting_docs/Paper_Outline.md`

---

## Objective

Produce a **full, reproducible empirical economics paper** —
*"Carbon Pricing in Reverse: Evidence from Virginia's Exit and Re-Entry into RGGI"* — using
**public data only**. We acquire the public datasets, estimate causal effects (synthetic
control + event-study DiD + synthetic DiD) for the **entry (Jan 2021)** and **exit
(Dec 2023)** events, and report results. The **re-entry (Jul 2026)** event is prospective
(future as of today, 2026-05-30): its design is pre-registered and its results section is
scaffolded for later. The manuscript targets JAERE / JEEM / Energy Economics and is intended
to become a dissertation chapter.

**Authoring model (decided):** a **plain LaTeX article** (`Paper/…tex`), compiled via the
repo's XeLaTeX workflow. R scripts do **all** estimation and write tables (`.tex`) and
figures (`.pdf`) to disk; the manuscript `\input{}`s tables and `\includegraphics` figures.
This is the econ-standard, lowest-friction path to journal submission (native journal class,
clean replication package). Quarto is **not** used for the paper.

---

## Requirements

### MUST Have (Non-Negotiable)
- [ ] A **plain LaTeX article** (`Paper/rggi_carbon_pricing_reverse.tex`) compiling cleanly
      via the repo's 3-pass XeLaTeX + bibtex workflow, using `Preambles/header.tex` and
      citing from `Bibliography_base.bib` (econ author-year, natbib/biblatex).
- [ ] **Strict code/prose separation:** all numbers, tables (`.tex` via
      `modelsummary`/`fixest::etable`), and figures (`.pdf`) are produced by versioned R
      scripts and written to disk; the `.tex` only `\input{}`s tables and `\includegraphics`
      figures — no hand-typed estimates.
- [ ] A **reproducible data pipeline** (`scripts/R/`) that ingests **public** sources only:
      EIA Form 861/861M, EPA CEMS (CAMPD), PJM Data Miner 2.0, RGGI Inc. auction reports,
      NOAA (HDD/CDD), EIA gas prices (Henry Hub / Transco Z5), BEA/Census controls, and
      **public SCC dockets** for the Dominion rider. **No Dominion internal data; no SAS.**
- [ ] **Estimation for the entry and exit events:** synthetic control (primary), event-study
      DiD (robustness), synthetic DiD (bridge) on retail prices, wholesale LMPs (PJM-zone),
      and CO₂ emissions; plus the leakage and asymmetry analyses.
- [ ] **Inference:** SCM placebo/permutation tests, conformal prediction intervals
      (Cattaneo–Feng–Titiunik 2021), and wild cluster bootstrap for DiD (small-N).
- [ ] Complete, submission-quality prose for §1–§7 (Intro, Background, Lit, Theory, Data,
      Strategy, Threats) plus §8 Results and §9 Interpretation populated from **real
      estimates** (entry + exit).
- [ ] **No fabricated numbers.** Every reported figure traces to a code chunk run on real
      public data. Where data are unavailable/insufficient, say so explicitly.
- [ ] **Re-entry (Jul 2026)** handled as a **pre-registered design + placeholder** results
      slot — never reported as if observed.
- [ ] All literature claims cited and verified; `/validate-bib` passes.
- [ ] Manuscript renders end-to-end; results reproducible from raw-data fetch to PDF; quality
      gate **>= 90/100** before PR/merge.

### SHOULD Have (Preferred)
- [ ] `/lit-review` completed first; all ~31 outline references verified (year, journal,
      vol/pp, DOI), with working papers / grey literature flagged as such.
- [ ] A documented, cached data layer (raw → tidy) so re-runs don't re-hit every API; record
      data vintages/access dates for replication.
- [ ] Robustness suite from the outline's §7 table actually executed (alternative treatment
      dates for anticipation, control inclusion/exclusion, gas-adjusted outcomes, per-MWh vs.
      revenue, SUTVA/PJM-wide bounds, fleet-composition controls).
- [ ] Publication-quality `ggplot2` figures (SCM gap plots, event-study coefficient plots,
      placebo distributions) and formatted regression/SCM tables.
- [ ] Donor-pool / sample-construction tables rendered from a config; VA timeline & a
      treatment-event diagram as illustrative figures.
- [ ] A "data sources & access" appendix mapping each variable to its public retrieval method.

### MAY Have (Optional, If Time)
- [ ] `did` (Callaway–Sant'Anna) and `fect` (matrix completion) as additional robustness.
- [ ] Journal-specific output template once a target is chosen.
- [ ] Distributional/heterogeneity analysis if suitable public microdata exist.
- [ ] `/review-paper` and `/devils-advocate` adversarial passes; companion slide deck later.

---

## Clarity Status

| Aspect | Status | Notes |
|--------|--------|-------|
| Deliverable = full empirical paper | CLEAR | User selected "Full paper incl. empirics." |
| Data scope = public only, no Dominion | CLEAR | User selected. Rider from public SCC dockets; SAS dropped. |
| Format = plain LaTeX article + separate R scripts | CLEAR | User chose after weighing tradeoffs. Lowest journal-submission friction (native journal class, clean replication package); R scripts write `.tex` tables + `.pdf` figures that the article `\input{}`s/`\includegraphics`. Quarto not used for the paper. |
| Research-first sequencing | CLEAR | `/lit-review` + bib before drafting/estimation. |
| Entry + exit empirics in-scope now | CLEAR | Public data cover Jan 2018–~early 2026. |
| Re-entry (Jul 2026) empirics | ASSUMED | Future date → design + placeholder only; revisit post-data. |
| Data currently in hand | ASSUMED-NO | User said public-only (not "available now"); plan treats acquisition as its own phase. |
| Journal target | ASSUMED | Journal-agnostic article now; pick template later. |
| Author/affiliation | ASSUMED | Placeholders; external researcher using public data. |
| This session = spec + plan only | CLEAR | No building this session. |

---

## Success Criteria

- A rendered PDF with §1–§9 complete; §8/§9 report real entry + exit estimates with figures,
  tables, and inference; re-entry clearly marked prospective.
- A one-command reproducible path: fetch public data → tidy → estimate → render PDF.
- `Bibliography_base.bib` populated and verified; `/validate-bib` clean.
- Robustness/threats checks executed and reported.
- Quality score >= 90/100; no fabricated numbers; data vintages documented.

---

## Out of Scope (Now)

- Any Dominion internal data or SAS preprocessing.
- Reporting re-entry (Jul 2026) results (event is in the future).
- Slide deck / teaching materials (deferred; repo capability retained).
- New primary data collection beyond public sources.

---

## Approval

[ ] User approved: __________

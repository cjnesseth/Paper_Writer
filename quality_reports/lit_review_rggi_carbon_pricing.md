# Literature Review: Carbon Pricing in Reverse (RGGI)

**Date:** 2026-05-30
**Query:** Verify and assemble bibliographic details for the ~31 references in
`master_supporting_docs/Paper_Outline.md` and add gap-filling citations, writing verified
BibTeX into `Bibliography_base.bib` for *"Carbon Pricing in Reverse: Evidence from
Virginia's Exit and Re-Entry into RGGI."*
**Method:** Four parallel verification agents cross-checked each reference against Crossref
(authoritative publisher metadata), AEA/journal pages, and RePEc/IDEAS. Working papers and
grey literature were flagged where unconfirmable. **No citations were fabricated.**

## Summary

The empirical literature on RGGI converges on three robust facts: (i) emissions reductions
in RGGI states are only partly attributable to the cap, with gas-for-coal switching and the
recession doing much of the work [Murray2015_rggi_attribution; Yan2021_rggi]; (ii) sub-national
carbon pricing induces measurable **leakage** to neighboring non-participating jurisdictions
[Fell2018_leakage]; and (iii) the program's federalist design raises efficiency questions that
remain unsettled [Shobe2012_federalism]. The pass-through literature establishes that emissions
costs are passed into electricity prices in both restructured and regulated settings
[Fabra2014_passthrough; Hintermann2016_passthrough], with firm-level rent effects
[Bushnell2013_profiting; Fowlie2016_dynamics]. The policy-reversal/asymmetry question this
paper targets is essentially **open**: the closest analogues study Clean Air Act
designations and coal-sector dynamics [Greenstone2002_caa; Walker2013_reallocation;
Coglianese2020_coal], but no study estimates the causal effect of *removing* a carbon market.
Methodologically, the synthetic-control family [Abadie2010_synth; Abadie2015_comparative;
Abadie2021_using_synth] now has principled inference [Cattaneo2021_prediction] and a DiD bridge
[Arkhangelsky2021_sdid], complemented by modern staggered-DiD [Callaway2021_did] and
small-cluster inference [Cameron2008_bootstrap] — exactly the toolkit this design requires.

## Corrections to the Outline (important)

| Outline claim | Verified correction |
|---|---|
| Yan (2021) "Emissions Leakage from RGGI" (working paper) | Published as *"The Impact of Climate Policy on Fossil Fuel Consumption: Evidence from RGGI,"* Energy Economics 100:105333. |
| Hintermann (2016) in JEEA 14(6):1329–1362 | Correct journal **JAERE 3(4):857–891**, DOI 10.1086/688486. |
| VCEA codified at § 10.1-1330 | VCEA is **§ 56-585.5**. § 10.1-1329 et seq. is the separate RGGI-enabling *Clean Energy and Community Flood Preparedness Act* (added as `VACEFPA2020`). |
| "TCR (Competitive Enterprise Institute / Common Resources Group)" white paper | Author is **Tabors Caramanis Rudkevich, Inc.** (Rudkevich & Tabors 2025); not CEI. No CEI study located. |
| Analysis Group (2023) "Nine ... States" | Title says **"Ten"** states (Hibbard, Darling & Stuart 2023). |
| Dominion SCC docket PUR-2021-00197 | Relevant dockets: **PUR-2020-00169, PUR-2021-00281, PUR-2022-00070**. |
| RGGI Third Program Review "2024/2025" | Updated Model Rule finalized **2025-07-16**, effective **2027**. |

## Unverified (must confirm before submission)

- **SongHochman2025_retail** — Working paper; could not confirm exact title, author initial
  (likely *Ze* Song, not "Y."), year, or a stable URL/DOI. The ~11% short-run retail effect
  and Rutgers/DiD provenance are consistent with search results, but the entry is flagged
  `UNVERIFIED` in the `.bib`. Confirm with the authors or Hochman's Rutgers page.

## Thematic Organization

- **Empirical effects of carbon pricing (RGGI):** Fell2018_leakage, Murray2015_rggi_attribution,
  Yan2021_rggi, Burtraw2009_so2nox, Shobe2012_federalism, (SongHochman2025_retail*).
- **Pass-through & incidence:** Fabra2014_passthrough, Hintermann2016_passthrough,
  Fowlie2016_dynamics, Bushnell2013_profiting.
- **Policy reversal & asymmetry:** Greenstone2002_caa, Coglianese2020_coal, Walker2013_reallocation.
- **Methodology (SCM / DiD):** Abadie2010_synth, Abadie2015_comparative, Abadie2021_using_synth,
  Arkhangelsky2021_sdid, Cattaneo2021_prediction, Callaway2021_did, Cameron2008_bootstrap.
- **RGGI program / policy / grey lit:** RGGI_auctions, RGGI_thirdreview, VCEA2020, VACEFPA2020,
  VAAPCB2023_repeal, WholesaleCost2025, AnalysisGroup2023_impacts, NRDC_reentry, DominionSCC_rider.
- **Virginia energy markets:** LBNL_datacenters, PJM_som.

## Gaps and Opportunities (this paper's contribution)

1. **No causal study of a carbon-market exit.** All RGGI empirics study adoption or steady
   state; none estimate the effect of *removal*. Virginia's exit is the first clean case.
2. **Asymmetry / hysteresis is untested in carbon markets.** The CAA analogues hint at
   ratchet effects, but no one has paired entry and exit estimates on one unit.
3. **Within-RTO leakage under sub-national pricing** is estimated cross-sectionally
   [Fell2018_leakage]; a within-PJM exit gives a sharper, event-based leakage estimate.

## Suggested Next Steps

- Resolve the `SongHochman2025_retail` citation before submission.
- Phase 2: build the public-data panel; the TCR white paper [WholesaleCost2025] and Analysis
  Group report [AnalysisGroup2023_impacts] give comparison magnitudes for wholesale effects.
- Consider adding `did`/`synthdid`/`fect` methods cites already covered above; add a
  staggered-DiD robustness cite if the design expands.

## BibTeX

All 29 verified entries are written to `Bibliography_base.bib` (grouped A–F). The manuscript
compiles with **0 undefined citations** and **0 bibtex warnings**.

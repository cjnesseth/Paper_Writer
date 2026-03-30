# Reference List: Data Center Costs and Benefits in Loudoun County

## Downloaded (in `master_supporting_docs/supporting_papers/`)

### Core Papers (already had)
1. **Jarvis (2025)** "The Economic Costs of NIMBYism: Evidence from Renewable Energy Projects." *JAERE* 12(4). `Nimbyism_Model.pdf` — Model paper; hedonic DiD for wind/solar, distance rings, political economy framing.
2. **Jaros (2025)** "Tax Abatements for Data Centers and Government Output." Clemson dissertation ch.3. `TaxDataCenters.pdf` — No short-run tax revenue gain from abatements; useful contrast (Loudoun has no local abatements).
3. **Waters & Clower (2025)** "Data Centers and 2023 Home Sales in Northern Virginia." George Mason CRA. `NoVa_DataCenters.pdf` — Cross-sectional hedonic; no negative property effect but lacks causal ID.

### Hedonic / Infrastructure Disamenity
4. **Davis (2011)** "The Effect of Power Plants on Local Housing Values and Rents." *Review of Economics and Statistics* 93(4): 1391-1402. `Davis_2011_PowerPlants.pdf` — 3-7% housing decline within 2 miles of new plants; closest analog to our design.

### Staggered DiD Methodology
5. **Roth, Sant'Anna, Bilinski & Poe (2023)** "What's Trending in Difference-in-Differences?" *Journal of Econometrics* 235(2): 2218-2244. `Roth_etal_2023_DiD_Review.pdf` — Comprehensive review of new DiD literature; essential methodological reference.
6. **Jarvis (2025)** Working paper version with additional appendices. `Jarvis_2025_NIMBYism_WP.pdf`

### Data Center Economics & Policy
7. **JLARC (2024)** "Data Centers in Virginia." Report 598. `JLARC_2024_DataCenters.pdf` — 4,140 MW NoVA load, $700M Loudoun tax revenue, ratepayer impact estimates.
8. **Good Jobs First (2025)** "Cloudy with a Loss of Spending Control." `GoodJobsFirst_2025_DataCenters.pdf` — VA data center sales tax exemption cost $732M in FY2024.

### Electricity / Energy
9. **Borenstein & Bushnell (2015)** "The U.S. Electricity Industry After 20 Years of Restructuring." *Annual Review of Economics* 7: 437-463. `Borenstein_Bushnell_2015_Restructuring.pdf` — Cross-subsidies between customer classes; residential ratepayer burden.
10. **DeCarolis et al. (2025)** "Electricity Grid Impacts of Rising Demand from Data Centers." CMU/NC State WP. `DeCarolis_etal_2025_GridImpacts.pdf` — DC demand 350% growth 2020-2030; avg bills up 8% nationally, 25%+ in NoVA.
11. **Knittel, Senga & Wang (2025)** "Flexible Data Centers and the Grid." NBER WP 34065. `Knittel_etal_2025_FlexibleDC_NBER.pdf` — DC temporal flexibility as demand response; cost vs emissions tradeoff.
12. **LBNL (2025)** "Electricity Rate Designs for Large Loads." DOE Technical Brief. `LBNL_2025_RateDesignsLargeLoads.pdf` — Rate design for DC-scale customers; cost-causation principles.
13. **LBNL/Shehabi et al. (2024)** "2024 United States Data Center Energy Usage Report." `LBNL_2024_DCEnergyReport.pdf` — Projects US DC electricity 176 TWh (2023) to 325-580 TWh (2028).

### Incidence / Incentives
14. **Bartik (2020)** "Using Place-Based Jobs Policies to Help Distressed Communities." *JEP* 34(3): 99-127. `Bartik_2020_PlaceBased_JEP.pdf` — ~75% of incentives inframarginal; recommends targeting.
15. **Slattery & Zidar (2020)** "Evaluating State and Local Business Tax Incentives." *JEP* 34(2): 90-118. `Slattery_Zidar_2020_Incentives.pdf` — Incentive spending = 40% of corporate tax revenue; avg subsidy $178M for 1,500 jobs.

### Environmental / Community
16. **Hogan et al. (2025)** "The Cloud Next Door: Investigating the Environmental and Socioeconomic Strain of Datacenters on Local Communities." *ACM COMPASS 2025*. `Hogan_etal_2025_CloudNextDoor.pdf` — Northern Virginia case study; noise, water, aesthetics, electricity costs for neighbors.

---

## Need to Gather Manually

### Hedonic / Infrastructure (behind paywalls)
17. **Currie, Davis, Greenstone & Walker (2015)** "Environmental Health Risks and Housing Values: Evidence from 1,600 Toxic Plant Openings and Closings." *AER* 105(2): 678-709. — 11% decline within 0.5 mi; template for plant entry/exit events. *[AER paywall; check university library]*
18. **Greenstone & Gallagher (2008)** "Does Hazardous Waste Matter? Evidence from the Housing Market and the Superfund Program." *QJE* 123(3): 951-1003. — Superfund RD design. *[QJE paywall]*
19. **Muehlenbachs, Spiller & Timmins (2015)** "The Housing Market Impacts of Shale Gas Development." *AER* 105(12): 3633-3659. — Fracking + groundwater heterogeneity. *[AER paywall]*
20. **Hoen et al. (2015)** "A Spatial Hedonic Analysis of the Effects of US Wind Energy Facilities on Surrounding Property Values." *JREFE* 51(1): 22-51. — 7,500 sales near wind farms; no significant negative effect. *[Springer paywall; LBNL WP may be free]*
21. **Gibbons (2015)** "Gone with the Wind: Valuing the Visual Impacts of Wind Turbines through House Prices." *JEEM* 72: 177-196. — Visual disamenity from turbines. *[Elsevier paywall]*
22. **Kiel & McClain (1995)** "House Prices during Siting Decision Stages." *JUE* 37(3): 311-323. — Property values across rumor/construction/operation. *[Elsevier paywall]*
23. **Linden & Rockoff (2008)** "Estimates of the Impact of Crime Risk on Property Values from Megan's Laws." *AER* 98(3): 1103-1127. — Sharp spatial decay of disamenity effects. *[AER paywall]*
24. **Bollinger, Gillingham & Kirkpatrick (2024)** "Who Bears the Cost of Renewable Power Transmission Lines?" *Energy Policy* 190: 114138. — TX transmission; 10% decline within 0.5 km. *[Elsevier paywall]*

### Staggered DiD (check NBER/author pages)
25. **Callaway & Sant'Anna (2021)** "Difference-in-Differences with Multiple Time Periods." *Journal of Econometrics* 225(2): 200-230. — Group-time ATT; likely primary estimator. *[Try author's website or R package vignette]*
26. **Sun & Abraham (2021)** "Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects." *JoE* 225(2): 175-199. — Interaction-weighted estimator. *[Elsevier paywall]*
27. **de Chaisemartin & D'Haultfoeuille (2020)** "Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects." *AER* 110(9): 2964-2996. — Negative weights in TWFE. *[AER paywall]*
28. **Goodman-Bacon (2021)** "Difference-in-Differences with Variation in Treatment Timing." *JoE* 225(2): 254-277. — TWFE decomposition. *[NBER WP 25018 may be free]*
29. **Borusyak, Jaravel & Spiess (2024)** "Revisiting Event-Study Designs." *Review of Economic Studies* 91(6): 3253-3285. — Imputation-based estimator. *[Author's website]*
30. **Athey & Imbens (2022)** "Design-Based Analysis in Difference-in-Differences Settings with Staggered Adoption." *JoE* 226(1): 62-79. — Finite-sample inference. *[NBER WP may be free]*

### Foundational / Theory
31. **Rosen (1974)** "Hedonic Prices and Implicit Markets." *JPE* 82(1): 34-55. — Foundational hedonic theory. *[JSTOR]*
32. **Kuminoff, Smith & Timmins (2013)** "The New Economics of Equilibrium Sorting and Policy Evaluation Using Housing Markets." *JEL* 51(4): 1007-1062. — Motivates DiD over cross-section. *[AEA paywall]*
33. **Fischel (2001)** *The Homevoter Hypothesis.* Harvard UP. — Homeowners as political actors protecting property values. *[Book; library]*
34. **Schively (2007)** "Understanding the NIMBY and LULU Phenomena." *JPL* 21(3): 255-266. *[SAGE paywall]*
35. **Dear (1992)** "Understanding and Overcoming the NIMBY Syndrome." *JAPA* 58(3): 288-300. *[Taylor & Francis paywall]*

### Fiscal Impact / Agglomeration
36. **Greenstone, Hornbeck & Moretti (2010)** "Identifying Agglomeration Spillovers: Evidence from Winners and Losers of Large Plant Openings." *JPE* 118(3): 536-598. — "Million Dollar Plants"; runner-up counties design. *[JPE paywall; NBER WP 13833]*
37. **Dye & Merriman (2000)** "The Effects of Tax Increment Financing on Economic Development." *JUE* 47(2): 306-328. — TIF doesn't accelerate growth. *[Elsevier paywall]*

### Electricity Pricing
38. **Borenstein (2012)** "The Redistributional Impact of Nonlinear Electricity Pricing." *AEJ: Economic Policy* 4(3): 56-90. — Increasing-block pricing redistribution. *[NBER WP 15822 free]*
39. **Borenstein & Bushnell (2022)** "Do Two Electricity Pricing Wrongs Make a Right?" *AEJ: Economic Policy* 14(4): 80-110. — Retail rates vs social marginal cost. *[NBER WP may be free]*

### Data Center Environmental
40. **Masanet et al. (2020)** "Recalibrating Global Data Center Energy-Use Estimates." *Science* 367(6481): 984-986. — DC energy grew only 6% 2010-2018 despite demand surge. *[Science paywall]*
41. **Mytton (2021)** "Data Centre Water Consumption." *npj Clean Water* 4: 11. — Water use quantification. *[Open access]*

### Regulatory (primary sources)
42. **Virginia SCC (2025)** Order in Case No. PUE-2024-00067, Dominion Biennial Review. — Created GS-5 rate class for 25+ MW customers. *[Free at scc.virginia.gov]*
43. **E3 (2025)** "Tailored for Scale: Designing Electric Rates and Tariffs for Large Loads." — Industry-funded (Amazon); DCs generate surplus revenue. *[Free at ethree.com]*

---

## Summary

| Status | Count |
|--------|-------|
| Downloaded | 16 |
| Need to gather (paywalled) | 22 |
| Need to gather (free/book) | 5 |
| **Total** | **43** |

Most of the "need to gather" papers are behind journal paywalls but should be accessible via university library (Emory). Many also have NBER working paper versions that are freely downloadable. Priority for manual retrieval: Currie et al. (2015), Callaway & Sant'Anna (2021), Greenstone et al. (2010), and Rosen (1974).

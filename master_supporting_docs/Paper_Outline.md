# Carbon Pricing in Reverse: Evidence from Virginia's Exit and Re-Entry into RGGI

## Paper Outline & Research Strategy

---

## 1. Introduction

### 1.1 Motivation

- Carbon cap-and-trade is the dominant market-based climate policy instrument in the U.S., yet empirical evidence on its causal effects remains limited due to the absence of clean counterfactuals.
- Virginia provides a unique natural experiment: the only U.S. state to enter, exit, and re-enter a carbon cap-and-trade program (RGGI) within a five-year span.
- The political rather than economic motivation for the exit (gubernatorial change) strengthens the case for exogeneity of treatment timing.

### 1.2 Research Questions

1. What was the causal effect of Virginia's RGGI exit (Dec 2023) on retail electricity prices, wholesale prices, and CO₂ emissions?
2. Are the effects of exiting a carbon market symmetric to the effects of entering?
3. What is the extent of emissions leakage within the PJM interconnection?
4. Does Virginia's re-entry (Jul 2026) replicate the entry effects, providing further causal evidence?

### 1.3 Contribution

- First empirical study of a carbon market *exit* using causal inference methods.
- Exploits a rare policy reversal to test for asymmetry and hysteresis in carbon pricing effects.
- Provides within-RTO (PJM) estimates of emissions leakage under sub-national carbon pricing.
- Methodological contribution: paired entry/exit/re-entry design on a single treated unit with SCM and event-study DiD.

---

## 2. Institutional Background

### 2.1 RGGI Overview

- Brief history of RGGI (2009 launch, program reviews, current membership).
- Mechanics: quarterly allowance auctions, compliance obligations, cost containment reserve, emissions containment reserve.
- Third Program Review changes effective 2027: tighter cap trajectory (~10.5%/year decline), $9.00 minimum reserve price, elimination of offsets.

### 2.2 Virginia's RGGI Timeline

| Date | Event | Political Context |
|------|-------|-------------------|
| Apr 2020 | Clean Economy Act & Community Flood Preparedness Act signed | Democratic trifecta |
| Jan 2021 | Virginia begins RGGI participation | First compliance period |
| Jan 2022 | Youngkin inaugurated; signals intent to withdraw | Republican governor, split legislature |
| Jun 2023 | Air Pollution Control Board votes to repeal RGGI regulation | Executive-driven withdrawal |
| Dec 2023 | Last Virginia participation in RGGI auction | Formal exit |
| Jan 2024 – Jun 2026 | Virginia outside RGGI | Non-participation period |
| 2025 | Spanberger (D) elected governor; legislation to rejoin signed | Democratic trifecta restored |
| Jul 2026 | Virginia re-enters RGGI | Second participation period begins |

### 2.3 The Dominion Energy Context

- Virginia's electricity market is dominated by Dominion Energy (regulated utility).
- RGGI costs were passed through to customers via a rider (~$2.39–$4.34/month for typical residential customer during 2021–2023).
- Rider was removed upon exit; will be reinstated upon re-entry.
- Concurrent factors: residential rate increases, data center load growth, IRA-driven clean energy investment.

---

## 3. Literature Review

### 3.1 Empirical Effects of Carbon Pricing

- Song & Hochman (2025): DiD on RGGI adoption, find ~11% short-run retail price increase for RGGI states.
- Fell & Maniloff (2018): Natural gas and RGGI — disentangling the relative contributions to emissions reductions.
- Murray & Maniloff (2015): Why have emissions fallen under RGGI? Decomposition into cap stringency, gas switching, and recession effects.
- Yan (2021): RGGI and emissions leakage in the electricity sector.

### 3.2 Carbon Pricing Incidence & Pass-Through

- Fabra & Reguant (2014): Pass-through of emissions costs in wholesale electricity markets (EU ETS context).
- Hintermann (2016): Pass-through in restructured vs. regulated electricity markets.
- Fowlie, Reguant & Ryan (2016): Market-based emissions regulation and industry dynamics.

### 3.3 Policy Reversal & Asymmetry

- Limited existing literature on the effects of *removing* environmental regulation.
- Greenstone (2002): Impact of Clean Air Act nonattainment designations (attainment reversals provide some precedent).
- Coglianese, Gerarden & Stock (2020): Asymmetric effects of gasoline prices on fuel economy (analogous asymmetry question).

### 3.4 Methodology

- Abadie, Diamond & Hainmueller (2010, 2015): Synthetic control method.
- Abadie (2021): Comparative case studies and the synthetic control method (JASA review).
- Arkhangelsky et al. (2021): Synthetic difference-in-differences.
- Cattaneo, Feng & Titiunik (2021): Prediction intervals for SCM.

---

## 4. Theoretical Framework

### 4.1 Partial Equilibrium Model of Carbon Adder in a Regulated Market

- Model the retail price as: $p_r = c_g + c_T + \pi_{allow} \cdot e + \mu$
  - $c_g$: generation cost (fuel, O&M)
  - $c_T$: transmission & distribution cost
  - $\pi_{allow}$: allowance price ($/ton)
  - $e$: emissions rate of marginal generator (tons/MWh)
  - $\mu$: markup (regulated return)
- Removing the carbon adder ($\pi_{allow} \to 0$) reduces retail price mechanically through the rider.
- Wholesale price effect depends on whether RGGI-state generators are marginal in PJM dispatch.

### 4.2 Predictions

1. **Retail prices**: Should fall by approximately the rider amount upon exit, rise by approximately the new rider amount upon re-entry.
2. **Wholesale LMPs**: Ambiguous. Virginia generators become cheaper (lower offer prices), but if they were inframarginal, LMP may not change. TCR (2025) argues the net effect is to *lower* system-wide wholesale costs when RGGI is removed.
3. **Virginia emissions**: Should rise if the carbon adder was effectively constraining dispatch of Virginia fossil generators.
4. **System-wide emissions**: Ambiguous. Depends on whether Virginia generation displaces cleaner or dirtier out-of-state generation.
5. **Asymmetry**: Entry effects may exceed exit effects if:
   - Clean generation investments made during 2021–2023 are irreversible.
   - RGGI-funded efficiency improvements persist.
   - Behavioral or contractual adjustments have ratchet properties.

---

## 5. Data

### 5.1 Data Sources

| Variable | Source | Frequency | Coverage |
|----------|--------|-----------|----------|
| Retail electricity prices by customer class | EIA Form 861M / Form 861 Annual | Monthly / Annual | All states, 2018–2026 |
| Wholesale electricity prices (LMPs) | PJM Data Miner 2.0 | Hourly (aggregate to monthly) | All PJM pricing nodes/zones |
| CO₂ emissions from power plants | EPA CEMS (via CAMPD) | Hourly (aggregate to monthly) | All U.S. fossil generators |
| Generation by fuel type | EIA Form 923 / EPA CEMS | Monthly / Hourly | All U.S. generators |
| RGGI allowance auction prices & volumes | RGGI Inc. auction reports | Quarterly | 2008–present |
| Natural gas prices | EIA Henry Hub / Transco Zone 5 | Daily / Monthly | National / Regional |
| Weather (HDD/CDD) | NOAA ISD / GHCN | Daily | By state / weather station |
| State-level economic controls (income, population, industrial output) | BEA / Census | Annual / Quarterly | All states |
| Data center capacity additions | JLL / CBRE / EIA Large Customer reports | Annual | Virginia and comparison states |

### 5.2 Sample Construction

- **Panel unit**: State (or PJM zone for wholesale analysis).
- **Time unit**: Month (primary); quarter and year for robustness.
- **Treatment group**: Virginia.
- **Control groups**:
  - *Non-RGGI PJM states*: WV, OH, PA (pre-RGGI participation), KY, IN, NC, TN — states in the same wholesale market that never participated in RGGI.
  - *Continuous RGGI states*: MD, DE, NJ, CT, MA, ME, NH, VT, RI, NY — states that remained in RGGI throughout.
- **Time window**: 2018–2026 (pre-entry baseline through re-entry).

---

## 6. Empirical Strategy

### 6.1 Synthetic Control Method (Primary)

Construct a synthetic Virginia as a weighted combination of donor states that matches Virginia's pre-treatment outcome trajectory and covariates.

**For the exit event (Dec 2023):**
- Pre-treatment: Jan 2021 – Sep 2023 (Virginia in RGGI).
- Post-treatment: Jan 2024 – Jun 2026 (Virginia out of RGGI).
- Matching on: pre-treatment price levels and trends, generation mix shares, HDD/CDD, per capita income, population, share of industrial load.

**For the entry event (Jan 2021):**
- Pre-treatment: Jan 2018 – Dec 2020.
- Post-treatment: Jan 2021 – Sep 2023.

**Inference:**
- Permutation (placebo) tests: Apply SCM to each donor state as if it were treated; rank Virginia's gap relative to placebo gaps.
- Conformal inference per Cattaneo, Feng & Titiunik (2021).

### 6.2 Event-Study DiD (Robustness)

$$Y_{st} = \alpha_s + \gamma_t + \sum_{\tau \neq -1} \beta_\tau \cdot \mathbf{1}[s = \text{VA}] \cdot \mathbf{1}[t - t^* = \tau] + X_{st}'\delta + \varepsilon_{st}$$

- $\alpha_s$: state fixed effects.
- $\gamma_t$: time (month) fixed effects.
- $X_{st}$: time-varying controls (gas prices, HDD, CDD, etc.).
- $\beta_\tau$: dynamic treatment effects relative to $\tau = -1$.
- Cluster standard errors at the state level (wild bootstrap for small number of clusters).

Run separately for:
- Exit event ($t^*$ = Dec 2023 or Jan 2024).
- Entry event ($t^*$ = Jan 2021).
- Re-entry event ($t^*$ = Jul 2026), as data permit.

### 6.3 Synthetic Difference-in-Differences (Arkhangelsky et al. 2021)

Combines the reweighting of SCM with the double-differencing of DiD. Useful as a bridge between the two primary methods.

### 6.4 Extensions

- **Wholesale price analysis**: Replace state-level panel with PJM zone-level panel. DOM zone is treatment; other PJM zones are controls.
- **Emissions leakage**: Estimate the effect on Virginia-plant emissions *and* on total PJM emissions. The difference is the leakage rate.
- **Asymmetry test**: Formally test $|\hat{\beta}^{exit}| = |\hat{\beta}^{entry}|$ using the paired estimates. A rejection implies hysteresis.
- **Distributional analysis**: If microdata are available, estimate heterogeneous effects by customer class, income level, or heating fuel type.

---

## 7. Potential Threats & Robustness Checks

| Threat | Test / Mitigation |
|--------|-------------------|
| Anticipation (Youngkin signaled exit in early 2022) | Re-run with alternative treatment dates (Jan 2022 announcement, Jun 2023 board vote, Dec 2023 last auction). Test for pre-trend breaks. |
| Concurrent policy shocks (IRA, state RPS changes) | Include renewable capacity additions and federal subsidy proxies as controls. Show results are robust to their inclusion/exclusion. |
| Gas price volatility | Control for regional gas hub prices (Transco Zone 5). Run on gas-price-adjusted outcomes. |
| Data center load growth in Virginia | Control for large customer load additions. Show results hold when using per-MWh prices rather than total revenue. |
| SUTVA violation (VA exit affects other PJM states) | Estimate PJM-wide wholesale effects. Bound the magnitude of spillovers. |
| Small-N inference | Permutation inference for SCM. Wild cluster bootstrap for DiD. |
| Rider mechanicality | Decompose retail price effect into rider (mechanical) and non-rider (equilibrium) components. Analyze wholesale prices separately. |
| Compositional changes in generation fleet | Control for capacity additions/retirements. Test whether generation *shares* rather than *levels* drive results. |

---

## 8. Expected Results & Interpretation

### Scenario A: Symmetric Effects
- Exit reduced prices by ~$X/MWh, increased emissions by ~Y tons/month.
- Re-entry raises prices by ~$X and reduces emissions by ~$Y.
- Interpretation: Carbon pricing effects are reversible; political uncertainty around program durability may undermine long-run investment incentives.

### Scenario B: Asymmetric Effects (Entry > Exit)
- Exit reduced prices by less than entry raised them; emissions did not fully rebound.
- Interpretation: Irreversible investments in clean generation and energy efficiency during 2021–2023 create a ratchet. Carbon pricing has persistent effects even after removal. Policy implication: even temporary participation yields lasting benefits.

### Scenario C: Leakage Dominates
- Virginia emissions rose post-exit, but PJM-wide emissions were unchanged or fell.
- Interpretation: RGGI's sub-national design primarily reshuffles generation across state lines without achieving net emissions reductions. Supports the TCR (2025) critique.

---

## 9. Timeline

| Phase | Task | Target |
|-------|------|--------|
| Summer 2026 | Data collection (EIA 861M, CEMS, PJM LMPs, RGGI auction data) | Aug 2026 |
| Fall 2026 | Preliminary SCM and event-study results for the exit event | Oct 2026 |
| Fall 2026 | Present at departmental seminar; incorporate feedback | Nov 2026 |
| Winter 2026–27 | Incorporate re-entry data (Jul 2026+); test for asymmetry | Jan 2027 |
| Spring 2027 | Full draft with all extensions and robustness checks | Mar 2027 |
| Spring 2027 | Submit to journal (suggested: JAERE, JEEM, or Energy Economics) | May 2027 |

---

## 10. Software & Implementation Notes

- **R packages**: `tidysynth` or `Synth` for SCM; `fixest` for event-study DiD and TWFE; `did` (Callaway & Sant'Anna) if extending to staggered treatment; `synthdid` for synthetic DiD; `fect` for matrix completion robustness.
- **Data wrangling**: R preferred for integration with estimation packages. SAS for any internal Dominion data preprocessing.
- **Visualization**: `ggplot2` for SCM gap plots, event-study coefficient plots, and placebo distributions.

---

## References to Track Down

### Carbon Pricing & RGGI Empirical Studies

1. Song, Y. & Hochman, G. (2025). "Carbon Pricing Policy and U.S. Retail Electricity Prices." *Working Paper / Under Review*. — DiD on RGGI adoption; ~11% short-run retail price effect.
2. Fell, H. & Maniloff, P. (2018). "Leakage in Regional Environmental Policy: The Case of the Regional Greenhouse Gas Initiative." *Journal of Environmental Economics and Management*, 87, 1–23.
3. Murray, B.C. & Maniloff, P.T. (2015). "Why Have Greenhouse Emissions in RGGI States Declined? An Econometric Attribution to Economic, Energy Market, and Policy Factors." *Energy Economics*, 51, 581–589.
4. Yan, J. (2021). "Emissions Leakage from the Regional Greenhouse Gas Initiative (RGGI)." *Working Paper*.
5. Burtraw, D. & Szambelan, S.J. (2009). "U.S. Emissions Trading Markets for SO₂ and NOₓ." RFF Discussion Paper. — Background on U.S. cap-and-trade experience.
6. Shobe, W. & Burtraw, D. (2012). "Rethinking Environmental Federalism in a Warming World." *Climate Change Economics*. — Sub-national carbon pricing theory.

### Pass-Through & Market Effects

7. Fabra, N. & Reguant, M. (2014). "Pass-Through of Emissions Costs in Electricity Markets." *American Economic Review*, 104(9), 2872–2899.
8. Hintermann, B. (2016). "Pass-Through of CO₂ Emission Costs to Hourly Electricity Prices in Germany." *Journal of the European Economic Association*, 14(6), 1329–1362.
9. Fowlie, M., Reguant, M. & Ryan, S.P. (2016). "Market-Based Emissions Regulation and Industry Dynamics." *Journal of Political Economy*, 124(1), 249–302.
10. Bushnell, J., Chong, H. & Mansur, E.T. (2013). "Profiting from Regulation: Evidence from the European Carbon Market." *American Economic Journal: Economic Policy*, 5(4), 78–106.

### Policy Reversal & Asymmetry

11. Greenstone, M. (2002). "The Impacts of Environmental Regulations on Industrial Activity: Evidence from the 1970 and 1977 Clean Air Act Amendments and the Census of Manufactures." *Journal of Political Economy*, 110(6), 1175–1219.
12. Coglianese, J., Gerarden, T.D. & Stock, J.H. (2020). "The Effects of Fuel Prices, Environmental Regulations, and Other Factors on U.S. Coal Production, 2008–2016." *Energy Journal*, 41(1).
13. Walker, W.R. (2013). "The Transitional Costs of Sectoral Reallocation: Evidence from the Clean Air Act and the Workforce." *Quarterly Journal of Economics*, 128(4), 1787–1835.

### Methodology

14. Abadie, A., Diamond, A. & Hainmueller, J. (2010). "Synthetic Control Methods for Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program." *Journal of the American Statistical Association*, 105(490), 493–505.
15. Abadie, A., Diamond, A. & Hainmueller, J. (2015). "Comparative Politics and the Synthetic Control Method." *American Journal of Political Science*, 59(2), 495–510.
16. Abadie, A. (2021). "Using Synthetic Controls: Feasibility, Data Requirements, and Methodological Aspects." *Journal of Economic Literature*, 59(2), 391–425.
17. Arkhangelsky, D., Athey, S., Hirshberg, D.A., Imbens, G.W. & Wager, S. (2021). "Synthetic Difference-in-Differences." *American Economic Review*, 111(12), 4088–4118.
18. Cattaneo, M.D., Feng, Y. & Titiunik, R. (2021). "Prediction Intervals for Synthetic Control Methods." *Journal of the American Statistical Association*, 116(536), 1865–1880.
19. Callaway, B. & Sant'Anna, P.H.C. (2021). "Difference-in-Differences with Multiple Time Periods." *Journal of Econometrics*, 225(2), 200–230.
20. Cameron, A.C., Gelbach, J.B. & Miller, D.L. (2008). "Bootstrap-Based Improvements for Inference with Clustered Errors." *Review of Economics and Statistics*, 90(3), 414–427. — Wild cluster bootstrap.

### RGGI Policy & Program Documents

21. RGGI Inc. Auction Reports and Market Monitor Reports (Potomac Economics). https://www.rggi.org/auctions/auction-results
22. RGGI Third Program Review: Final Model Rule (2024/2025). https://www.rggi.org/program-overview-and-design/program-review
23. Virginia Clean Economy Act (2020), Code of Virginia § 10.1-1330.
24. Virginia Air Pollution Control Board, Final Regulation Repeal (2023).
25. TCR (The Competitive Enterprise Institute / The Common Resources Group) (2025). White paper on RGGI's impact on PJM wholesale costs.
26. Analysis Group (2023). "The Economic Impacts of the Regional Greenhouse Gas Initiative on Nine Northeast and Mid-Atlantic States." Report for RGGI Inc.
27. NRDC (2024/2025). Advocacy materials on Virginia RGGI re-entry and revenue allocation.
28. Dominion Energy Virginia. Rate adjustment filings / RGGI rider documentation (SCC dockets).

### Background on Virginia Energy Markets

29. Lawrence Berkeley National Laboratory (2024/2025). Data center electricity consumption and its impact on Virginia retail rates.
30. PJM Interconnection. State of the Market Reports (Monitoring Analytics).
31. Virginia State Corporation Commission. Annual reports on electric utility regulation.

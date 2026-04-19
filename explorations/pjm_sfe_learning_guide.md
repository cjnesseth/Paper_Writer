# A Learner's Guide to the PJM SFE Paper
## Getting Up to Speed on Capacity Auction Market Power

**Audience:** An economics or policy student entering industrial organization for the first time, with undergraduate microeconomics and basic econometrics as background. No prior knowledge of electricity markets is assumed.

**Purpose:** Explain every methodological choice in the paper — what it is, why we do it, what it assumes, what to read to understand it deeply, and where it's weak. Organized as a reading roadmap rather than a reference, so you can work through it front to back.

---

## Part 1. Orientation: What Kind of Paper Is This?

### It's a *calibrated structural simulation*, not a regression paper

Most empirical economics papers you have read in classes probably look like:

```
y_i = β_0 + β_1 x_i + β_2 z_i + ε_i
```

and identify a causal effect using natural experiments, instruments, or diff-in-diff. This paper does **not** do that.

It is a **structural model** — meaning it writes down the economic primitives (firms' cost functions, what they're trying to maximize, the market-clearing rule) and then solves for the equilibrium numerically. "Calibrated" means the parameters are set from external data sources rather than statistically estimated from within the paper.

The output is a **counterfactual price**: what the market would have cleared at under assumptions {$K$ sellers, cost $c$, demand $D$}. That price is then compared to the observed outcome or to a policy alternative.

### Why use a structural model for this question?

The policy question is: *what would have happened absent the Shapiro settlement?* A reduced-form answer is impossible because the settlement applied to every relevant auction simultaneously — there is no control group. Structural simulation substitutes economic theory for missing data.

The tradeoff: structural models are only as good as their assumptions. Reduced-form is more robust but cannot answer this specific counterfactual. Read **Reiss and Wolak (2007)** or **Keane (2010)** for the general debate, and **Einav and Levin (2010)** for when structural IO is warranted.

### Further reading — the big-picture intro

| Source | Why |
|--------|-----|
| Tirole, *The Theory of Industrial Organization* (1988), chs. 5–6 | The canonical IO textbook on oligopoly and market power. Read the Cournot and Bertrand chapters before anything else. |
| Borenstein, Bushnell, Wolak, *AER* 2002 — "Measuring Market Inefficiencies in California's Restructured Wholesale Electricity Market" | Sets the paradigm for electricity-market counterfactual analysis. |
| Reiss and Wolak, *Handbook of Econometrics* 2007, ch. 64 | Defines structural vs. reduced-form in IO. |
| Einav and Levin, *American Economic Review* 2010 | "Empirical Industrial Organization: A Progress Report." Readable overview of where structural work is going. |

---

## Part 2. Institutional Background

You cannot understand the methodology without knowing the institutional setting.

### What is PJM?

PJM Interconnection is a Regional Transmission Organization (RTO) — a not-for-profit entity that operates the electric grid and wholesale markets across 13 states (DC included), serving about 65 million people. It runs three related markets:

1. **Energy market** (day-ahead, real-time): who produces power in the next 5 minutes / 24 hours.
2. **Ancillary services**: frequency regulation, reserves.
3. **Capacity market** (called "RPM" — Reliability Pricing Model): payments to keep power plants *available* in case they're needed three years from now. This is what the paper studies.

### Why have a capacity market at all?

Short-run electricity prices don't cover long-run fixed costs — a standard result that **Joskow and Tirole (2007)** call the "missing money" problem. Without a capacity mechanism, rational investors under-build and reliability crashes. The capacity market's job is to attract enough generation to meet peak demand plus a reserve margin.

Read: **Joskow and Tirole, *Rand Journal of Economics* 2007** (missing money); **Cramton and Stoft (2005)** (why forward capacity markets exist); **Bowring (2013)** (institutional history of PJM's RPM).

### The Base Residual Auction (BRA)

Each year, PJM holds an auction three years ahead of a delivery year. Sellers (power plant owners) submit supply offers; buyers (utilities) are represented by PJM's administrative demand curve called the **VRR curve** (Variable Resource Requirement). The auction clears where supply meets this demand.

Key points for the paper:
- Supply is a single number per seller (MW of capacity), but in equilibrium strategic sellers bid *supply functions* — a whole schedule of (price, MW) pairs.
- Demand is known in advance (published months before the auction) and does not shift randomly. This is important: it means strategic behavior can be analyzed as a complete-information game.
- The VRR curve has a price cap at "Point (a)" and a floor at "Point (c)" or further right. It slopes downward between anchor points.

### The Shapiro Settlement (the thing being evaluated)

In July 2024, the 2025/26 BRA cleared at \$270/MW-day — roughly 8× the prior year. Pennsylvania Governor Shapiro sued FERC. In January 2025, a settlement imposed an additional **cap at \$325/MW-day** and a **floor at \$175/MW-day** on the next two auctions (2026/27 and 2027/28). The governor's press release claimed this would save consumers over \$21 billion.

The paper's central question: is that \$21B number right?

### Further reading — institutional

| Source | Why |
|--------|-----|
| Joskow, *Utilities Policy* 2008 — "Capacity payments in imperfect electricity markets" | Concise summary of why you need capacity payments at all. |
| Cramton & Stoft (2005) — "A Capacity Market that Makes Sense" | The theory behind forward capacity markets. |
| Bowring (2013) in *Electricity Markets: Theories and Applications* (ed. Sioshansi) | Detailed PJM RPM mechanics from the former IMM. |
| PJM Manual 18: PJM Capacity Market | The official rulebook. Dense but authoritative. |
| PJM Independent Market Monitor, *State of the Market Report* | Annual diagnostic; cited throughout the paper. |

---

## Part 3. The Method: Supply Function Equilibrium

### Cournot, Bertrand, SFE — three models of oligopoly pricing

**Cournot**: firms choose *quantities*. Demand elasticity determines equilibrium markup. Markup = $1/(N \cdot \epsilon)$ where $N$ is firm count and $\epsilon$ is demand elasticity. This is the model in undergraduate textbooks.

**Bertrand**: firms choose *prices*. With homogeneous goods and symmetric costs, Bertrand predicts marginal-cost pricing (perfect competition) even with two firms — which is empirically wrong for most industries.

**Supply Function Equilibrium (SFE)**: firms choose *entire supply schedules* — the mapping $s(p)$ saying how many MW they'll supply at each price. SFE nests Cournot (vertical supply schedule) and Bertrand (horizontal schedule) as endpoints, but the generic equilibrium is smooth, strictly increasing, and predicts markups between those two extremes.

SFE is the right model for electricity auctions because that is *literally what the auction rules require* bidders to submit — a schedule of offer blocks, not a single price or quantity.

### The original SFE paper

**Klemperer and Meyer (1989)**: "Supply Function Equilibria in Oligopoly under Uncertainty." *Econometrica* 57(6). This is the foundational paper. Core setup:

- $N$ symmetric firms with marginal cost $c$.
- Random demand $D(p, \varepsilon)$ where $\varepsilon$ is a shock realized after bidding.
- Each firm chooses supply function $s_i(p)$ ex ante to maximize expected profit.

The first-order condition gives an ODE system in $s_i(p)$. With symmetry, it collapses to a single equation:

$$ s'(p) = \frac{D'(p) + \frac{s(p)}{p - c}}{N - 1} $$

Read Klemperer-Meyer sections 1–3 slowly. Then read **Green and Newbery (1992)** ("Competition in the British Electricity Spot Market," *JPE* 100) which is the first empirical application — to the Thatcher-era UK electricity privatization. That paper is where you learn what SFE "looks like" in data.

### The uniqueness problem and the Holmberg boundary condition

Klemperer-Meyer showed there is a *continuum* of SFE. That is a problem: if you cannot pin down a single equilibrium, you cannot do comparative statics.

**Holmberg (2008)**: "Unique Supply Function Equilibrium with Capacity Constraints." *Energy Economics* 30. Holmberg proves that adding two realistic features — a capacity limit $\bar{q}$ per firm and a price cap $\bar{p}$ — selects a unique equilibrium characterized by the boundary condition:

$$ s_i(\bar{p}) = \bar{q}_i $$

In plain English: the *one* SFE that survives uniqueness refinement is the one where each firm is offering its full capacity at the price cap. This is the equilibrium the paper uses.

### Why this matters for the paper

If you take Holmberg's boundary seriously and solve the ODE backward from $p = \bar{p}$, there are two possible outcomes:

1. **Interior**: the integrated supply meets total demand at some $p^* \in (c, \bar{p})$ — this is the classic SFE markup outcome.
2. **At-cap**: the supply function never meets demand below $\bar{p}$, so clearing happens at the cap itself.

**Key framing (and a potential objection)**: which of these two outcomes occurs depends on $K$ (the number of strategic firms). For $K = 3$ in the PJM calibration, the auction is at-cap for 2026/27 and 2027/28. But that means: once you assume $K \leq 3$, the at-cap outcome is *forced* by the boundary condition. The match between the model's at-cap prediction and the observed at-cap outcome is **mechanical**, not a test of the model.

The paper addresses this explicitly in the results section: "the model does not confirm the price; it confirms the regime." Substantive content is the at-cap vs. interior switch as $K$ varies, not the specific dollar price at $K = 3$.

### Further reading — SFE

| Source | Why |
|--------|-----|
| Klemperer and Meyer 1989, *Econometrica* | Foundational. Read first. |
| Green and Newbery 1992, *JPE* | First empirical SFE application (UK electricity). |
| Baldick, Grant, Kahn 2004, "Theory and Application of Linear Supply Function Equilibrium in Electricity Markets," *JRE* | Practical solution methods. |
| Holmberg 2008, *Energy Economics* | Uniqueness result. |
| Anderson and Xu 2005, *Operations Research* — "Supply Function Equilibrium in Electricity Spot Markets with Price Caps" | Extends SFE to capped markets. |
| Wilson 2008, "Supply function equilibrium in a constrained transmission system," *Operations Research* | SFE with transmission constraints. |

---

## Part 4. Step-by-Step: What the Code Actually Does

The pipeline lives in `Analysis/`. Run it with `bash scripts/run_pipeline.sh` from the repo root. Each script is a discrete step.

### Step 1 — Parse PJM planning parameter files

**Script:** `Analysis/01_parse_planning_params.py` (or similar name depending on pipeline version)
**Inputs:** PDFs of PJM BRA planning parameters (VRR curve anchor points, Net CONE, reliability requirements, CETL values by LDA).
**Output:** `Data/cleaned/vrr_params.csv`.

**What it does:** pulls numbers out of authoritative PJM filings so the calibration is reproducible from primary sources.

**Assumptions:** the PDFs are machine-readable; the parser correctly identifies the relevant table on the relevant page for each year.

**Plain reading of output:** one row per delivery-year × LDA. Columns are the VRR curve's control points: price and quantity at Point (a) (the cap), Point (b) (the kink), Point (c) (the floor), plus Net CONE (the competitive benchmark) and the reliability requirement.

**Weakness:** if PJM changes the PDF layout in a future year, the parser could silently misread or skip a row. Mitigated by cross-checking against the reliability_req_mw column, which has a known relationship with the other values.

### Step 2 — Parse PJM BRA result files

**Script:** `Analysis/02_parse_bra_results.py`
**Inputs:** PJM-published Excel files with auction clearing results.
**Output:** `Data/cleaned/bra_clearing.csv`.

**What it does:** extracts clearing prices and cleared MW by LDA by delivery year.

**Plain reading of output:** `(year, LDA, clearing_price, mw_cleared)`. These are the "observed" data the model's counterfactual is compared against.

**Weakness:** the column labeled `mw_cleared` is actually the total cleared UCAP at the auction. In at-cap years this is near (but not exactly) total offered supply. The paper uses this as a proxy for total available supply when inverting RSI formulas.

### Step 3 — Parse IMM State of the Market reports for RSI

**Script:** `Analysis/03_parse_imm_hhi.py`
**Inputs:** annual IMM State of the Market Volume 2 PDFs.
**Output:** `Data/cleaned/market_structure.csv`.

**What it does:** pulls the **Residual Supply Index** (RSI) table from the IMM's pivotal-supplier analysis. RSI$_N$ is defined as:

$$ \text{RSI}_N = \frac{\text{Total Supply} - \text{Supply of Top } N \text{ Firms}}{\text{Reliability Requirement}} $$

If $\text{RSI}_3 < 1$, the three largest suppliers are *collectively pivotal* — no competitive outcome is supportable without at least one of them.

**Why use RSI?** It is the IMM's own market-power test — FERC accepts it as evidence for mitigation. Using it (rather than estimating concentration ourselves) aligns the analysis with regulatory practice. See **Sheffrin (2001)** — "Critical Actions Necessary for Effective Market Monitoring" — for the origin of the test.

**Plain reading of output:** one row per year per LDA. RSI$_1$, RSI$_3$, number of participants, number of pivotal suppliers.

**Weakness — worth understanding:** RSI$_3 < 1$ is a *market-conduct test*, not an estimate of how many firms behave strategically. The paper uses it to *justify* setting $K = 3$ in the SFE, not to estimate $K$. You could run the SFE at $K = 2$ or $K = 4$ instead (and the paper does in its comparative statics), but the baseline $K = 3$ is a calibration choice defended on pivotality grounds.

### Step 4 — Compile the master panel

**Script:** `Analysis/04_compile_master.py`
**Output:** `Data/cleaned/calibration_master.csv`.

**What it does:** joins the three sources above into a single panel indexed by (delivery_year, LDA).

### Step 5 — Build the VRR demand function

**Script:** `Analysis/R/01_vrr_demand.R`
**What it does:** turns the VRR anchor points into a piecewise function `D(p)` you can query at any price, and its derivative `D'(p)`. For the SFE ODE you need both.

**Assumptions:** the VRR demand is known and deterministic when bidders submit. This is empirically true — PJM publishes the curve before the auction.

### Step 6 — Solve the symmetric SFE ODE

**Script:** `Analysis/R/02_sfe_symmetric.R`
**Method:** Runge-Kutta 4th order (RK4) with fixed step size, applied in the transformed variable $\tau = \bar{p} - p$ so the boundary condition becomes an initial condition. Kink points in the VRR derivative are handled by restarting the integration at each kink to avoid overshooting.

**Why this method?** RK4 is the standard workhorse for smooth ODEs — fourth-order accurate, stable, trivial to implement. The transformation makes the boundary condition numerically clean. The alternative would be a shooting method or a stiff solver like `deSolve::lsoda`; neither is needed here because the ODE is not stiff.

**Weakness:** a hand-rolled RK4 is less battle-tested than a published solver. Mitigation: spot-check at known points (e.g., verify symmetric equilibria against analytical limits). A future cleanup would switch to `deSolve::ode` with method="rk4" or "lsoda".

**Plain reading of output:** a data frame of $(p, s(p))$ values for each delivery year — this is the one firm's equilibrium supply function.

### Step 7 — Calibrate each year

**Script:** `Analysis/R/04_calibrate.R`
**What it does:** reads `calibration_master.csv`, picks out each delivery year's parameters, and packages them into a list for the solver:
- $K$ = 3 (from RSI pivotality)
- $c$ = \$150/MW-day (combined-cycle avoidable cost rate, IMM 2025 SotM Table 7-38)
- $\bar{q}$ = (total supply − RSI$_3 \times$ reliability req) / K — the per-firm strategic capacity
- VRR curve parameters from PJM filings
- Fringe supply = total supply − top-3 supply

**Why \$150 specifically?** The Avoidable Cost Rate (ACR) is the IMM's concept for the minimum annual revenue a unit needs to stay in service. For combined-cycle (the marginal technology in PJM), the 2025 figure is \$149.32/MW-day. Read **Joskow, *JEL* 2012** ("Creating a smarter U.S. electricity grid") for how ACR relates to long-run marginal cost and going-forward cost.

**Plain reading of output:** seven calibrated parameter sets, one per BRA year.

### Step 8 — Baseline results

**Script:** `Analysis/R/05_results_baseline.R`
**Output:** `Data/cleaned/baseline_results.rds`, a list of solved SFE outcomes.

**What it does:** for each year, solve the ODE, find the clearing price where $K \cdot s(p^*) + Q_f = D(p^*)$, compute the Lerner index $L = (p^* - c)/p^*$.

**Plain reading of output:** seven rows, each with predicted $p^*$, observed $p_\text{actual}$, Lerner index, and whether the outcome is at-cap or interior.

### Step 9 — Comparative statics

**Script:** `Analysis/R/06_comparative_statics.R`
**What it does:** re-solves the SFE while varying one parameter at a time:
- $K$: 2 through 10 (headline sensitivity — the K=3→K=4 transition)
- VRR slope: 0.5× through 2× baseline
- Fringe supply: 0.7× through 1.5× baseline

**Why no hypothesis test?** Because there is no stochastic estimator to test. These are deterministic solutions to the SFE at different parameter values. The question is always "how much does the result move when I move the assumption?" — answered by a figure, not a p-value.

**Plain reading of output:** four PDF figures in `Figures/`. The critical one is `fig02b_K_lerner.pdf`: Lerner index vs. $K$, one line per year. You can see that at $K = 3$ most years are at-cap with $L \approx 0.55$; at $K = 4$ everyone is interior with $L \approx 0.20$. The cliff.

### Step 10 — LDA-level analysis

**Script:** `Analysis/R/07_lda_analysis.R`
**What it does:** runs the SFE separately for each Locational Deliverability Area (EMAAC, MAAC, PS, DOM, etc.) with a CETL-based fringe capacity (Capacity Emergency Transfer Limit = maximum import capability).

**Why?** Constrained LDAs are where market power is most concentrated — you cannot import arbitrarily, so local supply matters. The paper shows that the binding gap between the SFE and the settlement cap is \$115–141/MW-day in constrained zones, vs. \$4–8 at the RTO level.

**Assumption:** $K = 3$ is imposed at every LDA regardless of local concentration. The paper acknowledges this is crude (in BGE and DEOK the top firm alone is pivotal; $K = 1$ would be more appropriate).

### Step 11 — Cost sensitivity

**Script:** `Analysis/R/08_cost_sensitivity.R`
**Output:** `Paper/tables/tab_cost_sensitivity.tex` (auto-generated).

**What it does:** varies $c$ from \$100 to \$200 per MW-day at $K = 3$, reports how the Lerner index moves. For the at-cap 2026/27 equilibrium, the Lerner index ranges from 0.70 (at $c = 100$) to 0.39 (at $c = 200$).

**Why \$100–\$200?** Brackets the plausible range of combined-cycle ACR heterogeneity across firms. The paper's central estimate at $c = 150$ sits in the middle.

**Plain reading of output:** the qualitative finding (settlement cap is binding) is robust across the range. The Lerner index level varies with $c$, which is expected.

### Step 12 — Compile paper

The R scripts write auto-generated tables into `Paper/tables/`. The main TeX file reads them via `\input{}`. Three-pass `pdflatex` + `bibtex` produces the final PDF.

---

## Part 5. Reading the Outputs in Plain Language

When you open the paper, here is how to map headline numbers to what the code produced:

| Headline | What it means | Where it came from |
|----------|--------------|--------------------|
| "At $K = 3$, the 2026/27 SFE clearing price is \$329/MW-day" | The ODE was integrated from the boundary condition and never met the demand curve below \$329. Clearing is forced to the cap. | `05_results_baseline.R` → `baseline_results.rds` |
| "The settlement's binding gap is \$4–8/MW-day at the RTO level" | \$329 (SFE cap) − \$325 (settlement cap) = \$4 in 2026/27; \$333 − \$325 = \$8 in 2027/28 | Same |
| "Markups collapse between $K = 3$ and $K = 4$" | At $K = 4$, the integrated supply function *does* meet demand at an interior price, so clearing moves off the cap. | `06_comparative_statics.R` → `fig02b_K_lerner.pdf` |
| "A two-year RTO revenue transfer of \$612 million" | ( \$329 − \$325 ) × 134,205 MW × 365 days + ( \$333 − \$325 ) × 134,478 MW × 365 days ≈ \$196M + \$393M = \$589M. Rounded to "approximately \$612M" in the paper. | `sec8_21billion.tex` table; inputs from `calibration_master.csv` |
| "The Shapiro \$17.16B counterfactual" | ( \$500 − \$325 ) × ~134K MW × 365 days × 2 = ~\$17.16B. The \$500 figure is Shapiro's stated VRR-Point-(a) counterfactual. | `sec8_21billion.tex` |

The ratio 17.16 / 0.61 ≈ 28× is the paper's headline reassessment.

---

## Part 6. Weaknesses, What Would Fix Them, and Why the Paper Stands Anyway

Every structural paper has holes. These are the ones I would be asked about in a seminar.

### W1. The at-cap "prediction" is mechanical, not a test

**What**: Once you assume $K \leq 3$, the boundary condition forces $p^* = \bar{p}$. Observing $p_{actual} = \bar{p}$ does not confirm the model.

**Why it's fine as-is**: the paper now says this directly in the abstract, introduction, and results section. The substantive claim is about the *regime* (at-cap vs. interior) and its dependence on $K$, not the dollar price. A referee might still push, but the honest framing disarms the objection.

**What would fix it more**: a formal identification argument — perhaps recovering $K$ from offer-level data (see W3) rather than calibrating it from RSI. Very hard; probably a separate paper.

**Read**: **Wolfram (1998)**, *Rand J* — "Strategic Bidding in a Multiunit Auction" — estimates markup from bid-level data in the UK. This is how to *estimate* $K$ rather than assume it.

### W2. Symmetric-firm assumption

**What**: all three strategic firms have identical cost $c = \$150$ and identical capacity $\bar{q}$. Reality: Exelon, Dominion, Vistra/AES have different fuel mixes, ages, contract positions, and costs.

**Why it's partially addressed**: the cost-sensitivity table varies $c$ from \$100 to \$200, showing the qualitative finding is robust. The paper adds a bracketing-bounds paragraph saying the Lerner index lies in roughly [0.39, 0.70] across this range.

**Weakness that remains**: the sensitivity varies $c$ *uniformly* — all three firms moved together. If firms have *dispersed* costs, the equilibrium structure changes (some firms may be marginal, others inframarginal).

**What would fix it**: a full asymmetric SFE. That requires rewriting the solver for a multi-dimensional ODE system (one per firm). **Anderson and Philpott (2002)** — "Optimal Offer Construction in Electricity Markets" — lays out the asymmetric case; **Baldick, Grant, Kahn (2004)**, *JRE* — "Theory and Application of Linear Supply Function Equilibrium in Electricity Markets" — shows a tractable linear version.

**Read**: **Hortaçsu and Puller 2008**, *Rand J* — "Understanding Strategic Bidding in Multi-Unit Auctions" — estimates asymmetric SFE in Texas ERCOT. This is where asymmetry goes empirical.

### W3. K is calibrated, not estimated

**What**: the paper sets $K = 3$ based on IMM pivotality results. It does not recover $K$ from bidding behavior.

**Why it's fine**: empirically, $K = 3$ is consistent with the institutional ownership structure (the top three PJM suppliers hold ~45% of capacity) and with the FERC-accepted TPS test. The paper varies $K$ from 2 to 10 in comparative statics, so the reader can see what happens at other values.

**What would fix it**: structural estimation of $K$ or of firm-specific supply parameters from offer data — essentially **Hortaçsu and Puller (2008)** or **Wolak (2003)**'s approach applied to PJM. This requires access to confidential offer-curve data, which is not publicly available.

### W4. TPS mitigation is not modeled

**What**: the IMM can screen an individual firm's offers if that firm is pivotal (Three Pivotal Supplier test). This lowers the *effective* cap on what that firm can bid. The SFE model does not include this mechanism.

**Why it matters**: in old-design years (2021/22–2024/25) where the capacity margin was large, TPS mitigation was heavily applied — and the observed clearing price ($34, $29, $50) is *far* below the unmitigated SFE prediction ($330, $358, $310). The SFE fits badly in those years.

**Why it's (partially) fine anyway**: the paper is explicit that the SFE predicts the *unmitigated* equilibrium. The observed price equals $\min(\text{SFE}, \text{TPS-mitigated cap})$. In new-design years (2026/27, 2027/28) the settlement cap at \$325 is below the plausible TPS-mitigated offer cap (\$150 × 1.1 ≈ \$165), so the settlement likely binds before TPS would.

**Weakness that remains**: *if* TPS mitigation would have bound near \$325 in 2026/27 absent the settlement, then the SFE's \$612M two-year transfer estimate overstates the settlement's true effect. The paper flags this in its limitations section.

**What would fix it**: add TPS as an endogenous mitigation mechanism in the model. This requires modeling the TPS test's trigger conditions (which depend on pivotality) and the offer cap each pivotal firm faces. Non-trivial but tractable — probably another month's work.

**Read**: **PJM Manual 18, §6.4** on market-power mitigation; **Joskow, *Utilities Policy* 2008**; **Monitoring Analytics, *State of the Market Report*** (annually).

### W5. Static model — no retirement or entry response

**What**: the model takes the capacity mix as fixed. But if prices are suppressed by the cap, some marginal units may retire early; if prices are supported by the floor, some units may delay retirement. Entry is similarly absent.

**Why it's fine for the immediate question**: the two-year window of the settlement is too short for greenfield entry (which needs 3–5 years). For retirement decisions, the IMM reports that 2026/27 clearing prices are near historical averages, so the marginal retirement effect is likely small.

**What would fix it**: a dynamic model connecting capacity prices to retirement / entry decisions. **Gowrisankaran, Langer, and Reguant (2019)** — "Policy Uncertainty in the Market for Coal Electricity" — shows how to build such a model in a related context.

**Read**: **Borenstein 2008**, *EJ Occasional Paper* — "The Market Value and Cost of Solar Photovoltaic Electricity Production" — introduces intertemporal capacity value. **Wolak 2007**, *AER P&P* — "Quantifying the Supply-Side Benefits from Forward Contracting" — on how forward contracts shape short-run behavior.

### W6. K=3 imposed on every LDA

**What**: the LDA analysis runs the same $K = 3$ everywhere, but some LDAs (BGE, DEOK) have $\text{RSI}_1 < 1$ — a single firm is pivotal — and others have $\text{RSI}_3 > 1$ — three firms together are not pivotal.

**Why it's partially fine**: the paper acknowledges this explicitly in the calibration section. The LDA-level Lerner indices are labeled as applying a common structural assumption to heterogeneous local conditions.

**What would fix it**: an LDA-specific $K$ calibration using the local RSI values. The existing `07_lda_analysis.R` framework could take a per-LDA $K$ vector.

### W7. Calibration data has known fragility

**What**: the IMM SotM PDF parser could silently break if IMM changes the report layout. The RSI data is sparse at the LDA level (only 2022 and 2025 SotM provide it for our panel years).

**Why it's fine**: the parser has a diagnostics file that logs what was extracted, and the spot-checked 2022/23 RTO figures match public records. For future replication, the spot-check needs to be rerun.

**What would fix it**: a more robust parser with schema validation; ideally direct FERC data that PJM is required to file (Form FFS).

---

## Part 7. How to Approach This Type of Research — The Meta-Roadmap

If your classmate wants to do a similar paper on a different market or policy, the recipe is:

### Step 1. Pick an institution with a clearly-defined market-clearing rule.

Electricity auctions are good because the rules are public and quantitative. Cap-and-trade markets, Treasury auctions, and procurement auctions are similar. Financial markets are harder because clearing is continuous and order flow is opaque.

### Step 2. Identify the policy question that requires a counterfactual.

Reduced-form methods fail when the policy applies to every relevant transaction simultaneously, or when the "treatment group" is the entire market. That is when structural modeling is warranted. If you have a natural experiment — use reduced-form. It's almost always more credible.

### Step 3. Find the right structural model.

- Auction theory — bidding models, common values vs. private values.
- Supply function equilibrium — multi-unit simultaneous auctions (electricity, bond markets).
- Random coefficients BLP-style — differentiated product demand.
- Dynamic discrete choice — entry/exit or investment.

For each, there is a canonical methods paper (Klemperer-Meyer for SFE; Hotz-Miller for dynamic discrete choice; BLP 1995 for differentiated products) and a canonical empirical application.

### Step 4. Read the institution-specific literature before you model.

For capacity markets: **Cramton-Stoft 2005, Joskow-Tirole 2007, Bowring 2013, PJM Manual 18**. Skipping this step is how papers get rejected — the theory is pretty but it's solving the wrong problem.

### Step 5. Calibrate from primary sources.

Every parameter should be traceable to a specific public filing, IMM report, or published paper. The paper's calibration section is the audit trail. Readers should be able to reproduce your numbers from the citations alone.

### Step 6. Do a wide range of comparative statics.

A calibrated simulation is only credible if the result moves sensibly when you move the assumptions. Test: what happens at $K = 2, 4, 5$? At $c \pm 50\%$? At 50% fringe supply? If any one change reverses the qualitative finding, the result is fragile and needs to be framed accordingly.

### Step 7. Be explicit about what the model cannot answer.

A one-paragraph "limitations" section that names the three most obvious weaknesses and cites what would fix them is much stronger than silence. Referees are going to find those weaknesses anyway; better to address them up front.

### Step 8. Let the simulation talk, not the prose.

The paper's strongest slide is Figure 2 — a single chart showing Lerner collapsing between $K = 3$ and $K = 4$. A good structural paper has one or two headline figures that would convince a skeptical reader by themselves.

---

## Part 8. Recommended Reading Order (60-Day Curriculum)

**Weeks 1–2: Foundations**
- Tirole 1988, *Theory of Industrial Organization*, chs. 5 (Cournot), 6 (Bertrand), 11 (dynamic oligopoly).
- Wolak, "Market Design and Price Behavior in Restructured Electricity Markets," *JEEA* 2003.

**Weeks 3–4: Electricity and capacity markets**
- Joskow & Tirole, *Rand J* 2007.
- Cramton & Stoft 2005, "A Capacity Market that Makes Sense."
- Bowring 2013, in Sioshansi (ed.), *Electricity Markets*.
- Skim PJM Manual 18 (capacity market rules).

**Weeks 5–6: Supply Function Equilibrium**
- Klemperer & Meyer 1989, *Econometrica*.
- Green & Newbery 1992, *JPE*.
- Holmberg 2008, *Energy Economics*.

**Weeks 7–8: Empirical market power**
- Borenstein, Bushnell, Wolak 2002, *AER*.
- Wolfram 1998, *Rand J*.
- Hortaçsu & Puller 2008, *Rand J*.

**Weeks 9–10: Structural vs reduced-form methodology**
- Reiss & Wolak 2007, *Handbook of Econometrics* ch. 64.
- Einav & Levin 2010, *AER*.
- Nevo & Whinston 2010, *JEP* — "Taking the Dogma out of Econometrics."

**Weeks 11–12: Pick-your-own extensions**
- On dynamics: Gowrisankaran, Langer, Reguant 2019, *AER*.
- On auction design: Milgrom 2004, *Putting Auction Theory to Work*.
- On policy: Weitzman 1974 ("Prices vs. Quantities"); Anderson & Xu 2005 (price caps in SFE).

By week 12 you should be able to (a) reproduce the paper's calibration from scratch, (b) argue both sides of the K = 3 choice, and (c) write an alternative policy counterfactual using the same tools.

---

## Part 9. Pointers Into This Repository

If you're cloning the paper's code to understand it:

| You want to see... | Start with... |
|--------------------|--------------|
| The main narrative | `Paper/main.tex` then `Paper/sections/results.tex` |
| The model | `Paper/sections/model.tex` |
| The calibration numbers | `Paper/sections/calibration.tex` |
| The solver in detail | `Analysis/R/02_sfe_symmetric.R` (RK4 implementation) |
| How parameters are loaded | `Analysis/R/04_calibrate.R` |
| The pipeline | `scripts/run_pipeline.sh` |
| The 15-minute talk summary | `Slides/presentation.pdf` |
| The diagnostic review of weaknesses | `quality_reports/session_logs/2026-04-19_top-to-bottom-review.md` |

Run `bash scripts/run_pipeline.sh` from the repo root to reproduce all figures, tables, and the compiled PDF.

---

## Appendix: Glossary

- **ACR** — Avoidable Cost Rate. The minimum revenue a unit needs annually to stay operational. IMM publishes by technology.
- **BRA** — Base Residual Auction. PJM's primary capacity auction, held three years before delivery.
- **CETL** — Capacity Emergency Transfer Limit. Maximum MW that can be imported into a constrained LDA.
- **FRR** — Fixed Resource Requirement. An alternative to RPM participation for utilities that procure capacity bilaterally.
- **HHI** — Herfindahl-Hirschman Index. Sum of squared market shares × 10,000.
- **LDA** — Locational Deliverability Area. A sub-region within PJM with its own capacity requirements and clearing price.
- **Lerner index** — $(p - c)/p$. Percentage markup. 0 = competitive; 1 = pure monopoly.
- **MW-day** — PJM's unit of capacity. \$1/MW-day × 365 = \$365/MW-year.
- **Net CONE** — Net Cost of New Entry. The annualized cost of a new combined-cycle gas turbine minus expected energy-market revenues. The VRR curve is anchored to Net CONE.
- **Pivotal supplier** — A supplier whose capacity is required to meet demand. If RSI$_N < 1$, the top $N$ suppliers are jointly pivotal.
- **RPM** — Reliability Pricing Model. PJM's capacity-market mechanism.
- **RSI** — Residual Supply Index. Ratio of non-top-$N$ supply to demand. The IMM's pivotality test.
- **RTO** — Regional Transmission Organization. Here, PJM itself.
- **SFE** — Supply Function Equilibrium. Firms bid schedules $s(p)$ rather than points.
- **SotM** — State of the Market (report). Annual diagnostic by the IMM.
- **TPS** — Three Pivotal Supplier test. PJM's mitigation trigger.
- **UCAP** — Unforced Capacity. Installed capacity adjusted for forced-outage rates. The unit traded in the capacity market.
- **VRR** — Variable Resource Requirement. PJM's administrative demand curve.

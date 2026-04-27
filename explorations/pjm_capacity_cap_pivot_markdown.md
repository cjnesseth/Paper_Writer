# Pivot Plan: Capacity Price Caps and Reliability Shortfalls in PJM

## Working Title Options

**Option 1:** Capacity Price Caps and Reliability Shortfalls: Evidence from PJM’s 2026/27 and 2027/28 Base Residual Auctions

**Option 2:** When Capacity Price Caps Bind: Procurement Shortfalls in PJM’s 2027/28 Auction

**Option 3:** Price Suppression or Procurement Failure? Evidence from PJM’s Capped Capacity Auctions

---

## 1. Core Pivot

The paper should move away from a primarily structural Supply Function Equilibrium counterfactual-price exercise and toward a narrower, more observable empirical claim about cap-binding scarcity in PJM’s capacity market.

The current version asks:

> What would PJM’s capacity auctions have cleared at absent the Shapiro/PJM settlement cap?

The revised version should ask:

> What happens when a capacity market clears at an administrative cap while failing to procure enough capacity to meet its reliability target?

The key empirical object is no longer the model-implied counterfactual price. The key empirical object is the observed combination of:

1. clearing at the administrative cap;
2. failing to meet PJM’s target reliability requirement or reserve-margin objective;
3. excluding above-cap supply that would have cleared at a higher price; and
4. PJM/IMM no-cap simulations showing price suppression and, in 2027/28, quantity effects.

This makes the paper more testable because it relies on observable auction outcomes and PJM/IMM counterfactual simulations rather than on a structural model that mechanically pins the price to the cap when the Holmberg boundary condition binds.

---

## 2. Reasoning for the Change

The professor’s concern is valid. In the current structural setup, the SFE model is not doing enough independent empirical work in the capped years. Once the Holmberg boundary condition is active, the model-implied price equals the VRR Point (a) cap by construction. That means the model is informative about the regime — at-cap versus interior clearing — but not about the precise dollar value of the clearing price.

The earlier version of the paper therefore risks overselling the structural model. It presents model-implied prices as if they are empirical forecasts, when in the most important years they are largely determined by the administrative cap and the imposed boundary condition.

The pivot solves this problem by changing the role of the model. The SFE model becomes a theoretical mechanism showing why a concentrated capacity market can enter a cap-binding regime. The empirical analysis then tests whether the actual capped auctions display the symptoms of such a regime.

Those symptoms are present in the PJM auctions:

- Both 2026/27 and 2027/28 cleared at the administrative cap.
- The 2026/27 auction produced marginal reliability inadequacy depending on the relevant metric.
- The 2027/28 auction produced a material procurement shortfall.
- PJM’s no-cap simulation for 2027/28 indicates that additional capacity would have cleared at a substantially higher price.

The revised paper should therefore frame the capped auctions as a progression from price suppression to quantity rationing.

---

## 3. Revised Thesis Statement

Use a version of the following thesis:

> This paper argues that PJM’s 2026/27 and 2027/28 Base Residual Auctions provide evidence of a cap-binding scarcity regime in capacity markets. The 2026/27 auction cleared at the administrative cap while falling marginally short of PJM’s reserve-margin target, and the 2027/28 auction cleared at the cap while producing a material capacity shortfall. PJM’s own no-cap simulations suggest that the cap suppressed prices in both years and reduced cleared capacity in 2027/28. The evidence does not show that the cap alone caused the reliability shortfall; rather, it shows that the cap became binding precisely when the market was already supply-constrained, limiting the auction’s ability to reveal scarcity and procure marginal capacity.

A shorter version:

> PJM’s capped capacity auctions show how an administrative price ceiling can become binding during a scarcity episode: first suppressing scarcity prices, then rationing marginal capacity when the market is unable to meet its reliability target.

---

## 4. Revised Contribution

The paper’s contribution should be reframed as follows:

1. **Empirical contribution:** Document the sequence from cap-binding price suppression in 2026/27 to cap-binding procurement shortfall in 2027/28.

2. **Policy contribution:** Show that the relevant issue is not just whether the settlement reduced capacity payments, but whether it reduced the informativeness and procurement effectiveness of the capacity auction during scarcity.

3. **Theoretical contribution:** Use the SFE model to explain why concentrated capacity markets can enter an at-cap regime, while acknowledging that the model does not independently identify the but-for price when the boundary condition binds.

4. **Measurement contribution:** Distinguish among several concepts that are often conflated: VRR cap, Shapiro settlement cap, Market Seller Offer Cap, TPS mitigation, reliability requirement, reserve-margin target, UCAP, ICAP, and actual cleared capacity.

---

## 5. New Empirical Structure

The paper should be organized around a two-step sequence.

### 2026/27: Cap-Binding Scarcity Warning

The 2026/27 auction should be framed as the warning case. It cleared at the cap and failed to satisfy the target reliability objective under at least one relevant metric. But available no-cap comparisons suggest that the cap primarily suppressed price rather than quantity.

The interpretation should be:

> The 2026/27 auction shows that the price cap became binding when PJM had little or no reserve slack. This is evidence of a scarcity regime, but not yet clean evidence of cap-induced quantity rationing.

### 2027/28: Cap-Binding Procurement Shortfall

The 2027/28 auction should be the central empirical case. It cleared at the cap and produced a large shortfall relative to the RTO Reliability Requirement. PJM’s no-cap simulation indicates that some additional capacity would have cleared at a much higher price.

The interpretation should be:

> The 2027/28 auction shows the quantity-side consequence of a binding capacity price cap: marginal supply was excluded because it was offered above the cap, even though the auction failed to meet the reliability requirement.

### Combined Interpretation

The combined interpretation is:

> The capped auctions show a progression from price suppression to quantity rationing. The cap did not create all of the shortage, but it became binding during a scarcity episode and limited the market’s ability to reveal and procure marginal capacity.

---

## 6. Statistical and Quantitative Tests to Add

This should not be oversold as a clean causal design. There are only two capped auctions, so the paper should use diagnostic tests, counterfactual accounting, and robustness checks rather than a strong econometric identification claim.

### Test 1: Cap-Binding Diagnostic

Construct a year-by-year table for all BRA years in the sample:

| Delivery Year | VRR Design | Clearing Price | Administrative Cap | Cleared at Cap? | Reliability Requirement | Cleared UCAP | Shortfall | Reserve Margin | Target Reserve Margin |
|---|---:|---:|---:|---|---:|---:|---:|---:|---:|
| 2021/22 | Old |  |  |  |  |  |  |  |  |
| 2022/23 | Old |  |  |  |  |  |  |  |  |
| 2023/24 | Old |  |  |  |  |  |  |  |  |
| 2024/25 | Old |  |  |  |  |  |  |  |  |
| 2025/26 | Old |  |  |  |  |  |  |  |  |
| 2026/27 | Capped |  |  | Yes |  |  |  |  |  |
| 2027/28 | Capped |  |  | Yes |  |  |  |  |  |

Define:

```text
CapBind_t = 1[p_t = cap_t]
Shortfall_t = Reliability Requirement_t - Cleared Capacity_t
ReserveMarginGap_t = Target Reserve Margin_t - Actual Reserve Margin_t
```

This table should establish the basic facts: the capped years are also the years in which the auction reaches the cap and fails, or nearly fails, PJM’s reliability target.

### Test 2: Actual versus No-Cap Simulation

This should become one of the main results tables.

For 2026/27:

| Scenario | Price | Cleared UCAP | Shortfall | Revenue |
|---|---:|---:|---:|---:|
| Actual capped VRR |  |  |  |  |
| Unrestricted/no-cap VRR |  |  |  |  |
| Difference |  |  |  |  |

For 2027/28:

| Scenario | Price | Cleared UCAP | Shortfall | Revenue |
|---|---:|---:|---:|---:|
| Actual capped VRR |  |  |  |  |
| No-cap/no-floor simulation |  |  |  |  |
| Difference |  |  |  |  |

The key distinction:

- In 2026/27, the cap appears to suppress price without materially changing cleared quantity.
- In 2027/28, the cap appears to suppress price and reduce cleared quantity.

This is the central empirical contrast.

### Test 3: Shortfall Decomposition

Decompose the 2027/28 shortfall into contributing factors:

```text
Reliability Shortfall = Reliability Requirement - Cleared Capacity
```

Then discuss components such as:

- load forecast growth;
- increased data center demand;
- IRM/FPR changes;
- resource retirements or deactivations;
- delayed new entry;
- interconnection queue transition issues;
- supply-chain constraints;
- imports and CETL constraints;
- demand response participation;
- uncleared above-cap supply.

This prevents the paper from over-attributing the entire shortfall to the cap.

The strongest claim is not that the cap caused the full shortfall. The strongest claim is that the cap rationed some marginal capacity in a market that was already short.

### Test 4: Offer-Exclusion and Bunching Analysis

If data are available, examine whether offers cluster around the cap or whether a meaningful block of supply sits just above the cap.

Possible outputs:

- histogram of offer prices near the cap;
- cumulative offer curve with cap line;
- share of offered MW above cap;
- MW excluded because offers exceeded the cap;
- density of offers immediately below versus above the cap;
- comparison of capped years to prior uncapped years.

This test would directly address the question:

> Does a cap close to the expected clearing price incentivize bids to line up near the cap?

If offer-level data are not available, use PJM/IMM aggregate offer-curve evidence and clearly state the limitation.

### Test 5: LDA-Level Robustness

Use LDA results cautiously. In 2027/28, the RTO-wide shortfall limited the relevance of LDA price separation. Still, LDA-level evidence can support the broader mechanism.

Possible LDA-level checks:

- Are import-constrained LDAs more likely to exhibit cap-binding outcomes?
- Do LDAs with lower CETL/reliability-requirement ratios show larger modeled scarcity markups?
- Do high Net CONE LDAs face a larger wedge between local investment cost and the administrative cap?
- Do constrained LDAs reveal greater exposure to reliability risk under a uniform cap?

These should be supporting checks, not the main identification strategy.

---

## 7. Revised Role of the SFE Model

The SFE model should remain in the paper, but its role should change.

Do not present the SFE model as the main estimator of the but-for clearing price.

Instead, present it as a mechanism:

> The SFE model shows why a concentrated capacity market facing an administratively capped demand curve can enter a cap-binding regime. The empirical analysis then asks whether the observed PJM auctions display the predicted symptoms of that regime.

The model can still support several useful points:

1. Under concentrated supply, the equilibrium can reach the cap.
2. Once the cap binds, the clearing price reveals the cap, not the latent market-clearing price.
3. A lower cap truncates the scarcity signal.
4. If supply is tight enough, the cap can exclude marginal capacity that would have cleared at a higher price.

The model should probably move to a shorter theory section or an appendix. The main paper should lead with the observed auction evidence.

---

## 8. Sections Requiring Revision

### Abstract

Rewrite completely. The abstract should no longer lead with SFE counterfactual prices. It should lead with cap-binding scarcity and reliability shortfall.

Suggested opening:

> This paper studies the reliability consequences of administrative price caps in PJM’s capacity market using the 2026/27 and 2027/28 Base Residual Auctions, the first auctions conducted under the Shapiro/PJM price collar.

### Introduction

Change the research question.

Old question:

> What would the auction have cleared at absent the settlement cap?

New question:

> What happens when a capacity auction clears at an administrative cap while failing to meet its reliability target?

The introduction should end with three facts:

1. The capped auctions cleared at the cap.
2. 2026/27 marginally missed PJM’s reserve-margin target or target reliability requirement, depending on metric.
3. 2027/28 materially missed the RTO Reliability Requirement and excluded above-cap supply.

### Institutional Background

Keep the VRR discussion, but add a clearer explanation of reliability metrics:

- Reliability Requirement;
- Forecast Pool Requirement;
- Installed Reserve Margin;
- UCAP versus ICAP;
- FRR commitments;
- RPM clearing versus total procured capacity;
- what it means to miss PJM’s target;
- how PJM treats reserve target shortfalls under the tariff.

This is essential because “failed to meet the reliability requirement” can be ambiguous unless the metric is defined precisely.

### Literature Review

Reduce the emphasis on SFE literature and add more literature on:

- price ceilings and shortages;
- scarcity pricing;
- missing money;
- capacity-market design;
- resource adequacy;
- market-power mitigation;
- investment incentives under administratively capped prices.

The SFE literature should remain, but it should no longer dominate the paper.

### Model

Shorten and reposition.

The model section should say:

> The model motivates why a concentrated capacity market can enter an at-cap regime, but the empirical contribution comes from observed auction outcomes and PJM/IMM counterfactual simulations.

Move detailed ODE derivations to an appendix if space is tight.

### Data

Add a table listing all data sources:

| Source | Use in Paper |
|---|---|
| PJM BRA reports | Clearing prices, cleared MW, reserve margins, no-cap simulations |
| PJM planning parameters | VRR curve, Reliability Requirement, IRM, FPR, cap/floor values |
| IMM BRA analyses | Unrestricted VRR scenarios, mitigation interpretation, market-power context |
| PJM Reserve Target Shortfall Report | Causes of 2027/28 shortfall |
| FERC settlement/order materials | Regulatory basis for price collar |
| IMM State of the Market reports | TPS, RSI, market power, MSOC/mitigation |
| Offer-curve data, if available | Bunching and above-cap supply tests |

### Results

Replace the current results sequence with:

1. Historical BRA outcomes and cap-binding status.
2. 2026/27: marginal target miss and price suppression.
3. 2027/28: material shortfall and above-cap supply exclusion.
4. Actual versus no-cap/floor simulations.
5. Shortfall decomposition.
6. SFE interpretation as mechanism.

### Discussion

The discussion should explicitly distinguish what the paper shows from what it does not show.

The paper shows:

- the cap bound during a scarcity episode;
- the cap suppressed scarcity prices;
- in 2027/28, the cap excluded marginal capacity;
- the auction failed to meet reliability targets while clearing at the cap.

The paper does not show:

- that the cap caused the entire shortage;
- that uncapping the auction would have fully restored resource adequacy;
- that PJM’s no-cap simulation is a full behavioral counterfactual;
- that the SFE model independently predicts observed capped prices.

---

## 9. Additional Sources to Find

The revised paper needs a different source base.

### PJM Sources

1. **PJM 2026/27 BRA Report**
   - clearing price;
   - cleared MW;
   - reserve margin;
   - target reserve margin;
   - capped versus no-cap comparison if available.

2. **PJM 2027/28 BRA Report**
   - clearing price;
   - cleared MW;
   - RTO Reliability Requirement shortfall;
   - above-cap uncleared supply;
   - no-cap/no-floor simulation;
   - capacity-price and revenue implications.

3. **PJM 2027/28 Reserve Target Shortfall Report**
   - PJM’s explanation of the shortfall;
   - demand growth;
   - data centers;
   - supply-chain constraints;
   - interconnection queue transition;
   - retirements and deactivations.

4. **PJM Planning Parameters for 2026/27 and 2027/28**
   - Reliability Requirement;
   - IRM;
   - FPR;
   - Net CONE;
   - VRR curve coordinates;
   - cap and floor values;
   - UCAP/ICAP conversion assumptions.

### IMM Sources

5. **IMM 2026/27 BRA Analysis, Part A and Part B**
   - unrestricted VRR simulation;
   - price effects;
   - cleared capacity effects;
   - IMM interpretation of the price collar.

6. **IMM 2027/28 BRA Analysis**
   - comparison of 2026/27 and 2027/28;
   - discussion of shortfall;
   - offer-cap interaction;
   - market-power mitigation context.

7. **IMM State of the Market Reports**
   - TPS test;
   - RSI values;
   - Market Seller Offer Cap;
   - offer-cap mitigation;
   - resource mix and ACR assumptions.

### Regulatory Sources

8. **FERC settlement/order materials**
   - legal basis for the price collar;
   - consumer-cost rationale;
   - temporary nature of cap/floor;
   - treatment of constrained LDAs.

9. **Pennsylvania/Shapiro complaint and public materials**
   - claimed consumer savings;
   - stated rationale for cap;
   - asserted but-for price.

### Academic Literature

10. **Missing Money and Capacity Market Design**
    - Joskow and Tirole;
    - Joskow;
    - Cramton and Stoft;
    - Bowring;
    - Hogan.

11. **Price Controls and Shortages**
    - Weitzman;
    - Glaeser and Luttmer;
    - standard price-ceiling theory;
    - any electricity-market-specific price-cap literature.

12. **Market Power and SFE Literature**
    - Klemperer and Meyer;
    - Green and Newbery;
    - Holmberg;
    - Anderson and Hu;
    - Rudkevich et al.

---

## 10. Fine Points and Cautions

### Avoid Overclaiming Causality

Do not write:

> The Shapiro cap caused PJM’s reliability shortfall.

Write:

> The cap became binding during a scarcity episode and, in 2027/28, excluded marginal supply that would have cleared at a higher price.

### Distinguish 2026/27 from 2027/28

Do not treat the two capped auctions as identical.

Use this distinction:

> 2026/27 shows price suppression with marginal reliability inadequacy. 2027/28 shows price suppression plus quantity rationing.

### Define the Reliability Metric Carefully

Be precise about whether the paper is referring to:

- RTO Reliability Requirement;
- target reserve margin;
- installed reserve margin;
- UCAP shortfall;
- ICAP shortfall;
- RPM-procured capacity;
- RPM plus FRR commitments.

This is important because 2026/27 can look different depending on the metric.

### Separate the Different Caps

The paper needs to distinguish:

- VRR Point (a) cap;
- Shapiro settlement cap;
- Market Seller Offer Cap;
- TPS mitigation cap;
- unit-specific avoidable-cost-based offer cap.

Otherwise the analysis will confuse administrative demand-curve truncation with market-power mitigation.

### Treat No-Cap Simulations Carefully

PJM/IMM no-cap simulations are not full behavioral counterfactuals. They usually hold offers fixed and rerun the clearing mechanism under an alternative demand curve. That means they show mechanical clearing effects, not necessarily how sellers would have bid in a world without the cap.

Use wording like:

> PJM’s no-cap simulation provides a useful mechanical counterfactual, but not a full equilibrium behavioral counterfactual.

### Keep the SFE Model, But Downgrade It

The SFE model should no longer carry the main empirical burden. Its revised role is:

> Theoretical mechanism and interpretive framework.

Not:

> Main estimator of the but-for price.

---

## 11. Suggested Revised Abstract

This paper studies the reliability consequences of administrative price caps in PJM’s capacity market using the 2026/27 and 2027/28 Base Residual Auctions, the first auctions conducted under the Shapiro/PJM price collar. Both auctions cleared at the administrative cap. In 2026/27, the auction marginally failed to satisfy PJM’s target reliability objective, while in 2027/28 it produced a material shortfall relative to the RTO Reliability Requirement. PJM’s no-cap simulations indicate that the cap suppressed prices in both years and reduced cleared capacity in 2027/28 by excluding above-cap supply. I argue that these auctions provide evidence of a cap-binding scarcity regime: the cap did not create the underlying supply-demand imbalance, but it became binding precisely when scarcity prices were most informative and when marginal capacity was needed. A Supply Function Equilibrium model is used to motivate the at-cap regime, but the main empirical evidence comes from observed auction outcomes, no-cap simulations, and reliability shortfall accounting. The results suggest that temporary capacity price caps can reduce consumer payments while weakening the auction’s ability to reveal scarcity and procure marginal resources during tight system conditions.

---

## 12. One-Paragraph Prompt for Revision Workflow

Revise this paper by pivoting it away from a primarily structural SFE counterfactual-price exercise and toward a more specific empirical claim about cap-binding scarcity in PJM’s 2026/27 and 2027/28 Base Residual Auctions. The new thesis is that the capped auctions show a progression from marginal reliability inadequacy in 2026/27 to material procurement shortfall in 2027/28: both auctions cleared at the administrative cap, the 2026/27 auction fell slightly short of PJM’s reserve-margin target or target reliability objective, and the 2027/28 auction cleared materially below the RTO Reliability Requirement while excluding above-cap supply. The SFE model should be retained only as a theoretical mechanism explaining why a concentrated capacity market can enter an at-cap regime, not as the main empirical estimator of the but-for clearing price. The revised empirical core should compare actual capped outcomes with PJM/IMM no-cap or unrestricted-VRR simulations, decompose the reliability shortfall into load growth, IRM/FPR changes, retirements, imports, demand response, and uncleared above-cap supply, and clearly distinguish price suppression from quantity rationing. The paper should avoid claiming that the cap alone caused the shortage; instead, it should argue that the cap became binding during a scarcity episode and limited the market’s ability to reveal scarcity and procure marginal capacity.


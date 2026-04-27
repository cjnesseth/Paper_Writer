# Speaker Script — Verbatim Narration

**Deck:** `presentation.tex` (14 frames + title) — *Capping the Capacity Market: A Supply Function Equilibrium Analysis of Price Controls in PJM*

**Target total:** ~15:00 | **Delivery pace:** ~150 words/minute | **Style:** First person, conversational, tight

Each frame heading below matches the Beamer `\begin{frame}{...}` title verbatim. Read or closely paraphrase; the bracketed transitions belong to the presenter, not the audience.

---

## 1. Title *(≈0:20)*

Thank you for having me. The paper I'm going to present today asks a pretty specific question: when Pennsylvania and PJM agreed to cap the capacity auction at three hundred twenty-five dollars per megawatt-day, and the settlement was announced as saving consumers twenty-one billion dollars — how should we think about that number? I'll argue that a supply function equilibrium model, calibrated to the actual PJM market, gives us a very different benchmark for that counterfactual.

*[Advance.]*

---

## 2. PJM at a Glance *(≈0:50)*

Very briefly, for anyone not steeped in PJM: PJM is the regional transmission organization that covers thirteen states plus D.C. — roughly sixty-five million customers and a hundred and eighty gigawatts of installed capacity. It runs three wholesale markets: an energy market that pays for the electricity that's actually produced; an ancillary services market that pays for reserves and grid support; and a capacity market, which pays generators three years in advance simply to be available. Today's paper is entirely about that third market — specifically the annual Base Residual Auction, or BRA, under PJM's Reliability Pricing Model.

*[Transition: so why are we talking about this auction right now?]*

---

## 3. The $21 Billion Question *(≈1:00)*

The reason this auction is getting policy attention is a sequence of events that started in December 2024. Pennsylvania filed a FERC complaint after the 2025/26 auction cleared at two hundred sixty-nine dollars and ninety-two cents per megawatt-day — an eight hundred percent jump relative to the prior year. That jump is consistent with a concentrated supply side interacting with a steepening VRR curve — which is the main mechanism I'll walk through. In January 2025, Governor Shapiro and PJM reached a settlement that capped the next two auctions — 2026/27 and 2027/28 — at three hundred twenty-five dollars per megawatt-day, with a floor at one hundred seventy-five. The headline of that settlement is a claim of more than twenty-one billion dollars in two-year consumer savings.

*[Transition: the question this paper asks is simple.]*

---

## 4. Research Question *(≈0:45)*

What would PJM's 2026/27 and 2027/28 auctions have cleared at, absent the settlement? And what does the revenue transfer actually look like once you replace the administrative counterfactual with a strategic one? Those are the two questions, and the rest of the talk is how I answer them.

*[Transition: to get there, we need one institutional detail about PJM's demand curve.]*

---

## 5. The VRR Curve Slopes Only in Scarcity *(≈1:30)*

PJM's demand for capacity isn't a single quantity — it's a piecewise-linear curve called the Variable Resource Requirement, or VRR. The key property, shown on the left, is that the curve is flat above Point (a), which is the administrative price cap at around five hundred dollars. It then slopes downward through Point (b) at Net CONE — roughly two hundred twelve dollars per megawatt-day — and continues to fall as capacity grows. There is no pre-settlement floor in this market; the curve is bounded above by PJM's administrative cap but not below. That asymmetry — a ceiling but no floor — is what the settlement will modify.

*[Transition: so what does the settlement actually do to this curve?]*

---

## 6. The Settlement Bounds the Clearing Price *(≈1:30)*

The settlement lays a pair of horizontal lines across that VRR curve. The red line at three hundred twenty-five is the new cap — no clearing price is allowed above it in 2026/27 or 2027/28. The blue line at one hundred seventy-five is the floor. What this produces is the bold curve you see on the slide, which is the effective demand that strategic sellers actually face. On the left, the cap binds, flattening the curve at three hundred twenty-five. In the middle, the original VRR slope binds — the same downward region from the previous slide. On the right, the floor kicks in at one hundred seventy-five. The two dots mark the kink points where each bound meets the underlying VRR. It truncates from above, supports from below, and it applies to the RTO as a whole and to each Locational Deliverability Area within it.

*[Transition: with the setting in place, here is the model I use to evaluate it.]*

---

## 7. Model: Supply Function Equilibrium *(≈1:30)*

I use a static supply function equilibrium, in the tradition of Klemperer and Meyer's 1989 paper. There are $K$ symmetric strategic sellers, each of whom bids an entire supply schedule against PJM's known VRR demand. Profit maximization yields the ordinary differential equation on the slide: the slope of each seller's equilibrium supply is determined by demand slope, residual supply, and the number of competitors. Because the Klemperer–Meyer framework has a continuum of equilibria, I follow Holmberg (2008) and use the boundary condition $s$ of $p$-bar equals $q$-bar to select among them. I allow for a competitive fringe that offers a block of capacity at cost $c$, and the equilibrium price $p^*$ is the one that clears total supply against the VRR demand.

*[Transition: that boundary condition has a consequence that matters a lot.]*

---

## 8. The At-Cap Regime Is Mechanical *(≈1:15)*

When $K$ is three or fewer — which is the empirically relevant case for PJM — the interior ODE does not have a solution that clears the market below the VRR cap. The boundary condition then forces the market to clear at $p$-bar by construction. I want to flag this clearly: the dollar figures — three hundred twenty-nine in 2026/27 and three hundred thirty-three in 2027/28 — come directly from PJM's VRR Point (a) parameters, not from an independent price forecast by the model. So the substantive content of the model isn't the dollar value. It's the regime — at-cap versus interior — and how that regime depends on $K$.

*[Transition: with that caveat noted, let me describe the calibration.]*

---

## 9. Calibration *(≈1:00)*

I set $K$ equal to three strategic sellers. That is supported by residual supply index calculations: in all seven completed BRA years, the three-largest RSI is below one at the RTO level, meaning the top three sellers are collectively pivotal. Marginal cost is calibrated at one hundred fifty dollars per megawatt-day, which is the combined-cycle sector's avoidable cost rate as reported by PJM's Independent Market Monitor in 2025. I want to note explicitly that this is my choice of benchmark technology, not a cost figure the Market Monitor itself recommends using. The VRR curve parameters, demand forecast, and capacity emergency transfer limits all come directly from PJM's planning filings.

*[Transition: here's what the model produces at baseline.]*

---

## 10. Baseline SFE: New-Design Years Clear at the Cap *(≈1:30)*

The table shows equilibrium price $p^*$ next to the actual BRA clearing price for each of the seven completed delivery years. For the five old-design years, from 2021/22 through 2025/26, the model predicts interior equilibria with $p^*$ values substantially above the actual clearing — the gap there reflects the PJM-imposed Three-Pivotal-Supplier mitigation, which I don't model endogenously. For the two new-design years, bolded at the bottom — 2026/27 and 2027/28 — the SFE equilibrium is at the cap, and the values three hundred twenty-nine and three hundred thirty-three match the observed clearing exactly, by construction of the boundary condition. So the model is consistent with the at-cap outcomes we actually see.

*[Transition: the more interesting comparative static is what happens as $K$ changes.]*

---

## 11. Markups Collapse Between $K = 3$ and $K = 4$ *(≈1:00)*

This figure plots the Lerner index — the equilibrium markup as a share of price — on the vertical axis, against the number of strategic sellers $K$ on the horizontal. I hold 2026/27 VRR parameters and the baseline cost fixed. The striking feature is the discontinuity between $K$ equals three and $K$ equals four. At $K$ equals three, we are in the at-cap regime — the Lerner index is essentially the ratio of cap to cap-minus-cost. At $K$ equals four and above, we exit the at-cap regime, the interior ODE binds, and the Lerner index drops by more than half. So concentration — specifically the difference between three and four effective sellers — is doing enormous work here.

*[Transition: that sets up the headline comparison on the $21 billion claim.]*

---

## 12. Same Arithmetic, Different Counterfactual *(≈1:30)*

The twenty-one billion dollar claim is not an arithmetic error. It's a counterfactual choice. The top row of the table uses VRR Point (a) — roughly five hundred dollars — as the but-for price. That implicitly assumes the market would have cleared at the old design cap absent the settlement. That calculation produces a two-year transfer of seventeen point one six billion dollars at the RTO level. The second row uses the SFE equilibrium price — three hundred twenty-nine and three hundred thirty-three — as the but-for price. That calculation gives a two-year transfer of zero point six one billion — substantially smaller. Two caveats sharpen this. First, both 2026/27 and 2027/28 cleared below their reliability requirements — by roughly 0.2 percent and 4.7 percent. Under that kind of physical scarcity, the at-cap outcome is overdetermined: it is consistent with my strategic mechanism and with an atomistic market that is simply short of capacity. Second, the counterfactual magnitude is sensitive to which Point (a) we take as the pre-settlement benchmark — if that value is closer to five hundred than to three hundred twenty-nine, the gap with Shapiro's seventeen point one six billion narrows substantially. The qualitative point — that the counterfactual choice drives the headline — holds. The specific ratio is more contingent than the table suggests.

*[Transition: before concluding, I want to be upfront about what the model does not do.]*

---

## 13. Limitations *(≈1:00)*

Five limitations I want to put on the table. First, and most important, both 2026/27 and 2027/28 cleared below their reliability requirements — by roughly 0.2 percent and 4.7 percent. That means the at-cap outcome is overdetermined: it is consistent with my strategic mechanism, but also with a physically scarce atomistic market that would clear at the cap regardless of concentration. Second, I don't model Three-Pivotal-Supplier mitigation endogenously — it may well be the true binding constraint in old-design years. Third, firms are assumed symmetric; I bracket cost heterogeneity rather than solve it. Fourth, I use the Holmberg boundary condition as an equilibrium selection rule, not as something derived from stochastic demand — the BRA is effectively deterministic on the relevant horizon. Fifth, the model is static, so I'm not capturing retirement or entry responses to suppressed prices.

*[Transition: let me close with what I think this result says about the settlement.]*

---

## 14. What the Settlement Does, and What It Does Not *(≈1:20)*

The cap at three hundred twenty-five sits fifty-three percent above the 2026/27 Net Cost of New Entry of two hundred twelve dollars per megawatt-day. So entry remains financially viable under the cap — the concern the model surfaces is informational, not cost recovery. What the cap truncates is the price signal that investors use to distinguish a market that would have cleared at three hundred thirty-three from one that would have cleared far above three hundred twenty-five. Structural channels — transmission expansion, a steeper VRR slope, or entry — would reduce markups without that truncation. Temporary price suppression is not a substitute for structural reform. Thank you.

*[End.]*

---

## Quick Numeric Cross-Reference

| Claim | Value | Slides |
|---|---|---|
| 2025/26 clearing price | \$269.92 | 3 |
| Settlement cap | \$325 | 3, 6, 12, 14 |
| Settlement floor | \$175 | 3, 6, 14 |
| SFE $p^*$ 2026/27 | \$329 | 8, 10, 12 |
| SFE $p^*$ 2027/28 | \$333 | 8, 10, 12 |
| Headline savings claim | \$21B | 3, 12 |
| VRR counterfactual transfer | \$17.16B | 12 |
| SFE counterfactual transfer | \$0.61B | 12 |
| Strategic sellers | $K=3$ | 9, 10 |
| Marginal cost | $c=\$150$ | 9, 10 |
| 2026/27 Net CONE | \$212 | 14 |
| Cap headroom over Net CONE | 53% | 14 |

---

## Timing Budget

| Frame | Time | Cumulative |
|---|---|---|
| 1 Title | 0:20 | 0:20 |
| 2 PJM at a Glance | 0:50 | 1:10 |
| 3 \$21B Question | 1:00 | 2:10 |
| 4 Research Question | 0:45 | 2:55 |
| 5 VRR Curve | 1:30 | 4:25 |
| 6 Settlement overlay | 1:30 | 5:55 |
| 7 Model: SFE | 1:30 | 7:25 |
| 8 At-cap mechanical | 1:15 | 8:40 |
| 9 Calibration | 1:00 | 9:40 |
| 10 Baseline results | 1:30 | 11:10 |
| 11 $K$ transition | 1:00 | 12:10 |
| 12 \$21B reassessment | 1:30 | 13:40 |
| 13 Limitations | 1:00 | 14:40 |
| 14 Implications | 1:20 | 16:00 |

If running long, compress frames 5, 6, and 11 — those have the most slack.

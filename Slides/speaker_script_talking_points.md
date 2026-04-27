# Speaker Script — Talking Points

**Deck:** `presentation.tex` (14 frames + title) — *Capping the Capacity Market*

**Target total:** ~15:00 | **Use:** Quick podium cues, not verbatim | **Companion:** `speaker_script_verbatim.md` for fuller phrasing

Each frame heading matches the Beamer `\begin{frame}{...}` title. Bold = delivery emphasis. *Italic* = transition to next frame.

---

## 1. Title *(0:20 | ~50 words)*

- Thank the audience
- Frame the ask: **$21 billion** headline → what does an SFE model say?
- Position: calibrated model, not reduced-form
- *Advance*

---

## 2. PJM at a Glance *(0:50 | ~125 words)*

- PJM = **RTO**, 13 states + DC, **65M customers**, **180 GW** capacity
- Three markets: **energy** (produced MWh), **ancillary** (reserves), **capacity** (availability, **3 years ahead**)
- This paper = **capacity** only, the **Base Residual Auction** under RPM
- *So why does this auction matter in 2025?*

---

## 3. The $21 Billion Question *(1:00 | ~150 words)*

- **Dec 2024**: PA files FERC complaint
- **2025/26 BRA cleared at \$269.92** — an **800% jump**
- Read: consistent with **concentrated supply** meeting a **steepening VRR**
- **Jan 2025**: Shapiro–PJM settlement
  - Cap **\$325/MW-day**, floor **\$175/MW-day**
  - Applies to **2026/27 and 2027/28** only
- Headline: **>\$21B** two-year savings
- *What question does this paper actually ask?*

---

## 4. Research Question *(0:45 | ~110 words)*

- Two parts:
  1. What would **2026/27 and 2027/28** have cleared at, **absent the settlement**?
  2. What is the **actual revenue transfer**?
- Shift from administrative counterfactual to **strategic counterfactual**
- *One institutional detail first — PJM's demand curve*

---

## 5. The VRR Curve Slopes Only in Scarcity *(1:30 | ~225 words)*

- Point to left diagram
- Two regions:
  - **Flat above (a)** — administrative cap at \$500
  - **Sloped from (a) through (b)** at Net CONE (\$212), continuing to fall
- Key takeaway: **pre-settlement VRR has a ceiling but no floor**
- Top set by **administrative parameters**, not bidder behavior
- This asymmetry is what the settlement modifies
- *Now overlay the settlement*

---

## 6. The Settlement Bounds the Clearing Price *(1:30 | ~225 words)*

- Point to **bold composite curve** = effective demand facing strategic sellers
- Red segment on left = **cap \$325** binds (truncates above)
- Gray segment in middle = **original VRR slope** still binds
- Blue segment on right = **floor \$175** binds (supports below)
- Two **kink dots** where cap and floor meet the VRR
- Applies **2026/27 and 2027/28 only, RTO + all LDAs**
- *Now the model*

---

## 7. Model: Supply Function Equilibrium *(1:30 | ~225 words)*

- Static SFE, **Klemperer–Meyer (1989)** tradition
- **$K$ symmetric strategic sellers**, each bids full supply schedule
- Point to ODE: $s'(p) = \frac{D'(p) + s(p)/(p-c)}{K-1}$
- **Holmberg (2008)** boundary $s(\bar p) = \bar q$ **selects the equilibrium** (KM has a continuum)
- **Competitive fringe** offers a block $Q_f$ at cost $c$
- **$p^*$** clears total supply against VRR demand
- *That boundary condition matters a lot when $K$ is small*

---

## 8. The At-Cap Regime Is Mechanical *(1:15 | ~190 words)*

- When **$K \le 3$**, interior ODE has **no solution below the cap**
- Boundary condition forces clearing **at $\bar p$ by construction**
- **Flag clearly**: \$329 (2026/27) and \$333 (2027/28) are from **PJM's VRR Point (a)**, not an **independent price forecast**
- Substantive content = the **regime** (at-cap vs. interior), not the dollar value
- *Now the calibration*

---

## 9. Calibration *(1:00 | ~150 words)*

- **$K = 3$** strategic sellers
  - Justified by **RSI$_3 < 1$** at RTO in all seven BRA years
- **$c = \$150$/MW-day**
  - Combined-cycle ACR from **IMM 2025**
  - **This is my choice of benchmark tech, not the IMM's recommendation**
- **VRR, demand, CETL** direct from PJM planning filings
- *Baseline results*

---

## 10. Baseline SFE: New-Design Years Clear at the Cap *(1:30 | ~225 words)*

- Point to table
- **Old-design years (2021/22–2025/26)**: interior SFE, $p^*$ **substantially above** actual — gap is unmodeled **TPS mitigation**
- **New-design years (bold)**: **2026/27 $p^* = \$329$**, **2027/28 $p^* = \$333$**
- Both **match observed clearing** exactly — by construction of the boundary
- Model is **consistent with observed at-cap outcomes**
- *Comparative static on $K$*

---

## 11. Markups Collapse Between $K = 3$ and $K = 4$ *(1:00 | ~150 words)*

- Point to figure
- Axes: **Lerner index** vs. **$K$**; 2026/27 params, $c = \$150$
- Key feature: **discontinuity** between $K=3$ and $K=4$
  - $K=3$: **at-cap regime**, high Lerner
  - $K \ge 4$: interior ODE binds, **Lerner drops by half**
- **Three vs. four sellers** is doing enormous work
- *Now the \$21B comparison*

---

## 12. Same Arithmetic, Different Counterfactual *(1:30 | ~225 words)*

- Point to table
- **Row 1** VRR Point (a) = **\$500** as but-for → **\$17.16B** two-year transfer
- **Row 2** SFE equilibrium = **\$329 / \$333** as but-for → **\$0.61B** two-year transfer
- **Substantially smaller** — two caveats sharpen this:
  - Both 2026/27 and 2027/28 cleared **below reliability req.** (−0.2%, −4.7%)
  - At-cap is **overdetermined**: strategic mechanism vs. physical scarcity
  - Transfer sensitive to which **Point (a)** is the pre-settlement benchmark
- Settlement cap **\$325** sits **\$4 below** SFE $p^*$ at RTO
- Footer caveat: **RTO level only**; LDAs add more, not computed here
- **Qualitative point — counterfactual choice drives the headline — holds; specific ratio is contingent**
- *Limitations before concluding*

---

## 13. Limitations *(1:00 | ~150 words)*

- **Both new-design auctions cleared below reliability req.** — at-cap is overdetermined (strategic vs. physical scarcity)
- **TPS mitigation** not endogenous — may be true binding constraint
- **Symmetric firms**; cost heterogeneity bracketed
- **Holmberg boundary** used as **selection rule**, not derived from stochastic demand
- **Static model** — no retirement/entry response
- *Closing slide*

---

## 14. What the Settlement Does, and What It Does Not *(1:20 | ~200 words)*

- **Cap \$325 sits 53% above Net CONE (\$212)** — entry remains viable
- So the binding concern is **informational, not cost recovery**
- What the cap truncates = **the price signal** for investment decisions
- Structural fixes — **transmission, steeper VRR, entry** — would reduce markups **without truncation**
- **Temporary suppression is not structural reform**
- *Thank you*

---

# Anticipated Q&A

**Q1. Why symmetric firms when PJM suppliers clearly differ in cost?**
Symmetric SFE gives a central estimate, not a measurement. Cost heterogeneity is known to shift markups in both directions depending on who is pivotal; treating it would require asymmetric SFE, which has no closed form and fragile comparative statics.

**Q2. Isn't $K=3$ imposed rather than estimated?**
Yes, but it's disciplined by RSI$_3 < 1$ in every BRA year at RTO — the top three are collectively pivotal. Estimating $K$ structurally would require bid data PJM does not release.

**Q3. Why is the Holmberg boundary the right selection rule?**
In stochastic-demand markets it's a genuine equilibrium refinement (Holmberg 2008). In the deterministic BRA I use it as a selection device — the paper is explicit about this. Alternative selections would change dollar predictions but not the at-cap/interior regime finding.

**Q4. Why is $c = \$150$ the right cost?**
It's the combined-cycle avoidable cost rate from the IMM's 2025 State of the Market. I use it as this paper's benchmark technology; the IMM itself prefers CT. Sensitivity to $c \in \{\$100, \$125, \$150, \$175, \$200\}$ is in the paper and the at-cap conclusion for $K=3$ is robust.

**Q5. Doesn't the $21B figure hold if TPS mitigation would have failed?**
That is one possible counterfactual, and I don't rule it out — it's one of the limitations. The paper's contribution is to show that under a plausible strategic benchmark, the gap between counterfactual and realized clearing is far smaller than the administrative benchmark implies.

**Q6. What about LDA-level transfers?**
The paper reports RTO-level transfers. Constrained LDAs (PS, PS NORTH) had Net CONE above the settlement cap and would contribute additional transfer, but LDA-level strategic calibration is out of scope for this draft.

**Q7. What would change your conclusion?**
Evidence that $K_{\text{eff}} \ge 4$ at the RTO (e.g., bilateral contracts breaking collective pivotality), or credible entry responses within the 10-month lead time. Either would push the equilibrium into the interior regime and the at-cap result would no longer follow mechanically.

**Q8. Is the settlement bad policy?**
The paper is evaluative, not normative. Cap truncates an informational signal; structural channels are better targeted. Whether the trade-off is worth it depends on weights on short-run consumer savings vs. long-run investment adequacy — which is outside the model.

---

## Numeric Cross-Reference

All values match the post-audit paper (2026-04-19, 2026-04-21):

\$269.92 | \$325 | \$175 | \$329 | \$333 | \$212 (Net CONE) | \$21B | \$17.16B | \$0.61B | $K=3$ | $c=\$150$ | 53% headroom | 800% jump

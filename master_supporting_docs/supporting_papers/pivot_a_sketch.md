# Pivot A: Calibrated SFE Simulation of Market Power in PJM RPM

## Paper in one sentence

Solve for supply function equilibria in a model of PJM's capacity auction calibrated to observed market structure, then use comparative statics to quantify how market power varies with concentration, transmission constraints, and demand-curve design.

---

## 1. Model Setup

### Players

- **K strategic firms** (e.g., K = 3–5), each owning a capacity portfolio $\bar{q}_i$.
- **A competitive fringe** that bids at avoidable cost — this is price-taking residual supply that absorbs the rest of the market. Treating the fringe as mechanical keeps the dimensionality of the equilibrium problem manageable.

### Demand side: the VRR curve

PJM's Variable Resource Requirement curve is piecewise-linear and publicly specified. Parameterize it as $D(p)$ with three anchor points:

| Point | Price | Quantity |
|---|---|---|
| Price cap | $1.5 \times \text{Net CONE}$ | $\text{Reliability Requirement} - X\%$ of reserve margin |
| Target | $\text{Net CONE}$ | Reliability Requirement (target reserve margin) |
| Floor | $0$ (or some minimum) | $\text{Reliability Requirement} + Y\%$ |

The exact coordinates are published in PJM's planning parameters for each delivery year. The key property is that $D'(p) < 0$ and is known to all bidders — there is no demand uncertainty.

### Cost structure

For existing capacity, the relevant cost is the **avoidable cost rate (ACR)** — the going-forward fixed cost a resource must cover to stay in the market. For new entry, the cost is **Net CONE** (Cost of New Entry net of expected energy/ancillary revenue). A tractable approach:

- Each strategic firm $i$ has a portfolio with marginal cost function $C_i'(q)$ that is flat at the firm's average ACR for $q \leq \bar{q}_i$ and then jumps to $\infty$ (capacity constraint).
- The fringe has a marginal cost function $C_f'(q)$ that is upward-sloping, representing heterogeneous going-forward costs across smaller generators.

A simpler alternative (appropriate for a term paper): assume all existing capacity has zero marginal cost and the capacity constraint binds, so the only decision variable is whether to withhold. This converts the SFE into a simpler capacity-withholding game but loses some richness.

### Supply function equilibrium

Each strategic firm $i$ chooses a supply function $S_i(p) : \mathbb{R}_+ \to [0, \bar{q}_i]$ to maximize profit taking rivals' supply functions as given.

**Market clearing condition:**

$$\sum_{i=1}^{K} S_i(p^*) + S_f(p^*) = D(p^*)$$

where $S_f(p)$ is the fringe supply function (assumed known/competitive) and $p^*$ is the clearing price.

**Firm $i$'s residual demand:**

$$RD_i(p) = D(p) - \sum_{j \neq i} S_j(p) - S_f(p)$$

In equilibrium, $S_i(p) = RD_i(p)$ at the clearing price.

### First-order condition (the core ODE)

Firm $i$ maximizes $\pi_i = p \cdot S_i(p) - C_i(S_i(p))$ along its residual demand. The necessary condition for an optimal supply function yields:

$$S_i(p) = -\bigl(p - C_i'(S_i(p))\bigr) \cdot \left(D'(p) - \sum_{j \neq i} S_j'(p) - S_f'(p)\right)$$

This is a system of $K$ coupled ordinary differential equations in the supply functions $\{S_1(p), \ldots, S_K(p)\}$.

**Boundary conditions:**

- At the price cap, $S_i = \bar{q}_i$ (each firm offers full capacity).
- The system is integrated backward from the price cap to lower prices.

**Symmetric special case:** If all $K$ firms are identical (same $\bar{q}_i$ and $C_i$), the system collapses to a single ODE:

$$s(p) = -\bigl(p - c'(s(p))\bigr) \cdot \left(D'(p) - (K-1) s'(p) - S_f'(p)\right)$$

where $s(p)$ is the common supply function and total strategic supply is $K \cdot s(p)$.

---

## 2. Solution Method

### For symmetric firms

1. Start at the price cap with the boundary condition $s(\bar{p}) = \bar{q}$.
2. Integrate the ODE backward (decreasing $p$) using a standard solver (Runge-Kutta via `deSolve` in R or `scipy.integrate.solve_ivp` in Python).
3. The equilibrium clearing price is where $K \cdot s(p) + S_f(p) = D(p)$.

### For asymmetric firms

The coupled ODE system requires iterative methods. Two standard approaches:

**Approach 1 — Backward-shooting (Holmberg 2008):** Guess a clearing price $p^*$, compute the equilibrium quantities from the FOCs, check market clearing, and iterate.

**Approach 2 — Iterative best response (Anderson & Hu 2008):**
1. Initialize each firm's supply function (e.g., competitive bidding).
2. For each firm $i$, solve its single-firm ODE taking rivals' current supply functions as given.
3. Update all supply functions simultaneously.
4. Repeat until convergence.

Anderson & Hu (2008) demonstrate convergence properties and provide pseudocode. This is the recommended approach for the term paper because it's modular — you code the single-firm problem once, then iterate.

### Numerical considerations

- Discretize the price grid finely (e.g., $0.01 increments in $/MW-day).
- The ODE can be stiff near capacity constraints; use an adaptive step solver.
- Check for multiplicity: SFE models generically have multiple equilibria (Klemperer & Meyer 1989). The standard selection is the "highest equilibrium" or the one closest to the Cournot outcome. Report the competitive equilibrium as a benchmark.

---

## 3. Calibration Targets

All of the following are obtainable from PJM public data without any proprietary access.

| Parameter | Source |
|---|---|
| VRR curve coordinates (Net CONE, reliability requirement, reserve margin) | PJM Planning Parameters (published annually for each BRA) |
| Capacity shares of top firms by LDA | PJM IMM State of the Market Report (Table on capacity market seller concentration, HHI by LDA) |
| Aggregate capacity offered vs. cleared | PJM RPM auction results (posted publicly) |
| Avoidable cost rates by resource type | PJM IMM reports (average ACRs by fuel type) or PJM's CONE study documentation |
| Import limits by LDA | PJM RTEP (Regional Transmission Expansion Plan) and planning parameters |
| Competitive fringe size | Total capacity minus top-K firms' portfolios |

### Recommended calibration delivery years

Pick 2–3 delivery years that bracket an interesting structural change. Good candidates:

- **2018/19 or 2019/20:** Pre-Capacity Performance (CP) transition, relatively "normal" market structure.
- **2022/23 or 2023/24:** Post-CP, with significant retirement-driven tightening.
- **A recent year with high prices or a binding LDA constraint:** The 2025/26 BRA cleared at a record high price — use this if the data and parameters are available.

Running the model under 2–3 different parameterizations gives you a natural panel for the comparative statics.

---

## 4. Output / Results Structure

The paper should produce four types of results:

### A. Baseline equilibrium

For each calibrated year, show:
- The equilibrium supply functions $S_i(p)$ plotted against the VRR curve.
- The equilibrium clearing price vs. the competitive benchmark (where all firms bid at cost).
- The implied Lerner index: $L_i = (p^* - C_i'(q_i^*)) / p^*$.

### B. Comparative statics on market structure

Hold the VRR curve and total capacity fixed, vary the number of strategic firms $K$ (equivalently, vary the HHI). Plot equilibrium markup as a function of concentration. This is the core "market power" result.

### C. Comparative statics on the VRR curve

Hold market structure fixed, vary the VRR slope (steeper vs. flatter demand). A steeper VRR curve gives firms more market power (price is more sensitive to withholding). This has direct policy relevance since PJM periodically redesigns the VRR shape.

### D. Transmission constraint counterfactual

Model a constrained LDA (e.g., EMAAC or MAAC) as a separate market with a limited import supply from the RTO. Show how tightening the import limit increases local market power. This connects to real PJM planning debates about transmission investment.

---

## 5. Key Data Requirements

### Must-have (publicly available, no access issues)

1. **PJM Planning Parameters** — Published for each BRA. Contains Net CONE, VRR curve parameters, reliability requirement, installed reserve margin, and CETL (Capacity Emergency Transfer Limit) by LDA. Available from PJM's RPM page.

2. **PJM IMM State of the Market Report** — Annual. Contains capacity market HHI by LDA, Three Pivotal Supplier test results, aggregate offer curves, and summary statistics on offers vs. clearing. Published by Monitoring Analytics (the IMM).

3. **PJM BRA Results** — Total capacity cleared, clearing prices by LDA, total capacity offered. Posted by PJM after each auction.

### Nice-to-have (for richer calibration)

4. **RPM Offer Data** — Individual unit-level offers (price-quantity pairs) with seller identification. Released by PJM with a ~3-year lag. This would let you construct actual firm-level supply curves rather than using the symmetric/stylized calibration, but it is not necessary for the simulation approach.

5. **PJM CONE Study** — Detailed bottom-up estimate of the cost of new entry by technology. Published periodically (the most recent should be for the reference technology, currently a combined-cycle gas turbine). Useful for calibrating the fringe supply function.

6. **Generator attribute data** — Nameplate capacity, fuel type, age, zone, and owner from PJM's Generator Attribute Tracking System (GATS) or EIA-860. Useful for building the capacity portfolios of the top-K firms.

---

## 6. Literature to Cite

### Foundational SFE theory

- **Klemperer, P. & Meyer, M. (1989).** "Supply Function Equilibria in Oligopoly under Uncertainty." *Econometrica*, 57(6), 1243–1277.
  - The original SFE model. Establishes existence and multiplicity of equilibria when firms choose supply functions under demand uncertainty. Your model uses deterministic demand (the VRR curve), which actually pins down the equilibrium more tightly — discuss this.

- **Green, R. & Newbery, D. (1992).** "Competition in the British Electricity Spot Market." *Journal of Political Economy*, 100(5), 929–953.
  - First application of SFE to electricity markets. Calibrated duopoly model of the England & Wales spot market. This is your closest methodological template — they do essentially what you're doing, but for the energy market.

- **Holmberg, P. (2008).** "Unique Supply Function Equilibrium with Capacity Constraints." *Energy Economics*, 30(1), 148–172.
  - Shows how capacity constraints resolve the SFE multiplicity problem and provide a unique equilibrium. Directly relevant since your generators are capacity-constrained. Also gives the backward-integration solution method.

### Numerical methods for SFE

- **Anderson, E. & Hu, X. (2008).** "Finding Supply Function Equilibria with Asymmetric Firms." *Operations Research*, 56(3), 697–711.
  - The main methods paper for computing SFE with heterogeneous firms. Provides the iterative best-response algorithm and convergence results. This is your primary reference for the computational approach.

- **Baldick, R., Grant, R., & Kahn, E. (2004).** "Theory and Application of Linear Supply Function Equilibrium in Electricity Markets." *Journal of Regulatory Economics*, 25(2), 143–167.
  - Linear SFE approximation, computationally simpler. A useful fallback if the full nonlinear ODE approach proves too costly in time.

### Market power in electricity (empirical motivation)

- **Wolak, F. (2003).** "Measuring Unilateral Market Power in Wholesale Electricity Markets: The California Market, 1998–2000." *American Economic Review P&P*, 93(2), 425–430.
  - Uses observed bid data to measure markups in California. Motivates why simulation is needed when you can't directly estimate from bids.

- **Bushnell, J., Mansur, E., & Saravia, C. (2008).** "Vertical Arrangements, Market Structure, and Competition: An Analysis of Restructured US Electricity Markets." *American Economic Review*, 98(1), 237–266.
  - Cournot simulation calibrated to US electricity markets. Compares predicted prices to observed prices to measure market power. Methodologically related — they also calibrate a strategic model to real market structure.

- **Sweeting, A. (2007).** "Market Power in the England and Wales Wholesale Electricity Market 1995–2000." *Economic Journal*, 117(520), 654–685.
  - Structural estimation of strategic behavior in electricity auctions. Tests SFE predictions against data.

### Residual demand and the B&B framework

- **Baker, J. & Bresnahan, T. (1988).** "Estimating the Residual Demand Curve Facing a Single Firm." *International Journal of Industrial Organization*, 6(3), 283–300.
  - The foundational paper you're adapting. Even though you're not estimating econometrically, you should frame the Lerner index from your simulation as the theoretical counterpart to what B&B would estimate.

- **Wolfram, C. (1999).** "Measuring Duopoly Power in the British Electricity Spot Market." *American Economic Review*, 89(4), 805–826.
  - Empirically tests whether generators exercise market power consistent with SFE predictions. Bridges the gap between the SFE theory and the B&B measurement approach.

### Capacity market design

- **Cramton, P. & Stoft, S. (2005).** "A Capacity Market that Makes Sense." *Electricity Journal*, 18(7), 43–54.
  - Foundational paper on why capacity markets exist and how the demand curve should be designed. Relevant for your VRR comparative statics.

- **Cramton, P. & Ockenfels, A. (2012).** "Economics and Design of Capacity Markets for the Power Sector." *Zeitschrift für Energiewirtschaft*, 36(2), 113–134.
  - Broader treatment of capacity market design with attention to market power concerns.

### PJM-specific institutional references

- **Monitoring Analytics (annual).** *State of the Market Report for PJM.* — Your primary data source for calibration.

- **PJM Interconnection.** *RPM Planning Parameters* and *BRA Results.* — Publicly posted for each delivery year.

- **Bowring, J. (2013).** "Capacity Markets in PJM." *Economics of Energy & Environmental Policy*, 2(2), 47–64.
  - Overview of RPM's design and market power mitigation rules by PJM's Independent Market Monitor. Good institutional background for the paper.

---

## 7. Suggested Paper Outline

1. **Introduction** — Market power in capacity markets matters for consumer costs and reliability. Existing monitoring (pivotal supplier tests) is coarse. SFE simulation provides a richer structural measure.
2. **Institutional Background** — PJM RPM, the VRR curve, the BRA process, existing mitigation rules.
3. **Model** — Setup, FOCs, the ODE system, boundary conditions, discussion of equilibrium selection.
4. **Calibration** — Data sources, parameter choices, baseline market structure.
5. **Results** — Baseline markups, then the four comparative statics (concentration, VRR slope, import limits, competitive benchmark).
6. **Discussion** — Compare implied markups to IMM's reported metrics. Policy implications for VRR design and transmission planning.
7. **Conclusion**

---

## 8. Risk Register

| Risk | Mitigation |
|---|---|
| ODE solver fails to converge for asymmetric case | Fall back to symmetric firms (one ODE, always solvable) or use Baldick et al. (2004) linear SFE |
| SFE multiplicity — unclear which equilibrium to report | Report the "highest" (most collusive) and the competitive benchmark as bounds. Holmberg (2008) uniqueness result applies if capacity constraints bind. |
| Calibration data too coarse (IMM reports only HHI, not firm-level shares) | Use EIA-860 generator ownership data to construct capacity portfolios directly. This is publicly available. |
| VRR curve parameters changed significantly across delivery years, complicating comparison | Choose delivery years within a single VRR regime, or make the VRR change itself one of the comparative statics. |
| Time constraint — model + calibration + writing in limited weeks | Start with the symmetric case (solvable in a day of coding), produce the core results, then extend to asymmetry only if time permits. The symmetric case alone is a complete paper. |

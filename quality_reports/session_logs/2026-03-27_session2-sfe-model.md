# Session Log: 2026-03-27 Session 2 — SFE Literature + Model Section

## Goal
Write the SFE theory/methods literature subsections and the full model section,
grounded in KM1989, G&N1992, Holmberg 2008, and Anderson & Hu 2008.

## Papers Read
- Klemperer & Meyer (1989) Econometrica pp.1–15: FOC, the symmetric ODE
  (their Eq.5), the continuum of equilibria, claims 1–7 on trajectory structure
- Green & Newbery (1992) JPE pp.929–939: electricity application, symmetric
  duopoly ODE (their Eq.3), capacity constraint analysis (Section B),
  backward-integration method, Figure 3 (feasible SFE region)
- Holmberg (2008) Uppsala WP 2004:20: uniqueness conditions, boundary condition
  intuition (binding capacity → inelastic residual demand → optimal price = cap)
- Anderson & Hu (2008) OR 56(3): general K-firm asymmetric FOC (their Eq.1),
  iterative best-response algorithm, convergence characterization

## Work Completed

### 1. `Paper/sections/literature.tex` — SFE Theory + Methods subsections

**SFE Theory subsection (~600 words):**
- KM1989: supply function as strategy, demand uncertainty pins equilibrium,
  continuum bounded by Cournot and competitive
- G&N1992: E&W electricity application, backward integration method,
  closest methodological template; key difference noted (VRR vs. load duration)
- Holmberg 2008: uniqueness via capacity constraint + price cap + inelastic demand;
  boundary condition S(p̄) = q̄; direct connection to at-cap outcomes in data
- Holmberg 2009, Vasin 2016: uniqueness extensions
- Allaz & Vila 1993, Anderson & Xu 2005: forward commitments reduce markups

**SFE Methods subsection (~450 words):**
- Anderson & Hu 2008: iterative best-response algorithm, ordering of equilibria,
  GAMS convergence
- Baldick et al. 2004: linear SFE as tractable benchmark; noted VRR incompatibility
- Niu et al. 2005, Rudkevich 2004: extensions
- Sioshansi & Oren 2007: empirical validation (ERCOT) — SFE tracks prices well
  at high demand, overpredicts at low demand

### 2. `Paper/sections/model.tex` — Full Draft (~280 lines)

Five subsections:

**4.1 Setup:** Three assumptions (players + capacity, fringe at ACR, flat MC);
market clearing Eq.(1); residual demand Eq.(2); determinism of VRR noted

**4.2 VRR Demand Schedule:** Piecewise-linear formulas for old (3-pt, Eq.3)
and new (4-pt, Eq.4) designs with explicit anchor-point notation;
Assumption 3 (D'<0 on sloped segments); cross-reference to results Section 5.3

**4.3 Firm Optimization and SFE Condition:** Derivation of MR equation from
price-impact formula; Proposition 1 (SFE FOC, Eq.6); economic interpretation
(markup = inverse residual demand elasticity); K-firm generalization of G&N Eq.3

**4.4 Equilibrium Selection:** KM1989 multiplicity problem stated;
Proposition 2 (Holmberg uniqueness, Eq.8 boundary condition S(p̄)=q̄);
intuition (inelastic residual demand at binding capacity → optimal price = cap);
connection to PJM data (at-cap in 2026/27 and 2027/28)

**4.5 Symmetric Special Case:** Rearrangement to boxed ODE (Eq.10):
  s'(p) = [D'(p) + s(p)/(p-c)] / (K-1)
Economic interpretation (VRR slope → higher supply; more firms → flatter supply);
equilibrium condition (Eq.11); Lerner index (Eq.12); Cournot upper bound stated;
numerical method (deSolve::lsoda, restart at VRR kinks) noted

## Key Equations Established

| Eq. | Content |
|-----|---------|
| (1) | Market clearing: Σ S_i(p*) + S_f(p*) = D(p*) |
| (2) | Residual demand: R_i(p) = D(p) - Σ_{j≠i} S_j(p) - S_f(p) |
| (3) | VRR old design (piecewise linear, 3 anchor points) |
| (4) | VRR new design (4 anchor points with floor p_f) |
| (6) | SFE FOC: S_i = -(p-c)[D' - Σ_{j≠i} S_j' - S_f'] |
| (8) | Boundary condition: S_i(p̄) = q̄_i |
| (10) | Symmetric ODE: s'(p) = [D'(p) + s(p)/(p-c)] / (K-1) |
| (11) | Symmetric clearing: K·s(p*) + S_f(p*) = D(p*) |
| (12) | Lerner index: L = (p* - c) / p* |

## Compilation
- Two-pass compile: clean (0 errors, 0 undefined refs final pass, 0 overfull)
- Quality score: **100/100**

## Open for Session 3
1. Introduction (requires model to preview results)
2. R solver: 01_vrr_demand.R + 02_sfe_symmetric.R + 04_calibrate.R +
   05_results_baseline.R
3. Calibration section stubs: market structure, cost parameters, delivery years

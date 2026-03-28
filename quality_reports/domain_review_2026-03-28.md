# Substance Review: PJM Capacity Auction SFE Paper
**Date:** 2026-03-28
**Reviewer:** domain-reviewer agent
**Files reviewed:** model.tex, calibration.tex, results.tex, discussion.tex, literature.tex;
Analysis/R/02_sfe_symmetric.R, 04_calibrate.R; Bibliography_base.bib

---

## Summary
- **Total issues:** 14 (2 blocking, 7 major, 5 minor)
- **Overall:** Substantively sound; no critical math errors; issues are correctable

---

## BLOCKING Issues

### B1: `q_bar` calibration uses `mw_cleared` instead of total installed capacity
- **Location:** Analysis/R/04_calibrate.R, lines 59–64
- **Code:** `total_supply <- row$mw_cleared` then `Q_top3 = total_supply - rsi_3 * rel_req`
- **Problem:** RSI₃ formula is (total_available_supply - capacity_top3) / reliability_req.
  Using `mw_cleared` (cleared quantity) instead of total available supply understates `q_bar`,
  especially in oversupplied years like 2023/24 where cleared < total available.
- **Fix:** Replace `mw_cleared` with total installed/offered capacity, verify against IMM source.

### B2: RSI₃ year-order inconsistency (Sections 4.2 vs 4.3)
- **Status:** ALREADY FIXED in Session 7 (proofreader H2 fix applied)

---

## MAJOR Issues

### M1: Stochastic vs. deterministic demand — tension with Holmberg uniqueness
- **Location:** model.tex §3.1 and §3.4
- **Problem:** Holmberg (2008) requires stochastic demand with positive probability of
  capacity constraints binding. Paper asserts deterministic demand then invokes Holmberg.
  "Determinism strengthens the boundary condition" claim is unexplained.
- **Fix:** Add footnote: either argue BRA involves ex-ante demand uncertainty (allowing
  Holmberg to apply directly) or acknowledge the boundary condition is imposed as a
  selection criterion motivated by, but not identical to, Holmberg's stochastic result.

### M2: ODE interpretation paragraph inverts the mechanism
- **Location:** model.tex §3.5, paragraph after Eq. (10)
- **Claim:** "as the markup grows, firms optimally increase the rate at which they
  withdraw supply as price falls"
- **Problem:** The s(p)/(p-c) term makes s'(p) MORE positive (steeper supply), not flatter.
  The mechanism is markup amplification near p=c, not withdrawal.
- **Fix:** Revise to describe the term as "markup amplification": as (p-c)→0, the term
  blows up, enforcing the lower boundary of the supply function.

### M3: K=3 identification overrelied on RSI₃ alone
- **Location:** calibration.tex §4.3
- **Problem:** RSI₃ < 1 identifies K≤3 (necessary), not K=3 specifically. The at-cap
  2026/27 outcome rules out K≥4 but does not distinguish K=2 from K=3.
- **Fix:** Clarify: RSI₃ < 1 → K≤3 as upper bound; 2026/27 at-cap → rules out K≥4;
  K=3 vs K=2 distinguishable via IMM TPS test outcomes (all three firms pass).

### M4: Cournot upper bound mislabeled "evaluated at residual demand"
- **Location:** model.tex §3.5
- **Problem:** L = 1/(K·|ε|) uses market demand elasticity, not residual demand elasticity.
  In symmetric case they coincide, but the label is misleading.
- **Fix:** Change to "evaluated at market demand (= residual demand elasticity in the symmetric case)"

### M5: Holmberg (2008) conditions understated in Proposition 2
- **Location:** model.tex §3.4
- **Problem:** Missing: distributional regularity conditions on demand uncertainty
- **Fix:** Add qualifying phrase: "Under the conditions of Holmberg (2008), including
  stochastic demand with continuous support..." with footnote on which conditions hold here.

### M6: Anderson-Xu (2005) contribution overstated
- **Location:** literature.tex §2.1
- **Problem:** Paper attributes directional shift result (contracts/caps → competitive) to
  Anderson-Xu, but this is primarily Allaz-Vila. Anderson-Xu prove existence, not direction.
- **Fix:** Separate: Allaz-Vila → forward contracts reduce markups; Anderson-Xu → existence of SFE with both instruments.

### M7: "Order of magnitude" claim vs. HHI thresholds unsubstantiated
- **Location:** discussion.tex §6.1
- **Problem:** HHI is a concentration index, not a markup measure. Cannot compare Lerner to
  "what HHI thresholds would suggest" without the Cournot conversion step.
- **Fix:** Either remove the claim or provide the Cournot conversion: L = 1/(K·|ε|) with
  K=3, ε≈0.5 implies L≈0.67, consistent with SFE estimate.

---

## MINOR Issues

### m1: DATA_PATH in 04_calibrate.R breaks when sourced
- **Location:** Analysis/R/04_calibrate.R, line ~29
- **Fix:** Replace `sys.frame(1)$ofile` with `.here`

### m2: MR derivation missing intermediate step
- **Location:** model.tex §3.3, Equations (5)→(7)
- **Fix:** Add one line showing dπ/dS_i before MR expression

### m3: "No evidence of strategic withholding" in 2023/24 contradicts TPS story
- **Location:** calibration.tex §4.2
- **Fix:** Change to "no observable strategic pricing, due to effective TPS mitigation"

### m4: Fringe cost = strategic cost assumption should be flagged
- **Location:** calibration.tex §4.4
- **Fix:** Add footnote noting c_f = c is conservative; if c_f < c, fringe supply increases and markups fall

### m5: Table decimal precision inconsistent (whole dollars vs. $X.XX)
- **Location:** results.tex Table 1 vs Tables 2–3
- **Fix:** Standardize to whole dollars in Tables 2–3, or add note "prices rounded to nearest dollar"

---

## Positive Findings
1. ODE derivation (Eq. 7–10) is algebraically correct
2. RK4 solver handles VRR kink-point discontinuities correctly
3. Benchmark year selection and 2024/25 exclusion are well-justified
4. Limitations subsection is unusually candid and complete

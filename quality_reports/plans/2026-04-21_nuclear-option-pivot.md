# Nuclear Option: Structural Diagnosis Pivot

**Status:** STORED PLAN — not implemented. Hold for activation.
**Trigger:** referee pushback on the Holmberg-under-scarcity identification
or the $329 vs. $500 counterfactual dismissal that the 2026-04-21 conservative
fix does not close.

---

## What triggered this plan

On 2026-04-21 a substantive critique flagged that the 2026/27 RTO auction
cleared ~314 MW below its reliability requirement (−0.23%) and the 2027/28
auction cleared 6,623 MW short (−4.69%). The critique identified four
vulnerabilities, all verified against the paper and `Data/cleaned/calibration_master.csv`:

1. **Holmberg mechanism under scarcity is non-discriminating.** The
   Klemperer--Meyer intuition behind Holmberg selection (rivals' capacity
   binds → residual demand inelastic → p* = p̄) is indistinguishable from
   physical scarcity clearing at the cap. An atomistic market with aggregate
   supply below $q_a$ produces the same at-cap outcome.

2. **K ≤ 3 identification breaks.** The `results.tex:169-171` claim that
   2026/27 at-cap is "consistent with $K \leq 3$ but inconsistent with
   $K \geq 4$" requires that four symmetric sellers plus the fringe can
   actually supply $D(\$228)$. The 2026/27 shortfall is evidence they cannot,
   so $K \geq 4$ also predicts at-cap clearing.

3. **Counterfactual transfer is Point-(a)-sensitive.** If Shapiro's implicit
   pre-settlement Point (a) is ~$500 (a CT-reference value the settlement
   slides visualize, and consistent with the pre-settlement VRR design),
   then under scarcity the SFE forces $p^* = \$500$ and the "$612M vs
   $17.16B" gap collapses.

4. **The allocative argument in Section 7 is the stronger finding and is
   sharpened, not threatened, by the shortfall.**

The conservative fix (shipped 2026-04-21) adds a margin column to Table 1,
a limitation paragraph to Section 8, and softens "35 times smaller" in the
abstract/intro/conclusion. It concedes the vulnerability without restructuring
the paper.

---

## When to activate the pivot

Activate when one or more of the following occurs:

- A referee independently raises the Holmberg-under-scarcity concern and is
  not satisfied by the limitation paragraph.
- A referee challenges the new-design $329 as the pre-settlement
  counterfactual, preferring pre-settlement $500.
- Two or more referees flag the 2026/27 shortfall as a first-order concern
  rather than a secondary caveat.
- The "$612M vs $21B" framing becomes a liability in discussion with editors
  or at workshops.

Do **not** activate on a single referee comment that the conservative fix
already answers. The conservative fix was designed to close the issue at
low structural cost.

---

## Core argument inversion

**Current framing:** *"Shapiro's \$21B figure is ~35× too large because the
SFE strategic counterfactual is closer to the settlement cap than the
administrative VRR counterfactual Shapiro implicitly used."*

**Pivoted framing:** *"Shapiro's number is approximately right on magnitude
for structural reasons the settlement design does not address. The 2026/27
and 2027/28 auctions cleared below their reliability requirements, which
means the cap binds because of capacity adequacy failure, not oligopolistic
markup. Suppressing the scarcity price truncates the entry signal that would
otherwise attract adequate supply."*

The pivot reframes from *distributional* (how much rent does the settlement
transfer?) to *allocative* (what does the settlement tell investors about
scarcity?). This is the contribution that the shortfall sharpens rather than
threatens.

---

## Section-by-section pivot summary

- **Abstract:** Lead with "markups → scarcity" transition, not "\$612M vs
  \$21B." Main finding: 2026/27 is PJM's first supply-short BRA under the
  new design; the cap binds because structural shortfall produces a scarcity
  price that the cap truncates. Welfare implication is informational
  (suppressed entry signal), not distributional.

- **Section 5 (Results):** Margin column becomes the anchor of the
  analysis. Recast old-design cap-binding ($K \leq 3$ in 2021/22--2025/26)
  as the *strategic-markup regime* (identified), new-design cap-binding as
  the *scarcity regime* (not strategically identified, overdetermined).

- **Section 6 (Concentration):** $K$-identification argument restricted to
  supply-adequate years. For 2026/27 and 2027/28, the table is informative
  about the *counterfactual* markup under adequacy, not about observed
  behavior.

- **Section 7 (Lead time):** Elevated to the paper's core contribution.
  Under physical scarcity, the cap suppresses the price signal that drives
  entry/retention decisions precisely when the signal is most needed. The
  informational cost is larger, not smaller, in a supply-short world.

- **Section 8 (21B claim):** Rewritten. Shapiro's magnitude is roughly right
  because the pre-settlement VRR with scarcity clears near $500 (via
  Holmberg). Disagreement with Shapiro becomes interpretive, not
  quantitative: Shapiro frames the transfer as "rents captured," the
  structural view frames it as "scarcity price suppressed by administrative
  fiat addressing a symptom rather than the cause."

- **Section 9 (Policy alternatives):** Reframe transmission/VRR
  steepening/entry as *addressing the underlying shortfall*, not as
  *reducing strategic markup*. The settlement suppresses the price; the
  structural channels supply the capacity.

- **Conclusion:** Three new findings:
  1. 2026/27 is PJM's transition from markup-constrained to
     scarcity-constrained cap-binding.
  2. The cap at \$325 is binding not because it is below competitive entry
     economics (it is 53% above Net CONE) but because it is below the
     scarcity price structural shortfall produces under the pre-settlement
     VRR.
  3. SFE $K$-identification requires supply sufficiency; new-design years
     fail this condition. The allocative (lead-time) argument does not
     rely on $K$-identification.

---

## What to preserve

- Theoretical model (Section 4): retained, possibly moved to appendix.
- LDA analysis: preserved. Constrained LDAs likely have their own scarcity
  channels distinct from RTO-level.
- Calibration data: preserved. Re-used for descriptive claims.
- TPS-mitigation discussion in old-design years: preserved as supporting
  evidence for the markup regime.

## What to drop or demote

- "\$612M vs \$21B" framing — drop.
- "35 times smaller" language — drop.
- Strong claims that SFE identifies $K$ in new-design years — drop.
- Claim that Shapiro's number is wrong — invert.

---

## Method-level implications

- SFE model remains internally valid. Its predictions are descriptive, not
  identifying, in the scarcity regime.
- $K$-sensitivity table (`tab:K_sensitivity` in `results.tex`) remains but
  is flagged as informative only in supply-adequate regimes. Add a row or
  column marking where the interior prediction requires supply beyond
  what the fringe + K sellers can deliver.
- Cost sensitivity (`tab:cost_sensitivity`) is unaffected.

---

## Decision checklist before pivoting

- [ ] Two or more referees independently raise the Holmberg-under-scarcity
      or pre-settlement Point (a) concerns.
- [ ] Conservative fix (limitation paragraph + margin column + softened
      language) has failed to close the issue in at least one review cycle.
- [ ] The pivoted framing is defensible against the next round of
      criticism (e.g., would not invite a referee to ask "what is the
      pre-settlement Point (a)?").
- [ ] I am comfortable stating that Shapiro is "approximately right for the
      wrong reasons" rather than "wrong by 35×."

---

## Estimated effort

- Writing: ~2-3 days of focused work (abstract, intro, Section 7 expansion,
  Section 8 rewrite, conclusion).
- Empirical work: modest. Verify LDA-level shortfall values. Potentially
  decompose the 2027/28 shortfall into "offers above cap" vs. "no offer."
- Tables: regenerate `tab:baseline` with scarcity regime annotation;
  extend `tab:K_sensitivity` with supply-sufficiency flag.

Not a ground-up rewrite. Substantial section-level restructuring with core
empirical material preserved.

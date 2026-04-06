# Session Log: 2026-04-05 -- Narrow Law-and-Econ Framing Retrenchment

**Status:** COMPLETED

## Objective

Retrench the datacenter paper's claims from a broader welfare judgment ("the Board made the wrong move" / "more consistent with collective action than regulatory correction of welfare losses") to the narrower defensible law-and-economics claim the evidence actually supports: Loudoun's institutional setting separated who captured fiscal gains, who bore localized burdens, and who held approval rights, and the housing evidence does not show localized losses robustly enough to clearly justify the 2025 shift from by-right development to discretionary Special Exception review. Build the whole paper around the caution level expressed by the sentence "the design is better at ruling out a strong harm narrative than at establishing a precise zero effect."

## Key Context

User direction: the abstract and conclusion were sounding like a paper with cleaner identification than we actually have. The defensible contribution is a narrow institutional claim using Coase, Calabresi-Melamed, Olson, and Fischel in a disciplined way. Avoid sliding into a broader welfare conclusion the evidence does not support.

## Changes Made

| File | Change | Reason |
|------|--------|--------|
| `paper/datacenter_paper.tex` abstract L49 | Replaced "more consistent with collective action... than regulatory correction of demonstrated welfare losses" with institutional-separation + "does not show localized losses robustly enough to clearly justify the 2025 shift from by-right to discretionary Special Exception review, though the design is better at ruling out a strong harm narrative than at establishing a precise zero effect" | Remove welfare overclaim; foreground the narrow law-and-econ claim and the caution level |
| `paper/datacenter_paper.tex` intro L65 | Replaced "more consistent with collective action... than regulatory correction of welfare losses" with "complicates a straightforward welfare justification... Whether the housing evidence is robust enough to clearly justify that reallocation of decision rights is the law-and-economics question this paper takes up" | Frame the paper's contribution as the narrow question, not the welfare verdict |
| `paper/datacenter_paper.tex` discussion L249 | Replaced "incentives consistent with over approval" with Calabresi-Melamed decoupling language + explicit disclaimer "The claim here is not that by-right approvals were welfare-incorrect" | User's own reviewer constraint forbids asserting over-approval; make the narrowness explicit |
| `paper/datacenter_paper.tex` discussion L251 | Replaced "against the majority's fiscal interest" with "despite the majority's diffuse fiscal stake" + "describes the collective-action structure of the shift, not its welfare consequences" | Remove welfare claim embedded in the Olson paragraph |
| `paper/datacenter_paper.tex` discussion L253 | Tightened reallocation sentence to match "ruling out strong harm narrative vs establishing precise zero" caution level | Match the caution level expressed elsewhere |
| `paper/datacenter_paper.tex` discussion L255 fiscal-risk para | Softened "likely require substantial residential tax rate increases" to "could require residential tax rate adjustments"; replaced "fiscal interests were served by the by-right regime" with neutral "currently receives the tax savings funded by the sector"; added disclaimer that pass-through magnitude depends on parameters not estimated | Avoid pretending pass-through was estimated; remove implicit welfare endorsement of by-right regime |
| `paper/datacenter_paper.tex` conclusion L262 | Replaced "more consistent with collective action than regulatory correction of demonstrated welfare losses, and introduces fiscal risk" with narrow institutional claim + explicit disclaimer "This is a narrow law-and-economics claim about whether the evidence justifies the reallocation, not a broader welfare judgment about whether the Board should have acted differently" | Match abstract; make the scope of the claim unmistakable |

## Design Decisions

| Decision | Alternatives Considered | Rationale |
|----------|------------------------|-----------|
| Propose edits before applying | Apply directly | User has explicit proofreading-protocol (propose first) and user was making a substantive argumentative shift that deserved review |
| Drop "reallocation of decision rights" phrasing in abstract/conclusion | Keep it (more precise) | User found it "clogged"; "shift from by-right development to discretionary Special Exception review" names the same thing more cleanly |
| Soften "likely require" to "could require" | Keep "likely" | User flagged that "likely" implies a pass-through elasticity not actually estimated |
| Self-correct semicolon and colon in Edit 3 before applying | Apply as originally drafted | User's saved feedback memory forbids semicolons and colons in prose where avoidable |
| Use pdflatex rather than xelatex | Fall back on xelatex-dev | xelatex not on PATH on this machine; paper uses only vanilla LaTeX features (amsmath, fontenc, microtype) so pdflatex produces identical output |

## Incremental Work Log

- Read full paper (274 lines) to locate every instance where the draft slid from the narrow institutional claim into a broader welfare conclusion
- Identified seven specific overclaims (abstract final sentence, intro final sentence of para 3, discussion "over approval" line, discussion "against majority's fiscal interest", discussion final sentences of para 3, discussion fiscal-risk paragraph, conclusion final sentence)
- Drafted proposed replacements and presented them to user before editing
- User approved with two tightenings: (1) simplify "reallocation of decision rights from by-right..." to "shift from by-right...", (2) soften "likely require" to "could require"
- Self-caught semicolon and colon in draft Edit 3 and repunctuated before applying per writing-style feedback memory
- Applied all seven edits via Edit tool
- Compiled with pdflatex (xelatex not available on this machine); paper uses only vanilla LaTeX so output is identical

## Verification Results

| Check | Result | Status |
|-------|--------|--------|
| pdflatex 3-pass compile | Exit 0 | PASS |
| bibtex resolution | All refs resolved | PASS |
| Page count | 28 pages (was 27, expected increase from added framing) | PASS |
| No compile errors | Confirmed | PASS |
| Overfull hboxes | 2, both in included table files (tab_main_results, tab_incidence), pre-existing and unrelated to these edits | PRE-EXISTING |

## Open Questions / Blockers

None.

## Next Steps

- User may want to re-read the paper straight through to verify the narrowed claim holds consistently from abstract through conclusion
- The two pre-existing overfull hboxes in included table files could be addressed in a future session if desired
- If user wants to push further, the literature-review paragraph on Coase/Calabresi-Melamed (L107-108) already uses the "who holds the initial entitlement" language that the new framing builds on, so the paper is now internally consistent on the narrow institutional claim

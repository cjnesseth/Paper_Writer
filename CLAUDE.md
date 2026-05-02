# CLAUDE.md — PJM Capacity Auction SFE Paper

**Paper:** *Capping the Capacity Market: A Supply Function Equilibrium Analysis of Price Controls in PJM*
**Active branch:** `PJM-Paper` (ahead of `main`; PR not yet opened)
**Working title before pivot:** "Calibrated SFE Simulation of Market Power in PJM Capacity Auctions" — the project re-framed around the Jan 2025 Shapiro settlement and its $325/MW-day cap. Old framing artifacts may still appear in stale notes.

---

## Core principles

- **Plan first** for non-trivial work. Save plans to `quality_reports/plans/YYYY-MM-DD_description.md`.
- **Verify after** every task: compile the paper, render figures, confirm output. See `.claude/rules/verification-protocol.md`.
- **Single source of truth:** the LaTeX in `Paper/` is authoritative. Slides, figures, and any Quarto derivatives must follow.
- **Quality gates** in `.claude/rules/quality-gates.md`: 80 = commit, 90 = PR, 95 = submission.
- **Auto-memory** at `~/.claude/projects/-home-chris-projects-Paper-Writer/memory/` is the persistence mechanism — write/update memories there, not in CLAUDE.md or MEMORY.md in the repo root.

---

## Repo layout (what actually exists)

```
Paper_Writer/
├── CLAUDE.md                    ← this file
├── Bibliography_base.bib        ← Zotero export (used as ../Bibliography_base from Paper/)
├── Paper/
│   ├── main.tex                 ← entry point; \input{header} from ../Preambles
│   ├── sections/                ← see "Current sections" below
│   └── tables/                  ← R-generated .tex tables
├── Preambles/header.tex         ← loaded via TEXINPUTS=../Preambles
├── Figures/                     ← fig01–fig06, fig_bunching (PDFs from R)
├── Data/{raw,cleaned}/          ← inputs and calibration_master.csv
├── Analysis/
│   ├── *.py                     ← parsers (01–04): planning params, BRA results, IMM/HHI, master compile
│   └── R/                       ← 01_vrr_demand → 10_bunching (the SFE solver pipeline)
├── Slides/                      ← presentation.tex (15-min Beamer/metropolis) + speaker scripts
├── Quarto/                      ← only emory-clean.scss; no active .qmd files for this paper
├── scripts/                     ← quality_score.py, run_pipeline.sh, sync_to_docs.sh
├── quality_reports/{plans,session_logs,merges}/
├── explorations/                ← sandbox; see exploration-fast-track.md
├── templates/                   ← session-log.md, quality-report.md, etc.
├── master_supporting_docs/      ← reference papers (PDF processing rule applies)
├── docs/                        ← deployed slide HTML (sync target)
└── guide/, README.md            ← public-facing project documentation
```

---

## Current paper state (as of 2026-04-27, latest commit `65dc0c5`)

All sections written. Zero `\TODO` stubs. Body 37 pages, total 45.

| # | File | Topic |
|---|------|-------|
| 1 | `introduction.tex` | Shapiro complaint → settlement; $325/$175 cap-and-floor |
| 2 | `literature.tex` | Capacity markets, SFE theory, market power |
| 3 | `institutional.tex` | PJM RPM, VRR, BRA process, cap mechanics |
| 4 | `model.tex` | SFE setup, FOCs, ODE, at-cap (Holmberg) regime |
| 5 | `calibration.tex` | All 7 BRAs (2021/22 → 2027/28); ACR, RSI, fringe |
| 6 | `results.tex` | Baseline markups + comparative statics |
| 7 | `cap_incidence.tex` | Cap-incidence panel (Phase A pivot, 2026-04) |
| 8 | `bunching.tex` | Aggregate bunching diagnostic (Phase B pivot) |
| 9 | `sec8_21billion.tex` | Case study: $21B claim deconstruction (Phase C) |
| 10 | `conclusion.tex` | Three findings; policy implications |
| A1 | `appendix_derivations.tex` | SFE math |
| A2 | `appendix_figures.tex` | Supporting figures |

`sec9_policy_alternatives.tex` exists in the folder but is **not** included in `main.tex` — old draft material, do not re-include without asking.

The previously listed `discussion.tex` no longer exists; its content was absorbed into §§ 7–10.

---

## Compile commands

Paper (3 passes from `Paper/`):
```bash
cd Paper && \
  TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex && \
  BIBINPUTS=..:$BIBINPUTS bibtex main && \
  TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex && \
  TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex
```
The `TEXINPUTS=../Preambles` is required — `\input{header}` will not resolve without it.

Slides (3 passes from `Slides/`, `pdflatex` not xelatex):
```bash
cd Slides && \
  pdflatex -interaction=nonstopmode presentation.tex && \
  pdflatex -interaction=nonstopmode presentation.tex && \
  pdflatex -interaction=nonstopmode presentation.tex
```

Quality score: `python scripts/quality_score.py Paper/main.tex`

R pipeline (from repo root): scripts in `Analysis/R/` are numbered 01–10 and meant to be run in order. They produce `.rds` files and the figures/tables consumed by `main.tex`.

---

## Working with me on this project

- Skills are auto-discovered from `.claude/skills/` — invoke any of them via the Skill tool when their description matches. I do not need an enumeration here.
- Path-scoped rules in `.claude/rules/` load automatically when matching files are touched. Read them when relevant; don't re-derive their content.
- Domain non-obvious: PJM auction *date* ≠ delivery year. Lead times in `Analysis/04_compile_master.py` were caught wrong in April 2026 — see the BRA-dates feedback memory before citing any auction date.
- Reviewer agents (`tikz-reviewer`, `domain-reviewer`, `proofreader`, `r-reviewer`, `pedagogy-reviewer`, `slide-auditor`, `verifier`, `quarto-critic`/`-fixer`, `beamer-translator`) are configured under `.claude/agents/` and exposed via the Agent tool.

---

## What to do if context is fresh

1. Read this file.
2. Read the most recent plan in `quality_reports/plans/`.
3. `git log --oneline -10` and `git status` for current state.
4. Read MEMORY index (loaded automatically) and any memory it points to.
5. State your understanding before acting.

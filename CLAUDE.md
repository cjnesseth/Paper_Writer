# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** IO Paper 2: Calibrated SFE Simulation of Market Power in PJM Capacity Auctions
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Single source of truth** -- Paper `.tex` is authoritative; slides derive from it
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
io-paper-2/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Zotero-exported .bib
├── Paper/                       # Main paper .tex + sections
│   ├── main.tex
│   ├── sections/                # Modular \input sections
│   └── tables/                  # Generated .tex tables
├── Figures/                     # Publication-ready figures
├── Data/                        # Raw + cleaned data
│   ├── raw/
│   └── cleaned/
├── Analysis/                    # R scripts (estimation, simulation)
├── Preambles/header.tex         # LaTeX preamble
├── Slides/                      # (Future) Beamer presentation slides
├── scripts/                     # Utility scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Reference papers
```

---

## Commands

```bash
# Paper compilation (3-pass, from Paper/ directory)
cd Paper && TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex
BIBINPUTS=..:$BIBINPUTS bibtex main
TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode main.tex

# Slide compilation (future -- 3-pass XeLaTeX)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Quality score
python scripts/quality_score.py Paper/main.tex
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for circulation |
| 95 | Excellence | Submission-ready |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass LaTeX + bibtex |
| `/proofread [file]` | Grammar/typo review |
| `/review-r [file]` | R code quality review |
| `/validate-bib` | Cross-reference citations |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/devils-advocate` | Challenge research design |

---

## Current Paper State

| Section | File | Status | Description |
|---------|------|--------|-------------|
| Introduction | `sections/introduction.tex` | Stub | Market power in capacity markets; SFE simulation approach |
| Literature | `sections/literature.tex` | Skeleton | Citations only, no prose; 5 subsections |
| Institutional | `sections/institutional.tex` | Stub | PJM RPM, VRR curve, BRA process, mitigation rules |
| Model | `sections/model.tex` | Stub | SFE setup, FOCs, ODE system, equilibrium selection |
| Calibration | `sections/calibration.tex` | Stub | PJM data sources, parameter choices, baseline structure |
| Results | `sections/results.tex` | Stub | Baseline markups + 4 comparative statics |
| Discussion | `sections/discussion.tex` | Stub | Compare to IMM metrics; VRR and transmission policy |
| Conclusion | `sections/conclusion.tex` | Stub | Policy implications |

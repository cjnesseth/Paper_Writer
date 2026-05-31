# CLAUDE.MD -- Academic Project Development with Claude Code

<!-- HOW TO USE: Replace [BRACKETED PLACEHOLDERS] with your project info.
     Customize Beamer environments and CSS classes for your theme.
     Keep this file under ~150 lines — Claude loads it every session.
     See the guide at docs/workflow-guide.html for full documentation. -->

**Project:** [YOUR PROJECT NAME]
**Institution:** [YOUR INSTITUTION]
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Single source of truth** -- Beamer `.tex` is authoritative; Quarto `.qmd` derives from it
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
[YOUR-PROJECT]/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images
├── Preambles/header.tex         # LaTeX headers
├── Slides/                      # Beamer .tex files
├── Quarto/                      # RevealJS .qmd files + theme
├── docs/                        # GitHub Pages (auto-generated)
├── scripts/                     # Utility scripts + R code
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing slides
```

---

## Commands

```bash
# Paper (3-pass, pdfLaTeX — XeLaTeX not installed; pdflatex is standard for econ journals)
cd Paper && TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode rggi_carbon_pricing_reverse.tex
BIBINPUTS=..:$BIBINPUTS bibtex rggi_carbon_pricing_reverse
TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode rggi_carbon_pricing_reverse.tex
TEXINPUTS=../Preambles:$TEXINPUTS pdflatex -interaction=nonstopmode rggi_carbon_pricing_reverse.tex

# R analysis pipeline (writes Tables/*.tex and Figures/*.pdf)
Rscript scripts/R/00_setup.R   # then 01_* -> 02 -> 03 -> 04 -> 05 -> 06 -> 07

# Quality score
python scripts/quality_score.py Paper/rggi_carbon_pricing_reverse.tex

# (Dormant) Legacy slide commands: xelatex on Slides/, Quarto deploy via scripts/sync_to_docs.sh
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/deploy [LectureN]` | Render Quarto + sync to docs/ |
| `/extract-tikz [LectureN]` | TikZ → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-r [file]` | R code quality review |
| `/qa-quarto [LectureN]` | Adversarial Quarto vs Beamer QA |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/translate-to-quarto [file]` | Beamer → Quarto translation |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |

---

<!-- CUSTOMIZE: Replace the example entries below with your own
     Beamer environments and Quarto CSS classes. These are examples
     from the original project — delete them and add yours. -->

## Beamer Custom Environments

| Environment       | Effect        | Use Case       |
|-------------------|---------------|----------------|
| `[your-env]`      | [Description] | [When to use]  |

<!-- Example entries (delete and replace with yours):
| `keybox` | Gold background box | Key points |
| `highlightbox` | Gold left-accent box | Highlights |
| `definitionbox[Title]` | Blue-bordered titled box | Formal definitions |
-->

## Quarto CSS Classes

| Class              | Effect        | Use Case       |
|--------------------|---------------|----------------|
| `[.your-class]`    | [Description] | [When to use]  |

<!-- Example entries (delete and replace with yours):
| `.smaller` | 85% font | Dense content slides |
| `.positive` | Green bold | Good annotations |
-->

---

## Current Project State

**Active deliverable: an empirical economics paper (not lecture slides).**
*"Carbon Pricing in Reverse: Evidence from Virginia's Exit and Re-Entry into RGGI"* —
target JAERE/JEEM/Energy Economics; eventual dissertation chapter.

- **Manuscript:** `Paper/rggi_carbon_pricing_reverse.tex` (plain LaTeX article, **pdfLaTeX** —
  XeLaTeX is not installed in this environment and is not needed for a journal article).
- **Analysis:** `scripts/R/` (00–07) — R scripts do all estimation and write `Tables/*.tex`
  and `Figures/*.pdf`; the manuscript `\input`/`\includegraphics` them. No hand-entered numbers.
- **Data:** public sources only (EIA, EPA CEMS, PJM, RGGI, NOAA, BEA/Census, public SCC
  dockets). No Dominion internal data; no SAS.
- **Spec/plan:** `quality_reports/specs/2026-05-30_rggi-paper.md`,
  `quality_reports/plans/2026-05-30_rggi-paper.md`.
- **Status:** Phase 0 (repo skeleton) complete; Phase 1 (`/lit-review` + bibliography) next.

The slide infrastructure (Beamer/Quarto skills, lecture workflow) is retained but dormant.

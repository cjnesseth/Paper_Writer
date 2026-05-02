---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
---

# Beamer ↔ Quarto Sync (currently inactive for this project)

This project has **one** Beamer slide deck — `Slides/presentation.tex` (15-minute talk for the PJM paper) — and **no** active Quarto target. `Quarto/` only contains an SCSS theme stub. There is therefore nothing to sync today.

If a Quarto translation is ever added (e.g. for web hosting via `docs/`), enforce the SSOT chain in `single-source-of-truth.md`:

- The Beamer `.tex` is authoritative; the Quarto `.qmd` is derived.
- Every edit to the Beamer source must be propagated to the Quarto file in the same task, before reporting completion.
- Compile both (3-pass `pdflatex` for Beamer, `./scripts/sync_to_docs.sh` for Quarto) before declaring done.

## Common Beamer → Quarto translations (for reference)

| Beamer | Quarto |
|--------|--------|
| `\textcolor{positive}{x}` | `[x]{.positive}` |
| `\textcolor{negative}{x}` | `[x]{.negative}` |
| `\begin{highlightbox}…\end{highlightbox}` | `::: {.highlightbox} … :::` |
| `$formula$` | `$formula$` |
| `\item x` | `- x` |

## Active mapping

(none — the project has a single standalone Beamer deck)

#!/usr/bin/env bash
# run_pipeline.sh -- Master pipeline for the PJM SFE paper.
#
# Chains Python parsers, R analysis scripts, and LaTeX compilation in the
# correct dependency order. Run from repo root (or from anywhere; the script
# resolves paths relative to itself).
#
# Usage:
#   bash scripts/run_pipeline.sh
#
# Requires:
#   - Python 3 with pdfplumber, pandas
#   - R with ggplot2, dplyr, tidyr
#   - TeX distribution with pdflatex, bibtex, booktabs package
#
# Halts on first error.

set -euo pipefail
cd "$(dirname "$0")/.."

echo "==== [1/6] Parsing IMM RSI/HHI data from PDF reports ===="
python3 Analysis/03_parse_imm_hhi.py

echo "==== [2/6] Baseline SFE results (all seven BRAs) ===="
Rscript Analysis/R/05_results_baseline.R

echo "==== [3/6] Comparative statics (K, VRR slope, fringe) ===="
Rscript Analysis/R/06_comparative_statics.R

echo "==== [4/6] LDA-level analysis and table ===="
Rscript Analysis/R/07_lda_analysis.R

echo "==== [5/6] Cost sensitivity and Table tab_cost_sensitivity.tex ===="
Rscript Analysis/R/08_cost_sensitivity.R

echo "==== [6/6] Compiling LaTeX paper (3-pass + bibtex) ===="
cd Paper
TEXINPUTS=../Preambles:${TEXINPUTS:-} pdflatex -interaction=nonstopmode main.tex
BIBINPUTS=..:${BIBINPUTS:-} bibtex main
TEXINPUTS=../Preambles:${TEXINPUTS:-} pdflatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:${TEXINPUTS:-} pdflatex -interaction=nonstopmode main.tex
cd ..

echo "==== Done ===="
echo "Output: Paper/main.pdf"

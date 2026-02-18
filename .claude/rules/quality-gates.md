---
paths:
  - "Paper/**/*.tex"
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
  - "Analysis/**/*.R"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for circulation
- **95/100 = Excellence** -- submission-ready

## Research Papers (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Compilation failure | -100 |
| Critical | Mathematical errors in proofs/derivations | -30 |
| Critical | Misattributed results | -20 |
| Critical | Undefined citation | -15 |
| Major | Missing identification discussion | -10 |
| Major | Inconsistent notation across sections | -5 |
| Major | Unreferenced empirical claims | -5 |
| Major | Overfull hbox > 10pt | -3 |
| Minor | Style inconsistencies | -2 |
| Minor | Overfull hbox 1-10pt | -1 |
| Minor | Long lines (>100 chars in source) | -1 |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs (e.g., wrong IV construction) | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing set.seed() | -10 |
| Major | Missing figure generation | -5 |

## Beamer Slides (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |

## Quarto Slides (.qmd)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Compilation failure | -100 |
| Critical | Equation overflow | -20 |
| Critical | Broken citation | -15 |
| Critical | Typo in equation | -10 |
| Major | Text overflow | -5 |
| Major | TikZ label overlap | -5 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 per slide |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (IO Estimation)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates (demand elasticities) | 1e-4 | Numerical precision of optimization |
| Standard errors | 1e-3 | Bootstrap/clustering variation |
| Lerner indices / markups | 1e-4 | Derived from estimated parameters |
| Market shares | 1e-6 | Observed data, should match exactly |
| First-stage F-statistics | 1e-2 | Diagnostic, less precision needed |
| Coverage rates (simulation) | +/- 0.01 | MC variability with B reps |

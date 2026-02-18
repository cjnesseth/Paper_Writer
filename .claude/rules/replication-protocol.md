---
paths:
  - "Analysis/**/*.R"
  - "scripts/**/*.R"
---

# Replication-First Protocol

**Core principle:** Replicate established stylized facts and key results from the literature BEFORE extending with novel analysis.

---

## Phase 1: Inventory & Baseline

Before writing any R code:

- [ ] Identify key stylized facts from electricity market / capacity auction literature
- [ ] Record gold standard numbers from reference papers:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Lerner index | Table 2, Col 3 | 0.15 | (0.03) | Peak hours, PJM |
```

- [ ] Store targets in `quality_reports/replication_targets.md` or as RDS
- [ ] Document data sources:

| Source | Data | Access | Notes |
|--------|------|--------|-------|
| PJM Data Portal | Capacity auction results | Public | RPM BRA results by delivery year |
| EIA Form 860 | Generator characteristics | Public | Nameplate capacity, fuel type, location |
| EIA Form 923 | Generation and fuel data | Public | Monthly generation by plant |
| FERC filings | Market participant data | Public | Ownership, affiliations |

---

## Phase 2: Translate & Execute

- [ ] Follow `r-code-conventions.md` for all R coding standards
- [ ] Replicate existing results first -- don't "improve" during replication
- [ ] Match original specification exactly (covariates, sample, clustering, SE computation)
- [ ] Save all intermediate results as RDS

### PJM / Auction Data Pitfalls

| Issue | Trap | Prevention |
|-------|------|------------|
| Delivery year vs auction date | PJM runs BRA ~3 years ahead; the auction date ≠ delivery year | Always label which date concept is being used |
| Zone aggregation changes | PJM transmission zones have been reorganized over time | Document zone definitions by vintage |
| Capacity product types | Different products (annual, summer, limited) clear at different prices | Specify which product when reporting prices |
| MOPR / buyer-side mitigation | Minimum offer price rules changed multiple times | Track regulatory regime by auction year |
| New entry vs existing resources | Different offer rules and price formation dynamics | Separate in analysis or control explicitly |
| Incremental auctions | Supplemental auctions after BRA may adjust commitments | Clarify whether analysis uses BRA-only or includes IAs |
| Price units | $/MW-day is PJM convention; some papers convert to $/MW-year or $/kW-month | State units explicitly in every table/figure |

---

## Phase 3: Verify Match

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Integers (N, counts) | Exact match | No reason for any difference |
| Point estimates (elasticities) | < 1e-4 | Numerical optimization precision |
| Standard errors | < 1e-3 | Bootstrap/clustering variation |
| Lerner indices | < 1e-4 | Derived quantities |
| Market shares | < 1e-6 | Observed data |
| P-values | Same significance level | Exact p may differ slightly |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample construction, SE computation, default options, variable definitions), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/replication_report.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Original language:** [Stata/R/Python/etc.]
**R translation:** [script path]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- R version, key packages (with versions), data source
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication script: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with novel analysis (data center demand characterization, residual demand with lumpy bidders, etc.)
- [ ] Each extension builds on the verified baseline

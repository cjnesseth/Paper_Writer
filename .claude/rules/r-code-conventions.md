---
paths:
  - "**/*.R"
  - "Analysis/**/*.R"
  - "Figures/**/*.R"
  - "scripts/**/*.R"
---

# R Code Standards

**Standard:** Senior Principal Data Engineer + PhD researcher quality

---

## 1. Reproducibility

- `set.seed()` called ONCE at top (YYYYMMDD format)
- All packages loaded at top via `library()` (not `require()`)
- All paths relative to repository root
- `dir.create(..., recursive = TRUE)` for output directories

## 2. Function Design

- `snake_case` naming, verb-noun pattern
- Roxygen-style documentation
- Default parameters, no magic numbers
- Named return values (lists or tibbles)

## 3. Domain Correctness

- Verify estimator implementations match paper equations
- IV construction must match exclusion restriction argument
- Check instrument strength (first-stage F-statistics)
- Ensure clustering level matches data structure (auction-level, zone-level)
- Check known package bugs (document below in Common Pitfalls)

## 4. Visual Identity

```r
# --- Clean academic palette ---
primary_dark  <- "#2c3e50"
primary_blue  <- "#2980b9"
accent_gray   <- "#7f8c8d"
positive_green <- "#27ae60"
negative_red  <- "#c0392b"
highlight_orange <- "#e67e22"
```

### Custom Theme
```r
theme_paper <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      axis.title = element_text(size = base_size),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}
```

### Figure Dimensions for Paper
```r
# Single-column figure
ggsave(filepath, width = 6.5, height = 4.5, dpi = 300)

# Full-width figure
ggsave(filepath, width = 6.5, height = 3.5, dpi = 300)

# For Beamer slides (future)
# ggsave(filepath, width = 12, height = 5, bg = "transparent")
```

## 5. Table Generation

```r
# Preferred: modelsummary for regression tables
library(modelsummary)
modelsummary(models, output = "Paper/tables/table_name.tex",
             stars = c('*' = 0.10, '**' = 0.05, '***' = 0.01))

# Alternative: stargazer
library(stargazer)
stargazer(model, out = "Paper/tables/table_name.tex", type = "latex")
```

## 6. RDS Data Pattern

**Heavy computations saved as RDS; paper tables and figures load pre-computed data.**

```r
saveRDS(result, file.path(out_dir, "descriptive_name.rds"))
```

## 7. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| OLS demand estimation without instruments | Biased elasticities (simultaneous equations) | Always use IV/2SLS for price coefficients |
| Weak instruments in demand estimation | Unreliable IV estimates, worse than OLS | Report first-stage F; use Cragg-Donald/Kleibergen-Paap |
| Wrong clustering level | Invalid inference | Cluster at market/auction level; consider two-way clustering |
| Panel data — ignoring auction periodicity | Temporal aggregation bias | Align with PJM BRA schedule (annual delivery years) |
| Price unit confusion | Orders of magnitude errors | Document $/MW-day vs $/MW-year conversions explicitly |
| `fixest::feols` vs `AER::ivreg` SE defaults | Different SEs for same model | Explicitly specify `vcov` argument |
| Hardcoded paths | Breaks on other machines | Use relative paths from repo root |
| Missing `bg = "transparent"` in slide figures | White boxes on slides | Include in ggsave() for Beamer output |

## 8. Line Length & Mathematical Exceptions

**Standard:** Keep lines <= 100 characters.

**Exception: Mathematical Formulas** -- lines may exceed 100 chars **if and only if:**

1. Breaking the line would harm readability of the math (influence functions, matrix ops, finite-difference approximations, formula implementations matching paper equations)
2. An inline comment explains the mathematical operation:
   ```r
   # Residual demand: total demand minus rivals' aggregate supply at price p
   resid_demand_i <- total_demand(p) - sum(rival_supply[-i](p))
   ```
3. The line is in a numerically intensive section (simulation loops, estimation routines, inference calculations)

**Quality Gate Impact:**
- Long lines in non-mathematical code: minor penalty (-1 to -2 per line)
- Long lines in documented mathematical sections: no penalty

## 9. Code Quality Checklist

```
[ ] Packages at top via library()
[ ] set.seed() once at top
[ ] All paths relative
[ ] Functions documented (Roxygen)
[ ] Figures: explicit dimensions, 300 dpi
[ ] Tables: output to Paper/tables/ as .tex
[ ] RDS: every computed object saved
[ ] IV diagnostics: first-stage F reported
[ ] Comments explain WHY not WHAT
```

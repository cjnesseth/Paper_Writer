# ==============================================================================
# 02_make_sample_panel.R -- SYNTHETIC sample panel for pipeline development
# ==============================================================================
# !!! SIMULATED DATA -- NOT REAL. FOR TESTING THE PIPELINE ONLY. !!!
# This environment has no internet access, so the real 01_fetch_* scripts cannot
# run here. This script generates a realistic state-month panel with a KNOWN,
# injected treatment effect so that 03_scm/04_did/05_synthdid can be developed and
# shown to recover it. Outputs are written with a `synthetic = TRUE` flag and a
# loud filename. NOTHING produced from this data may appear in the manuscript as a
# finding. Replace with 02_tidy_panel.R output (real public data) before reporting.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

set.seed(20260531L)  # fixed seed for reproducibility (Date.now not used)

make_sample_panel <- function() {
  states <- c(TREATED_STATE, DONORS_NONRGGI_PJM, DONORS_CONT_RGGI)
  months <- seq(SAMPLE_START, SAMPLE_END, by = "month")
  grid <- CJ(state = states, month = months, sorted = FALSE)

  # --- state baselines (heterogeneous fixed effects) ---
  st <- data.table(
    state = states,
    base_retail = runif(length(states), 95, 135),     # $/MWh
    base_lmp    = runif(length(states), 28, 45),       # $/MWh
    base_co2    = runif(length(states), 0.8, 4.0),     # MM tons/month
    rggi_cont   = states %in% DONORS_CONT_RGGI         # continuous-RGGI donors
  )
  grid <- st[grid, on = "state"]

  # --- common time structure ---
  grid[, t := as.integer(month) ]
  grid[, t := (t - min(t)) / 30.4 ]                    # months since start
  grid[, mo := as.integer(format(month, "%m")) ]
  grid[, season := cos(2 * pi * (mo - 1) / 12) ]       # winter/summer swing
  grid[, gas := 3.0 + 0.6 * sin(2 * pi * t / 12) + rnorm(.N, 0, 0.4) ]  # $/MMBtu
  grid[, hdd := pmax(0, 700 * season + rnorm(.N, 0, 60)) ]
  grid[, cdd := pmax(0, -500 * season + rnorm(.N, 0, 60)) ]

  # --- treatment windows (VA in RGGI: entry .. exit) ---
  grid[, va := as.integer(state == TREATED_STATE) ]
  grid[, in_rggi_va := as.integer(state == TREATED_STATE &
                                  month >= EVENTS$entry & month < EVENTS$exit) ]
  # continuous-RGGI donors are "in RGGI" throughout (affects their carbon adder)
  grid[, adder := 0 ]
  grid[rggi_cont == TRUE, adder := 6 ]                 # $/MWh carbon adder
  grid[in_rggi_va == 1, adder := 6 ]

  # --- KNOWN injected effects (what the estimators should recover) ---
  # Retail: full carbon adder passes through (mechanical rider) -> ~+6 $/MWh.
  # Emissions: RGGI participation lowers VA CO2 by ~12%.
  TRUE_RETAIL_EFFECT <- 6.0
  TRUE_EMISSIONS_PCT <- -0.12

  grid[, retail := base_retail + 8 * gas + 0.004 * hdd + 0.003 * cdd +
                   1.5 * t + adder + rnorm(.N, 0, 2.5) ]
  grid[, lmp := base_lmp + 5 * gas + 0.5 * adder + 0.5 * t + rnorm(.N, 0, 2.0) ]
  grid[, co2 := base_co2 * (1 + 0.05 * gas - 0.02 * t) *
                (1 + ifelse(adder > 0, TRUE_EMISSIONS_PCT, 0)) +
                rnorm(.N, 0, 0.1) ]

  setorder(grid, state, month)
  out <- grid[, .(state, month, retail, lmp, co2, gas, hdd, cdd,
                  va, in_rggi_va, rggi_cont,
                  synthetic = TRUE)]
  attr(out, "true_effects") <- list(retail = TRUE_RETAIL_EFFECT,
                                    emissions_pct = TRUE_EMISSIONS_PCT)
  out[]
}

if (sys.nframe() == 0) {
  panel <- make_sample_panel()
  saveRDS(panel, file.path(DIRS$data_tidy, "panel_state_month_SAMPLE.rds"))
  fwrite(panel, file.path(DIRS$data_tidy, "panel_state_month_SAMPLE.csv"))
  message(sprintf("[02_make_sample_panel] SYNTHETIC panel: %d rows, %d states, %s..%s",
                  nrow(panel), uniqueN(panel$state),
                  format(min(panel$month)), format(max(panel$month))))
  message("  TRUE injected effects -> retail: +$6.0/MWh ; emissions: -12% (VA in RGGI)")
  message("  !!! SIMULATED -- not for the manuscript !!!")
}

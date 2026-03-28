# =============================================================================
# 01_vrr_demand.R
# VRR demand curve: D(p) and D'(p) for old (3-point) and new (4-point) designs
# =============================================================================
# Units: prices in $/MW-day, quantities in MW

# -----------------------------------------------------------------------------
# make_vrr_params()
# Build a named list of VRR parameters from a single-row data.frame
# (one row from calibration_master.csv).
# -----------------------------------------------------------------------------
make_vrr_params <- function(row) {
  design <- as.character(row$vrr_design)
  if (design == "old") {
    list(
      design = "old",
      pa = row$vrr_pt_a_price,   # price cap (1.5 × Net CONE)
      pb = row$vrr_pt_b_price,   # reliability-requirement price (0.75 × Net CONE)
      pc = 0,                    # floor price = 0 for old design
      qa = row$vrr_pt_a_mw,      # MW at price cap
      qb = row$vrr_pt_b_mw,      # MW at reliability-requirement price
      qc = row$vrr_pt_c_mw       # MW at p = 0
    )
  } else {
    # new design: pt_b and pt_c columns both equal the floor price p_f
    list(
      design = "new",
      pa = row$vrr_pt_a_price,   # price cap
      pf = row$vrr_pt_b_price,   # floor price (~$177/MW-day)
      qa = row$vrr_pt_a_mw,      # MW at price cap
      qb = row$vrr_pt_b_mw,      # MW at top of sloped segment (= MW at floor start)
      qd = row$vrr_pt_c_mw       # MW at floor (flat segment demand)
    )
  }
}

# -----------------------------------------------------------------------------
# vrr_demand(p, vp)
# D(p): quantity demanded at price p.
# vp: list returned by make_vrr_params()
# Vectorised over p.
# -----------------------------------------------------------------------------
vrr_demand <- function(p, vp) {
  if (vp$design == "old") {
    slope_upper <- (vp$qb - vp$qa) / (vp$pb - vp$pa)   # < 0
    slope_lower <- (vp$qc - vp$qb) / (0    - vp$pb)    # < 0
    dplyr::case_when(
      p >= vp$pa ~ vp$qa,
      p >= vp$pb ~ vp$qa + slope_upper * (p - vp$pa),
      p >= 0     ~ vp$qb + slope_lower * (p - vp$pb),
      TRUE       ~ vp$qc   # p < 0 not feasible but guard
    )
  } else {
    slope_upper <- (vp$qb - vp$qa) / (vp$pf - vp$pa)   # < 0
    dplyr::case_when(
      p >= vp$pa ~ vp$qa,
      p >= vp$pf ~ vp$qa + slope_upper * (p - vp$pa),
      TRUE       ~ vp$qd   # flat floor segment
    )
  }
}

# Vectorised-safe wrapper that avoids loading dplyr if not needed
vrr_demand_scalar <- function(p, vp) {
  if (vp$design == "old") {
    slope_upper <- (vp$qb - vp$qa) / (vp$pb - vp$pa)
    slope_lower <- (vp$qc - vp$qb) / (0 - vp$pb)
    if (p >= vp$pa) return(vp$qa)
    if (p >= vp$pb) return(vp$qa + slope_upper * (p - vp$pa))
    return(vp$qb + slope_lower * (p - vp$pb))
  } else {
    slope_upper <- (vp$qb - vp$qa) / (vp$pf - vp$pa)
    if (p >= vp$pa) return(vp$qa)
    if (p >= vp$pf) return(vp$qa + slope_upper * (p - vp$pa))
    return(vp$qd)
  }
}

# -----------------------------------------------------------------------------
# vrr_deriv_at(p, vp)
# D'(p) = dQ/dP at price p. Piecewise constant; returns 0 on flat segments.
# Scalar only (used inside the ODE).
# -----------------------------------------------------------------------------
vrr_deriv_at <- function(p, vp) {
  if (vp$design == "old") {
    if (p >= vp$pa) return(0)
    if (p >= vp$pb) return((vp$qb - vp$qa) / (vp$pb - vp$pa))
    return((vp$qc - vp$qb) / (0 - vp$pb))
  } else {
    if (p >= vp$pa) return(0)
    if (p >= vp$pf) return((vp$qb - vp$qa) / (vp$pf - vp$pa))
    return(0)   # flat floor segment
  }
}

# -----------------------------------------------------------------------------
# vrr_kinks(vp)
# Returns the interior kink prices (points where D'(p) is discontinuous).
# Used to restart the ODE integrator at each kink for accuracy.
# -----------------------------------------------------------------------------
vrr_kinks <- function(vp) {
  if (vp$design == "old") {
    c(vp$pb)   # one kink: at the reliability-requirement price
  } else {
    c(vp$pf)   # one kink: at the floor price
  }
}

# =============================================================================
# 01_vrr_demand.R
# VRR demand curve: D(p) and D'(p) for three designs:
#
#   "old"     -- 3-point piecewise linear (floor at p=0)
#                Used for delivery years 2021/22-2025/26
#   "new"     -- 2-point slope + flat floor (pt_b = pt_c = p_f)
#                Used for RTO/BGE/ATSI/DPL/SWMAAC in 2026/27
#   "new_4pt" -- 3-point slope + flat floor (pt_b > pt_c = p_f, pt_d = floor demand)
#                Used for EMAAC/MAAC/COMED/PS/PEPCO/PL/JCPL in 2026/27
# =============================================================================
# Units: prices in $/MW-day, quantities in MW

# -----------------------------------------------------------------------------
# make_vrr_params(row)
# Build a named list of VRR parameters from a single-row data.frame.
# Detects new_4pt automatically when vrr_pt_d_price is non-empty.
# -----------------------------------------------------------------------------
make_vrr_params <- function(row) {
  design <- as.character(row$vrr_design)

  if (design == "old") {
    list(
      design = "old",
      pa = as.numeric(row$vrr_pt_a_price),  # price cap (1.5 × Net CONE)
      pb = as.numeric(row$vrr_pt_b_price),  # reliability-requirement price
      pc = 0,                               # floor price = 0 for old design
      qa = as.numeric(row$vrr_pt_a_mw),
      qb = as.numeric(row$vrr_pt_b_mw),
      qc = as.numeric(row$vrr_pt_c_mw)
    )
  } else {
    # New design: detect whether there is a 4th anchor point.
    # 4-point LDAs have pt_d_price = floor price (~177.24) and pt_d_mw = floor demand.
    pd_price <- suppressWarnings(as.numeric(row$vrr_pt_d_price))
    pd_mw    <- suppressWarnings(as.numeric(row$vrr_pt_d_mw))
    has_4pt  <- !is.na(pd_price) && !is.na(pd_mw)

    if (has_4pt) {
      # new_4pt: pa > pb > pf=pc=pd, two sloped segments + flat floor
      list(
        design = "new_4pt",
        pa = as.numeric(row$vrr_pt_a_price),  # price cap
        pb = as.numeric(row$vrr_pt_b_price),  # intermediate kink
        pf = as.numeric(row$vrr_pt_c_price),  # floor price (= pt_d_price)
        qa = as.numeric(row$vrr_pt_a_mw),
        qb = as.numeric(row$vrr_pt_b_mw),     # MW at pb (top of lower slope)
        qc = as.numeric(row$vrr_pt_c_mw),     # MW at pf (top of flat floor)
        qd = pd_mw                             # MW at flat floor (demand below pf)
      )
    } else {
      # new (simple): pa > pf=pb, single sloped segment + flat floor
      list(
        design = "new",
        pa = as.numeric(row$vrr_pt_a_price),  # price cap
        pf = as.numeric(row$vrr_pt_b_price),  # floor price (= pt_b = pt_c)
        qa = as.numeric(row$vrr_pt_a_mw),
        qb = as.numeric(row$vrr_pt_b_mw),     # MW at top of flat floor (sloped side)
        qd = as.numeric(row$vrr_pt_c_mw)      # flat floor demand (below pf)
      )
    }
  }
}

# -----------------------------------------------------------------------------
# vrr_demand_scalar(p, vp)
# D(p): quantity demanded at price p. Scalar. Used in equilibrium finder.
# -----------------------------------------------------------------------------
vrr_demand_scalar <- function(p, vp) {
  if (vp$design == "old") {
    s1 <- (vp$qb - vp$qa) / (vp$pb - vp$pa)
    s2 <- (vp$qc - vp$qb) / (0 - vp$pb)
    if (p >= vp$pa) return(vp$qa)
    if (p >= vp$pb) return(vp$qa + s1 * (p - vp$pa))
    return(vp$qb + s2 * (p - vp$pb))

  } else if (vp$design == "new") {
    s1 <- (vp$qb - vp$qa) / (vp$pf - vp$pa)
    if (p >= vp$pa) return(vp$qa)
    if (p >= vp$pf) return(vp$qa + s1 * (p - vp$pa))
    return(vp$qd)

  } else {   # new_4pt
    s1 <- (vp$qb - vp$qa) / (vp$pb - vp$pa)
    s2 <- (vp$qc - vp$qb) / (vp$pf - vp$pb)
    if (p >= vp$pa) return(vp$qa)
    if (p >= vp$pb) return(vp$qa + s1 * (p - vp$pa))
    if (p >= vp$pf) return(vp$qb + s2 * (p - vp$pb))
    return(vp$qd)
  }
}

# Vectorised wrapper (uses dplyr if available, else loops)
vrr_demand <- function(p, vp) {
  sapply(p, vrr_demand_scalar, vp = vp)
}

# -----------------------------------------------------------------------------
# vrr_deriv_at(p, vp)
# D'(p) = dQ/dP at price p. Piecewise constant; right-continuous at kinks.
# Scalar only (used inside the ODE).
# -----------------------------------------------------------------------------
vrr_deriv_at <- function(p, vp) {
  # Strict upper inequalities: kink points belong to the lower segment,
  # giving D'(p) right-continuous as p decreases into each segment.
  if (vp$design == "old") {
    if (p > vp$pa) return(0)
    if (p > vp$pb) return((vp$qb - vp$qa) / (vp$pb - vp$pa))
    return((vp$qc - vp$qb) / (0 - vp$pb))

  } else if (vp$design == "new") {
    if (p > vp$pa) return(0)
    if (p > vp$pf) return((vp$qb - vp$qa) / (vp$pf - vp$pa))
    return(0)

  } else {   # new_4pt
    if (p > vp$pa) return(0)
    if (p > vp$pb) return((vp$qb - vp$qa) / (vp$pb - vp$pa))
    if (p > vp$pf) return((vp$qc - vp$qb) / (vp$pf - vp$pb))
    return(0)
  }
}

# -----------------------------------------------------------------------------
# vrr_kinks(vp)
# Interior kink prices (D'(p) discontinuous). Used to restart ODE integrator.
# Returns numeric vector, ascending in price.
# -----------------------------------------------------------------------------
vrr_kinks <- function(vp) {
  if (vp$design == "old")     return(c(vp$pb))
  if (vp$design == "new")     return(c(vp$pf))
  if (vp$design == "new_4pt") return(c(vp$pb, vp$pf))  # two kinks
}

# -----------------------------------------------------------------------------
# vrr_floor_price(vp)
# Returns the floor price below which D(p) = qd (flat). NA for old design.
# -----------------------------------------------------------------------------
vrr_floor_price <- function(vp) {
  if (vp$design == "old")     return(NA_real_)
  if (vp$design == "new")     return(vp$pf)
  if (vp$design == "new_4pt") return(vp$pf)
}

# -----------------------------------------------------------------------------
# vrr_floor_demand(vp)
# Returns the [qb, qd] range at the floor price (for clearing-check).
# -----------------------------------------------------------------------------
vrr_floor_demand <- function(vp) {
  if (vp$design == "old")     return(NULL)
  if (vp$design == "new")     return(c(qb = vp$qb, qd = vp$qd))
  if (vp$design == "new_4pt") return(c(qb = vp$qc, qd = vp$qd))  # qc is demand at pf from sloped side
}

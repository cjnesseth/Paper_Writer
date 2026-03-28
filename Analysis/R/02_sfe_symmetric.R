# =============================================================================
# 02_sfe_symmetric.R
# Symmetric SFE ODE solver and equilibrium-price finder.
#
# ODE (from model.tex Eq.10):
#   s'(p) = [D'(p) + s(p) / (p - c)] / (K - 1)
# Boundary condition (Holmberg 2008, Eq.8):
#   s(p_bar) = q_bar
#
# Numerical strategy: substitute tau = p_bar - p so the boundary condition
# becomes an initial condition at tau = 0, and integrate forward (increasing
# tau) using RK4 with fixed step size.  Kink points in D'(p) are handled by
# restarting integration at each kink (= exact grid boundary), preventing
# lsoda from overshooting the discontinuity and producing NaN.
# =============================================================================

.here <- local({
  a <- grep("--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("--file=", "", a)))
  else tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) "Analysis/R")
})
source(file.path(.here, "01_vrr_demand.R"))

# -----------------------------------------------------------------------------
# .f_tau(tau, s, p_bar, vp, K, c)
# RHS of the τ-transformed ODE: ds/dτ = -[D'(p) + s/(p-c)] / (K-1)
# where p = p_bar - tau.
# -----------------------------------------------------------------------------
.f_tau <- function(tau, s, p_bar, vp, K, c) {
  p      <- p_bar - tau
  Dp     <- vrr_deriv_at(p, vp)
  markup <- max(p - c, 1e-6)       # guard against p ≈ c singularity
  -(Dp + s / markup) / (K - 1)
}

# -----------------------------------------------------------------------------
# solve_sfe_sym(vp, K, c, q_bar, p_min, step)
# Solve the symmetric ODE using RK4 with fixed step in tau = p_bar - p.
#
# Arguments:
#   vp    : list from make_vrr_params()
#   K     : number of symmetric strategic sellers
#   c     : marginal cost ($/MW-day)
#   q_bar : capacity per seller (MW); boundary condition s(p_bar) = q_bar
#   p_min : lower price limit for integration (default: c + 1)
#   step  : RK4 step size in tau-space ($/MW-day); default 0.05
#
# Returns a data.frame with columns (p, s) sorted decreasing in p.
# -----------------------------------------------------------------------------
solve_sfe_sym <- function(vp, K, c, q_bar, p_min = NULL, step = 0.05) {
  p_bar <- vp$pa
  if (is.null(p_min)) p_min <- c + 1

  # Kink prices → tau_kink = p_bar - p_kink (ascending in tau)
  kinks     <- vrr_kinks(vp)
  kinks     <- kinks[kinks > p_min & kinks < p_bar]
  tau_kinks <- sort(p_bar - kinks)     # ascending
  tau_max   <- p_bar - p_min

  breakpts_tau <- c(0, tau_kinks, tau_max)

  # --- RK4 integration over each segment ---
  tau_all <- numeric(0)
  s_all   <- numeric(0)
  s_curr  <- q_bar

  for (i in seq_along(breakpts_tau[-length(breakpts_tau)])) {
    tau_start <- breakpts_tau[i]
    tau_end   <- breakpts_tau[i + 1]
    seg_len   <- tau_end - tau_start
    n_steps   <- max(1L, ceiling(seg_len / step))
    h         <- seg_len / n_steps

    tau_seg    <- seq(tau_start, tau_end, length.out = n_steps + 1L)
    s_seg      <- numeric(n_steps + 1L)
    s_seg[1L]  <- s_curr

    for (j in seq_len(n_steps)) {
      s0 <- s_seg[j]
      t0 <- tau_seg[j]
      k1 <- .f_tau(t0,       s0,             p_bar, vp, K, c)
      k2 <- .f_tau(t0 + h/2, s0 + h/2 * k1, p_bar, vp, K, c)
      k3 <- .f_tau(t0 + h/2, s0 + h/2 * k2, p_bar, vp, K, c)
      k4 <- .f_tau(t0 + h,   s0 + h   * k3, p_bar, vp, K, c)
      s_next <- s0 + h/6 * (k1 + 2*k2 + 2*k3 + k4)
      # Enforce non-negativity
      s_seg[j + 1L] <- if (is.finite(s_next) && s_next >= 0) s_next else 0
    }

    # Don't duplicate the segment-start point (already in previous segment)
    tau_all <- c(tau_all, tau_seg[-1L])
    s_all   <- c(s_all,   s_seg[-1L])
    s_curr  <- s_seg[n_steps + 1L]
  }

  # Prepend the boundary condition at tau = 0 (p = p_bar)
  tau_all <- c(0, tau_all)
  s_all   <- c(q_bar, s_all)

  # Convert to p space and return sorted decreasing
  sol <- data.frame(p = p_bar - tau_all, s = s_all)
  sol[order(sol$p, decreasing = TRUE), ]
}

# -----------------------------------------------------------------------------
# equilibrium_price(sol, vp, K, Q_fringe, c_fringe)
# Find p* where K * s(p*) + S_f(p*) = D(p*).
#
# sol:      data.frame from solve_sfe_sym, columns (p, s)
# Q_fringe: total fringe capacity (MW)
# c_fringe: fringe avoidable cost rate ($/MW-day)
# -----------------------------------------------------------------------------
equilibrium_price <- function(sol, vp, K, Q_fringe = 0, c_fringe = 0) {
  Sf       <- function(p) if (p >= c_fringe) Q_fringe else 0
  s_interp <- approxfun(sol$p, sol$s, rule = 2)

  # Excess supply function; root = equilibrium price
  excess <- function(p) K * s_interp(p) + Sf(p) - vrr_demand_scalar(p, vp)

  p_lo <- min(sol$p)
  p_hi <- max(sol$p)
  e_lo <- excess(p_lo)
  e_hi <- excess(p_hi)

  if (e_lo * e_hi > 0) {
    # No sign change: market clears at a boundary
    if (abs(e_hi) <= abs(e_lo)) {
      return(list(p_star = p_hi, note = "cleared at price cap"))
    } else {
      return(list(p_star = p_lo, note = "cleared at lower boundary"))
    }
  }

  p_star <- uniroot(excess, interval = c(p_lo, p_hi), tol = 1e-6)$root
  list(p_star = p_star, note = "interior equilibrium")
}

# -----------------------------------------------------------------------------
# sfe_summary(cal, K)
# High-level wrapper: solve ODE + find equilibrium + compute Lerner index.
# cal: list from calibrate_year() in 04_calibrate.R
# -----------------------------------------------------------------------------
sfe_summary <- function(cal, K = 3) {
  sol <- solve_sfe_sym(
    vp    = cal$vp,
    K     = K,
    c     = cal$c,
    q_bar = cal$q_bar,
    p_min = cal$c + 1
  )

  eq     <- equilibrium_price(sol, cal$vp, K, cal$Q_fringe, cal$c)
  p_star <- eq$p_star
  s_star <- approx(sol$p, sol$s, xout = p_star)$y
  lerner <- (p_star - cal$c) / p_star

  list(
    delivery_year = cal$delivery_year,
    p_star        = p_star,
    p_actual      = cal$p_actual,
    s_star        = s_star,
    q_bar         = cal$q_bar,
    Q_fringe      = cal$Q_fringe,
    c             = cal$c,
    K             = K,
    lerner        = lerner,
    note          = eq$note,
    sol           = sol
  )
}

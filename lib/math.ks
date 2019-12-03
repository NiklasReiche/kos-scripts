@lazyglobal off.

runoncepath("lang.ks").

//------------------------------------------------------------------------------

// Returns gravitational acceleration at height over body
//
// @p orb_body: the reference body
// @p h: height over body
function g_from_altitude {
  parameter orb_body, h.
  return orb_body:MU / (orb_body:RADIUS + h)^2.
}

// Returns the velocity on an elliptical orbit (see vis-viva equation)
// 
// @p orb_body: the reference body
// @p r1: apoapsis
// @p r2: periapsis
// @p r0: height over sea level for which the velocity is calculated
function v_from_orbit {
  parameter orb_body, r1, r2, r0.
  return sqrt(orb_body:MU * ( (2/(r0+orb_body:radius)) - (2/(r1+r2 + 2*orb_body:radius)) )).
}

// Returns the burn duration for given a dV.
function time_from_dv {
  parameter dv.
  local g is 9.80665.
  local e is constant:e.
  local m is ship:mass * 1000.
  local f is ship:maxthrust * 1000.
  //local isp is get_average(map(get_active_stage_engines(), {parameter engine. return engine:isp.})).
  local isp is get_active_stage_engines()[0]:isp.
  return g * m * isp * (1 - e^(-dv / (g * isp))) / f.
}

// Returns the remaining dv in the current stage 
function get_stage_dv {
  // TODO
}

// Returns throttle needed for a given twr
function THROTTLE_FROM_TWR {
  parameter twr.
  if SHIP:AVAILABLETHRUST > 0 {
    local totalThrust IS twr * SHIP:MASS * G_FROM_ALTITUDE(SHIP:BODY, SHIP:ALTITUDE).
    local srbThrust IS GET_SRB_THRUST().
    return (totalThrust - srbThrust) / (SHIP:AVAILABLETHRUST - srbThrust).
  } else { 
    return 0. 
  }
}

function GET_SRB_THRUST {
  local thrust is 0.
  local engs is LIST().
  list ENGINES in engs.
  for eng in engs {
    if eng:THROTTLELOCK {
      set thrust to thrust + eng:AVAILABLETHRUST.
    }
  }
  return thrust.
}

// Calculates TWR on Kerbin sea level
function get_launch_twr {
  local engs is list().
  list engines in engs.
  local thrust is 0.
  for eng in engs {
    if eng:stage = stage:number {
      lock throttle to 0.
      eng:activate.
      set thrust to thrust + eng:availablethrust.
      eng:shutdown.
    }
  }
  return thrust / (ship:mass * 9.80665).
}

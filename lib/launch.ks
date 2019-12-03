@lazyglobal off.

runoncepath("craft.ks").
runoncepath("math.ks").
runoncepath("maneuver.ks").

// -----------------------------------------------------------------------------

// Launches the craft
//
// @p launch_direction (90): 
// @p turn_end (70000): target orbit apoapsis height
// @p firstStage (6): lower stage bound for auto staging
// @p lastStage (1): upper stage bound for auto staging
function launch {
  parameter launch_direction, turn_end, firstStage, lastStage.

  local turn_start is 1000.
  local limited_throttle_start_height is 20000.
  local escape_burn_start_height is 40000.
  local target_ap_eta is 30.
  local event_log is list().
  local t is time:seconds.

  // console update trigger
  when time:seconds - t > 0.5 then {
    update_terminal().
    set t to time:seconds.
    return true.
  }

  // auto staging trigger
  when is_stage_ready() then {
    if stage:number > firstStage { return true. }
    if stage:number > lastStage {
      STAGE.
      return true.
    }
    return false.
  }

  clearscreen.

  event_log:add("> initiating launch procedure...").

  // set manual throttle to 0, so it is 0 after releasing throttle lock
  set ship:control:pilotmainthrottle to 0.
  SAS off.
  // lock throttle and steering
  local throttle_cotrol is 1.
  lock throttle to throttle_cotrol.
  lock steering to heading(launch_direction, pitch_from_altitude(turn_start, turn_end)).

  event_log:add("> locking throttle...").
  event_log:add("> locking steering...").

  wait until altitude > turn_start.

  event_log:add("> initiating ascent turn...").

  wait until eta:apoapsis > target_ap_eta and altitude > limited_throttle_start_height.
  // while waiting for solid boosters to empty keep minimal throttle for stability
  set throttle_cotrol to 0.5.
  wait until isSolidBoosterFlameout(). 

  event_log:add("> initiating constant eta to apoapsis...").
  
  local kp is 0.01.
  local ki is 0.0006.
  local kd is 0.006.
  local pid is pidloop(kp, ki, kd).
  set pid:setpoint to target_ap_eta.

  // keep apoapsis 30 seconds ahead
  until altitude > escape_burn_start_height {
    set throttle_cotrol to max(0.5, min(1, throttle_cotrol + pid:update(time:seconds, eta:apoapsis))).
    wait 0.
  }

  event_log:add("> initiating escape burn...").

  set throttle_cotrol to 1.
  wait until apoapsis > turn_end.
  set throttle_cotrol to 0.

  event_log:add("> calculating circularization maneuver...").

  local ap is apoapsis.
  local pe is periapsis.
  local dv is v_from_orbit(ship:body, ap, ap, ap) - v_from_orbit(ship:body, ap, pe, ap).
  local circ_node is node(time:seconds + eta:apoapsis, 0, 0, dv).
  add circ_node.
  execute_next_maneuver(5 + event_log:length() + 2).
  clear_quad(0, terminal:width, 5 + event_log:length() + 2, terminal:height).

  event_log:add("> arrived at target.").


  //----------------------------------------------------------------------------
  function update_terminal {
    // clear terminal
    print "                           " at(16, 1).
    print "                           " at(16, 2).
    print "                           " at(16, 3).

    print "----------> LAUNCH PROCEDURE <----------" at(0, 0).
    print "> target orbit: " + turn_end + "m" at(0, 1).
    print "> asl height:   " + round(altitude, 0) + "m" at(0, 2).
    print "> time to ap:   " + round(eta:apoapsis, 2) + "s" at(0, 3).
    print "----------------------------------------" at(0, 4).
    print "> mission event log:" at(0,5).

    local line is 6.
    for msg in event_log {
      print msg at(2, line).
      set line to line + 1.
    }
  }
}

// Calculates the pitch for the current altitude based on an ascent profile 
// for a given target orbit height
function pitch_from_altitude {
  parameter start_height, target_height.

  local turn_exp is 0.4.
  // local launchTWR is get_launch_twr().
  // local turnEnd is 0.128*atmoHeight*launchTWR + 0.5*atmoHeight.
  // local turn_exp is max(1/(2.5*launchTWR - 1.7), 0.25).

  if altitude < start_height {
    return 90.
  }

  return max(0, 90 - 90*( (altitude-start_height) / (target_height-start_height) )^turn_exp).
}

// Returns true if the craft is ready to stage
function should_stage {
  local engs is list().
  list engines in engs.
  for eng in engs {
    if eng:ignition and eng:flameout and stage:ready { 
      return true. 
    }
  }
  return false.
}

function isSolidBoosterFlameout {
  local engs is list().
  list engines in engs.
  for eng in engs {
    if eng:throttlelock and not (eng:ignition and eng:flameout) { 
      return false. 
    }
  }
  return true.
}

@lazyglobal off.

runoncepath("craft.ks").
runoncepath("math.ks").

//------------------------------------------------------------------------------

// Executes maneuver autopilot
function EXECUTE_NEXT_MANEUVER {
  parameter terminal_line is 0.

  local node is nextnode.
  local turn_start is 60.
  local t_burn is time_from_dv(node:deltav:mag).
  lock t0 to node:ETA - (t_burn / 2).

  local event_log is list().
  local t is time:seconds.

  // console update trigger
  when time:seconds - t > 0.5 then {
    update_terminal().
    set t to time:seconds.
    return true.
  }


  if (not hasnode) { 
    event_log:add("!> ABORTING: no node found."). 
    return 1.
  }

  event_log:add("> initiating maneuver").

  wait until t0 < max(turn_start, t_burn).

  event_log:add("> initiating turn at t-" + round(abs(t0), 2)).
  event_log:add("> locking controls").

  SAS off.
  local throttle_set is 0.
  lock throttle to throttle_set.
  lock steering to node:deltav.
  RCS on.

  // wait for turn completion
  wait until vang(ship:facing:vector, node:deltav) < 0.25.

  if (t0 < 0) { 
    event_log:add("!> ABORTING: failed to turn in time."). 
    return 1. 
  }

  wait until t0 <= 0.

  event_log:add("> initiating burn at t-" + round(abs(t0), 2)).

  local dv0 is node:deltav.

  until false {
    set throttle_set to min(node:deltav:mag/(ship:maxthrust/ship:mass), 1).

    if (node:deltav:mag < 0.1) {
      event_log:add("> initiating precise burn at t+" + round(abs(t0), 2)).
      wait until vdot(dv0, node:deltav) < 0.5.
      set throttle_set to 0.
      break.
    }
    if (vdot(dv0, node:deltav) < 0) {
      set throttle_set to 0.
      break.
    }
  }

  event_log:add("> finfished burn.").

  unlock throttle.
  unlock steering.
  rcs off. sas on.
  set ship:control:pilotmainthrottle to 0.
  remove node.

  event_log:add("> finished maneuver.").


  //----------------------------------------------------------------------------
  function update_terminal {
    // clear terminal
    print "                           " at(17, terminal_line + 1).
    print "                           " at(17, terminal_line + 2).
    print "                           " at(17, terminal_line + 3).

    print "---------> MANEUVER EXECUTION <---------" at(0, terminal_line).
    print "> deltaV:        " + round(node:deltav:mag, 2) + "m/s" at(0, terminal_line + 1).
    print "> burn duration: " + round(t_burn, 2) + "s" at(0, terminal_line + 2).
    print "> eta:           " + round(abs(t0), 2) + "s" at(0, terminal_line + 3).
    print "----------------------------------------" at(0, terminal_line + 4).
    print "> event log:" at(0, terminal_line + 5).

    local line is terminal_line + 6.
    for msg in event_log {
      print msg at(2, line).
      set line to line + 1.
    }
  }
}

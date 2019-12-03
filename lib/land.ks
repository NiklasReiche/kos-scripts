@lazyglobal off.

runoncepath("math.ks").
runoncepath("maneuver.ks").

// -----------------------------------------------------------------------------

function land {
  SAS off.
  RCS on.

print "kill horizontal speed".
  //kill_horizontal_speed().

print "descent".
  descent().

  set ship:control:pilotmainthrottle to 0.
  SAS on.
}

function kill_horizontal_speed {
  // point at horizon.
  lock vs to velocity:surface:normalized. 
  lock steering to angleaxis(-90, vcrs(up:forevector,vs)) * up:forevector.

  lock throttle to 1.
  wait until groundspeed <= 1.
  lock throttle to 0.
}

function descent {
  local throttle_cotrol is 0.
  lock throttle to throttle_cotrol.

  lock steering to srfRetrograde.

  GEAR on.

  wait until alt:radar < 500.
  
  // keep speed at -1 m/s
  local kp is 0.01.
  local ki is 0.0006.
  local kd is 0.006.
  local pid is pidloop(kp, ki, kd).
  
  until ship:status = "LANDED" {
    set pid:setpoint to f().
    set throttle_cotrol to clamp(0, 1, throttle_cotrol + pid:update(time:seconds, verticalSpeed)).
    wait 0.
  }
}

function f {
  local start_height is 200.
  local end_height is 10.
  local start_throttle is 10.
  local end_throttle is 1.

  if alt:radar < end_height {
    return -end_throttle.
  }
  if alt:radar > start_height {
    return -start_throttle.
  }
  return -(end_throttle + (start_throttle-end_throttle)/(start_height-end_height) * (alt:radar-end_height)).
}

land().

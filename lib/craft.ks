@lazyglobal off.

//------------------------------------------------------------------------------

// Returns true if the craft is ready to stage
function is_stage_ready {
  if stage:ready and not (get_active_stage_engines():length() = get_stage_engines():length()) {
    return true.
  }
  return false.
}

// Returns a list of all engines in the active stage
function get_stage_engines {
  local stage_engines is list().
  local craft_engines is list().
  list engines in craft_engines.
  for e in craft_engines {
    if e:ignition { 
      stage_engines:add(e). 
    }
  }
  return stage_engines.
}

// Returns a list of active engines in the active stage
function get_active_stage_engines {
  local stage_engines is get_stage_engines().
  local active_engines is list().
  for e in stage_engines {
    if not e:flameout { 
      active_engines:add(e). 
    }
  }
  return active_engines.
}

function clear_quad {
	parameter column1,column2,line1,line2.
	local column is column1.
	local s is "".
	until column > column2 {
		set s to " " + s.
		set column to column + 1.
	}
	local line is line1.
	until line > line2 {
		print s at (column1,line).
		set line to line + 1.
	}
}

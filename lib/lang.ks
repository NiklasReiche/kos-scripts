@lazyglobal off.

//------------------------------------------------------------------------------

// Returns the sum of all elements in a list
function get_sum {
  parameter lst.

  local sum is 0.
  for e in lst {
    set sum to sum + e.
  }
}

// Returns the average of all elements in a list
function get_average {
  parameter lst.

  return get_sum(lst) / lst:length.
}

// Maps all elements of a list to the results of the function
function map {
  parameter lst, f.
  local lst2 is list().
  for e in lst {
    lst2:add(f(e)).
  }
  return lst2.
}

function clamp {
  parameter lo, hi, value.
  return max(lo, min(hi, value)).
}

// update
local phase is 0.

PRINT "  > deleting scripts...".
if phase = 1 {
  deletepath("launch.ks").
}

PRINT "  > downloading libraries...".
if phase = 0 {
  DOWNLOAD("lib/lang.ks").
  DOWNLOAD("lib/math.ks").
  DOWNLOAD("lib/craft.ks").
  DOWNLOAD("lib/launch.ks").
  DOWNLOAD("lib/land.ks").
  DOWNLOAD("lib/maneuver.ks").
} 

PRINT "  > downloading scripts...".
if phase = 0 {
  DOWNLOAD("Template/startlaunch.ks").
  DOWNLOAD("Template/nextmaneuver.ks").
} else if phase = 1 {
  
}

PRINT "  > download complete.".

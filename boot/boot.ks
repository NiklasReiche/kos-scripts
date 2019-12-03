@LAZYGLOBAL off.

// Copies a file from KSC to the local volume.
FUNCTION DOWNLOAD {
  PARAMETER name.
  COPYPATH("0:/" + name, "1:/").
}

// Copies a file from the local volume to KSC.
FUNCTION UPLOAD {
  PARAMETER name.
  COPYPATH("1:/" + name, "0:/" + SHIP:NAME + "/").
}

//------------------------------------------------------------------------------

// Open terminal
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// Boot process
PRINT "----------------> BOOT <----------------".
PRINT "> checking for updates...".

IF EXISTS("0:/" + "Template/" + "/update.ks") {
  PRINT "> updating...".
  DOWNLOAD("Template/" + "/update.ks").
  RUNPATH("update.ks").
  DELETEPATH("update.ks").
  PRINT "> update complete.".
} else {
  PRINT "> no update found.".
}

PRINT "> checking for autostart...".
IF EXISTS("1:/" + SHIP:NAME + "startup.ks") {
  PRINT "> autostarting...".
  RUNPATH("startup.ks").
} else {
  PRINT "> no autostart routine found.".
  PRINT "> boot finished".
  PRINT "----------------------------------------".
}

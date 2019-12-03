@lazyglobal off.
RUNONCEPATH("hud.ks").

FUNCTION COUNTDOWN {
  PARAMETER start IS 10.
  FROM {LOCAL t IS start.} UNTIL t = 0 STEP {SET t TO t-1.} DO {
    NOTIFY("T - " + t, 1).
    WAIT 1.
  }
}

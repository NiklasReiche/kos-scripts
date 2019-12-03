@lazyglobal off.

// @p launch_direction (90): 
// @p turn_end (70000): target orbit apoapsis height
// @p firstStage (6): lower stage bound for auto staging
// @p lastStage (1): upper stage bound for auto staging
parameter launch_direction, turn_end, firstStage, lastStage.

runoncepath("launch.ks").

// -----------------------------------------------------------------------------

launch(launch_direction, turn_end, firstStage, lastStage).

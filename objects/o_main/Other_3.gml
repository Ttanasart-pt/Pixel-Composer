/// @description 
log_message("SESSION", "Ended");
PREF_SAVE();

if(STEAM_ENABLED) steam_shutdown();
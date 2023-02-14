/// @description 
#region log
	log_message("SESSION", "Ended");
	PREF_SAVE();
#endregion

#region steam
	if(STEAM_ENABLED) {
		steam_shutdown();
	}
#endregion
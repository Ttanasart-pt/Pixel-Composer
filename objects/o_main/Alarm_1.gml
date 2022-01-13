/// @description init
#region prefload
	RECENT_LOAD();
	
	LOAD_SAMPLE();
	INIT_FOLDERS();
	
	if(!file_exists(file_open_parameter) && PREF_MAP[? "show_splash"]) {
		dialogCall(o_dialog_splash, WIN_W / 2, WIN_H / 2);
	}
#endregion
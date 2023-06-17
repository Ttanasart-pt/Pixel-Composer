/// @description 
gameframe_init();
gameframe_button_array = [];
#region setup
	window_set_size(640, 480);
	display_set_gui_size(640, 480);
	
	window_set_caption("Pixel Composer crashed")
	window_set_position(
		(display_get_width()  - 640) / 2, 
		(display_get_height() - 320) / 2); // center window
#endregion

#region directory
	globalvar DIRECTORY, APP_DIRECTORY;
	DIRECTORY = "";
	
	if(OS == os_windows) {	
		APP_DIRECTORY = environment_get_variable("userprofile") + "\\AppData\\Local\\PixelComposer\\";
	} else if(OS == os_macosx) {
		var home_dir = environment_get_variable("HOME");
		if(string(home_dir) == "0")
			log_message("DIRECTORY", "Directory not found.");
		else 
			APP_DIRECTORY = string(home_dir) + "/PixelComposer/";
	}
	
	var perstPath = APP_DIRECTORY + "persistPreference.json"; 
	if(file_exists(perstPath)) {
		PRESIST_PREF = json_load_struct(perstPath);
		DIRECTORY    = struct_has(PRESIST_PREF, "path")? PRESIST_PREF.path : "";
	}
	
	var dir_valid = DIRECTORY != "" && directory_exists(DIRECTORY);
	if(!dir_valid) DIRECTORY = APP_DIRECTORY;
#endregion

#region log
	path = DIRECTORY + "log/crash_log.txt";
	if(!file_exists(path)) game_end(1);
	
	crash_content = file_text_read_all(path);
	log_surface = surface_create(1, 1);
	log_y = 0;
	log_y_to = 0;
	
	LOCALE = {
		config: {
			per_character_line_break: true
		}
	}
	
	win_w = 640;
	win_h = 320;
#endregion
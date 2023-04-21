/// @description main directory, parameter
//print("===== Game Start Begin =====");

#region directory
	globalvar DIRECTORY, APP_DIRECTORY, PRESIST_PREF;
	DIRECTORY = "";
	PRESIST_PREF = {};
	
	if(OS == os_windows) {	
		APP_DIRECTORY = environment_get_variable("userprofile") + "\\AppData\\Local\\PixelComposer\\";
	} else if(OS == os_macosx) {
		var home_dir = environment_get_variable("HOME");
		if(string(home_dir) == "0")
			log_message("DIRECTORY", "Directory not found.");
		else 
			APP_DIRECTORY = string(home_dir) + "/PixelComposer/";
	}
	show_debug_message("App directory: " + string(APP_DIRECTORY));
	
	if(!directory_exists(APP_DIRECTORY)) directory_create(APP_DIRECTORY);
	
	var perstPath = APP_DIRECTORY + "persistPreference.json"; 
	if(file_exists(perstPath)) {
		PRESIST_PREF = json_load_struct(perstPath);
		DIRECTORY    = struct_has(PRESIST_PREF, "path")? PRESIST_PREF.path : "";
	}
	
	show_debug_message("Env directory: " + string(DIRECTORY));
	var dir_valid = DIRECTORY != "" && directory_exists(DIRECTORY);
	var tmp = file_text_open_write(DIRECTORY + "val_check.txt");
	
	if(tmp == -1) {
		dir_valid = false;
		print("WARNING: Inaccessible directory [" + DIRECTORY + "] this may be caused by non existing folder, or Pixel Composer has no permission to open the folder.");
	} else {
		file_text_close(tmp);
		file_delete(DIRECTORY + "val_check.txt");
	}
	
	if(!dir_valid) DIRECTORY = APP_DIRECTORY;
	
	PRESIST_PREF.path = DIRECTORY;
	json_save_struct(perstPath, PRESIST_PREF);
	
	if(!directory_exists(DIRECTORY))
		directory_create(DIRECTORY);
	if(!directory_exists(DIRECTORY + "temp"))
		directory_create(DIRECTORY + "temp");
	
	METADATA = __getdefaultMetaData();
#endregion

#region Set up
	PREF_LOAD();
	
	log_clear();
	log_newline();
	log_message("SESSION", "Begin");
	log_message("DIRECTORY", DIRECTORY);
	
	window_set_showborder(false);
	
	__initSurfaceFormat();
	__initLocale();
	__initTheme();
	__initCollection();
	__initAssets();
	__initPresets();
	__initFontFolder();
	__initLua();
	__initNodeData();
	__initNodes();
	__initSteamUGC();
	
	PREF_APPLY();
	loadFonts();
	loadGraphic(PREF_MAP[? "theme"]);
	loadColor(PREF_MAP[? "theme"]);
	
	setPanel();
	
	if(file_exists("icon.png"))
		file_copy("icon.png", DIRECTORY + "icon.png");
	
	environment_set_variable("IMGUI_DIALOG_WIDTH", string(800));
	
	var cmd = ".pxc=\"" + string(program_directory) + "PixelComposer.exe\"";
	execute_shell("assoc", cmd);
	
	var cmd = ".pxcc=\"" + string(program_directory) + "PixelComposer.exe\"";
	execute_shell("assoc", cmd);
#endregion

#region parameter
	alarm[1] = 2;
	
	if(parameter_count() > 1) {
		var path = parameter_string(1);
		if(path == "--crashed") {
			if(PREF_MAP[? "show_crash_dialog"])
				dialogCall(o_dialog_crashed);
		} else {
			path = string_replace_all(path, "\n", "");
			path = string_replace_all(path, "\"", "");
		
			if(file_exists(path) && filename_ext(path) == ".pxc") {
				file_open_parameter = path;
				alarm[2] = 3;
			
				directory_set_current_working(DIRECTORY);
			}
		}
	}
#endregion

#region lua
	lua_error_handler = _lua_error;
#endregion

//print("===== Game Start End =====");
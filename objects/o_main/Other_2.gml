/// @description main directory, parameter
//print("===== Game Start Begin =====");

#region directory
	globalvar DIRECTORY, APP_DIRECTORY, APP_LOCATION, PRESIST_PREF;
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
	
	directory_verify(APP_DIRECTORY);
	
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
	directory_verify(DIRECTORY);
	//directory_set_current_working(DIRECTORY);
	
	APP_LOCATION = program_directory;
	if(string_pos("GameMakerStudio2\\Cache\\runtimes", APP_LOCATION))
		APP_LOCATION = working_directory;
	//print($"===================== WORKING DIRECTORIES =====================\n\t{working_directory}\n\t{DIRECTORY}");
#endregion

#region Set up
	var t = current_time;
	PREF_LOAD();
	
	var dir  = string(DIRECTORY) + "log";
	directory_verify(dir);
	
	log_clear();
	log_newline();
	log_message("SESSION", "Begin");
	log_message("DIRECTORY", DIRECTORY);
	
	PREF_APPLY();
	
	log_message("SESSION", "> init Patreon");		__initPatreon();
	log_message("SESSION", "> init Theme");			__initTheme();
	log_message("SESSION", "> init Locale");		__initLocale();
	log_message("SESSION", "> init Font");			  loadFonts();
	log_message("SESSION", "> init Project");		__initProject();
	log_message("SESSION", "> init Action");		__initAction();
	log_message("SESSION", "> init SurfaceFormat");	__initSurfaceFormat();
	log_message("SESSION", "> init Collection");	__initCollection();
	log_message("SESSION", "> init Assets");		__initAssets();
	log_message("SESSION", "> init Presets");		__initPresets();
	log_message("SESSION", "> init FontFolder");	__initFontFolder();
	log_message("SESSION", "> init Lua");			__initLua();
	log_message("SESSION", "> init NodeData");		__initNodeData();
	log_message("SESSION", "> init Nodes");			__initNodes();
	log_message("SESSION", "> init SteamUGC");		__initSteamUGC();
	log_message("SESSION", "> init Addon");			__initAddon();
	log_message("SESSION", "> init Palette");		__initPalette();
	log_message("SESSION", "> init Gradient");		__initGradient();
	
	log_message("SESSION", "> init Ins Renderer");	__initInstanceRenderer();
	log_message("SESSION", "> init Addons");		  loadAddon();
	
	log_message("SESSION", ">> Initialization complete");
	
	__initPanel();
	
	if(file_exists("icon.png"))
		file_copy("icon.png", DIRECTORY + "icon.png");
	
	environment_set_variable("IMGUI_DIALOG_WIDTH", string(800));
	
	var cmd = ".pxc=\"" + string(program_directory) + "PixelComposer.exe\"";
	shell_execute_async("assoc", cmd);
	
	var cmd = ".pxcc=\"" + string(program_directory) + "PixelComposer.exe\"";
	shell_execute_async("assoc", cmd);
	
	directory_set_current_working(DIRECTORY);
	//print($"Setup time: {(current_time - t)/1000}s");
#endregion

#region parameter
	alarm[1] = 2;
	
	if(parameter_count() > 1) {
		var path = parameter_string(1);
		if(path == "--crashed") {
			if(PREFERENCES.show_crash_dialog) dialogCall(o_dialog_crashed);
		} else {
			path = string_replace_all(path, "\n", "");
			path = string_replace_all(path, "\"", "");
		
			if(file_exists(path) && filename_ext(path) == ".pxc") {
				file_open_parameter = path;
				alarm[2] = 3;
			}
		}
	}
#endregion

#region lua
	//lua_error_handler = _lua_error;
#endregion

//print("===== Game Start End =====");
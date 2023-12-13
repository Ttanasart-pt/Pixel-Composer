/// @description main directory, parameter
//print("===== Game Start Begin =====");

#region directory
	globalvar DIRECTORY, APP_DIRECTORY, APP_LOCATION, PRESIST_PREF;
	DIRECTORY = "";
	PRESIST_PREF = {
		path: ""
	};
	
	APP_DIRECTORY = env_user();
	show_debug_message($"App directory: {APP_DIRECTORY}");
	
	directory_verify(APP_DIRECTORY);
	
	var perstPath = APP_DIRECTORY + "persistPreference.json"; 
	if(file_exists_empty(perstPath)) {
		struct_override(PRESIST_PREF, json_load_struct(perstPath));
		DIRECTORY    = struct_has(PRESIST_PREF, "path")? PRESIST_PREF.path : "";
	}
	
	if(DIRECTORY != "") {
		var _ch = string_char_last(DIRECTORY);
		if(_ch != "\\" && _ch != "/") DIRECTORY += "\\";
	
		show_debug_message($"Env directory: {DIRECTORY}");
		var dir_valid = DIRECTORY != "" && directory_exists(DIRECTORY);
		var tmp = file_text_open_write(DIRECTORY + "val_check.txt");
	
		if(tmp == -1) {
			dir_valid = false;
			show_message($"WARNING: Inaccessible main directory ({DIRECTORY}) this may be caused by non existing folder, or Pixel Composer has no permission to open the folder.");
		} else {
			file_text_close(tmp);
			file_delete($"{DIRECTORY}val_check.txt");
		}
		
		if(!dir_valid) {
			show_debug_message("Invalid directory revert back to default %APPDATA%");
			DIRECTORY = APP_DIRECTORY;
		}
	} else 
		DIRECTORY = APP_DIRECTORY;
	
	directory_verify(DIRECTORY);
	
	APP_LOCATION = program_directory;
	if(string_pos("GameMakerStudio2\\Cache\\runtimes", APP_LOCATION))
		APP_LOCATION = working_directory;
	print($"===================== WORKING DIRECTORIES =====================\n\t{working_directory}\n\t{DIRECTORY}");
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
	var t0 = get_timer();
	var t  = get_timer();
	
    __initPatreon();              log_message("SESSION", $"> init Patreon       | complete in {get_timer() - t}");    t = get_timer();
    __initTheme();                log_message("SESSION", $"> init Theme         | complete in {get_timer() - t}");    t = get_timer();
    __initLocale();               log_message("SESSION", $"> init Locale        | complete in {get_timer() - t}");    t = get_timer();
    loadFonts();                  log_message("SESSION", $"> init Font          | complete in {get_timer() - t}");    t = get_timer();
    __initProject();              log_message("SESSION", $"> init Project       | complete in {get_timer() - t}");    t = get_timer();
    __initAction();               log_message("SESSION", $"> init Action        | complete in {get_timer() - t}");    t = get_timer();
    __initSurfaceFormat();        log_message("SESSION", $"> init SurfaceFormat | complete in {get_timer() - t}");    t = get_timer();
    __initCollection();           log_message("SESSION", $"> init Collection    | complete in {get_timer() - t}");    t = get_timer();
    __initAssets();               log_message("SESSION", $"> init Assets        | complete in {get_timer() - t}");    t = get_timer();
    __initPresets();              log_message("SESSION", $"> init Presets       | complete in {get_timer() - t}");    t = get_timer();
    __initFontFolder();           log_message("SESSION", $"> init FontFolder    | complete in {get_timer() - t}");    t = get_timer();
    __initLua();                  log_message("SESSION", $"> init Lua           | complete in {get_timer() - t}");    t = get_timer();
    __initNodeData();             log_message("SESSION", $"> init NodeData      | complete in {get_timer() - t}");    t = get_timer();
    __initNodes();                log_message("SESSION", $"> init Nodes         | complete in {get_timer() - t}");    t = get_timer();
    __initSteamUGC();             log_message("SESSION", $"> init SteamUGC      | complete in {get_timer() - t}");    t = get_timer();
    __initAddon();                log_message("SESSION", $"> init Addon         | complete in {get_timer() - t}");    t = get_timer();
    __initPalette();              log_message("SESSION", $"> init Palette       | complete in {get_timer() - t}");    t = get_timer();
    __initGradient();             log_message("SESSION", $"> init Gradient      | complete in {get_timer() - t}");    t = get_timer();
    
    loadAddon();                  log_message("SESSION", $"> init Addons        | complete in {get_timer() - t}");    t = get_timer();
    
    LOAD_SAMPLE();                log_message("SESSION", $"> init sample        | complete in {get_timer() - t}");    t = get_timer();
    INIT_FOLDERS();               log_message("SESSION", $"> init folders       | complete in {get_timer() - t}");    t = get_timer();
    RECENT_LOAD();                log_message("SESSION", $"> init recents       | complete in {get_timer() - t}");    t = get_timer();
    
	log_message("SESSION", $">> Initialization complete in {get_timer() - t0}");
	
	__initPanel();
	
	if(file_exists_empty("icon.png"))
		file_copy("icon.png", DIRECTORY + "icon.png");
	
	var cmd = ".pxc=\"" + string(program_directory) + "PixelComposer.exe\"";
	shell_execute_async("assoc", cmd);
	
	var cmd = ".pxcc=\"" + string(program_directory) + "PixelComposer.exe\"";
	shell_execute_async("assoc", cmd);
	
	directory_set_current_working(DIRECTORY);
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
		
			if(file_exists_empty(path) && filename_ext(path) == ".pxc") {
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
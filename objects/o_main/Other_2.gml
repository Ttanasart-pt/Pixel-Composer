/// @description main directory, parameter
//print("===== Game Start Begin =====");

#region directory
	globalvar DIRECTORY, APP_DIRECTORY, APP_LOCATION, PRESIST_PREF;
	DIRECTORY = "";
	PRESIST_PREF = { path: "" };
	
	APP_DIRECTORY = env_user();
	APP_DIRECTORY = string_replace_all(APP_DIRECTORY, "\\", "/");
	show_debug_message($"App directory: {APP_DIRECTORY}");
	
	directory_verify(APP_DIRECTORY);
	
	var perstPath = APP_DIRECTORY + "persistPreference.json"; 
	if(file_exists_empty(perstPath)) {
		struct_override(PRESIST_PREF, json_load_struct(perstPath));
		DIRECTORY = struct_has(PRESIST_PREF, "path")? PRESIST_PREF.path : "";
	}
	
	show_debug_message($"Persisted directory: {perstPath}");
	
	if(DIRECTORY != "") {
		var _ch = string_char_last(DIRECTORY);
		if(_ch != "\\" && _ch != "/") DIRECTORY += "/";
	
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
	
	PREFERENCES_DIR = $"{DIRECTORY}Preferences/{PREF_VERSION}/";
	directory_verify(DIRECTORY);
	directory_verify($"{DIRECTORY}Cache");
	
	APP_LOCATION = program_directory;
	if(OS == os_macosx) APP_LOCATION = string_replace(APP_LOCATION, "/Contents/MacOS/", "/Contents/Resources/");
	if(RUN_IDE)         APP_LOCATION = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/";
		
	printDebug($"===================== WORKING DIRECTORIES =====================\n\t{working_directory}\n\t{DIRECTORY}");
	directory_verify($"{DIRECTORY}log");
#endregion

#region Set up
	var t = get_timer();
	
	              PREF_LOAD();                  printDebug($"> init Preferences   | complete in {get_timer() - t}");    t = get_timer();
	if(!IS_CMD) { __initLocale();               printDebug($"> init Locale        | complete in {get_timer() - t}");    t = get_timer(); }
	if(!IS_CMD) { __initHotKey();               printDebug($"> init Hotkeys       | complete in {get_timer() - t}");    t = get_timer(); }
	
	log_clear();
	log_newline();
	printDebug("Begin");
	printDebug($"DIRECTORY {DIRECTORY}");
	
	PREF_APPLY();
	var t0   = get_timer();
	var t    = get_timer();
	var _lua = PROGRAM_ARGUMENTS._lua;
	
				  __initKeys()
				  __initPatreon();              printDebug($"> init Patreon       | complete in {get_timer() - t}");    t = get_timer();
    if(!IS_CMD) { __initTheme();                printDebug($"> init Theme         | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { loadFonts();                  printDebug($"> init Font          | complete in {get_timer() - t}");    t = get_timer(); }
	if(!IS_CMD) { __initProject();              printDebug($"> init Project       | complete in {get_timer() - t}");    t = get_timer(); }
	              __fnInit();
    
	if(!IS_CMD) { __initAction();               printDebug($"> init Action        | complete in {get_timer() - t}");    t = get_timer(); }
				  __initSurfaceFormat();        printDebug($"> init SurfaceFormat | complete in {get_timer() - t}");    t = get_timer();
    if(!IS_CMD) { __initCollection();           printDebug($"> init Collection    | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { __initAssets();               printDebug($"> init Assets        | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { __initPresets();              printDebug($"> init Presets       | complete in {get_timer() - t}");    t = get_timer(); }
	if(!IS_CMD) { __initFontFolder();           printDebug($"> init FontFolder    | complete in {get_timer() - t}");    t = get_timer(); }
	if(_lua)    { __initLua();                  printDebug($"> init Lua           | complete in {get_timer() - t}");    t = get_timer(); }
	if(!IS_CMD) { __initNodeData();             printDebug($"> init NodeData      | complete in {get_timer() - t}");    t = get_timer(); }
				  __initNodes();                printDebug($"> init Nodes         | complete in {get_timer() - t}");    t = get_timer();
    if(!IS_CMD) { __initSteamUGC();             printDebug($"> init SteamUGC      | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { __initAddon();                printDebug($"> init Addon         | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { __initPalette();              printDebug($"> init Palette       | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { __initGradient();             printDebug($"> init Gradient      | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { __initPen();					printDebug($"> init Pen           | complete in {get_timer() - t}");    t = get_timer(); }
    
    if(!IS_CMD) { loadAddon();                  printDebug($"> init Addons        | complete in {get_timer() - t}");    t = get_timer(); }
    
    if(!IS_CMD) { LOAD_SAMPLE();                printDebug($"> init sample        | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { INIT_FOLDERS();               printDebug($"> init folders       | complete in {get_timer() - t}");    t = get_timer(); }
    if(!IS_CMD) { RECENT_LOAD();                printDebug($"> init recents       | complete in {get_timer() - t}");    t = get_timer(); }
    
	printDebug($">> Initialization complete in {get_timer() - t0}");
	
	if(!IS_CMD) { 
		__initPanel();
		
		if(file_exists_empty("icon.png"))
			file_copy("icon.png", DIRECTORY + "icon.png");
		
		var _prg_path = $"{program_directory}PixelComposer.exe";
		// var cmd = ".pxc=\"" + string(program_directory) + "PixelComposer.exe\"";
		// shell_execute_async("assoc", cmd);
	
		// var cmd = ".pxcc=\"" + string(program_directory) + "PixelComposer.exe\"";
		// shell_execute_async("assoc", cmd);
		
		// shell_execute_async("reg",  "ADD HKCU\\Software\\Classes\\pxc");
		// shell_execute_async("reg",  "ADD HKCU\\Software\\Classes\\pxc /v \"URL Protocol\" /t REG_SZ");
		// shell_execute_async("reg",  "ADD HKCU\\Software\\Classes\\pxc\\shell");
		// shell_execute_async("reg",  "ADD HKCU\\Software\\Classes\\pxc\\shell\\open");
		
		// shell_execute_async("reg", $"DELETE HKCU\\Software\\Classes\\pxc\\shell\\open\\command");
		// shell_execute_async("reg", $"ADD HKCU\\Software\\Classes\\pxc\\shell\\open\\command /t REG_SZ /d \"{_prg_path} -m %1\"");
	}
	
	directory_set_current_working(DIRECTORY);
#endregion

#region lua
	lua_error_handler = _lua_error;
#endregion

//print("===== Game Start End =====");
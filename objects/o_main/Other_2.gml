/// @description main directory, parameter
//print("===== Game Start Begin =====");

#region directory
	globalvar APP_DIRECTORY, APP_LOCATION; 
	
	globalvar WORKING_DIRECTORY; WORKING_DIRECTORY = working_directory;
	globalvar ROAMING_DIRECTORY; ROAMING_DIRECTORY = "";
	globalvar DIRECTORY; DIRECTORY         = "";
	globalvar FS_PATH; FS_PATH           = "";
	globalvar PRESIST_PREF; PRESIST_PREF      = { path: "" };
	
	if(OS == os_linux) {
		APP_DIRECTORY = working_directory;
		DIRECTORY     = working_directory;
	    APP_LOCATION  = working_directory;
	    
	    var _user = string_trim(shell_execute("", "whoami"));
		DIRECTORY = $"/home/{_user}/PixelComposer/";
	    
	    show_debug_message($"working_directory = {working_directory}");
	    show_debug_message($"temp_directory = {temp_directory}");
	    show_debug_message($"program_directory = {program_directory}");
	    
		PREFERENCES_DIR = $"{DIRECTORY}Preferences/{PREF_VERSION}/";
		directory_verify($"{DIRECTORY}Cache");
		directory_verify($"{DIRECTORY}log");
		
		var fsPath = $"{APP_LOCATION}fs/fs.appimage";
		FS_PATH    = $"{DIRECTORY}fs.appimage";
		
		file_copy_override(fsPath, FS_PATH);
		shell_execute("", $"chmod +x {FS_PATH}");
		
	} else if(OS == os_macosx) {
		APP_DIRECTORY = working_directory;
		DIRECTORY     = working_directory;
	    APP_LOCATION  = working_directory;
	    
		PREFERENCES_DIR = $"{DIRECTORY}Preferences/{PREF_VERSION}/";
		directory_verify($"{DIRECTORY}Cache");
		directory_verify($"{DIRECTORY}log");
		
	} else {
		APP_DIRECTORY = env_user();
		APP_DIRECTORY = string_replace_all(APP_DIRECTORY, "\\", "/");
		ROAMING_DIRECTORY = string_replace(APP_DIRECTORY, "Local", "Roaming");
		show_debug_message($"App directory: {APP_DIRECTORY}");
		
		directory_verify(APP_DIRECTORY);
		
		var perstPath = APP_DIRECTORY + "persistPreference.json"; 
		if(file_exists_empty(perstPath) && !PROGRAM_ARGUMENTS._nodir) {
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
		directory_verify($"{DIRECTORY}log");
		
		APP_LOCATION = working_directory;
		
		var _testdir = $"{DIRECTORY}test";
		directory_verify(_testdir);
		
		// if(RUN_IDE) {
			// APP_LOCATION = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/";
		// }
	}
	
	printDebug($"===================== WORKING DIRECTORIES =====================\n");
    show_debug_message($"APP_DIRECTORY: {APP_DIRECTORY}");
    show_debug_message($"DIRECTORY: {DIRECTORY}");
    show_debug_message($"PREFERENCES_DIR: {PREFERENCES_DIR}");
    show_debug_message($"working_directory: {working_directory}");
    
    directory_verify(PREFERENCES_DIR);
#endregion
	pid  = ProcIdFromSelf();
	
	__t = get_timer();
	__r = getMemoryUsage(pid); 
	_r0 = __r;
	function __log_tr() {
		var _t = get_timer();
		var _r = getMemoryUsage(pid); 
		var _txt = $"complete in {(_t-__t)/1000}ms [{string_byte_format(_r-__r)}]";
		
		__t = _t;
		__r = _r; 
		return _txt;
	}
	
	printDebug($"- Setup");
	              PREF_LOAD();            printDebug($"- init Preferences   | {__log_tr()}");
	if(!IS_CMD) { __initLocale();         printDebug($"- init Locale        | {__log_tr()}"); }
	if(!IS_CMD) { __initHotKey();         printDebug($"- init Hotkeys       | {__log_tr()}"); }
	
	log_clear();
	log_newline();
	printDebug("Begin");
	printDebug($"DIRECTORY {DIRECTORY}");
	
	PREF_APPLY();
	var t0   = get_timer();
	var t    = get_timer();
	var _lua = PROGRAM_ARGUMENTS._lua;
	__r = getMemoryUsage(pid); 
	
				  __initSurfaceFormat();  printDebug($"- init SurfaceFormat | {__log_tr()}"); 
				  __initUser();           printDebug($"- init User          | {__log_tr()}"); 
	if(!IS_CMD) { __initTheme();          printDebug($"- init Theme         | {__log_tr()}");  }
	if(!IS_CMD) { loadFonts();            printDebug($"- init Font          | {__log_tr()}");  }
	if(!IS_CMD) { __initProject();        printDebug($"- init Project       | {__log_tr()}");  }
	              __fnInit();             printDebug($"- init Functions     | {__log_tr()}"); 
	
	if(!IS_CMD) { __initCollection();     printDebug($"- init Collection    | {__log_tr()}"); }
	if(!IS_CMD) { __initAssets();         printDebug($"- init Assets        | {__log_tr()}"); }
	if(!IS_CMD) { __initPresets();        printDebug($"- init Presets       | {__log_tr()}"); }
	if(!IS_CMD) { __initFontFolder();     printDebug($"- init FontFolder    | {__log_tr()}"); }
	
	if(_lua)    { __initLua();            printDebug($"- init Lua           | {__log_tr()}"); }
	if(!IS_CMD) { __initNodeData();       printDebug($"- init NodeData      | {__log_tr()}"); }
				  __initNodes();          printDebug($"- init Node Registry | {__log_tr()}");
	if(!IS_CMD) { __initSteamUGC();       printDebug($"- init SteamUGC      | {__log_tr()}"); }
	if(!IS_CMD) { __initPen();            printDebug($"- init Pen           | {__log_tr()}"); }
	if(!IS_CMD) { __initAddon();          printDebug($"- init Addon         | {__log_tr()}"); }
	
	if(!IS_CMD) { LOAD_SAMPLE();          printDebug($"- init Sample        | {__log_tr()}"); }
	if(!IS_CMD) { INIT_FOLDERS();         printDebug($"- init Folders       | {__log_tr()}"); }
	if(!IS_CMD) { RECENT_LOAD();          printDebug($"- init Recents       | {__log_tr()}"); }
	
	printDebug($"-- Initialization complete in {(get_timer()-t0)/1000}ms [{string_byte_format(getMemoryUsage(pid) - _r0)}]");
	display_set_timing_method(tm_countvsyncs);
	
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

#region post init
	directory_set_current_working(DIRECTORY);
	
	print($"working: {working_directory}");
	print($"project: {program_directory}");
	
	// if(RUN_IDE) __test_update_theme();
	
	if(PREFERENCES.video_mode)
		APP_SURF_OVERRIDE = true;
	
#endregion
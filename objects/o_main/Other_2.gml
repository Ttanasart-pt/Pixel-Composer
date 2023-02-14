/// @description main directory, parameter
#region directory
	globalvar DIRECTORY;
	DIRECTORY = environment_get_variable("userprofile") + "\\AppData\\Local\\PixelComposer\\";
	if(!directory_exists(DIRECTORY))
		directory_create(DIRECTORY);
	if(!directory_exists(DIRECTORY + "temp"))
		directory_create(DIRECTORY + "temp");
	
	METADATA = __getdefaultMetaData();
	
	log_clear();
	log_newline();
	log_message("SESSION", "Begin");
	log_message("DIRECTORY", DIRECTORY);
	
	PREF_LOAD();
	loadFonts();
	loadGraphic(PREF_MAP[? "theme"]);
	loadColor(PREF_MAP[? "theme"]);
	
	__initLocale();
	__init_theme();
	__initCollection();
	__initAssets();
	__initPresets();
	__initFontFolder();
	__initLua();
	__init_node_guide();
	__initSteamUGC();
	
	setPanel();
	
	if(file_exists("icon.png"))
		file_copy("icon.png", DIRECTORY + "icon.png");
	
	environment_set_variable("IMGUI_DIALOG_WIDTH", string(800));
	
	var cmd = "assoc .pxc=\"" + string(program_directory) + "PixelComposer.exe\"";
	execute_shell("", cmd);
			
	var cmd = "assoc .pxcc=\"" + string(program_directory) + "PixelComposer.exe\"";
	execute_shell("", cmd);
#endregion

#region parameter
	alarm[1] = 2;
	
	if(parameter_count() > 1) {
		var path = parameter_string(1);
		if(path == "--crashed") {
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
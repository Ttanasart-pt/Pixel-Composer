/// @description main directory, parameter
#region directory
	globalvar DIRECTORY;
	DIRECTORY = environment_get_variable("userprofile") + "\\AppData\\Local\\Pixels_Composer\\";
	if(!directory_exists(DIRECTORY))
		directory_create(DIRECTORY);
	if(!directory_exists(DIRECTORY + "temp"))
		directory_create(DIRECTORY + "temp");
		
	log_clear();
	log_newline();
	log_message("SESSION", "Begin");
	log_message("DIRECTORY", DIRECTORY);
	__init_theme();
	__initCollection();
	__initAssets();
	__initPresets();
	__initFontFolder();
	
	PREF_LOAD();
	loadFonts();
	loadGraphic(PREF_MAP[? "theme"]);
	loadColor(PREF_MAP[? "theme"]);
	
	setPanel();
#endregion

#region parameter
	alarm[1] = 2;

	if(parameter_count() > 1) {
		var path = parameter_string(1);
		path = string_replace_all(path, "\n", "");
		path = string_replace_all(path, "\"", "");
		
		if(file_exists(path) && filename_ext(path) == ".pxc") {
			file_open_parameter = path;
			alarm[2] = 3;
			
			directory_set_current_working(DIRECTORY);
		}
	}
#endregion
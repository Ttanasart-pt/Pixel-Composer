/// @description main directory, parameter
#region directory
	globalvar DIRECTORY;
	DIRECTORY = "C:\\Users\\" + environment_get_variable("USERNAME") + "\\AppData\\Local\\Pixels_Composer\\";
	log_clear();
	log_newline();
	log_message("SESSION", "Begin");
	log_message("DIRECTORY", DIRECTORY);
	__init_collection();
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
		
			set_working_directory(DIRECTORY);
		}
	}
#endregion

#region pref
	PREF_LOAD();
	setPanel();
#endregion
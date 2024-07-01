#region samples
	globalvar SAMPLE_PROJECTS;
	SAMPLE_PROJECTS = ds_list_create();
#endregion

function LOAD_FOLDER(list, folder) { #region
	var path = $"{DIRECTORY}Welcome files/{folder}";
	var file = file_find_first(path + "/*", fa_directory);
	
	while(file != "") {		
		var f = file;
		var full_path = path + "/" + file;
		file = file_find_next();
		
		if(!path_is_project(full_path)) continue;
		
		var f = new FileObject(filename_name_only(f), full_path);
		var icon_path = string_replace(full_path, filename_ext(full_path), ".png");
			
		if(file_exists_empty(icon_path)) {
			f.spr = sprite_add(icon_path, 0, false, false, 0, 0);
			sprite_set_offset(f.spr, sprite_get_width(f.spr) / 2, sprite_get_height(f.spr) / 2);
		}
		
		f.tag = folder;
		
		ds_list_add(list, f);
	}
	file_find_close();
} #endregion

function LOAD_SAMPLE() { #region
	ds_list_clear(SAMPLE_PROJECTS);
	var zzip = "Welcome files/Welcome files.zip";
	var targ = $"{DIRECTORY}Welcome files";
	
	directory_verify(targ);
	zip_unzip(zzip, targ);
	
	var _dir = [];
	var path = $"{DIRECTORY}Welcome files/";
	var file = file_find_first(path + "/*", fa_directory);
	
	while(file != "") {		
		if(directory_exists(path + "/" + file)) 
			array_push(_dir, file);
		file = file_find_next();
	}
	file_find_close();
	
	LOAD_FOLDER(SAMPLE_PROJECTS, "Getting started"); array_remove(_dir, "Getting started");
	LOAD_FOLDER(SAMPLE_PROJECTS, "Sample Projects"); array_remove(_dir, "Sample Projects");
	
	for (var i = 0, n = array_length(_dir); i < n; i++) 
		LOAD_FOLDER(SAMPLE_PROJECTS, _dir[i]); 
} #endregion
#region samples
	globalvar SAMPLE_PROJECTS;
	SAMPLE_PROJECTS = ds_list_create();
#endregion

function LOAD_FOLDER(list, path) {
	if(!directory_exists(path)) return;
	
	var folder = filename_name_only(path);
	var files  = directory_listdir(path, 0);
	
	for( var i = 0, n = array_length(files); i < n; i++ ) {
		var fPath = files[i];
		if(!path_is_project(fPath)) continue;
		
		var fObj  = new FileObject(fPath);
		var iPath = filename_ext_verify(fPath, ".png");
			
		if(file_exists_empty(iPath)) {
			fObj.spr = sprite_add(iPath, 0, false, false, 0, 0);
			sprite_set_offset(fObj.spr, sprite_get_width(fObj.spr) / 2, sprite_get_height(fObj.spr) / 2);
		}
		
		fObj.tag = folder;
		ds_list_add(list, fObj);
	}
	
	var _dir = directory_listdir(path, fa_directory);
	for( var i = 0, n = array_length(_dir); i < n; i++ ) 
		LOAD_FOLDER(list, _dir[i]);
}

function LOAD_SAMPLE() {
	ds_list_clear(SAMPLE_PROJECTS);
	var zzip = "data/Welcome files/Welcome files.zip";
	var targ = $"{DIRECTORY}Welcome files";
	
	directory_verify(targ);
	zip_unzip(zzip, targ);
	
	var path = $"{DIRECTORY}Welcome files";
	var _dir = directory_listdir(path, fa_directory);
	
	for (var i = 0, n = array_length(PREFERENCES.welcome_file_order); i < n; i++) {
		var _f = PREFERENCES.welcome_file_order[i];
		
		LOAD_FOLDER(SAMPLE_PROJECTS, $"{path}/{_f}"); 
		array_remove(_dir, $"{path}/{_f}");
	}	
	
	for (var i = 0, n = array_length(_dir); i < n; i++) 
		LOAD_FOLDER(SAMPLE_PROJECTS, _dir[i]); 
		
	for( var i = 0, n = array_length(PREFERENCES.path_welcome); i < n; i++ ) 
		LOAD_FOLDER(SAMPLE_PROJECTS, PREFERENCES.path_welcome[i]); 
}
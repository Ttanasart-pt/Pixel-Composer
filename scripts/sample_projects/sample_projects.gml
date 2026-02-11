#region globals
	globalvar SAMPLE_PROJECTS; SAMPLE_PROJECTS = [];
#endregion

function LOAD_FOLDER(list, path) {
	if(!directory_exists(path)) return;
	
	var folder = filename_name_only(path);
	var files  = directory_listdir(path, 0);
	
	for( var i = 0, n = array_length(files); i < n; i++ ) {
		var fPath = files[i];
		if(!path_is_project(fPath)) continue;
		
		var fObj = new FileObject(fPath);
		fObj.tag = folder;
		array_push(list, fObj);
	}
	
	var _dir = directory_listdir(path, fa_directory);
	for( var i = 0, n = array_length(_dir); i < n; i++ ) 
		LOAD_FOLDER(list, _dir[i]);
}

function LOAD_SAMPLE() {
	SAMPLE_PROJECTS = [];
	
	var zzip = $"{working_directory}packs/Welcome files.zip";
	var targ = $"{DIRECTORY}Welcome files";
	directory_verify(targ);
	
	if(check_version($"{targ}/version")) {
		directory_destroy($"{targ}/Sample Projects")
		zip_unzip(zzip, targ);
	}
	
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
#region globals
	globalvar SAMPLE_PROJECTS; SAMPLE_PROJECTS = [];
	globalvar GETTING_STARTED; GETTING_STARTED = [];
#endregion

function loadSampleFolder(list, path) {
	if(!directory_exists(path)) return;
	
	var folder = filename_name_only(path);
	var files  = directory_listdir(path, 0);
	var pr     = ds_priority_create();
	
	for( var i = 0, n = array_length(files); i < n; i++ ) {
		var fPath = files[i];
		if(!path_is_project(fPath)) continue;
		
		var fObj  = new FileObject(fPath);
		fObj.name = filename_strip_order(fObj.name);
		fObj.tag  = filename_strip_order(folder);
		
		var wei   = 0;
		var fname = filename_name_only(fPath);
		var sname = string_split(fname, " ");
		if(isNumber(sname[0])) wei = toNumber(sname[0]);
		ds_priority_add(pr, fObj, wei);
	}
	
	while(!ds_priority_empty(pr))
		array_push(list, ds_priority_delete_min(pr));
	ds_priority_destroy(pr);
	
	var _dir = directory_listdir(path, fa_directory);
	for( var i = 0, n = array_length(_dir); i < n; i++ ) 
		loadSampleFolder(list, _dir[i]);
}

function LOAD_SAMPLE() {
	SAMPLE_PROJECTS = [];
	GETTING_STARTED = [];
	
	var targ = $"{DIRECTORY}Welcome files";
	directory_verify(targ);
	
	if(check_version($"{targ}/version")) {
		var _path = $"{DIRECTORY}Welcome files/Getting started";
		if(directory_exists(_path)) directory_destroy(_path);
		
		directory_destroy($"{targ}/Sample Projects")
		zip_unzip($"{working_directory}pack/welcome_files.zip", targ);
	}
	
	var path = $"{DIRECTORY}Welcome files";
	var _dir = directory_listdir(path, fa_directory);
	
	loadSampleFolder(GETTING_STARTED, $"{path}/Getting started"); 
	array_remove(_dir, $"{path}/Getting started");
	
	for (var i = 0, n = array_length(_dir); i < n; i++) 
		loadSampleFolder(SAMPLE_PROJECTS, _dir[i]); 
		
	for( var i = 0, n = array_length(PREFERENCES.path_welcome); i < n; i++ ) 
		loadSampleFolder(SAMPLE_PROJECTS, PREFERENCES.path_welcome[i]); 
}
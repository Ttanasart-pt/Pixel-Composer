function path_search(paths, _filter = ".png") {
	var _paths = [];
	for( var i = 0, n = array_length(paths); i < n; i++ )
		array_append(_paths, paths_to_array_ext(paths[i], _filter));
	return _paths;
}

function path_dir_get_files(paths, _extension = ".png", _recur = true) {
	paths      = string_trim_end(paths, ["/", "\\"]);
	var _ext   = string_splice(_extension, ";", false, false);
	var _paths = [];
	
	if(!directory_exists(paths)) return _paths;
	
	var st    = ds_stack_create();
	var _root = true;
	ds_stack_push(st, paths);
	
	while(!ds_stack_empty(st)) {
		var curr_path = ds_stack_pop(st);
		var file = file_find_first(curr_path + "/*", fa_none);
		
		while(file != "") {
			var file_full = curr_path + "/" + file;
			
			if((_recur || _root) && directory_exists(file_full))
				ds_stack_push(st, file_full);
				
			else if(array_exists(_ext, string_lower(filename_ext(file))))
				array_push(_paths, file_full);
		
			file = file_find_next();
		}
		file_find_close();
		
		_root = false;
	}
	
	ds_stack_destroy(st);
	
	return _paths;
}

function paths_to_array_ext(paths, _extension = ".png") {
	var _ext = string_splice(_extension, ";", false, false);
	var _pth = [];
	
	for(var i = array_length(paths) - 1; i >= 0; i--) {
		var _e = string_lower(filename_ext(paths[i]));
		
		if(file_exists(paths[i]) && array_exists(_ext, _e))
			array_push(_pth, paths[i]);
	}
	
	return _pth;
}

function path_is_image(path) {
	if(!file_exists_empty(path)) return false;	
	
	var ext = string_lower(filename_ext(path));
	switch(ext) {
		case ".png":
		case ".jpg":
		case ".jpeg":
		case ".gif":
			return true;
	}
	return false;
}

function path_is_project(path, checkExist = true) {
	if(checkExist && !file_exists_empty(path)) return false;
	
	var ext = filename_ext(path);
	    ext = string_letters(ext);
	    ext = string_lower(ext);
	    ext = string_trim(ext, ["."]);
	
	switch(ext) {
		case "pxc":
		case "cpxc":
			return true;
			
		default : 
			return string_starts_with(ext, "pxc");
	}
	
	return false;
}

function path_is_backup(path) {
	if(!path_is_project(path)) return false;
	
	var ext = string_lower(filename_ext(path));
	    ext = string_replace(ext, ".", "");
	
	return string_letters(ext) != ext;
}

function filename_ext_raw(path) { return string_lower(string_replace(filename_ext(path), ".", "")); }
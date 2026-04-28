function directory_verify(path) {
	var _d = path;
	var _v = ds_stack_create();
	
	while(!directory_exists(_d)) {
		ds_stack_push(_v, _d);
		_d = filename_dir(_d);
	}
	
	repeat(ds_stack_size(_v)) 
		directory_create(ds_stack_pop(_v));
	
	ds_stack_destroy(_v);
}

function directory_clear(path) {
	if(directory_exists(path)) 
		directory_destroy(path);
	directory_create(path);
}

function directory_size_mb(dir) {
	if(!directory_exists(dir)) return 0;
	return directory_size(dir) / (1024*1024);
}

function directory_get_files_ext(dir, ext) {
	var a = [];
	
	if(!directory_exists(dir)) return a;
	var f = file_find_first(dir + "/*", 0), _f;
	while (f != "") {
		var _ext = string_lower(filename_ext(f));
		if(array_exists(ext, _ext)) array_push(a, f);
		
		f = file_find_next();
	}
	file_find_close();
	
	return a;
}

function directory_listdir(path, flag = fa_directory, _full = true) {
	var _dir = []
	var file = file_find_first($"{path}/*", flag);
	
	while(file != "") {	
		var f = filename_combine(path, file);
		if(flag == fa_directory && directory_exists(f) || flag != fa_directory && file_exists_empty(f)) 
			array_push(_dir, _full? f : file);
			
		file = file_find_next();
	}
	file_find_close();
	
	return _dir;
}


function directory_listdir_all(path) {
	var files = directory_listdir(path, 0, true);
	var dirs  = directory_listdir(path, fa_directory, true);
	
	for( var i = 0, n = array_length(dirs); i < n; i++ )
		array_append(files, directory_listdir_all(dirs[i], true));
	
	return files;
}

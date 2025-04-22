function directory_verify(path) {
	// show_debug_message($"verify: {path}")
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
	if(!directory_exists(path)) return;
	directory_destroy(path);
	directory_create(path);
}

function directory_size_mb(dir) {
	if(!directory_exists(dir)) return 0;
	return directory_size(dir) / (1024*1024);
}

function directory_get_files_ext(dir, ext) {
	var a = [];
	
	var f = file_find_first(dir + "/*", 0), _f;
	while (f != "") {
		if(filename_ext(f) == ext) array_push(a, f);
		f = file_find_next();
	}
	file_find_close();
	
	return a;
}
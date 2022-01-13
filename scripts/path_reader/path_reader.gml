function paths_to_array(paths, recur = false, _filter = "") {
	var _paths = [];
	var in = 0;
	
	if(directory_exists(paths)) {
		var st = ds_stack_create();
		ds_stack_push(st, paths);
		var regx = new regex_tree(_filter);
		
		while(!ds_stack_empty(st)) {
			var curr_path = ds_stack_pop(st);
			
			var file = file_find_first(curr_path + "/*", fa_directory);
			while(file != "") {
				var file_full = curr_path + "/" + file;
				if(directory_exists(file_full) && recur) {
					ds_stack_push(st, file_full);
				} else if(path_is_image(file_full) && regx.eval(file_full)) {
					array_push(_paths, file_full);
				}
			
				file = file_find_next();
			}
			file_find_close();
		}
		
		regx.free();
		delete regx;
		ds_stack_destroy(st);
	} else {
		var path_left = paths;
		
		while(string_length(path_left) > 0) {
			var space;
			if(string_pos("\n", path_left) == 0) space = string_length(path_left) + 1;
			else space = string_pos("\n", path_left);
			
			var path_str	= string_copy(path_left, 1, space - 1);
			path_left		= string_copy(path_left, space + 1, string_length(path_left) - space);
			
			if(!file_exists(path_str)) {
				var local_path = filename_dir(CURRENT_PATH) + "\\" + path_str;
				if(path_is_image(local_path))
					path_str = local_path;
			}
			
			if(file_exists(path_str))
				array_push(_paths, path_str);
		}
	}
	
	return _paths;
}

function path_is_image(path) {
	if(!file_exists(path)) return false;	
	
	var ext = filename_ext(path);
	switch(ext) {
		case ".png":
		case ".jpg":
		case ".jpeg":
		case ".gif":
			return true;
	}
	return false;
}
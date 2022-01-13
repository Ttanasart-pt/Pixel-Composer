function try_get_path(path) {
	if(!file_exists(path)) {
		var local_path = filename_dir(CURRENT_PATH) + "\\" + path;
		if(file_exists(local_path))
			return local_path;
		else 
			return -1;
	}
	
	return path;
}
function try_get_path(path) {
	if(file_exists_empty(path))
		return path;
		
	var local_path = filename_dir(PROJECT.path) + "/" + path;
	if(file_exists_empty(local_path))
		return local_path;
	
	return -1;
}
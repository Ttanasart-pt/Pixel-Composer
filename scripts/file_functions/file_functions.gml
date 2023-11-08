function file_copy_override(src, dest) {
	if(file_exists(dest)) file_delete(dest);
	file_copy(src, dest);
}

function filepath_resolve(path) {
	gml_pragma("forceinline");
	var _path = path;
	
	_path = string_replace_all(_path, "%DIR%/", DIRECTORY);
	_path = string_replace_all(_path, "%APP%/", working_directory);
	
	return _path;
}

function get_open_filenames_compat(ext, sel) {
	if(OS == os_windows) return get_open_filenames(ext, sel);
	return get_open_filename(ext, sel);
}
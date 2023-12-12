function file_exists_empty(path) { INLINE return path != "" && file_exists(path); }

function file_copy_override(src, dest) {
	if(file_exists_empty(dest)) file_delete(dest);
	file_copy(src, dest);
}

function filepath_resolve(path) {
	INLINE
	var _path = path;
	
	_path = string_replace_all(_path, "%DIR%/", DIRECTORY);
	_path = string_replace_all(_path, "%APP%/", APP_LOCATION);
	
	return _path;
}

function get_open_filenames_compat(ext, sel) {
	INLINE
	if(OS == os_windows) return get_open_filenames(ext, sel);
	return get_open_filename(ext, sel);
}
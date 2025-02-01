function file_exists_empty(path) { return is_string(path) && path != "" && file_exists(path); }

function file_copy_override(src, dest) {
	if(file_exists_empty(dest)) file_delete(dest);
	file_copy(src, dest);
}

function filepath_resolve(path) {
	INLINE
	
	path = string_replace_all(path, "%DIR%/", DIRECTORY);
	path = string_replace_all(path, "%APP%/", APP_LOCATION);
	path = string_replace_all(path, "\\", "/");
	if(PROJECT) path = string_replace_all(path, "./", filename_dir(PROJECT.path) + "/");
	
	return path;
}

function get_open_filenames_compat(ext, sel, caption = "Open") {
	INLINE
	
	var pat = OS == os_windows? get_open_filenames_ext(ext, sel, PREFERENCES.dialog_path, caption) : get_open_filename_pxc(ext, sel, caption);
	key_release();
	
	return pat;
}
	
function file_get_modify_s(path) {
	INLINE
	
	if(!file_exists_empty(path)) return 0;
	
	var _y = file_datetime_modified_year(path);
	var _m = file_datetime_modified_month(path);
	var _d = file_datetime_modified_day(path);
	var _h = file_datetime_modified_hour(path);
	var _n = file_datetime_modified_minute(path);
	var _s = file_datetime_modified_second(path);
	
	return ((((_y * 12 + _m) * 31 + _d) * 24 + _h) * 60 + _n) * 60 + _s;
}

function filename_verify_dir(_path) {
	var _sp = string_splice(_path, "/");
	var _pa = "";
	
	for( var i = 0, n = array_length(_sp) - 1; i < n; i++ ) {
		_pa += _sp[i] + "/";
		directory_verify(_pa);
	}
}

function get_save_filename_pxc(filter, name, caption = "Save as") {
	INLINE
	
	var path = get_save_filename_ext(filter, name, PREFERENCES.dialog_path, caption);
	    path = string(path);
	    
	if(path != "") PREFERENCES.dialog_path = filename_dir(path);
	return path;
}

function get_open_filename_pxc(filter, name, caption = "Open") {
	INLINE
	
	var path = get_open_filename_ext(filter, name, PREFERENCES.dialog_path, caption);
	    path = string(path);
	if(path != "") PREFERENCES.dialog_path = filename_dir(path);
	
	return path;
}
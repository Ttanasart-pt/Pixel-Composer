function file_exists_empty(path) { INLINE return path != "" && file_exists(path); }

function file_copy_override(src, dest) { #region
	if(file_exists_empty(dest)) file_delete(dest);
	file_copy(src, dest);
} #endregion

function filepath_resolve(path) { #region
	INLINE
	var _path = path;
	
	_path = string_replace_all(_path, "%DIR%/", DIRECTORY);
	_path = string_replace_all(_path, "%APP%/", APP_LOCATION);
	
	return _path;
} #endregion

function get_open_filenames_compat(ext, sel, caption = "Open") { #region
	INLINE
	
	if(OS == os_windows) return get_open_filenames_ext(ext, sel, PREFERENCES.dialog_path, caption);
	return get_open_filename_pxc(ext, sel, caption);
} #endregion
	
function file_get_modify_s(path) { #region
	INLINE
	
	if(!file_exists_empty(path)) return 0;
	
	var _y = file_datetime_modified_year(path);
	var _m = file_datetime_modified_month(path);
	var _d = file_datetime_modified_day(path);
	var _h = file_datetime_modified_hour(path);
	var _n = file_datetime_modified_minute(path);
	var _s = file_datetime_modified_second(path);
	
	return ((((_y * 12 + _m) * 31 + _d) * 24 + _h) * 60 + _n) * 60 + _s;
} #endregion

function get_save_filename_pxc(filter, name, caption = "Save as") {
	INLINE
	
	var path = get_save_filename_ext(filter, name, PREFERENCES.dialog_path, caption);
	if(path != "") PREFERENCES.dialog_path = filename_dir(path);
	return path;
}

function get_open_filename_pxc(filter, name, caption = "Open") {
	INLINE
	
	var path = get_open_filename_ext(filter, name, PREFERENCES.dialog_path, caption);
	if(path != "") PREFERENCES.dialog_path = filename_dir(path);
	return path;
}
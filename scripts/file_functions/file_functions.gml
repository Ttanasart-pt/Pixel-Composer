
	////- Verify

function file_exists_empty(path) { return is_string(path) && path != "" && file_exists(path); }

function file_is_image(path) {
	var ext  = string_lower(filename_ext(path));
		
	switch(ext) {
		case ".png"  :
		case ".jpg"  :
		case ".jpeg" :
		case ".gif"  :
			return true;
			
		default : 
			return false;
	}
	
	return false;
}
	
	////- Get
	
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

	////- Open Dialog

function get_open_filenames_compat(ext, sel, caption = "Open") {
	INLINE
	
	var pat = OS == os_windows? get_open_filenames_ext(ext, sel, PREFERENCES.dialog_path, caption) : get_open_filename_pxc(ext, sel, caption);
	key_release();
	
	return pat;
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

	////- Directory

function directory_listdir(path, flag = fa_directory) {
	var _dir = []
	var file = file_find_first($"{path}/*", flag);
	
	while(file != "") {	
		var f = $"{path}/{file}";
		if(flag == fa_directory && directory_exists(f) || flag != fa_directory && file_exists_empty(f)) 
			array_push(_dir, f);
			
		file = file_find_next();
	}
	file_find_close();
	
	return _dir;
}

	////- File name
	
function filepath_resolve(path) {
	INLINE
	
	path = string_replace_all(path, "%DIR%/", DIRECTORY);
	path = string_replace_all(path, "%APP%/", APP_LOCATION);
	path = string_replace_all(path, "\\", "/");
	if(PROJECT) path = string_replace_all(path, "./", filename_dir(PROJECT.path) + "/");
	
	return path;
}

function filename_verify_dir(_path) {
	var _sp = string_splice(_path, "/");
	var _pa = "";
	
	for( var i = 0, n = array_length(_sp) - 1; i < n; i++ ) {
		_pa += _sp[i] + "/";
		directory_verify(_pa);
	}
}

function filename_name_validate(name) {
	static reserved = [ "/", "\\", ".", "<", ">", ":", "\"", "|", "?", "*" ];
	static no = [ "CON", "PRN", "AUX", "NUL", "COM0", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT0", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9" ];
	
	for (var i = 0, n = array_length(reserved); i < n; i++)
		name = string_replace_all(name, reserved[i], "");
	
	for (var i = 0, n = array_length(no); i < n; i++)
		if(string_lower(name) == string_lower(no[i]))
			return "";
	
	return name;
}

function filename_name_only(name) {
	name = filename_name(name);
	return string_replace(name, filename_ext(name), "")
}

function filename_ext_verify(_path, _ext) {
	var _pext = filename_ext(_path);
	if(_pext == _ext) return _path;
	return filename_dir(_path) + "/" + filename_name_only(_path) + _ext;
}

	////- Actions

function file_copy_override(src, dest) {
	if(file_exists_empty(dest)) file_delete(dest);
	file_copy(src, dest);
}

function file_delete_safe(path) { if(!file_exists_empty(path)) return; file_delete(path); }


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

function __file_selector(_mode = "save", _dir = PREFERENCES.dialog_path, _fname = "", _ftype = "", _multi = false) {
	var _resPath = filepath_resolve(PREFERENCES.temp_path) + "fs_selected.txt"
	file_delete_safe(_resPath);
	
	var _arg = {};
	_arg[$ "--out"]   = _resPath;
	_arg[$ "--pref"]  = $"{DIRECTORY}Preferences\\fs.json";
	_arg[$ "--mode"]  = _mode;
	_arg[$ "--multi"] = _multi? "true" : "false";
	_arg[$ "--dir"]   = _dir;
	_arg[$ "--file"]  = _fname;
	_arg[$ "--ftype"] = _ftype;
	_arg[$ "-x"]      = WIN_X + WIN_W / 2;
	_arg[$ "-y"]      = WIN_Y + WIN_H / 2;
	
	var rep  = $"{APP_LOCATION}fs/fs.exe";
	if(OS == os_linux) rep = $"{APP_LOCATION}assets/fs/fs.appimage";
	
	var args = shellCommandBuilder(_arg);
	var _out = shell_execute(rep, args);
	var _res = undefined;
	
	if(true) {
		var _lines = string_split(_out, "\n");
		for( var i = 0, n = array_length(_lines); i < n; i++ ) {
			var _l = _lines[i];
			if(!string_starts_with(_l, "result:")) continue;
			
			var _ll = string_split(_l, "|");
			var _rs = array_safe_get(_ll, 1);
			
			_res = json_try_parse(_rs, undefined);
		}
		
	} else
		_res = json_load_struct(_resPath, undefined);
	
	return _res;
}

function get_open_filenames_compat(ext, fname, caption = "Open") {
	var _native = PREFERENCES.use_native_file_browser && OS == os_windows;
	if(_native) {
		var pat, w = OS == os_windows;
		
		if(w) pat = get_open_filenames_ext(ext, fname, PREFERENCES.dialog_path, caption);
		else  pat = get_open_filename_compat(ext, fname, caption);
		
		key_release();
		
		return pat;
	} 
	
	var _res = __file_selector("load", PREFERENCES.dialog_path, fname, ext, true);
	if(!is_struct(_res)) return "";
	
	var path = _res.path;
	if(path != "") PREFERENCES.dialog_path = filename_dir(path);
	
	var _pth   = _res.selected;
	var _paths = [];
	for( var i = 0, n = array_length(_pth); i < n; i++ )
		_paths[i] = _pth[i].path;
	return _paths;
}

function get_open_filename_compat(ext, fname, caption = "Open") {
	var _native = PREFERENCES.use_native_file_browser && OS == os_windows;
	if(_native) {
		var path = get_open_filename_ext(ext, fname, PREFERENCES.dialog_path, caption);
		    path = string(path);
		if(path != "") PREFERENCES.dialog_path = filename_dir(path);
		
		return path;
	}
	
	var _res = __file_selector("load", PREFERENCES.dialog_path, fname, ext, false);
	if(!is_struct(_res)) return "";
	
	var path = array_empty(_res.selected)? "" : _res.selected[0].path;
	if(path != "") PREFERENCES.dialog_path = filename_dir(path);
	return path;
}

function get_save_filename_compat(ext, fname, caption = "Save as") {
	var _native = PREFERENCES.use_native_file_browser && OS == os_windows;
	if(_native) {
		var path = get_save_filename_ext(ext, fname, PREFERENCES.dialog_path, caption);
		    path = string(path);
		    
		if(path != "") PREFERENCES.dialog_path = filename_dir(path);
		return path;
	}
	
	var _res = __file_selector("save", PREFERENCES.dialog_path, fname, ext, false);
	if(!is_struct(_res)) return "";
	
	var path = _res.path;
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

function filename_name_only(name) { name = filename_name(name); return string_replace(name, filename_ext(name), ""); }

function filename_ext_verify(_path, _ext)     { return filename_ext(_path) == _ext? _path : $"{filename_dir(_path)}/{filename_name_only(_path)}{_ext}"; }
function filename_ext_verify_add(_path, _ext) { return filename_ext(_path) == _ext? _path : $"{_path}{_ext}"; }

	////- Actions

function file_copy_override(src, dest) {
	if(file_exists_empty(dest)) file_delete(dest);
	file_copy(src, dest);
}

function file_delete_safe(path) { if(!file_exists_empty(path)) return; file_delete(path); }


	////- Overrides

function filename_os(_p) {
    if(os_type == os_windows) return _p;
    // _p = string_lower(_p);
    _p = string_replace_all(_p, "\\", "/");
    return _p;
}

#macro __file_delete file_delete
#macro file_delete file_delete_os
function file_delete_os(_p) { return __file_delete(filename_os(_p)); }

#macro __file_exists file_exists
#macro file_exists file_exists_os
function file_exists_os(_p) { return __file_exists(filename_os(_p)); }

#macro __file_copy file_copy
#macro file_copy file_copy_os
function file_copy_os(_p0, _p1) { return __file_copy(filename_os(_p0), filename_os(_p1)); }

#macro __file_find_first file_find_first
#macro file_find_first file_find_first_os
function file_find_first_os(_p, attr) { return __file_find_first(filename_os(_p), attr); }

 // TEXT

#macro __file_text_open_read file_text_open_read
#macro file_text_open_read file_text_open_read_os
function file_text_open_read_os(_p) { return __file_text_open_read(filename_os(_p)); }

#macro __file_text_open_write file_text_open_write
#macro file_text_open_write file_text_open_write_os
function file_text_open_write_os(_p) { return __file_text_open_write(filename_os(_p)); }

 // DIR

#macro __directory_exists directory_exists
#macro directory_exists directory_exists_os
function directory_exists_os(_p) { return __directory_exists(filename_os(_p)); }

#macro __directory_create directory_create
#macro directory_create directory_create_os
function directory_create_os(_p) { return __directory_create(filename_os(_p)); }

 // ZIP
 
#macro __zip_unzip zip_unzip
#macro zip_unzip zip_unzip_os
function zip_unzip_os(p0, p1) { return __zip_unzip(filename_os(p0), filename_os(p1)); }

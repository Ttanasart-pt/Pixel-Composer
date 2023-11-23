globalvar FONT_ISLOADED, FONT_CACHE;
globalvar f_h1, f_h2, f_h3, f_h5, f_p0, f_p0b, f_p1, f_p2, f_p3, f_code, f_sdf;

FONT_CACHE = {};
FONT_ISLOADED = false;

function _font_add(path, size, sdf = false) {
	var font_cache_dir = DIRECTORY + "font_cache";
	directory_verify(font_cache_dir);
	
	var _key = $"{filename_name_only(path)}_{size}_{sdf}";
	if(struct_has(FONT_CACHE, _key) && font_exists(FONT_CACHE[$ _key])) {
		//print($"Add font {_key}: restore from cache");
		return FONT_CACHE[$ _key];
	}
	
	var _t = current_time;
	var _f = font_add(path, size, false, false, 0, 0);
	if(sdf) {
		font_enable_sdf(_f, true);
	}
	
	FONT_CACHE[$ _key] = _f;
	
	return _f;
}

function _font_path(rel) {
	rel = string_replace_all(rel, "./", "");
	
	var defPath = $"{DIRECTORY}themes/{PREFERENCES.theme}/fonts/{rel}";
	
	if(LOCALE.fontDir == noone)
		return defPath;
	
	var overridePath = $"{LOCALE.fontDir}{rel}";
	if(file_exists(overridePath))
		return overridePath;
		
	return defPath;
}

function _font_load_from_struct(str, name, def) {
	if(!struct_has(str, name)) return def;
	var font = str[$ name];
	var path = _font_path(font.path);
	
	if(!file_exists(path)) {
		noti_status("Font resource " + string(path), " not found. Rollback to default font.");
		return def;
	}
	
	var _sdf = struct_try_get(font, "sdf", false);
	//print($"Font [{name}] {font} : {_sdf}")
	
	font_add_enable_aa(THEME_VALUE.font_aa);
	var _font = _font_add(path, font.size * UI_SCALE, _sdf);
	
	return _font;
}

function font_clear(font) { if(font_exists(font)) font_delete(font); }

function loadFonts() {
	if(FONT_ISLOADED) {
		font_clear(f_h1);
		font_clear(f_h2);
		font_clear(f_h3);
		font_clear(f_h5);
					
		font_clear(f_p0);
		font_clear(f_p0b);
					
		font_clear(f_p1);
		font_clear(f_p2);
		font_clear(f_p3);
		
		font_clear(f_code);
		font_clear(f_sdf);
	}
	
	var path = _font_path("./fonts.json");
	
	if(!file_exists(path)) {
		noti_status("Font not defined at " + path + ", rollback to default fonts.");
		f_h1  = _f_h1;
		f_h2  = _f_h2;
		f_h3  = _f_h3;
		f_h5  = _f_h5;
		f_p0  = _f_p0;
		f_p0b = _f_p0b;
		f_p1  = _f_p1;
		f_p2  = _f_p2;
		f_p3  = _f_p3;
		f_code = _f_code;
		f_sdf  = _f_sdf;
		FONT_ISLOADED = false;
		return;
	}
	
	var s = file_read_all(path);
	var fontDef = json_try_parse(s);
	
	f_h1 = _font_load_from_struct(fontDef, "h1", _f_h1);
	f_h2 = _font_load_from_struct(fontDef, "h2", _f_h2);
	f_h3 = _font_load_from_struct(fontDef, "h3", _f_h3);
	f_h5 = _font_load_from_struct(fontDef, "h5", _f_h5);
	
	f_p0  = _font_load_from_struct(fontDef, "p0",  _f_p0);
	f_p0b = _font_load_from_struct(fontDef, "p0b", _f_p0b);
	
	f_p1 = _font_load_from_struct(fontDef, "p1", _f_p1);
	f_p2 = _font_load_from_struct(fontDef, "p2", _f_p2);
	f_p3 = _font_load_from_struct(fontDef, "p3", _f_p3);
	
	f_code = _font_load_from_struct(fontDef, "code", _f_code);
	f_sdf  = _font_load_from_struct(fontDef, "sdf",  _f_sdf);
	
	FONT_ISLOADED = true;
}
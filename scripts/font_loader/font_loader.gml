globalvar FONT_DEF, FONT_ISLOADED, FONT_CACHE, FONT_CUST_CACHE, FONT_LIST;
globalvar f_h1, f_h2, f_h3, f_h5, f_p0, f_p0b, f_p1, f_p1b, f_p2, f_p2b, f_p3, f_p4;
globalvar f_code, f_sdf, f_sdf_medium;

global.LINE_HEIGHTS = {};

#region default
	FONT_DEF        = true;
	FONT_CACHE      = {};
	FONT_CUST_CACHE = {};
	FONT_ISLOADED   = false;
	FONT_LIST       = {};
	
	f_h1   = _f_h1;
	f_h2   = _f_h2;
	f_h3   = _f_h3;
	f_h5   = _f_h5;
	f_p0   = _f_p0;
	f_p0b  = _f_p0b;
	f_p1   = _f_p1;
	f_p1b  = _f_p1b;
	f_p2   = _f_p2;
	f_p2b  = _f_p2b;
	f_p3   = _f_p3;
	f_p4   = _f_p4;
	
	f_code = _f_code;
	f_sdf  = _f_sdf;
	f_sdf_medium  = _f_sdf_medium;
	FONT_ISLOADED = false;
	
	enum UI_FONT_TYPE {
		medium,
		bold,
		code
	}
#endregion

function __font_cache_height(font) { INLINE  draw_set_font(font); global.LINE_HEIGHTS[$ font] = string_height("l"); }

function __font_refresh() {
	__font_cache_height(f_h1);
	__font_cache_height(f_h2);
	__font_cache_height(f_h3);
	__font_cache_height(f_h5);
					
	__font_cache_height(f_p0);
	__font_cache_height(f_p0b);
		
	__font_cache_height(f_p1);
	__font_cache_height(f_p1b);
	
	__font_cache_height(f_p2);
	__font_cache_height(f_p2b);
	
	__font_cache_height(f_p3);
	__font_cache_height(f_p4);
		
	__font_cache_height(f_code);
	__font_cache_height(f_sdf);
	__font_cache_height(f_sdf_medium);
}

function _font_add(path, size, sdf = false, custom = false) {
	var _cache = custom? FONT_CUST_CACHE : FONT_CACHE;
	
	var _key = $"{filename_name_only(path)}_{size}_{sdf}";
	if(struct_has(_cache, _key) && font_exists(_cache[$ _key]))
		return _cache[$ _key];
	
	var _f = font_add(path, size, false, false, 0, 0);
	_cache[$ _key] = _f;
	if(!font_exists(_f)) return undefined;
	
	if(sdf) font_enable_sdf(_f, true);
	
	return _f;
}

function _font_path(rel) {
	rel = string_replace_all(rel, "./", "");
	var defPath = $"{DIRECTORY}Themes/{PREFERENCES.theme}/fonts/{rel}";
	
	if(LOCALE.fontDir == noone)
		return defPath;
	
	var overridePath = $"{LOCALE.fontDir}{rel}";
	if(file_exists_empty(overridePath))
		return overridePath;
	
	return defPath;
}

function _font_load_default(name, def) { FONT_LIST[$ name] = { data: noone, font: def }; return def; }

function _font_load_from_struct(str, name, def, type = UI_FONT_TYPE.medium) {
	if(!struct_has(str, name)) { noti_status($"Font data {name} not found. Rollback to default font."); return def; }
	
	var _data = str[$ name];
	var _path = _font_path(_data.path);
	
	switch(type) {
		case UI_FONT_TYPE.medium : if(file_exists_empty(PREFERENCES.font_overwrite)) _path = PREFERENCES.font_overwrite; break;
		case UI_FONT_TYPE.bold :   
			if(file_exists_empty(PREFERENCES.font_overwrite_bold)) _path = PREFERENCES.font_overwrite_bold;
			else if(file_exists_empty(PREFERENCES.font_overwrite)) _path = PREFERENCES.font_overwrite;
			break;
		
		case UI_FONT_TYPE.code : if(file_exists_empty(PREFERENCES.font_overwrite_code)) _path = PREFERENCES.font_overwrite_code; break;
	}
	
	if(!file_exists_empty(_path)) { noti_status($"Font resource {_path} not found. Rollback to default font."); return def; }
	
	var _sdf = struct_try_get(_data, "sdf", false);
	var _aa  = struct_try_get(THEME_VALUE, "font_aa", true);
	
	font_add_enable_aa(_aa);
	var _font = _font_add(_path, round(_data.size * UI_SCALE * PREFERENCES.text_scaling), _sdf);
	
	FONT_LIST[$ name] = { data: str, font: _font }
	
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
		font_clear(f_p1b);
		
		font_clear(f_p2);
		font_clear(f_p2b);
		
		font_clear(f_p3);
		font_clear(f_p4);
		
		font_clear(f_code);
		font_clear(f_sdf);
		font_clear(f_sdf_medium);
	}
	
	var path = _font_path("./fonts.json");
	
	FONT_LIST = {};
	
	if(FONT_DEF) {
		printDebug($"  - Using Build-in fonts");
		f_h1   = _font_load_default("h1",  _f_h1);
		f_h2   = _font_load_default("h2",  _f_h2);
		f_h3   = _font_load_default("h3",  _f_h3);
		f_h5   = _font_load_default("h5",  _f_h5);
		f_p0   = _font_load_default("p0",  _f_p0);
		f_p0b  = _font_load_default("p0b", _f_p0b);
		f_p1   = _font_load_default("p1",  _f_p1);
		f_p1b  = _font_load_default("p1b", _f_p1b);
		f_p2   = _font_load_default("p2",  _f_p2);
		f_p2b  = _font_load_default("p2b", _f_p2b);
		
		f_p3   = _font_load_default("p3",  _f_p3);
		f_p4   = _font_load_default("p4",  _f_p4);
		
		f_code = _font_load_default("code", _f_code);
		f_sdf  = _font_load_default("sdf",  _f_sdf);
		f_sdf_medium  = _font_load_default("sdf_medium", _f_sdf_medium);
		FONT_ISLOADED = false;
		
		__font_refresh();
		return;
	}
	
	var s = file_read_all(path);
	var fontDef = json_try_parse(s);
	
	f_h1  = _font_load_from_struct(fontDef, "h1",    _f_h1,   UI_FONT_TYPE.bold    );
	f_h2  = _font_load_from_struct(fontDef, "h2",    _f_h2,   UI_FONT_TYPE.bold    );
	f_h3  = _font_load_from_struct(fontDef, "h3",    _f_h3,   UI_FONT_TYPE.bold    );
	f_h5  = _font_load_from_struct(fontDef, "h5",    _f_h5,   UI_FONT_TYPE.bold    );
	
	f_p0  = _font_load_from_struct(fontDef, "p0",    _f_p0,   UI_FONT_TYPE.medium  );
	f_p0b = _font_load_from_struct(fontDef, "p0b",   _f_p0b,  UI_FONT_TYPE.bold    );
	
	f_p1  = _font_load_from_struct(fontDef, "p1",    _f_p1,   UI_FONT_TYPE.medium  );
	f_p1b = _font_load_from_struct(fontDef, "p1b",   _f_p1b,  UI_FONT_TYPE.bold    );
	
	f_p2  = _font_load_from_struct(fontDef, "p2",    _f_p2,   UI_FONT_TYPE.medium  );
	f_p2b = _font_load_from_struct(fontDef, "p2b",   _f_p2b,  UI_FONT_TYPE.bold    );
	
	f_p3  = _font_load_from_struct(fontDef, "p3",    _f_p3,   UI_FONT_TYPE.medium  );
	f_p4  = _font_load_from_struct(fontDef, "p4",    _f_p4,   UI_FONT_TYPE.medium  );
	
	f_code       = _font_load_from_struct(fontDef, "code",        _f_code,       UI_FONT_TYPE.code );
	f_sdf        = _font_load_from_struct(fontDef, "sdf",         _f_sdf,        UI_FONT_TYPE.bold );
	f_sdf_medium = _font_load_from_struct(fontDef, "sdf_medium",  _f_sdf_medium, UI_FONT_TYPE.bold );
	
	FONT_ISLOADED = true;
	
	__font_refresh();
}
globalvar FONT_ISLOADED, f_h3, f_h5, f_p0, f_p0b, f_p1, f_p2, f_p3, f_code;

FONT_ISLOADED = false;

function _font_path(rel) {
	return DIRECTORY + "themes/" + PREF_MAP[? "theme"] + "/fonts/" + string_replace_all(rel, "./", "");
}

function _font_load_from_struct(str, def) {
	var path = _font_path(str.path);
	if(!file_exists(path)) {
		noti_status("Font resource " + string(path), " not found. Rollback to default font.");
		return def;
	}
	
	return font_add(path, str.size * UI_SCALE, false, false, str.range[0], str.range[1]);
}

function font_clear(font) { if(font_exists(font)) font_delete(font); }

function loadFonts() {
	if(FONT_ISLOADED) {
		font_clear(f_h3);
		font_clear(f_h5);
					
		font_clear(f_p0);
		font_clear(f_p0b);
					
		font_clear(f_p1);
		font_clear(f_p2);
		font_clear(f_p3);
		
		font_clear(f_code);
	}
	
	var path = _font_path("./fonts.json");
	if(!file_exists(path)) {
		noti_status("Font not defined at " + path + ", rollback to default fonts.");
		f_h3  = _f_h3;
		f_h5  = _f_h5;
		f_p0  = _f_p0;
		f_p0b = _f_p0b;
		f_p1  = _f_p1;
		f_p2  = _f_p2;
		f_p3  = _f_p3;
		f_code = _f_code;
		FONT_ISLOADED = false;
		return;
	}
	
	var s = file_text_read_all(path);
	var fontDef = json_try_parse(s);
	
	f_h3 = _font_load_from_struct(fontDef.h3, _f_h3);
	f_h5 = _font_load_from_struct(fontDef.h5, _f_h5);
	
	f_p0  = _font_load_from_struct(fontDef.p0, _f_p0);
	f_p0b = _font_load_from_struct(fontDef.p0b, _f_p0b);
	
	f_p1 = _font_load_from_struct(fontDef.p1, _f_p1);
	f_p2 = _font_load_from_struct(fontDef.p2, _f_p2);
	f_p3 = _font_load_from_struct(fontDef.p3, _f_p3);
	
	f_code = _font_load_from_struct(fontDef.code, _f_code);
	
	FONT_ISLOADED = true;
}
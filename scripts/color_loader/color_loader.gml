#region colors
	globalvar CDEF; CDEF            = new ThemeColorDef();
	globalvar COLORS; COLORS          = new ThemeColor();
	globalvar COLOR_KEY_ARRAY; COLOR_KEY_ARRAY = [];
	globalvar COLORS_KEYS; COLORS_KEYS     = {};
	globalvar COLORS_DEF; COLORS_DEF      = {};
	globalvar COLORS_OVERRIDE; COLORS_OVERRIDE = {};
	
	globalvar THEME_VALUE; THEME_VALUE     = new ThemeValue();
	globalvar THEME_SCALE; THEME_SCALE     = 1;
	
	global.palette_keys = [
		"main_dkblack", 
		"main_mdblack", 
		"main_black", 
		"main_dkgrey", 
		"main_dark", 
		"main_grey", 
		"main_ltgrey", 
		"main_mdwhite", 
		"main_white", 
		"main_bg", 
	
		"blue", 
		"cyan", 
		"yellow", 
		"orange", 
		"red", 
		"pink", 
		"purple", 
		"lime", 
		"pgreen", 
		"pblue", 
	
		"black", 
		"dkgrey", 
		"smoke", 
		"white", 
	];
#endregion

function loadColor(theme = "default") {
	CDEF		    = new ThemeColorDef();
	COLORS		    = new ThemeColor();
	THEME_VALUE     = new ThemeValue();
	COLORS_KEYS     = {};
	COLORS_OVERRIDE = {};
	COLORS_DEF      = {
		colors: new ThemeColorDef(),
		define: new ThemeColor(),
	};
	
	_loadColor(theme);
	_loadThemeParameter(theme);
}

function _loadColorStringParse(str) {
	str = string_trim(str);
	
	if(string_starts_with(str, "[") && string_ends_with(str, "]")) {
		str = string_trim(str, ["[", "]"]);
		var sp = string_splice(str, ",");
		
		if(array_length(sp) == 3) {
			sp[0] = string_trim(sp[0]);
			sp[1] = string_trim(sp[1]);
			sp[2] = toNumber(sp[2]);
			return sp;
		}
	}
	
	return str;
}

function _loadColorString(str) {
	if(!is_array(str)) return struct_has(CDEF, str)? CDEF[$ str] : color_from_rgb(str);
	if(array_length(str) != 3) return 0;
	
	var c0 = struct_try_get(CDEF, str[0], 0);
	var c1 = struct_try_get(CDEF, str[1], 0);
	var m  = toNumber(str[2]);
	return merge_color(c0, c1, m);
}

function _loadColor(theme = "default") {
	var t = get_timer();
		
	var dirr  = $"{DIRECTORY}Themes/{theme}";
	var path  = $"{dirr}/values.json";
	var pathO = $"{dirr}/{PREFERENCES.theme_override}.json";
	
	COLOR_KEY_ARRAY = variable_struct_get_names(COLORS);
	array_sort(COLOR_KEY_ARRAY, true);
		
	if(theme == "default" && !file_exists_empty(pathO)) { 
		COLORS_KEYS = json_load_struct(path); 
		return;  
	}
	
	if(!file_exists_empty(path)) { 
		noti_status($"Colors not defined at {path}, rollback to default color."); 
		return; 
	}
	
	var clrs = json_load_struct(path);
	COLORS_KEYS = clrs;
	
	////- Colors
	
	var clrkeys = variable_struct_get_names(clrs.colors);
	var defkeys = variable_struct_get_names(clrs.define);
	var arrkeys = variable_struct_get_names(clrs.array);
	
	var override = file_exists_empty(pathO)? json_load_struct(pathO) : {};
	COLORS_OVERRIDE = override;
	
	for( var i = 0, n = array_length(clrkeys); i < n; i++ ) {
		var key = clrkeys[i];
		var str = clrs.colors[$ key];
		
		COLORS_DEF.colors[$ key] = str;
		
		if(struct_has(override, key)) {
			str = override[$ key];
			COLORS_KEYS.colors[$ key] = str;
		} 
		
		CDEF[$ key] = color_from_rgb(str);
	}
	
	for( var i = 0, n = array_length(defkeys); i < n; i++ ) {
		var key = defkeys[i];
		var c   = c_white;
		var def = clrs.define[$ key];
		
		COLORS_DEF.define[$ key] = def;
		
		if(struct_has(override, key)) {
			def = override[$ key];
			COLORS_KEYS.define[$ key] = def;
		}
		
		COLORS[$ key] = _loadColorString(def);
	}
	
	for( var i = 0, n = array_length(arrkeys); i < n; i++ ) {
		var key = arrkeys[i];
		var def = clrs.array[$ key];
		
		COLORS_DEF.define[$ key] = def;
		
		if(struct_has(override, key)) {
			def = override[$ key];
			COLORS_KEYS.array[$ key] = def;
		}
		
		var c = array_create(array_length(def));
		for( var j = 0; j < array_length(def); j++ )
			c[j] = _loadColorString(def[j]);
		
		COLORS[$ key] = c;
	}
}

function _loadThemeParameter(theme = "default") {
	var dirr  = $"{DIRECTORY}Themes/{theme}";
	var path  = $"{dirr}/parameters.json";
	if(!file_exists_empty(path)) { noti_status($"Parameters not defined at {path}, rollback to default param."); return; }
	
	var vals = json_load_struct(path);
	struct_override(THEME_VALUE, vals);
	THEME_SCALE = THEME_VALUE.icon_scale;
}

function refreshThemePalette() {
	var defkeys = variable_struct_get_names(COLORS_KEYS.define);
	var arrkeys = variable_struct_get_names(COLORS_KEYS.array);
	
	for( var i = 0, n = array_length(defkeys); i < n; i++ ) {
		var key = defkeys[i];
		var def = COLORS_KEYS.define[$ key];
		var c   = c_white;
		
		COLORS[$ key] = _loadColorString(def);
	}
	
	for( var i = 0, n = array_length(arrkeys); i < n; i++ ) {
		var key = arrkeys[i];
		var def = COLORS_KEYS.array[$ key];
		
		var c = array_create(array_length(def));
		for( var j = 0; j < array_length(def); j++ )
			c[j] = _loadColorString(def[j]);
		
		COLORS[$ key] = c;
	}
}
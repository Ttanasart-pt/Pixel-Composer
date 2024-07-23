#region colors
	globalvar CDEF, COLORS, THEME_VALUE;
	
	CDEF		= new ThemeColorDef();
	COLORS		= new ThemeColor();
	THEME_VALUE = new ThemeValue();
#endregion

function loadColor(theme = "default") {
	CDEF		= new ThemeColorDef();
	COLORS		= new ThemeColor();
	THEME_VALUE = new ThemeValue();
	
	_loadColor(theme);
}

function _loadColor(theme = "default", replace = false) {
	var t = get_timer();
		
	var dirr  = DIRECTORY + "Themes/" + theme;
	var path  = dirr + "/values.json";
	var pathO = dirr + "/override.json";
	
	COLOR_KEYS = variable_struct_get_names(COLORS);
	array_sort(COLOR_KEYS, true);
		
	if(theme == "default" && !file_exists_empty(pathO)) return;
	if(!file_exists_empty(path)) { noti_status($"Colors not defined at {path}, rollback to default color."); return; }
	
	var clrs = json_load_struct(path);
	if(!struct_has(clrs, "values")) { print("Load color error"); return; }
	
	var valkeys = variable_struct_get_names(clrs.values);
	var defkeys = variable_struct_get_names(clrs.define);
	var clrkeys = variable_struct_get_names(clrs.colors);
	var arrkeys = variable_struct_get_names(clrs.array);
	
	if(replace)	THEME_VALUE = clrs.values;
	else		struct_override(THEME_VALUE, clrs.values);
	
	COLOR_KEYS = defkeys; 
	array_sort(COLOR_KEYS, true);
	
	for( var i = 0, n = array_length(clrkeys); i < n; i++ ) {
		var key = clrkeys[i];
		var str = struct_get(clrs.colors, key);
		
		CDEF[$ key] = color_from_rgb(str);
	}
	
	for( var i = 0, n = array_length(defkeys); i < n; i++ ) {
		var key = defkeys[i];
		var def = struct_get(clrs.define, key);
		var c   = c_white;
	
		if(is_array(def)) c = merge_color(struct_get(CDEF, def[0]), struct_get(CDEF, def[1]), def[2]);
		else              c = struct_has(CDEF, def)? struct_get(CDEF, def) : color_from_rgb(def);
		
		COLORS[$ key] = c;
	}
	
	for( var i = 0, n = array_length(arrkeys); i < n; i++ ) {
		var key = arrkeys[i];
		var def = struct_get(clrs.array, key);
		
		var c = array_create(array_length(def));
		for( var j = 0; j < array_length(def); j++ )
			c[j] = struct_has(CDEF, def[j])? struct_get(CDEF, def[j]) : color_from_rgb(def[j]);
		
		COLORS[$ key] = c;
	}
	
	if(file_exists_empty(pathO)) struct_override(COLORS, json_load_struct(pathO));
}
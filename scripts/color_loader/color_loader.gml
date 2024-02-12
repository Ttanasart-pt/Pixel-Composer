#region colors
	globalvar CDEF, COLORS, THEME_VALUE;
	
	CDEF		= new ThemeColorDef();
	COLORS		= new ThemeColor();
	THEME_VALUE = new ThemeValue();
#endregion

function loadColor(theme = "default") { #region
	CDEF		= new ThemeColorDef();
	COLORS		= new ThemeColor();
	THEME_VALUE = new ThemeValue();
	
	_loadColor("default", true);
	
	if(!THEME_DEF) _loadColor(theme);
} #endregion

function _loadColor(theme = "default", replace = false) { #region
	var dirr = DIRECTORY + "Themes/" + theme;
	var path  = dirr + "/values.json";
	var pathO = dirr + "/override.json";
	
	if(!file_exists_empty(path)) {
		noti_status("Colors not defined at " + path + ", rollback to default color.");
		return;
	}
	
	var clrs = json_load_struct(path);
	var oclr = file_exists_empty(pathO)? json_load_struct(pathO) : {};
	
	if(!struct_has(clrs, "values")) {
		print("Load color error");
		return;
	}
	
	var valkeys = variable_struct_get_names(clrs.values);
	if(replace)	THEME_VALUE = clrs.values;
	else		struct_override(THEME_VALUE, clrs.values);
	
	var defkeys = variable_struct_get_names(clrs.define);
	COLOR_KEYS = defkeys;
	array_sort(COLOR_KEYS, true);
	
	var clrkeys = variable_struct_get_names(clrs.colors);
	
	for( var i = 0, n = array_length(clrkeys); i < n; i++ ) {
		var key = clrkeys[i];
		var str = variable_struct_get(clrs.colors, key);
		
		var c = color_from_rgb(str);
		variable_struct_set(CDEF, key, c);
	}
	
	for( var i = 0, n = array_length(defkeys); i < n; i++ ) {
		var key = defkeys[i];
		var c   = c_white;
		
		if(variable_struct_exists(oclr, key)) {
			c = variable_struct_get(oclr, key);
		} else if(variable_struct_exists(clrs.define, key)) {
			var def = variable_struct_get(clrs.define, key);
		
			if(is_array(def)) {
				var c0 = variable_struct_get(CDEF, def[0]);
				var c1 = variable_struct_get(CDEF, def[1]);
				var t  = def[2];
				c  = merge_color(c0, c1, t);
			} else if(variable_struct_exists(CDEF, def))
				c = variable_struct_get(CDEF, def);
			else 
				c = color_from_rgb(def);
		}
		
		variable_struct_set(COLORS, key, c);
	}
	
	for( var i = 0, n = array_length(valkeys); i < n; i++ ) {
		var key = valkeys[i];
		if(variable_struct_exists(oclr, key)) {
			var c = variable_struct_get(oclr, key);
			variable_struct_set(THEME_VALUE, key, c);
		}
	}
	
	var arrkeys = variable_struct_get_names(clrs.array);
	for( var i = 0, n = array_length(arrkeys); i < n; i++ ) {
		var key = arrkeys[i];
		var def = variable_struct_get(clrs.array, key);
		
		var c = [];
		for( var j = 0; j < array_length(def); j++ ) {
			if(variable_struct_exists(CDEF, def[j]))
				c[j] = variable_struct_get(CDEF, def[j]);
			else
				c[j] = color_from_rgb(def[j]);
		}
		variable_struct_set(COLORS, key, c);
	}
} #endregion
#region colors
	CDEF = {};
	COLORS = {};
#endregion

function loadColor(theme = "default") {
	var dirr = DIRECTORY + "themes/" + theme;
	var path  = dirr + "/colors.json";
	var pathO = dirr + "/override.json";
	
	if(!file_exists(path)) {
		noti_status("Colors not defined at " + path + ", rollback to default color.");
		return;
	}
	
	var oclr = {};
	if(file_exists(pathO)) {
		var f = file_text_open_read(pathO);
		var s = file_text_read_all(f);
		file_text_close(f);
		
		oclr = json_parse(s);
	}
	
	var f = file_text_open_read(path);
	var s = file_text_read_all(f);
	file_text_close(f);
	
	var clrs = json_parse(s);
	
	var defkeys = variable_struct_get_names(clrs.define);
	COLOR_KEYS = defkeys;
	array_sort(COLOR_KEYS, true);
	
	var clrkeys = variable_struct_get_names(clrs.colors);
	
	for( var i = 0; i < array_length(clrkeys); i++ ) {
		var key = clrkeys[i];
		var str = variable_struct_get(clrs.colors, key);
		
		var c = color_from_rgb(str);
		variable_struct_set(CDEF, key, c);
	}
	
	for( var i = 0; i < array_length(defkeys); i++ ) {
		var key = defkeys[i];
		var c = c_white;
		
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
	
	var arrkeys = variable_struct_get_names(clrs.array);
	for( var i = 0; i < array_length(arrkeys); i++ ) {
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
}
#define lua_buffer_write
/// (buf, value)~
var b/*:Buffer*/ = argument0, v = argument1;
// GMS >= 2.3:
if (is_numeric(v)) {
	if (is_real(v)) {
		buffer_write(b, buffer_u8, lua_btype_real);
		buffer_write(b, buffer_f64, v);
	} else if (is_bool(v)) {
		// http://bugs.yoyogames.com/view.php?id=26211
		buffer_write(b, buffer_u8, lua_btype_bool);
		buffer_write(b, buffer_bool, v);
	} else {
		buffer_write(b, buffer_u8, lua_btype_int64);
		buffer_write(b, buffer_u64, v);
	}
}
/*/
if (is_real(v)) {
	buffer_write(b, buffer_u8, lua_btype_real);
	buffer_write(b, buffer_f64, v);
} else if (is_bool(v)) {
	// http://bugs.yoyogames.com/view.php?id=26211
	buffer_write(b, buffer_u8, lua_btype_bool);
	buffer_write(b, buffer_bool, v);
} else if (is_int64(v) || is_int32(v)) {
	buffer_write(b, buffer_u8, lua_btype_int64);
	buffer_write(b, buffer_u64, v);
}
//*/
else if (is_string(v)) {
	buffer_write(b, buffer_u8, lua_btype_string);
	buffer_write(b, buffer_string, v);
} else if (is_array(v)) {
	/* GMS < 2.3:
	if (array_height_2d(v) >= 2) { // [[v1, v2], [k1, k2]]
		var n = array_length_2d(v, 0);
		buffer_write(b, buffer_u8, lua_btype_struct);
		buffer_write(b, buffer_u32, n);
		for (var i = 0; i < n; i++) {
			var k = v[1, i];
			if (!is_string(k)) k = string(k);
			buffer_write(b, buffer_string, k);
			lua_buffer_write(b, v[0, i]);
		}
	} else
	//*/
	{
		var n = array_length_1d(v);
		if (n == 2 && v[0] == global.g_lua_script_marker) {
			buffer_write(b, buffer_u8, lua_btype_script);
			buffer_write(b, buffer_s32, v[1]);
			exit;
		}
		if (n == 4 && v[0] == global.g_lua_ref_marker) { // byref!
			buffer_write(b, buffer_u8, lua_btype_ref);
			var _val = v[1];
			var i = global.g_lua_ref_index[?_val];
			if (i == undefined) {
				i = ++global.g_lua_ref_next;
				global.g_lua_ref_index[?_val] = i;
				global.g_lua_ref_value[?i] = _val;
				global.g_lua_ref_count[?i] = 1;
			} else global.g_lua_ref_count[?i]++;
			buffer_write(b, buffer_u64, i);
			buffer_write(b, buffer_u8, v[2]);
			buffer_write(b, buffer_bool, v[3]);
			exit;
		}
		buffer_write(b, buffer_u8, lua_btype_array);
		buffer_write(b, buffer_u32, n);
		for (var i = 0; i < n; i++) {
			lua_buffer_write(b, v[i]);
		}
	}
}
// GMS >= 2.3:
else if (is_method(v)) {
	buffer_write(b, buffer_u8, lua_btype_method);
	var i = ++global.g_lua_method_next;
	global.g_lua_method_map[?i] = v;
	buffer_write(b, buffer_u64, i);
	buffer_write(b, buffer_string, "gml_method: " + script_get_name(method_get_index(v)));
}
else if (is_struct(v)) {
	var _keys = variable_struct_get_names(v);
	var n = array_length(_keys);
	buffer_write(b, buffer_u8, lua_btype_struct);
	buffer_write(b, buffer_u32, n);
	for (var i = 0; i < n; i++) {
		var k = _keys[i];
		buffer_write(b, buffer_string, k);
		lua_buffer_write(b, variable_struct_get(v, k));
	}
}
//*/
else buffer_write(b, buffer_u8, lua_btype_nil);

#define lua_buffer_read
/// (buf)~
var b/*:Buffer*/ = argument0;
switch (buffer_read(b, buffer_u8)) {
	case lua_btype_bool: return buffer_read(b, buffer_bool) != 0;
	case lua_btype_int32: case lua_btype_script:
		return buffer_read(b, buffer_s32);
	case lua_btype_int64: return buffer_read(b, buffer_u64);
	case lua_btype_real: return buffer_read(b, buffer_f64);
	case lua_btype_string: return buffer_read(b, buffer_string);
	case lua_btype_array:
		var n = buffer_read(b, buffer_u32);
		var a = array_create(n);
		for (var i = 0; i < n; i++) {
			a[i] = lua_buffer_read(b);
		}
		return a;
	case lua_btype_struct:
		var n = buffer_read(b, buffer_u32);
		// GMS >= 2.3:
		var q = {};
		for (var i = 0; i < n; i++) {
			var k = buffer_read(b, buffer_string);
			variable_struct_set(q, k, lua_buffer_read(b));
		}
		return q;
		/*/
		var q = array_create(0);
		q[2, 0] = undefined;
		if (n > 0) {
			q[1, n - 1] = 0;
			q[0, n - 1] = 0;
			for (var i = 0; i < n; i++) {
				q[1, i] = buffer_read(b, buffer_string);
				q[0, i] = lua_buffer_read(b);
			}
		}
		return q;
		//*/
	case lua_btype_method: return global.g_lua_method_map[?buffer_read(b, buffer_u64)];
	case lua_btype_ref: return global.g_lua_ref_value[?buffer_read(b, buffer_u64)];
	default: return undefined;
}
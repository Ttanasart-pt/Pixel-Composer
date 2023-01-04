#define lua_byref
/// (value, recursive = false)->marked_value
var _val = argument[0];
var _rec = argument_count > 1 ? argument[1] : false;
var _kind;
if (is_array(_val)) _kind = 0;
// GMS >= 2.3:
else if (is_struct(_val) && !is_method(_val)) _kind = 1;
//*/
else return _val;

return [global.g_lua_ref_marker, _val, _kind, _rec];

#define lua_script
/// (script_id)->marked_script
return [global.g_lua_script_marker, argument0];

#define lua_internal_array_get
var _uid = argument0, _index = argument1, _rec = argument2;
if !(
	// GMS >= 2.3:
	is_numeric(_index)
	/*/
	is_real(_index) || is_int64(_index)
	//*/
) {
	lua_show_error("Index must be numeric, got " + typeof(_index));
	return undefined;
}
var _arr = global.g_lua_ref_value[?_uid];
if (--_index >= 0 && _index < array_length_1d(_arr)) {
	var _val = _arr[_index];
	if (_rec) return lua_byref(_val, true); else return _val;
} else return undefined;

#define lua_internal_array_set
var _uid = argument0, _index = argument1, _val = argument2;
if !(
	// GMS >= 2.3:
	is_numeric(_index)
	/*/
	is_real(_index) || is_int64(_index)
	//*/
) {
	lua_show_error("Index must be numeric, got " + typeof(_index));
	return undefined;
}
var _arr = global.g_lua_ref_value[?_uid];
if (--_index >= 0) {
	_arr[@_index] = _val;
	return true;
} else lua_show_error("Index (" + string(_index + 1) + ") is out of bounds.");

#define lua_internal_array_len
return array_length_1d(global.g_lua_ref_value[?argument0]);

#define lua_internal_struct_get
// GMS >= 2.3:
var _uid = argument0, _key = argument1, _rec = argument2;
var _obj = global.g_lua_ref_value[?_uid];
if (_rec) {
	return lua_byref(variable_struct_get(_obj, _key), true);
} else return variable_struct_get(_obj, _key);
//*/

#define lua_internal_struct_set
// GMS >= 2.3:
var _uid = argument0, _key = argument1, _val = argument2;
var _obj = global.g_lua_ref_value[?_uid];
variable_struct_set(_obj, _key, _val);
//*/

#define lua_internal_struct_len
// GMS >= 2.3:
return variable_struct_names_count(global.g_lua_ref_value[?argument0]);
//*/

#define lua_internal_struct_keys
// GMS >= 2.3:
return variable_struct_get_names(global.g_lua_ref_value[?argument0]);
//*/
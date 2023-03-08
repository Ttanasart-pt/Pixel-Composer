#define lua_init
//#import "global"
/// ()~
//#global lua_buffer~
//#global lua_true
//#global lua_false
//#global lua_current
//#global lua_error_handler
//#global lua_call_result
// GMS >= 2.3:
global.g_lua_method_map = ds_map_create();
global.g_lua_method_next = 0;
//*/
var b/*:Buffer*/ = buffer_create(1024*64, buffer_grow, 1);
buffer_write(b, buffer_s32, asset_get_index("lua_internal_array_get"));
buffer_write(b, buffer_s32, asset_get_index("lua_internal_array_set"));
buffer_write(b, buffer_s32, asset_get_index("lua_internal_array_len"));
buffer_write(b, buffer_s32, asset_get_index("lua_internal_struct_get"));
buffer_write(b, buffer_s32, asset_get_index("lua_internal_struct_set"));
buffer_write(b, buffer_s32, asset_get_index("lua_internal_struct_len"));
buffer_write(b, buffer_s32, asset_get_index("lua_internal_struct_keys"));
if (!lua_init_raw(buffer_get_address(b))) {
	show_debug_message("Apollo extension couldn't load!");
}
lua_buffer = b;
lua_current = -1;
global.lua_script_args = array_create(0);
lua_error_handler = -1;
var z = 1;
lua_true = z == 1;
lua_false = z != 1;
lua_call_result = undefined;
//
global.g_lua_type_names = array_create(lua_type_unknown + 1);
global.g_lua_type_names[lua_type_none] = "no value";
global.g_lua_type_names[lua_type_nil] = "nil";
global.g_lua_type_names[lua_type_bool] = "boolean";
global.g_lua_type_names[lua_type_number] = "number";
global.g_lua_type_names[lua_type_string] = "string";
global.g_lua_type_names[lua_type_table] = "table";
global.g_lua_type_names[lua_type_function] = "function";
global.g_lua_type_names[lua_type_thread] = "thread";
global.g_lua_type_names[lua_type_userdata] = "userdata";
global.g_lua_type_names[lua_type_lightuserdata] = "userdata";
global.g_lua_type_names[lua_type_unknown] = "unknown";
//
global.g_lua_error_no_state = "Attempting to use a non-existent Lua state!";
global.g_lua_error_no_func = "Attempting to call a non-existent Lua function!";
//
global.g_lua_script_execute = 0;
for (var i = 0; i < 512; i++) {
	var q = asset_get_index("lua_script_execute_" + string(i));
	if (q < 0) break;
	global.g_lua_script_execute[i] = q;
}
global.g_lua_script_execute_max = array_length_1d(global.g_lua_script_execute);
//
global.g_lua_ref_value = ds_map_create(); // index -> value
global.g_lua_ref_index = ds_map_create(); // value -> index
global.g_lua_ref_count = ds_map_create(); // index -> refcount
global.g_lua_ref_next = 0;
global.g_lua_ref_marker = [];
global.g_lua_script_marker = [];

#define lua_update
var b = lua_buffer;
var _ptr = buffer_get_address(b);
var _size = buffer_get_size(b);
var _max = (_size div 8);
var n;
// GMS >= 2.3:
do {
	n = lua_update_method_gc(_ptr, _max);
	buffer_seek(b, buffer_seek_start, 0);
	for (var i = 0; i < n; i++) {
		ds_map_delete(global.g_lua_method_map, buffer_read(b, buffer_u64));
	}
} until (n == 0);
//*/
do {
	n = lua_update_ref_gc(_ptr, _max);
	buffer_seek(b, buffer_seek_start, 0);
	for (var i = 0; i < n; i++) {
		var u = buffer_read(b, buffer_u64);
		if (--global.g_lua_ref_count[?u] <= 0) {
			var v = global.g_lua_ref_value[?u];
			ds_map_delete(global.g_lua_ref_value, u);
			ds_map_delete(global.g_lua_ref_index, v);
			ds_map_delete(global.g_lua_ref_count, u);
		}
	}
} until (n == 0);

#define lua_bool
/// (value)
return bool(argument0);

#define lua_print_value
/// (value)->string : Prints a value as expression (e.g. for errors)
var v = argument0;
if (is_string(v)) {
	if (string_pos(chr(34), v)) {
		if (string_pos("'", v)) {
			return "`" + v + "`";
		} else return "'" + v + "'";
	} else return chr(34) + v + chr(34);
} else if (is_undefined(v)) {
	return "nil";
} else return string(v);

#define lua_state_exec
/// (state, status)~
var q = argument0, status = argument1;
if (status == lua_status_done) exit;
//
var _lua_current = lua_current;
lua_current = q;
//
var b/*:Buffer*/ = lua_buffer;
var loop = true;
while (loop) {
	switch (status) {
		case lua_status_call:
			buffer_seek(b, buffer_seek_start, 0);
			var script_id = buffer_read(b, buffer_s32);
			//
			var argc = buffer_read(b, buffer_s32);
			var args = global.lua_script_args;
			for (var i = 0; i < argc; i++) args[@i] = lua_buffer_read(b);
			//
			buffer_seek(b, buffer_seek_start, 0);
			var ret = lua_script_execute(script_id, args, argc);
			if (buffer_tell(b) == 0) {
				buffer_write(b, buffer_s32, 1);
				lua_buffer_write(b, ret);
			}
			status = lua_state_exec_raw(buffer_get_address(b));
			continue;
		// GMS >= 2.3:
		case lua_status_callmethod:
			buffer_seek(b, buffer_seek_start, 0);
			var ref = global.g_lua_method_map[?buffer_read(b, buffer_u64)];
			var argc = buffer_read(b, buffer_s32);
			var args = global.lua_script_args;
			for (var i = 0; i < argc; i++) args[@i] = lua_buffer_read(b);
			//
			buffer_seek(b, buffer_seek_start, 0);
			var _self = method_get_self(ref);
			var ret = undefined; with (method_get_self(ref)) {
				ret = script_execute_ext(method_get_index(ref), args, 0, argc)
			}
			if (buffer_tell(b) == 0) {
				buffer_write(b, buffer_s32, 1);
				lua_buffer_write(b, ret);
			}
			status = lua_state_exec_raw(buffer_get_address(b));
			continue;
		//*/
		case lua_status_error:
			buffer_seek(b, buffer_seek_start, 0);
			var error_text = buffer_read(b, buffer_string);
			if (lua_error_handler >= 0) {
				script_execute(lua_error_handler, lua_current, error_text);
			} else show_debug_message("Lua error: " + error_text);
			break;
		case lua_status_no_state: show_error(global.g_lua_error_no_state, 1); break;
		case lua_status_no_func: show_error(global.g_lua_error_no_func, 1); break;
		default: loop = false; break;
	}; break;
}
lua_current = _lua_current;
return status;

#define lua_add_code
/// (state_id, code)
var q = argument0, s = argument1;
var b/*:Buffer*/ = lua_buffer;
buffer_poke(b, 0, buffer_s32, 0);
lua_state_exec(q, lua_add_code_raw(q, s, buffer_get_address(b)));

#define lua_add_file
/// (state_id, path, chdir = true)
var q = argument[0], s = argument[1];
var chdir = argument_count > 2 ? argument[2] : true;
if !(string_ord_at(s, 1) == ord("/")
	|| string_ord_at(s, 2) == ord(":")
	|| string_copy(s, 1, 2) == (chr(92) + chr(92))
) for (var iter = 0; iter < 3; iter++) {
	var dir;
	switch (iter) {
		case 0: dir = game_save_id; break;
		case 1: dir = working_directory; break;
		default: dir = "";
	}
	switch (string_ord_at(dir, string_length(dir))) {
		case ord("/"): case 92/* \ */: break;
		default: if (os_type == os_windows) dir += chr(92); else dir += "/";
	}
	var fp = dir + s;
	if (file_exists(fp)) {
		if (chdir) {
			var _dir = lua_get_cwd();
			lua_set_cwd(dir);
			//
			var b/*:Buffer*/ = lua_buffer;
			buffer_poke(b, 0, buffer_s32, 0);
			lua_state_exec(q, lua_add_file_raw(q, s, buffer_get_address(b)));
			// if the path is what we've set it to, set it back to what it was
			if (lua_get_cwd() == dir) lua_set_cwd(_dir);
			exit;
		} else s = fp;
		break;
	}
}
var b/*:Buffer*/ = lua_buffer;
buffer_poke(b, 0, buffer_s32, 0);
lua_state_exec(q, lua_add_file_raw(q, s, buffer_get_address(b)));

#define lua_add_function
/// (state_id, func_name, script_id)
var q = argument0, s = argument1, i = argument2;
// GMS >= 2.3:
if (is_method(i)) {
	var b/*:Buffer*/ = lua_buffer;
	buffer_seek(b, buffer_seek_start, 0);
	lua_buffer_write(b, i);
	if (lua_global_set_raw(argument0, argument1, buffer_get_address(b))) {
		// ok!
	} else show_error(global.g_lua_error_no_state, 1);
} else //*/
lua_state_exec(q, lua_add_function_raw(q, s, i));

#define lua_global_get
/// (state_id, name)->value
var b/*:Buffer*/ = lua_buffer;
if (lua_global_get_raw(argument0, argument1, buffer_get_address(b))) {
	buffer_seek(b, buffer_seek_start, 0);
	return lua_buffer_read(b);
} else show_error(global.g_lua_error_no_state, 1);

#define lua_global_set
/// (state_id, name, value)
var b/*:Buffer*/ = lua_buffer;
buffer_seek(b, buffer_seek_start, 0);
lua_buffer_write(b, argument2);
if (lua_global_set_raw(argument0, argument1, buffer_get_address(b))) {
	// ok!
} else show_error(global.g_lua_error_no_state, 1);

#define lua_global_typeof
/// (state_id, name)->type_name
var t = lua_global_type_raw(argument0, argument1);
if (t < 0) {
	show_error(global.g_lua_error_no_state, 1);
	return global.g_lua_type_names[lua_type_unknown];
} else return global.g_lua_type_names[t];

#define lua_global_type
/// (state_id, name)->lua_type
var t = lua_global_type_raw(argument0, argument1);
if (t < 0) {
	show_error(global.g_lua_error_no_state, 1);
	return lua_type_unknown;
} else return t;
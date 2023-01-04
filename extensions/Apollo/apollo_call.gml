#define lua_call
/// (state_id, func_name, ...args)->result
var q = argument[0];
var b/*:Buffer*/ = lua_buffer;
var n = argument_count, r;
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n - 2);
for (var i = 2; i < n; i++) lua_buffer_write(b, argument[i]);
lua_state_exec(q, lua_call_raw(q, argument[1], buffer_get_address(b)));
buffer_seek(b, buffer_seek_start, 0);
if (buffer_read(b, buffer_s32) > 0) r = lua_buffer_read(b); else r = undefined;
return r;

#define lua_call_w
/// (state_id, func_name, args_array)->result
var q = argument0, s = argument1, w = argument2;
var b/*:Buffer*/ = lua_buffer;
var r, n = array_length_1d(w);
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n);
for (var i = 0; i < n; i++) lua_buffer_write(b, w[i]);
lua_state_exec(q, lua_call_raw(q, s, buffer_get_address(b)));
buffer_seek(b, buffer_seek_start, 0);
if (buffer_read(b, buffer_s32) > 0) r = lua_buffer_read(b); else r = undefined;
return r;

#define lua_call_m
/// (state_id, func_name, ...args)->results_array
var q = argument[0];
var b/*:Buffer*/ = lua_buffer;
var n = argument_count, r, i;
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n - 2);
for (i = 2; i < n; i++) lua_buffer_write(b, argument[i]);
lua_state_exec(q, lua_call_raw(q, argument[1], buffer_get_address(b)));
buffer_seek(b, buffer_seek_start, 0);
n = buffer_read(b, buffer_s32);
r = array_create(n);
for (i = 0; i < n; i++) r[i] = lua_buffer_read(b);
return r;

#define lua_call_xm
/// (state_id, func_name, results_array, ...args)->results_count
var q = argument[0], s = argument[1], r = argument[2];
var b/*:Buffer*/ = lua_buffer;
var n = argument_count, i;
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n - 3);
for (i = 3; i < n; i++) lua_buffer_write(b, argument[i]);
lua_state_exec(q, lua_call_raw(q, s, buffer_get_address(b)));
buffer_seek(b, buffer_seek_start, 0);
n = buffer_read(b, buffer_s32);
for (i = 0; i < n; i++) r[@i] = lua_buffer_read(b);
return n;

#define lua_call_wm
/// (state_id, func_name, args_array)->results_array
var q = argument0, s = argument1, w = argument2;
var i, n = array_length_1d(w);
var b/*:Buffer*/ = lua_buffer;
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n);
for (i = 0; i < n; i++) lua_buffer_write(b, w[i]);
lua_state_exec(q, lua_call_raw(q, s, buffer_get_address(b)));
buffer_seek(b, buffer_seek_start, 0);
n = buffer_read(b, buffer_s32);
var r = array_create(n);
for (i = 0; i < n; i++) r[i] = lua_buffer_read(b);
return r;

#define lua_call_wxm
/// (state_id, func_name, args_array, results_array)->result_count
var q = argument0, s = argument1, w = argument2, r = argument3;
var b/*:Buffer*/ = lua_buffer;
var i, n = array_length_1d(w);
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n);
for (i = 0; i < n; i++) lua_buffer_write(b, w[i]);
lua_state_exec(q, lua_call_raw(q, s, buffer_get_address(b)));
buffer_seek(b, buffer_seek_start, 0);
n = buffer_read(b, buffer_s32);
for (i = 0; i < n; i++) r[@i] = lua_buffer_read(b);
return n;

#define lua_return
/// (...values): Returns one or more values back to Lua code.
var b/*:Buffer*/ = lua_buffer;
buffer_seek(b, buffer_seek_start, 0);
var n = argument_count;
buffer_write(b, buffer_s32, n);
for (var i = 0; i < n; i++) lua_buffer_write(b, argument[i]);
if (n > 0) return argument[0]; else return undefined;

#define lua_return_w
/// (values:array)->values[0] : Returns the contents of an array as a multi-value return.
var b/*:Buffer*/ = lua_buffer;
var w = argument0;
buffer_seek(b, buffer_seek_start, 0);
var n = array_length_1d(w);
buffer_write(b, buffer_s32, n);
for (var i = 0; i < n; i++) lua_buffer_write(b, w[i]);
if (n > 0) return w[0]; else return undefined;

#define lua_return_add
/// (...values)->values[0] : Adds one or more values to the list of returned values.
var b/*:Buffer*/ = lua_buffer, r;
var n = argument_count;
if (buffer_tell(b) != 0) {
	buffer_poke(b, 0, buffer_s32, buffer_peek(b, 0, buffer_s32) + n);
} else buffer_write(b, buffer_s32, n);
for (var i = 0; i < n; i++) lua_buffer_write(b, argument[i]);
if (n > 0) return argument[0]; else return undefined;

#define lua_call_start
/// (state_id, func, ...args)->ok?
var b/*:Buffer*/ = lua_buffer;
var n = argument_count, r;
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n - 2);
for (var i = 2; i < n; i++) lua_buffer_write(b, argument[i]);
//
switch (lua_call_start_raw(argument[0], argument[1], buffer_get_address(b))) {
	case lua_status_no_state: show_error(global.g_lua_error_no_state, 1); break;
	case lua_status_no_func: show_error(global.g_lua_error_no_func, 1); break;
	default: return true;
}
return false;

#define lua_call_next
/// (state_id, ...values)->continue?
var b/*:Buffer*/ = lua_buffer;
var n = argument_count;
buffer_seek(b, buffer_seek_start, 0);
buffer_write(b, buffer_s32, n - 1);
for (var i = 1; i < n; i++) lua_buffer_write(b, argument[i]);
var status = lua_state_exec(argument[0], lua_call_next_raw(argument[0], buffer_get_address(b)));
buffer_seek(b, buffer_seek_start, 0);
if (buffer_read(b, buffer_s32) > 0) {
	lua_call_result = lua_buffer_read(b);
} else lua_call_result = undefined;
return status == lua_status_yield;

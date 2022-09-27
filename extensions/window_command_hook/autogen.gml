#define window_command_hook
/// window_command_hook(command:int)->bool
var _buf = window_command_hook_prepare_buffer(12);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_s32, argument0);
return window_command_hook_raw(buffer_get_address(_buf), 12);

#define window_command_unhook
/// window_command_unhook(command:int)->bool
var _buf = window_command_hook_prepare_buffer(12);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_s32, argument0);
return window_command_unhook_raw(buffer_get_address(_buf), 12);

#define window_command_check
/// window_command_check(command:int)->bool
var _buf = window_command_hook_prepare_buffer(4);
buffer_write(_buf, buffer_s32, argument0);
return window_command_check_raw(buffer_get_address(_buf), 4);

#define window_command_run
/// window_command_run(wParam:int, lParam:int = 0)->int
var _buf = window_command_hook_prepare_buffer(17);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_s32, argument[0]);
if (argument_count >= 2) {
	buffer_write(_buf, buffer_bool, true);
	buffer_write(_buf, buffer_s32, argument[1]);
} else buffer_write(_buf, buffer_bool, false);
return window_command_run_raw(buffer_get_address(_buf), 17);

#define window_command_get_active
/// window_command_get_active(command:int)->int
var _buf = window_command_hook_prepare_buffer(12);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_s32, argument0);
return window_command_get_active_raw(buffer_get_address(_buf), 12);

#define window_command_set_active
/// window_command_set_active(command:int, value:bool)->int
var _buf = window_command_hook_prepare_buffer(13);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_s32, argument0);
buffer_write(_buf, buffer_bool, argument1);
return window_command_set_active_raw(buffer_get_address(_buf), 13);

#define window_get_background_redraw
/// window_get_background_redraw()->bool
var _buf = window_command_hook_prepare_buffer(1);
return window_get_background_redraw_raw(buffer_get_address(_buf), 1);

#define window_set_background_redraw
/// window_set_background_redraw(enable:bool)->bool
var _buf = window_command_hook_prepare_buffer(9);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_bool, argument0);
return window_set_background_redraw_raw(buffer_get_address(_buf), 9);

#define window_get_topmost
/// window_get_topmost()->bool
var _buf = window_command_hook_prepare_buffer(8);
buffer_write(_buf, buffer_u64, int64(window_handle()));
return window_get_topmost_raw(buffer_get_address(_buf), 8);

#define window_set_topmost
/// window_set_topmost(enable:bool)->bool
var _buf = window_command_hook_prepare_buffer(9);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_bool, argument0);
return window_set_topmost_raw(buffer_get_address(_buf), 9);

#define window_get_taskbar_button_visible
/// window_get_taskbar_button_visible()->bool
var _buf = window_command_hook_prepare_buffer(8);
buffer_write(_buf, buffer_u64, int64(window_handle()));
return window_get_taskbar_button_visible_raw(buffer_get_address(_buf), 8);

#define window_set_taskbar_button_visible
/// window_set_taskbar_button_visible(show_button:bool)->bool
var _buf = window_command_hook_prepare_buffer(9);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_bool, argument0);
return window_set_taskbar_button_visible_raw(buffer_get_address(_buf), 9);

#define window_set_visible_w
/// window_set_visible_w(visible:bool)->bool
var _buf = window_command_hook_prepare_buffer(9);
buffer_write(_buf, buffer_u64, int64(window_handle()));
buffer_write(_buf, buffer_bool, argument0);
return window_set_visible_w_raw(buffer_get_address(_buf), 9);


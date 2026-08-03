#define winwin_init_2
/// winwin_init_2()-> ~
var _buf = winwin_prepare_buffer(8);
if (winwin_init_2_raw(buffer_get_address(_buf), 8)) {
	var _ptr = buffer_read(_buf, buffer_u64);
	var _box;
	if (_ptr != 0) {
	    _ptr = ptr(_ptr);
	    _box = new winwin(_ptr);
	    winwin_map[?_ptr] = _box;
	    ds_list_add(winwin_list, _box);
	} else _box = undefined;
	return _box;
} else return undefined;

#define winwin_create
/// winwin_create(x:int, y:int, width:int, height:int, config)->
var _buf = winwin_prepare_buffer(39);
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
var _struct_0 = argument4;
buffer_write(_buf, buffer_string, _struct_0.caption);
buffer_write(_buf, buffer_s32, _struct_0.kind);
buffer_write(_buf, buffer_bool, _struct_0.resize);
buffer_write(_buf, buffer_bool, _struct_0.show);
buffer_write(_buf, buffer_bool, _struct_0.topmost);
buffer_write(_buf, buffer_bool, _struct_0.taskbar_button);
buffer_write(_buf, buffer_bool, _struct_0.clickthrough);
buffer_write(_buf, buffer_bool, _struct_0.noactivate);
buffer_write(_buf, buffer_bool, _struct_0.per_pixel_alpha);
buffer_write(_buf, buffer_bool, _struct_0.thread);
buffer_write(_buf, buffer_s8, _struct_0.vsync);
buffer_write(_buf, buffer_s8, _struct_0.close_button);
var _val_2 = _struct_0.owner;
var _flag_2 = _val_2 != undefined;
buffer_write(_buf, buffer_bool, _flag_2);
if (_flag_2) {
	if (instanceof(_val_2) != "winwin") { show_error("Expected a winwin, got " + string(_val_2), true); exit }
	if (_val_2.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, int64(_val_2.__ptr__));
}
if (winwin_create_raw(buffer_get_address(_buf), 39, argument0, argument1)) {
	buffer_seek(_buf, buffer_seek_start, 0);
	var _ptr = buffer_read(_buf, buffer_u64);
	var _box;
	if (_ptr != 0) {
	    _ptr = ptr(_ptr);
	    _box = new winwin(_ptr);
	    winwin_map[?_ptr] = _box;
	    ds_list_add(winwin_list, _box);
	} else _box = undefined;
	return _box;
} else return undefined;

#define winwin_destroy
/// winwin_destroy(ww)
var _buf = winwin_prepare_buffer(8);
var _box_0 = argument0;
if (instanceof(_box_0) != "winwin") { show_error("Expected a winwin, got " + string(_box_0), true); exit }
var _ptr_0 = _box_0.__ptr__;
if (_ptr_0 == pointer_null) { show_error("This winwin is already destroyed.", true); exit; }
_box_0.__ptr__ = pointer_null;
ds_map_delete(winwin_map, _ptr_0);
var _ind = ds_list_find_index(winwin_list, _box_0);
if (_ind >= 0) ds_list_delete(winwin_list, _ind);
buffer_write(_buf, buffer_u64, int64(_ptr_0));
winwin_destroy_raw(buffer_get_address(_buf), 8)

#define winwin_get_topmost
/// winwin_get_topmost(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_topmost_raw(argument0.__ptr__);

#define winwin_set_topmost
/// winwin_set_topmost(ww, enable:bool)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_topmost_raw(argument0.__ptr__, argument1);

#define winwin_order_after
/// winwin_order_after(ww, ref)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (instanceof(argument1) != "winwin") { show_error("Expected a winwin, got " + string(argument1), true); exit }
if (argument1.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_order_after_raw(argument0.__ptr__, argument1.__ptr__);

#define winwin_order_front
/// winwin_order_front(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_order_front_raw(argument0.__ptr__);

#define winwin_order_back
/// winwin_order_back(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_order_back_raw(argument0.__ptr__);

#define winwin_get_taskbar_button_visible
/// winwin_get_taskbar_button_visible(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_taskbar_button_visible_raw(argument0.__ptr__);

#define winwin_set_taskbar_button_visible
/// winwin_set_taskbar_button_visible(ww, show_button:bool)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_taskbar_button_visible_raw(argument0.__ptr__, argument1);

#define winwin_get_clickthrough
/// winwin_get_clickthrough(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_clickthrough_raw(argument0.__ptr__);

#define winwin_set_clickthrough
/// winwin_set_clickthrough(ww, enable_clickthrough:bool)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_clickthrough_raw(argument0.__ptr__, argument1);

#define winwin_get_noactivate
/// winwin_get_noactivate(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_noactivate_raw(argument0.__ptr__);

#define winwin_set_noactivate
/// winwin_set_noactivate(ww, disable_activation:bool)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_noactivate_raw(argument0.__ptr__, argument1);

#define winwin_get_visible
/// winwin_get_visible(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_visible_raw(argument0.__ptr__);

#define winwin_set_visible
/// winwin_set_visible(ww, visible:bool)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_visible_raw(argument0.__ptr__, argument1);

#define winwin_get_cursor
/// winwin_get_cursor(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_cursor_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_set_cursor
/// winwin_set_cursor(ww, cursor:int)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_cursor_raw(argument0.__ptr__, argument1);

#define winwin_get_cursor_handle
/// winwin_get_cursor_handle(ww)->int
var _buf = winwin_prepare_buffer(8);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_cursor_handle_raw(buffer_get_address(_buf), 8, argument0.__ptr__)) {
	return ptr(buffer_read(_buf, buffer_u64));
} else return undefined;

#define winwin_set_cursor_handle
/// winwin_set_cursor_handle(ww, hcursor:int)->bool
var _buf = winwin_prepare_buffer(8);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
buffer_write(_buf, buffer_u64, argument1);
return winwin_set_cursor_handle_raw(buffer_get_address(_buf), 8, argument0.__ptr__);

#define winwin_resize_buffer
/// winwin_resize_buffer(ww, width:int, height:int)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_resize_buffer_raw(argument0.__ptr__, argument1, argument2);

#define winwin_draw_begin_raw
/// winwin_draw_begin_raw(ww)->bool ~
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_draw_begin_raw_raw(argument0.__ptr__);

#define winwin_has_focus
/// winwin_has_focus(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_has_focus_raw(argument0.__ptr__);

#define winwin_get_focus
/// winwin_get_focus()->
var _buf = winwin_prepare_buffer(8);
if (winwin_get_focus_raw(buffer_get_address(_buf), 8)) {
	var _ptr = buffer_read(_buf, buffer_u64);
	var _box;
	if (_ptr != 0) {
	    _ptr = ptr(_ptr);
	    _box = global.__winwin_map[?_ptr];
	    if (_box == undefined) {
	        _box = new winwin(_ptr);
	        winwin_map[?_ptr] = _box;
	        ds_list_add(winwin_list, _box);
	    }
	} else _box = undefined;
	return _box;
} else return undefined;

#define winwin_set_focus
/// winwin_set_focus(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_focus_raw(argument0.__ptr__);

#define winwin_keyboard_check
/// winwin_keyboard_check(ww, key:int)->bool
if (argument0 == winwin_main) return keyboard_check(argument1);
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_keyboard_check_raw(argument0.__ptr__, argument1);

#define winwin_keyboard_check_pressed
/// winwin_keyboard_check_pressed(ww, key:int)->bool
if (argument0 == winwin_main) return keyboard_check_pressed(argument1);
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_keyboard_check_pressed_raw(argument0.__ptr__, argument1);

#define winwin_keyboard_check_released
/// winwin_keyboard_check_released(ww, key:int)->bool
if (argument0 == winwin_main) return keyboard_check_released(argument1);
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_keyboard_check_released_raw(argument0.__ptr__, argument1);

#define winwin_keyboard_get_string
/// winwin_keyboard_get_string(ww)->string
if (argument0 == winwin_main) return keyboard_string;
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_keyboard_get_string_raw(argument0.__ptr__);

#define winwin_keyboard_set_string_raw
/// winwin_keyboard_set_string_raw(ww, buf:buffer)->int ~
var _buf = winwin_prepare_buffer(16);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
var _val_0 = argument1;
if (buffer_exists(_val_0)) {
	buffer_write(_buf, buffer_u64, int64(buffer_get_address(_val_0)));
	buffer_write(_buf, buffer_s32, buffer_get_size(_val_0));
	buffer_write(_buf, buffer_s32, buffer_tell(_val_0));
} else {
	buffer_write(_buf, buffer_u64, 0);
	buffer_write(_buf, buffer_s32, 0);
	buffer_write(_buf, buffer_s32, 0);
}
return winwin_keyboard_set_string_raw_raw(buffer_get_address(_buf), 16, argument0.__ptr__);

#define winwin_keyboard_get_max_string_length
/// winwin_keyboard_get_max_string_length(ww)->int
if (argument0 == winwin_main) return 1024;
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_keyboard_get_max_string_length_raw(argument0.__ptr__);

#define winwin_keyboard_set_max_string_length
/// winwin_keyboard_set_max_string_length(ww, new_capacity:int)->int
if (argument0 == winwin_main) return false;
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_keyboard_set_max_string_length_raw(argument0.__ptr__, argument1);

#define winwin_mouse_is_over
/// winwin_mouse_is_over(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_is_over_raw(argument0.__ptr__);

#define winwin_mouse_get_x
/// winwin_mouse_get_x(ww)->int
if (argument0 == winwin_main) return window_mouse_get_x();
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_get_x_raw(argument0.__ptr__);

#define winwin_mouse_get_y
/// winwin_mouse_get_y(ww)->int
if (argument0 == winwin_main) return window_mouse_get_y();
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_get_y_raw(argument0.__ptr__);

#define winwin_mouse_check_button
/// winwin_mouse_check_button(ww, button:int)->bool
if (argument0 == winwin_main) return mouse_check_button(argument1);
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_check_button_raw(argument0.__ptr__, argument1);

#define winwin_mouse_check_button_pressed
/// winwin_mouse_check_button_pressed(ww, button:int)->bool
if (argument0 == winwin_main) return mouse_check_button_pressed(argument1);
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_check_button_pressed_raw(argument0.__ptr__, argument1);

#define winwin_mouse_check_button_released
/// winwin_mouse_check_button_released(ww, button:int)->bool
if (argument0 == winwin_main) return mouse_check_button_released(argument1);
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_check_button_released_raw(argument0.__ptr__, argument1);

#define winwin_mouse_wheel_up
/// winwin_mouse_wheel_up(ww)->bool
if (argument0 == winwin_main) return mouse_wheel_up();
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_wheel_up_raw(argument0.__ptr__);

#define winwin_mouse_wheel_down
/// winwin_mouse_wheel_down(ww)->bool
if (argument0 == winwin_main) return mouse_wheel_down();
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_wheel_down_raw(argument0.__ptr__);

#define winwin_mouse_wheel_get_delta_x
/// winwin_mouse_wheel_get_delta_x(ww)->int
if (argument0 == winwin_main) return 0;
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_wheel_get_delta_x_raw(argument0.__ptr__);

#define winwin_mouse_wheel_get_delta_y
/// winwin_mouse_wheel_get_delta_y(ww)->int
if (argument0 == winwin_main) return mouse_wheel_down() - mouse_wheel_up();
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_mouse_wheel_get_delta_y_raw(argument0.__ptr__);

#define winwin_keyboard_clear
/// winwin_keyboard_clear(ww, key:int)
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
winwin_keyboard_clear_raw(argument0.__ptr__, argument1)

#define winwin_mouse_clear
/// winwin_mouse_clear(ww, button:int)
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
winwin_mouse_clear_raw(argument0.__ptr__, argument1)

#define winwin_io_clear
/// winwin_io_clear(ww)
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
winwin_io_clear_raw(argument0.__ptr__)

#define winwin_sleep
/// winwin_sleep(ms:int, process_messages:bool = true)
// no buffer!
winwin_sleep_raw(argument[0], argument[1])

#define winwin_game_end
/// winwin_game_end(exit_code:int = 0)
// no buffer!
winwin_game_end_raw(argument[0])

#define winwin_get_handle
/// winwin_get_handle(ww)->int
var _buf = winwin_prepare_buffer(8);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_handle_raw(buffer_get_address(_buf), 8, argument0.__ptr__)) {
	return ptr(buffer_read(_buf, buffer_u64));
} else return undefined;

#define winwin_get_caption
/// winwin_get_caption(ww)->string
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_caption_raw(argument0.__ptr__);

#define winwin_set_caption
/// winwin_set_caption(ww, caption:string)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_caption_raw(argument0.__ptr__, argument1);

#define winwin_get_close_button
/// winwin_get_close_button(ww)->int
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_close_button_raw(argument0.__ptr__);

#define winwin_set_close_button
/// winwin_set_close_button(ww, close_button_state:int)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_close_button_raw(argument0.__ptr__, argument1);

#define winwin_get_vsync
/// winwin_get_vsync(ww)->int
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_vsync_raw(argument0.__ptr__);

#define winwin_set_vsync
/// winwin_set_vsync(ww, sync_interval:int)
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
winwin_set_vsync_raw(argument0.__ptr__, argument1)

#define winwin_get_owner
/// winwin_get_owner(ww)->
var _buf = winwin_prepare_buffer(8);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_owner_raw(buffer_get_address(_buf), 8, argument0.__ptr__)) {
	var _ptr = buffer_read(_buf, buffer_u64);
	var _box;
	if (_ptr != 0) {
	    _ptr = ptr(_ptr);
	    _box = global.__winwin_map[?_ptr];
	    if (_box == undefined) {
	        _box = new winwin(_ptr);
	        winwin_map[?_ptr] = _box;
	        ds_list_add(winwin_list, _box);
	    }
	} else _box = undefined;
	return _box;
} else return undefined;

#define winwin_set_owner
/// winwin_set_owner(ww, owner)
var _buf = winwin_prepare_buffer(9);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
var _val_0 = argument1;
var _flag_0 = _val_0 != undefined;
buffer_write(_buf, buffer_bool, _flag_0);
if (_flag_0) {
	if (instanceof(_val_0) != "winwin") { show_error("Expected a winwin, got " + string(_val_0), true); exit }
	if (_val_0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, int64(_val_0.__ptr__));
}
winwin_set_owner_raw(buffer_get_address(_buf), 9, argument0.__ptr__)

#define winwin_get_x
/// winwin_get_x(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_x_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_get_y
/// winwin_get_y(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_y_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_get_width
/// winwin_get_width(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_width_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_get_height
/// winwin_get_height(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_height_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_set_position
/// winwin_set_position(ww, x:int, y:int)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_position_raw(argument0.__ptr__, argument1, argument2);

#define winwin_set_size
/// winwin_set_size(ww, width:int, height:int)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_size_raw(argument0.__ptr__, argument1, argument2);

#define winwin_set_rectangle
/// winwin_set_rectangle(ww, x:int, y:int, width:int, height:int)->bool
var _buf = winwin_prepare_buffer(12);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
buffer_write(_buf, buffer_s32, argument2);
buffer_write(_buf, buffer_s32, argument3);
buffer_write(_buf, buffer_s32, argument4);
return winwin_set_rectangle_raw(buffer_get_address(_buf), 12, argument0.__ptr__, argument1);

#define winwin_get_min_width
/// winwin_get_min_width(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_min_width_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_get_min_height
/// winwin_get_min_height(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_min_height_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_get_max_width
/// winwin_get_max_width(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_max_width_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_get_max_height
/// winwin_get_max_height(ww)->int?
var _buf = winwin_prepare_buffer(5);
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (winwin_get_max_height_raw(buffer_get_address(_buf), 5, argument0.__ptr__)) {
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define winwin_set_min_width
/// winwin_set_min_width(ww, ?min_width:int?)->bool
var _buf = winwin_prepare_buffer(6);
if (instanceof(argument[0]) != "winwin") { show_error("Expected a winwin, got " + string(argument[0]), true); exit }
if (argument[0].__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (argument_count >= 2) {
	buffer_write(_buf, buffer_bool, true);
	var _val_0 = argument[1];
	var _flag_0 = _val_0 != undefined;
	buffer_write(_buf, buffer_bool, _flag_0);
	if (_flag_0) {
		buffer_write(_buf, buffer_s32, _val_0);
	}
} else buffer_write(_buf, buffer_bool, false);
return winwin_set_min_width_raw(buffer_get_address(_buf), 6, argument[0].__ptr__);

#define winwin_set_min_height
/// winwin_set_min_height(ww, ?min_height:int?)->bool
var _buf = winwin_prepare_buffer(6);
if (instanceof(argument[0]) != "winwin") { show_error("Expected a winwin, got " + string(argument[0]), true); exit }
if (argument[0].__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (argument_count >= 2) {
	buffer_write(_buf, buffer_bool, true);
	var _val_0 = argument[1];
	var _flag_0 = _val_0 != undefined;
	buffer_write(_buf, buffer_bool, _flag_0);
	if (_flag_0) {
		buffer_write(_buf, buffer_s32, _val_0);
	}
} else buffer_write(_buf, buffer_bool, false);
return winwin_set_min_height_raw(buffer_get_address(_buf), 6, argument[0].__ptr__);

#define winwin_set_max_width
/// winwin_set_max_width(ww, ?max_width:int?)->bool
var _buf = winwin_prepare_buffer(6);
if (instanceof(argument[0]) != "winwin") { show_error("Expected a winwin, got " + string(argument[0]), true); exit }
if (argument[0].__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (argument_count >= 2) {
	buffer_write(_buf, buffer_bool, true);
	var _val_0 = argument[1];
	var _flag_0 = _val_0 != undefined;
	buffer_write(_buf, buffer_bool, _flag_0);
	if (_flag_0) {
		buffer_write(_buf, buffer_s32, _val_0);
	}
} else buffer_write(_buf, buffer_bool, false);
return winwin_set_max_width_raw(buffer_get_address(_buf), 6, argument[0].__ptr__);

#define winwin_set_max_height
/// winwin_set_max_height(ww, ?max_height:int?)->bool
var _buf = winwin_prepare_buffer(6);
if (instanceof(argument[0]) != "winwin") { show_error("Expected a winwin, got " + string(argument[0]), true); exit }
if (argument[0].__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
if (argument_count >= 2) {
	buffer_write(_buf, buffer_bool, true);
	var _val_0 = argument[1];
	var _flag_0 = _val_0 != undefined;
	buffer_write(_buf, buffer_bool, _flag_0);
	if (_flag_0) {
		buffer_write(_buf, buffer_s32, _val_0);
	}
} else buffer_write(_buf, buffer_bool, false);
return winwin_set_max_height_raw(buffer_get_address(_buf), 6, argument[0].__ptr__);

#define winwin_is_minimized
/// winwin_is_minimized(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_is_minimized_raw(argument0.__ptr__);

#define winwin_is_maximized
/// winwin_is_maximized(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_is_maximized_raw(argument0.__ptr__);

#define winwin_syscommand
/// winwin_syscommand(ww, command:int)->bool ~
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_syscommand_raw(argument0.__ptr__, argument1);

#define winwin_get_alpha
/// winwin_get_alpha(ww)->number
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_alpha_raw(argument0.__ptr__);

#define winwin_set_alpha
/// winwin_set_alpha(ww, alpha:number)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_alpha_raw(argument0.__ptr__, argument1);

#define winwin_get_chromakey
/// winwin_get_chromakey(ww)->int
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_chromakey_raw(argument0.__ptr__);

#define winwin_set_chromakey
/// winwin_set_chromakey(ww, color:number)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_chromakey_raw(argument0.__ptr__, argument1);

#define winwin_enable_per_pixel_alpha
/// winwin_enable_per_pixel_alpha(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_enable_per_pixel_alpha_raw(argument0.__ptr__);

#define winwin_set_shadow
/// winwin_set_shadow(ww, enable:bool)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_set_shadow_raw(argument0.__ptr__, argument1);

#define winwin_get_shadow
/// winwin_get_shadow(ww)->bool
// no buffer!
if (instanceof(argument0) != "winwin") { show_error("Expected a winwin, got " + string(argument0), true); exit }
if (argument0.__ptr__ == pointer_null) { show_error("This winwin is destroyed.", true); exit; }
return winwin_get_shadow_raw(argument0.__ptr__);

#define winwin_update
/// winwin_update()
// no buffer!
winwin_update_raw()


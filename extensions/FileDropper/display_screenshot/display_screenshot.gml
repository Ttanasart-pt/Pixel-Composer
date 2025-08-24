#define display_capture_init
//#global display_capture_rect
//#global display_capture_is_available
global.display_capture_mb = buffer_create(
	16 // xywh [always]
	+ 16 // xywh [all-only, workspace]
	+ 4 // flags [all]
	+ 128 // name [all]
, buffer_fixed, 1);
global.display_capture_buf = buffer_create(8, buffer_grow, 1);
display_capture_is_available = display_capture_init_raw();
if (!display_capture_is_available) {
	show_debug_message("Desktop Screenshots DLL failed to load.");
}
display_capture_rect[0] = 0;
display_capture_rect[1] = 0;
display_capture_rect[2] = display_get_width();
display_capture_rect[3] = display_get_height();

#define display_capture_measure
/// ()->success?
var l_buf = global.display_capture_mb;
if (display_capture_measure_raw(buffer_get_address(l_buf))) {
	display_capture_rect[@0] = buffer_peek(l_buf,  0, buffer_s32);
	display_capture_rect[@1] = buffer_peek(l_buf,  4, buffer_s32);
	display_capture_rect[@2] = buffer_peek(l_buf,  8, buffer_s32);
	display_capture_rect[@3] = buffer_peek(l_buf, 12, buffer_s32);
	return true;
} else return false;

#define display_capture_measure_all
/// ()->array<[screen_x,y,w,h, workspace_x,y,w,h, flags, name]>
var l_num = display_capture_measure_all_start_raw();
var l_res = array_create(0);
var l_buf = global.display_capture_mb;
var l_adr = buffer_get_address(l_buf);
var l_found = 0;
for (var l_i = 0; l_i < l_num; l_i++) {
	if (!display_capture_measure_all_next_raw(l_i, l_adr)) continue;
	var l_arr = array_create(10);
	for (var l_k = 0; l_k < 9; l_k++) {
		l_arr[l_k] = buffer_peek(l_buf, 4*l_k, buffer_s32);
	}
	buffer_seek(l_buf, buffer_seek_start, 40);
	l_arr[9] = buffer_read(l_buf, buffer_string);
	l_res[l_found++] = l_arr;
}
return l_res;

#define display_capture_rect_set
/// (x, y, w, h)
// by writing values into a buffer and reading them back we can be sure
// that it's going to be the same stuff that went to the DLL
var l_buf = global.display_capture_mb;
buffer_poke(l_buf,  0, buffer_s32, argument0);
buffer_poke(l_buf,  4, buffer_s32, argument1);
buffer_poke(l_buf,  8, buffer_s32, argument2);
buffer_poke(l_buf, 12, buffer_s32, argument3);
//
display_capture_rect[@0] = buffer_peek(l_buf,  0, buffer_s32);
display_capture_rect[@1] = buffer_peek(l_buf,  4, buffer_s32);
display_capture_rect[@2] = buffer_peek(l_buf,  8, buffer_s32);
display_capture_rect[@3] = buffer_peek(l_buf, 12, buffer_s32);

#define display_capture_buffer_impl
var l_est = display_capture_rect[2] * display_capture_rect[3] * 4;
var l_buf = argument0;
var l_exists = buffer_exists(l_buf);
if (l_exists) {
	if (buffer_get_size(l_buf) < l_est) buffer_resize(l_buf, l_est);
} else {
	l_buf = buffer_create(l_est, buffer_grow, 1);
}
if (display_capture_buffer_raw(buffer_get_address(global.display_capture_mb), buffer_get_address(l_buf))) {
	buffer_seek(l_buf, buffer_seek_start, l_est);
	return l_buf;
} else {
	if (!l_exists) buffer_delete(l_buf);
	return -1;
}

#define display_capture_buffer
/// @param ?out_buffer
if (display_capture_measure()) {
	return display_capture_buffer_impl(argument_count > 0 ? argument[0] : -1);
} else return -1;

#define display_capture_buffer_part
/// @param x
/// @param y
/// @param w
/// @param h
/// @param ?out_buffer
display_capture_rect_set(argument[0], argument[1], argument[2], argument[3]);
return display_capture_buffer_impl(argument_count > 4 ? argument[4] : -1);

#define display_capture_surface_impl
var l_buf = argument0, l_sf = argument1;
var l_sw = display_capture_rect[2], l_sh = display_capture_rect[3];
if (surface_exists(l_sf)) {
	if (surface_get_width(l_sf) != l_sw || surface_get_height(l_sf) != l_sh) {
		surface_resize(l_sf, l_sw, l_sh);
	}
} else l_sf = surface_create(l_sw, l_sh);
// GMS >= 2.3:
buffer_set_surface(l_buf, l_sf, 0);
/*/
buffer_set_surface(l_buf, l_sf, 0, 0, 0);
//*/
return l_sf;

#define display_capture_surface
/// @param ?out_surface
var l_buf = global.display_capture_buf;
if (display_capture_buffer(l_buf) < 0) return -1;
return display_capture_surface_impl(l_buf, argument_count > 0 ? argument[0] : -1);

#define display_capture_surface_part
/// @param x
/// @param y
/// @param w
/// @param h
/// @param ?out_surface
var l_buf = global.display_capture_buf;
if (display_capture_buffer_part(argument[0], argument[1], argument[2], argument[3], l_buf) < 0) return -1;
return display_capture_surface_impl(l_buf, argument_count > 4 ? argument[4] : -1);

#define display_capture_combined
/// @param out_buffer
/// @param ?out_surface
if (display_capture_buffer(argument[0]) < 0) return -1;
return display_capture_surface_impl(argument[0], argument_count > 1 ? argument[1] : -1);

#define display_capture_combined_part
/// @param x
/// @param y
/// @param w
/// @param h
/// @param out_buffer
/// @param ?out_surface
if (display_capture_buffer_part(argument[0], argument[1], argument[2], argument[3], argument[4]) < 0) return -1;
return display_capture_surface_impl(argument[4], argument_count > 5 ? argument[5] : -1);

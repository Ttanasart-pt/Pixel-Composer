#define display_measure_all
/// display_measure_all()->array<any>
var _buf = display_measure_prepare_buffer(8);
var __size__ = display_measure_all_raw(buffer_get_address(_buf), 8);
if (__size__ == 0) return [];
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
display_measure_all_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
var _len_0 = buffer_read(_buf, buffer_u32);
var _arr_0 = array_create(_len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	var _struct_1 = array_create(10); // display_measure_result
	_struct_1[0] = buffer_read(_buf, buffer_s32); // mx
	_struct_1[1] = buffer_read(_buf, buffer_s32); // my
	_struct_1[2] = buffer_read(_buf, buffer_s32); // mw
	_struct_1[3] = buffer_read(_buf, buffer_s32); // mh
	_struct_1[4] = buffer_read(_buf, buffer_s32); // wx
	_struct_1[5] = buffer_read(_buf, buffer_s32); // wy
	_struct_1[6] = buffer_read(_buf, buffer_s32); // ww
	_struct_1[7] = buffer_read(_buf, buffer_s32); // wh
	_struct_1[8] = buffer_read(_buf, buffer_s32); // flags
	_struct_1[9] = display_measure_read_chars(_buf, 128); // name
	_arr_0[_ind_0] = _struct_1;
}
return _arr_0;


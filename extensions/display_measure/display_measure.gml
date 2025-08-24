#define display_measure_init
//#init display_measure_init
global.display_measure_buf          = undefined;
global.display_measure_text_buf     = undefined;

#define display_measure_prepare_buffer
/// (size:int)->buffer~
var _size = argument0;
gml_pragma("global", "global.__display_measure_buffer = undefined");
var _buf = global.__display_measure_buffer;
if (_buf == undefined) {
    _buf = buffer_create(_size, buffer_grow, 1);
    global.__display_measure_buffer = _buf;
} else if (buffer_get_size(_buf) < _size) {
    buffer_resize(_buf, _size);
}
buffer_seek(_buf, buffer_seek_start, 0);
return _buf;

#define display_measure_read_chars
/// (buf, count)->string~
var _buf = argument0, _count = argument1;
var _tb = global.display_measure_text_buf;
if (_tb == undefined) {
    _tb = buffer_create(_count + 1, buffer_grow, 1);
    global.display_measure_text_buf = _tb;
} else if (buffer_get_size(_tb) <= _count) {
    buffer_resize(_tb, _count + 1);
}
buffer_copy(_buf, buffer_tell(_buf), _count, _tb, 0);
buffer_poke(_tb, _count, buffer_u8, 0);
buffer_seek(_buf, buffer_seek_relative, _count);
buffer_seek(_tb, buffer_seek_start, 0);
return buffer_read(_tb, buffer_string);
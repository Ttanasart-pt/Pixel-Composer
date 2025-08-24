#define file_dropper_prepare_buffer
/// (size:int)->buffer~
var _size = argument0;
gml_pragma("global", "global.__file_dropper_buffer = undefined");
var _buf = global.__file_dropper_buffer;
if (_buf == undefined) {
    _buf = buffer_create(_size, buffer_grow, 1);
    global.__file_dropper_buffer = _buf;
} else if (buffer_get_size(_buf) < _size) {
    buffer_resize(_buf, _size);
}
buffer_seek(_buf, buffer_seek_start, 0);
return _buf;
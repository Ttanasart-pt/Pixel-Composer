#define window_command_hook_init
//#init window_command_hook_init
//#macro window_command_close    $F060
//#macro window_command_maximize $F030
//#macro window_command_minimize $F020
//#macro window_command_restore  $F120
//#macro window_command_resize   $F000
//#macro window_command_move     $F010

#define window_command_hook_prepare_buffer
/// (size:int)->buffer~
var _size = argument0;
gml_pragma("global", "global.__window_command_hook_buffer = undefined");
var _buf = global.__window_command_hook_buffer;
if (_buf == undefined) {
    _buf = buffer_create(_size, buffer_grow, 1);
    global.__window_command_hook_buffer = _buf;
} else if (buffer_get_size(_buf) < _size) {
    buffer_resize(_buf, _size);
}
buffer_seek(_buf, buffer_seek_start, 0);
return _buf;
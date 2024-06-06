// Feather disable all
/// @return XML string that encodes the provided struct
/// 
/// @param struct  The data to encode
/// 
/// @jujuadams 2022-10-30

function SnapToXML(_struct)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWriteXML(_buffer, _struct);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string; 
}

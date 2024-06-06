// Feather disable all
/// Decodes an XML string and outputs a struct
/// 
/// @param string  String to decode
/// 
/// @jujuadams 2022-10-30

function SnapFromXML(_string)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferReadXML(_buffer, 0, buffer_get_size(_buffer));
    buffer_delete(_buffer);
    return _data;
}

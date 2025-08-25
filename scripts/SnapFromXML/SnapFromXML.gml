// Feather disable all
/// Decodes an XML string and outputs a struct
/// 
/// @param string  String to decode
/// 
/// @jujuadams 2022-10-30

function SnapFromXML(_string) {
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    buffer_to_start(_buffer);
    
    var _datas = [];
    var _offs  = 0;
    var _size  = buffer_get_size(_buffer);
    
    while(_offs < _size) {
        var _data = SnapBufferReadXML(_buffer, _offs, _size);
        array_push(_datas, _data);
        
        var _offp = _offs;
        _offs = buffer_tell(_buffer);
        
        if(_offp == _offs) break;
    }
    
    buffer_delete(_buffer);
    return _datas;
}

function xml_read_file(fpath) { return SnapFromXML(file_read_all(fpath)); }

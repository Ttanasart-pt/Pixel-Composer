// Feather disable all
/// @param buffer   Buffer to write the data to
/// @param struct   The data to be encoded
/// 
/// @jujuadams 2022-10-30

function SnapBufferWriteXML(_buffer, _struct)
{
    var _prologStruct = _struct[$ "prolog"];
    if (is_struct(_prologStruct))
    {
        var _attributeStruct = _prologStruct[$ "attributes"];
        if (is_struct(_attributeStruct))
        {
            var _names = variable_struct_get_names(_attributeStruct);
            
            var _count = array_length(_names);
            if (_count > 0)
            {
                buffer_write(_buffer, buffer_text, "<?xml");
                
                var _i = 0;
                repeat(_count)
                {
                    var _key = _names[_i];
                    var _value = _attributeStruct[$ _key];
                    
                    buffer_write(_buffer, buffer_text, " ");
                    buffer_write(_buffer, buffer_text, _key);
                    buffer_write(_buffer, buffer_text, "=\"");
                    buffer_write(_buffer, buffer_text, string(_value));
                    buffer_write(_buffer, buffer_text, "\"");
                    
                    ++_i;
                }
                
                buffer_write(_buffer, buffer_text, "?>\n");
            }
        }
    }
    
    var _children = _struct[$ "children"];
    if (is_array(_children))
    {
        var _i = 0;
        repeat(array_length(_children))
        {
            __SnapToXMLBufferInner(_buffer, _children[_i], "");
            ++_i;
        }
    }
}

function __SnapToXMLBufferInner(_buffer, _struct, _indent)
{
    buffer_write(_buffer, buffer_text, _indent);
    buffer_write(_buffer, buffer_text, "<");
    buffer_write(_buffer, buffer_text, _struct.type);
    
    var _attributeStruct = _struct[$ "attributes"];
    if (is_struct(_attributeStruct))
    {
        var _names = variable_struct_get_names(_attributeStruct);
        
        var _i = 0;
        repeat(array_length(_names))
        {
            var _key = _names[_i];
            var _value = _attributeStruct[$ _key];
            
            buffer_write(_buffer, buffer_text, " ");
            buffer_write(_buffer, buffer_text, _key);
            buffer_write(_buffer, buffer_text, "=\"");
            buffer_write(_buffer, buffer_text, string(_value));
            buffer_write(_buffer, buffer_text, "\"");
            
            ++_i;
        }
    }
    
    buffer_write(_buffer, buffer_text, ">");
    
    var _content = _struct[$ "text"];
    if (_content != undefined)
    {
        buffer_write(_buffer, buffer_text, string(_content));
    }
    else
    {
        var _children = _struct[$ "children"];
        if (is_array(_children))
        {
            var _count = array_length(_children);
            if (_count > 0)
            {
                var _preIndent = _indent;
                _indent += chr(0x09);
                
                var _i = 0;
                repeat(_count)
                {
                    buffer_write(_buffer, buffer_u8, 13);
                    __SnapToXMLBufferInner(_buffer, _children[_i], _indent);
                    ++_i;
                }
                
                _indent = _preIndent;
                buffer_write(_buffer, buffer_u8, 13);
                buffer_write(_buffer, buffer_text, _indent);
            }
        }
    }
    
    buffer_write(_buffer, buffer_text, "</");
    buffer_write(_buffer, buffer_text, _struct.type);
    buffer_write(_buffer, buffer_text, ">");
}

// Feather disable all
/// Decodes XML data stored in a buffer and outputs a sorta-JSON equivalent
///
/// @return Nested struct/array data that represents the contents of the XML data
/// 
/// @param buffer  Buffer to read data from
/// @param offset  Offset in the buffer to read data from
/// 
/// @jujuadams 2022-10-30

function SnapBufferReadXML(_buffer, _offset, _size)
{
    var _oldOffset = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    
    var _skip_whitespace = true;
    
    var _in_key    = false;
    var _key_start = -1;
    var _key       = "";
    
    var _in_value     = false;
    var _in_string    = false;
    var _string_start = 0;
    var _value        = "";
    
    var _in_text            = false;
    var _text               = "";
    var _text_has_ampersand = false;
    var _text_start         = 0;
    
    var _in_tag                 = false;
    var _tag                    = undefined;
    var _tag_terminating        = false;
    var _tag_self_terminating   = false;
    var _tag_is_prolog          = false;
    var _tag_is_comment         = false;
    var _tag_terminating        = false;
    var _tag_start              = 0;
    var _tag_reading_attributes = false;
    var _tag_has_attributes     = false;
    
    var _root = {
        type: "root",
    };
    
    var _stack_parent = undefined;
    var _stack_top =_root;
    var _stack = ds_list_create();
    ds_list_add(_stack, _stack_top);
    
    repeat(_size)
    {
        var _value = buffer_read(_buffer, buffer_u8);
        
        if (_skip_whitespace && (_value > 32)) _skip_whitespace = false;
    
        if (!_skip_whitespace)
        {
            if (_in_tag)
            {
                if (_in_key)
                {
                    if ((_value == ord("/")) || (_value == ord("?")))
                    {
                        _in_key = false;
                        if (_value == ord("/")) _tag_terminating = true;
                    }
                    else if ((_value == ord(" ")) || (_value == ord("=")))
                    {
                        buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                        buffer_seek(_buffer, buffer_seek_start, _key_start);
                        _key = buffer_read(_buffer, buffer_string);
                    
                        _in_key   = false;
                        _in_value = true;
                    }
                    else if (_key_start < 0)
                    {
                        _key_start = buffer_tell(_buffer) - 1;
                    }
                }
                else if (_in_value)
                {
                    if (_in_string)
                    {
                        if (_value == ord("&")) //Check for ampersands so we can trigger a find-replace on the output value
                        {
                            _text_has_ampersand = true;
                        }
                        else if (_value == ord("\"")) //End string
                        {
                            buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                            buffer_seek(_buffer, buffer_seek_start, _string_start);
                            var _substring = buffer_read(_buffer, buffer_string);
                        
                            if (_text_has_ampersand) //Only run these checks if we found an ampersand
                            {
                                _substring = string_replace_all(_substring, "&lt;"  , "<");
                                _substring = string_replace_all(_substring, "&gt;"  , ">");
                                _substring = string_replace_all(_substring, "&amp;" , "&");
                                _substring = string_replace_all(_substring, "&apos;", "'");
                                _substring = string_replace_all(_substring, "&quot;", "\"");
                            }
                        
                            if (!_tag_is_comment)
                            {
                                if (!variable_struct_exists(_stack_top, "attributes")) _stack_top.attributes = {};
                                _stack_top.attributes[$ _key] = _substring;
                            }
                        
                            _in_key          = true;
                            _key_start       = -1;
                            _in_string       = false;
                            _skip_whitespace = true;
                        }
                    }
                    else if (_value == ord("\"")) //Start the value reading at the quote mark
                    {
                        _in_string    = true;
                        _string_start = buffer_tell(_buffer);
                    }
                }
                else
                {
                    switch(_value)
                    {
                        case ord("?"): //Prolog indicator
                            if (buffer_tell(_buffer) == _tag_start + 1) _tag_is_prolog = true;
                        break;
                        
                        case ord("!"): //Comment indicator
                            if (buffer_tell(_buffer) == _tag_start + 1) _tag_is_comment = true;
                        break;
                        
                        case ord("/"): //Close tag indicator
                            if (buffer_tell(_buffer) == _tag_start + 1)
                            {
                                _tag_terminating = true;
                            }
                            else
                            {
                                if ((_tag == undefined) && (buffer_tell(_buffer) > _tag_start))
                                {
                                    _tag_terminating = true;
                                    
                                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                                    buffer_seek(_buffer, buffer_seek_start, _tag_start);
                                    _tag = buffer_read(_buffer, buffer_string);
                                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, _value);
                                    
                                    _stack_top = {
                                        type: _tag,
                                    };
                                    
                                    ds_list_insert(_stack, 0, _stack_top);
                                    
                                    if (!variable_struct_exists(_stack_parent, "children")) _stack_parent.children = [];
                                    array_push(_stack_parent.children, _stack_top);
                                    
                                    _in_key                 = true;
                                    _key_start              = -1;
                                    _tag_reading_attributes = true;
                                    _skip_whitespace        = true;
                                }
                            }
                        break;
                        
                        case ord(" "):
                            if (!_tag_is_prolog)
                            {
                                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                                buffer_seek(_buffer, buffer_seek_start, _tag_start);
                                _tag = buffer_read(_buffer, buffer_string);
                            }
                            
                            if (!_tag_is_comment && !_tag_terminating)
                            {
                                _stack_top = {
                                    type: (_tag_is_prolog? "prolog" : _tag),
                                };
                                
                                ds_list_insert(_stack, 0, _stack_top);
                                
                                if (_tag_is_prolog)
                                {
                                    _stack_parent.prolog = _stack_top;
                                }
                                else
                                {
                                    if (!variable_struct_exists(_stack_parent, "children")) _stack_parent.children = [];
                                    array_push(_stack_parent.children, _stack_top);
                                }
                            }
                        
                            _in_key                 = true;
                            _key_start              = -1;
                            _tag_reading_attributes = true;
                            _skip_whitespace        = true;
                        break;
                    }
                }
        
                if (!_in_string && (_value == ord(">")))
                {
                    if (!_tag_reading_attributes && !_tag_is_comment)
                    {
                        if (!_tag_is_prolog && (_tag == undefined))
                        {
                            buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                            buffer_seek(_buffer, buffer_seek_start, _tag_start);
                            _tag = buffer_read(_buffer, buffer_string);
                        }
                        
                        if (!_tag_terminating)
                        {
                            _stack_top = {
                                type: (_tag_is_prolog? "prolog" : _tag),
                            };
                            
                            ds_list_insert(_stack, 0, _stack_top);
                            
                            if (_tag_is_prolog)
                            {
                                _stack_parent.prolog = _stack_top;
                            }
                            else
                            {
                                if (!variable_struct_exists(_stack_parent, "children")) _stack_parent.children = [];
                                array_push(_stack_parent.children, _stack_top);
                            }
                        }
                    }
                    
                    var _previous_value = buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8);
                    if (_previous_value == ord("?")) //Detect ?> method to close the prolog
                    {
                        _tag_terminating = true;
                    }
                    else if (_previous_value == ord("/")) //Detect /> method to close a tag
                    {
                        _tag_terminating      = true;
                        _tag_self_terminating = true;
                    }
                    
                    if (!_tag_is_comment && (!_tag_self_terminating || _tag_reading_attributes))
                    {
                        if (_tag_terminating || _tag_is_prolog)
                        {
                            ds_list_delete(_stack, 0);
                            _stack_top = _stack[| 0];
                        }
                        else
                        {
                            _in_text            = true;
                            _text_has_ampersand = false;
                            _text_start         = buffer_tell(_buffer);
                        }
                    }
                    
                    if (!_tag_is_comment || (_tag_is_comment && _previous_value == ord("-")))
                    {
                        _tag      = undefined;
                        _in_tag   = false;
                        _in_key   = false;
                        _in_value = false;
                    }
                }
            }
            else if ((_value == 10) || (_value == 13)) //Newline
            {
                _in_text        = false;
                _skip_whitespace = true;
            }
            else if (_value == ord("<")) //Open a tag
            {
                if (_in_text)
                {
                    _in_text = false;
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                    buffer_seek(_buffer, buffer_seek_start, _text_start);
                    _text = buffer_read(_buffer, buffer_string);
                    
                    _stack_top.text = _text;
                }
            
                _stack_parent           = _stack_top;
                _in_tag                 = true;
                _tag_terminating        = false;
                _tag_self_terminating   = false;
                _tag_is_prolog          = false;
                _tag_is_comment         = false;
                _tag_terminating        = false;
                _tag_reading_attributes = false;
                _tag_has_attributes     = false;
                _tag_start              = buffer_tell(_buffer);
            }
        }
    }
    
    ds_list_destroy(_stack);
    
    buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    
    return _root;
}

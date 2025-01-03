function surface_exr_encode(surface, path, param = {}) {
    if(!surface_exists(surface)) return;
    
    var _sw = surface_get_width(surface);
    var _sh = surface_get_height(surface);
    var _fr = surface_get_format(surface);
    var _fb = surface_format_get_channel(_fr);
    var _ty = surface_format_get_buffer_type(_fr);
    
    var _px = array_create(_sw * _sh * _fb);
    var _sb = buffer_from_surface(surface, false);
    var _gam = struct_try_get(param, "gamma")? 2.2 : 1;
    var _lim = _fr == surface_rgba8unorm? 255 : 1;
    buffer_to_start(_sb);
    
    for( var i = 0; i < _sh; i++ ) {
        var _line = i * _sw * _fb;
        
        if(_fb == 1) {
            for( var j = 0; j < _sw; j++ ) {
                var _y = buffer_read(_sb, _ty);
                
                _px[_line + _sw * 0 + j] = power(_y, _gam) / _lim;
            }
            
        } else if(_fb == 4) {
            for( var j = 0; j < _sw; j++ ) {
                var _a = buffer_read(_sb, _ty);
                var _b = buffer_read(_sb, _ty);
                var _g = buffer_read(_sb, _ty);
                var _r = buffer_read(_sb, _ty);
                
                _px[_line + _sw * 0 + j] = power(_r, _gam) / _lim;
                _px[_line + _sw * 1 + j] = power(_g, _gam) / _lim;
                _px[_line + _sw * 2 + j] = power(_b, _gam) / _lim;
                _px[_line + _sw * 3 + j] = _a / _lim;
            }
        }
    }
    
    buffer_delete(_sb);
    
    var _offset_position = 0;
    var _line_count      = _sh;
    var _line_offsets    = array_create(_line_count);
    
    var _b  = buffer_create(1, buffer_grow, 1);
    buffer_to_start(_b);
    
    /// VERSION
    
    buffer_write(_b, buffer_u32, 20000630);
    buffer_write(_b, buffer_u8,  2);
    buffer_write(_b, buffer_u8,  0);
    buffer_write(_b, buffer_u8,  0);
    buffer_write(_b, buffer_u8,  0);
    
    /// HEADER
    
    buffer_write(_b, buffer_string, "channels");
    buffer_write(_b, buffer_string, "chlist");
    buffer_write(_b, buffer_u32,    18 * _fb + 1);
    if(_fb == 1) {
        buffer_write(_b, buffer_string, "Y");
        buffer_write(_b, buffer_u32,    2);
        buffer_write(_b, buffer_u32,    0);
        buffer_write(_b, buffer_u32,    1);
        buffer_write(_b, buffer_u32,    1);
        
    } else {
        buffer_write(_b, buffer_string, "R");
        buffer_write(_b, buffer_u32,    2);
        buffer_write(_b, buffer_u32,    0);
        buffer_write(_b, buffer_u32,    1);
        buffer_write(_b, buffer_u32,    1);
        
        buffer_write(_b, buffer_string, "G");
        buffer_write(_b, buffer_u32,    2);
        buffer_write(_b, buffer_u32,    0);
        buffer_write(_b, buffer_u32,    1);
        buffer_write(_b, buffer_u32,    1);
        
        buffer_write(_b, buffer_string, "B");
        buffer_write(_b, buffer_u32,    2);
        buffer_write(_b, buffer_u32,    0);
        buffer_write(_b, buffer_u32,    1);
        buffer_write(_b, buffer_u32,    1);
        
        buffer_write(_b, buffer_string, "A");
        buffer_write(_b, buffer_u32,    2);
        buffer_write(_b, buffer_u32,    0);
        buffer_write(_b, buffer_u32,    1);
        buffer_write(_b, buffer_u32,    1);
    }
    buffer_write(_b, buffer_u8,     0);
    
    buffer_write(_b, buffer_string, "compression");
    buffer_write(_b, buffer_string, "compression");
    buffer_write(_b, buffer_u32,    1);
    buffer_write(_b, buffer_u8,     0);
    
    buffer_write(_b, buffer_string, "dataWindow");
    buffer_write(_b, buffer_string, "box2i");
    buffer_write(_b, buffer_u32,     16);
    buffer_write(_b, buffer_u32,      0);
    buffer_write(_b, buffer_u32,      0);
    buffer_write(_b, buffer_u32,      _sw - 1);
    buffer_write(_b, buffer_u32,      _sh - 1);
    
    buffer_write(_b, buffer_string, "displayWindow");
    buffer_write(_b, buffer_string, "box2i");
    buffer_write(_b, buffer_u32,     16);
    buffer_write(_b, buffer_u32,      0);
    buffer_write(_b, buffer_u32,      0);
    buffer_write(_b, buffer_u32,      _sw - 1);
    buffer_write(_b, buffer_u32,      _sh - 1);
    
    buffer_write(_b, buffer_string, "lineOrder");
    buffer_write(_b, buffer_string, "lineOrder");
    buffer_write(_b, buffer_u32,    1);
    buffer_write(_b, buffer_u8,     0);
    
    buffer_write(_b, buffer_string, "pixelAspectRatio");
    buffer_write(_b, buffer_string, "float");
    buffer_write(_b, buffer_u32,    4);
    buffer_write(_b, buffer_f32,    1);
    
    buffer_write(_b, buffer_string, "screenWindowCenter");
    buffer_write(_b, buffer_string, "v2f");
    buffer_write(_b, buffer_u32,    8);
    buffer_write(_b, buffer_f32,    0);
    buffer_write(_b, buffer_f32,    0);
    
    buffer_write(_b, buffer_string, "screenWindowWidth");
    buffer_write(_b, buffer_string, "float");
    buffer_write(_b, buffer_u32,    4);
    buffer_write(_b, buffer_f32,    1);
    
    buffer_write(_b, buffer_u8,     0);
    
    /// OFFSETS
    
    _offset_position = buffer_tell(_b);
    repeat(_line_count) buffer_write(_b, buffer_u64, 0);
    
    /// PIXEL
    
    for( var i = 0; i < _line_count; i++ ) {
        _line_offsets[i] = buffer_tell(_b);
        var _lo = i * _sw * _fb;
        
        buffer_write(_b, buffer_u32, i);
        buffer_write(_b, buffer_u32, _sw * 4 * _fb);
        
        for( var j = 0; j < _sw * _fb; j++ )
            buffer_write(_b, buffer_f32, _px[_lo + j]);
    }
    
    buffer_seek(_b, buffer_seek_start, _offset_position);
    for( var i = 0; i < _line_count; i++ )
        buffer_write(_b, buffer_u64, _line_offsets[i]);
        
    buffer_save(_b, path);
    buffer_delete(_b);
    return 1;
}
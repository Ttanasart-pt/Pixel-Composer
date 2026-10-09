function read_png_header(path, noti = true) {
    static png_header = [ 137, 80, 78, 71, 13, 10, 26, 10 ];
    
    var f = file_bin_open(path, 0);
    if(f < 0) { 
        if(noti) noti_warning($"PNG header read error [{f}]. {path}"); 
        return noone; 
    }
    
    var b;
    
    file_bin_seek(f, 0);
    for (var i = 0, n = array_length(png_header); i < n; i++) {
        b = file_bin_read_byte(f); 
        if(b != png_header[i]) { 
            file_bin_close(f); 
            if(noti) noti_warning($"PNG header read error [{b} != {png_header[i]}]. {path}"); 
            return noone;
        }
    }
    
    repeat(4) b = file_bin_read_byte(f); // chunk size
    
    b = bin_read_chars(f, 4);
    if(b != "IHDR") { 
        file_bin_close(f);
        if(noti) noti_warning($"PNG header read error [{b} != IHDR]. {path}"); 
        return noone;
    }
    
    var _width  = Bin_read_dword(f);
    var _height = Bin_read_dword(f);
    var _depth  = Bin_read_byte(f);
    
    file_bin_close(f);
    
    return { width: _width, height: _height, depth: _depth };
}

function image_get_type(path) { 
    var _type = string_lower(filename_ext(path));
    print("image_get_type", path, _type);
    
    var f = file_bin_open(path, 0);
    if(f < 0) return _type; 
    
    static HEADERS = [
        [".png",  [ 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A ]],
        [".jpg",  [ 0xFF, 0xD8, 0xFF                               ]],
        [".webp", [ 0x52, 0x49, 0x46, 0x46                         ]], // ?? ?? ?? ?? 0x57 0x45 0x42 0x50
        [".gif",  [ 0x47, 0x49, 0x46, 0x38, 0x37, 0x61             ]], // GIF87a
        [".gif",  [ 0x47, 0x49, 0x46, 0x38, 0x39, 0x61             ]], // GIF89a
        [".bmp",  [ 0x42, 0x4d                                     ]],
        [".tiff", [ 0x49, 0x49, 0x2A, 0x00                         ]], // little end
        [".tiff", [ 0x4D, 0x4D, 0x00, 0x2A                         ]], // big end
    ];
    
    static MAX_HEADER = 8;
    
    var head = array_create(MAX_HEADER);
    for( var i = 0; i < MAX_HEADER; i++ ) 
        head[i] = file_bin_read_byte(f);
    file_bin_close(f);
    
    for( var i = 0, n = array_length(HEADERS); i < n; i++ ) {
        var _h = HEADERS[i];
        var _ext = _h[0];
        var _byt = _h[1];
        
        for( var j = 0, m = array_length(_byt); j < m; j++ ) {
            if(head[j] != _byt[j]) break;
            _type = _ext;
        }
    }
    
    return _type;
}
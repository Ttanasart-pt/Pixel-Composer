#macro ___PNG_READ_ERROR { if(noti) noti_warning($"PNG header read error."); return noone; }

function read_png_header(path, noti = true) {
    static png_header = [ 137, 80, 78, 71, 13, 10, 26, 10 ];
    
    var f = file_bin_open(path, 0);
    if(f < 0) ___PNG_READ_ERROR
    
    var b;
    
    for (var i = 0, n = array_length(png_header); i < n; i++) {
        b = file_bin_read_byte(f); 
        if(b != png_header[i]) { file_bin_close(f); ___PNG_READ_ERROR }
    }
    
    repeat(4) b = file_bin_read_byte(f); // chunk size
    
    b = bin_read_chars(f, 4);
    if(b != "IHDR") { file_bin_close(f); ___PNG_READ_ERROR }
    
    var _width  = Bin_read_dword(f);
    var _height = Bin_read_dword(f);
    var _depth  = Bin_read_byte(f);
    
    file_bin_close(f);
    
    return { width: _width, height: _height, depth: _depth };
}
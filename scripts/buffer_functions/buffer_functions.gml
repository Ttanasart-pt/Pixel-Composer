function buffer_get_string(buffer) {
	buffer_seek(buffer, buffer_seek_start, 0);
	var len = buffer_get_size(buffer);
    var ss = "";
    
    for (var i = 0; i < len; i++) {
		var _s = chr(buffer_read(buffer, buffer_u8));
        ss += _s;
	}
    
    return ss;
}

function buffer_from_string(str) {
	var _b = buffer_create(string_length(str) * 1, buffer_fast, 1);
	for( var i = 1; i <= string_length(str); i++ ) 
		buffer_write(_b, buffer_u8, ord(string_char_at(str, i)));
	return _b;
}

function buffer_from_surface(surface) {
	var _b = buffer_create(surface_get_width(surface) * surface_get_height(surface), buffer_fast, 1);
	buffer_set_surface(_b, surface, 0);
	return _b;
}

function buffer_from_file(path) {
	if(!file_exists(path)) return;
	var _b = buffer_load(path);
	return _b;
}
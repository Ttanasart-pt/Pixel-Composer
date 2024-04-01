function buffer_get_color(buffer, _x, _y, w, h) { #region
	buffer_seek(buffer, buffer_seek_start, (w * _y + _x) * 4);
	var c = buffer_read(buffer, buffer_u32);
	
	return c;
} #endregion

function buffer_get_string(buffer, text = true, limit = 400) { #region
	buffer_seek(buffer, buffer_seek_start, 0);
	var len = min(limit, buffer_get_size(buffer));
    var ss  = "";
    
    for (var i = 0; i < len; i++) {
		var _r = buffer_read(buffer, buffer_u8);
		var _s = text? chr(_r) : dec_to_hex(_r, 2);
        ss += _s;
		if(!text && i % 2) ss += " ";
	}
    
    return ss;
} #endregion

function buffer_from_string(str) { #region
	var _b = buffer_create(string_length(str) * 1, buffer_fast, 1);
	for( var i = 1; i <= string_length(str); i++ ) 
		buffer_write(_b, buffer_u8, ord(string_char_at(str, i)));
	return _b;
} #endregion

function buffer_from_surface(surface, header = true) { #region
	static header_length = 24;
	if(!is_surface(surface)) return noone;
	
	var bitSize = surface_format_get_bytes(surface_get_format(surface));
	
	var _b = buffer_create((header_length * header) + surface_get_width_safe(surface) * surface_get_height_safe(surface) * bitSize, buffer_fixed, 1);
	if(header) {
		buffer_write(_b, buffer_text, "PXCS");
		buffer_write(_b, buffer_u16, surface_get_width_safe(surface));
		buffer_write(_b, buffer_u16, surface_get_height_safe(surface));
		buffer_write(_b, buffer_u8,  surface_get_format(surface));
	}
	
	buffer_get_surface(_b, surface, header_length * header);
	return _b;
} #endregion

function buffer_from_file(path) { #region
	if(!file_exists_empty(path)) return;
	var _b = buffer_load(path);
	return _b;
} #endregion

function buffer_read_at(buffer, position, type) { #region
	buffer_seek(buffer, buffer_seek_start, position);
	return buffer_read(buffer, type);
} #endregion

function buffer_serialize(buffer, compress = true) { #region
	INLINE
	if(!buffer_exists(buffer)) return "";
	
	if(compress) {
		var comp = buffer_compress(buffer, 0, buffer_get_size(buffer));
		return buffer_base64_encode(comp, 0, buffer_get_size(comp));
	}
	
	return buffer_base64_encode(buffer, 0, buffer_get_size(buffer));
} #endregion

function buffer_deserialize(buffer, compress = true) { #region
	INLINE
	var buff = buffer_base64_decode(buffer);
	
	if(!compress) return buff;
	return buffer_decompress(buff);
} #endregion
	
function buffer_getPixel(buffer, _w, _h, _x, _y) { #region
	if(_x < 0 || _y < 0 || _x >= _w || _y >= _h) return 0;
	
	buffer_seek(buffer, buffer_seek_start, (_w * _y + _x) * 4);
	return buffer_read(buffer, buffer_u32);
} #endregion
	
function buffer_setPixel(buffer, _w, _h, _x, _y, _c) { #region
	if(_x < 0 || _y < 0 || _x >= _w || _y >= _h) return 0;
	
	buffer_seek(buffer, buffer_seek_start, (_w * _y + _x) * 4);
	buffer_write(buffer, buffer_u32, _c);
} #endregion
	
function buffer_compress_string(str) { #region
	var _len   = string_length(str);
	var buffer = buffer_create(1, buffer_grow, 1);
	
	buffer_write(buffer, buffer_string, str);
	return buffer_compress(buffer, 0, buffer_get_size(buffer));
} #endregion
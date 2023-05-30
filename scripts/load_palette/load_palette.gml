function loadPalette(path) {
	var pal = [];
		
	if(path != "" && file_exists(path)) {
		var _t = file_text_open_read(path);
		var _index = 0;
		var ext = string_lower(filename_ext(path));
		while(!file_text_eof(_t)) {
			var _w = file_text_readln(_t);
			if(_w != "") {
				switch(ext) {
					case ".hex" :
						var _r = string_hexadecimal(string_copy(_w, 1, 2));
						var _g = string_hexadecimal(string_copy(_w, 3, 2));
						var _b = string_hexadecimal(string_copy(_w, 5, 2));
						
						pal[_index++] = make_color_rgb(_r, _g, _b);
						break;
					case ".gpl" :
					case ".pal" :
						if(string_char_at(_w, 1) == "#") break;
						var _c = string_splice(_w, " ");
						if(array_length(_c) >= 3)
							pal[_index++] = make_color_rgb(toNumber(_c[0]), toNumber(_c[1]), toNumber(_c[2]));
						break;
				}
			}
		}
		file_text_close(_t);
	}
	return pal;
}
function isPaletteFile(path) { #region
	var ext = string_lower(filename_ext(path));
	switch(ext) {
		case ".hex" : 
		case ".gpl" : 
		case ".pal" : 
		case ".png" : 
			return true;
	}
	
	return false;
} #endregion

function loadPalette(path) { #region
	if(!file_exists(path))   return [];
	if(!isPaletteFile(path)) return [];
	
	var ext = string_lower(filename_ext(path));
	
	if(ext == ".png") {
		var _spr = sprite_add(path, 1, 0, 0, 0, 0);
		var _sw  = sprite_get_width(_spr);
		var _sh  = sprite_get_height(_spr);
		var _s   = surface_create(_sw, _sh);
		surface_set_target(_s);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
			draw_sprite(_spr, 0, 0, 0);
			BLEND_NORMAL
		surface_reset_target();
		
		var pal = array_create(_sw * _sh);
		for( var i = 0; i < _sh; i++ ) 
		for( var j = 0; j < _sw; j++ ) 
			pal[i * _sh + j] = surface_getpixel(_s, j, i);
		
		surface_free(_s);
		
		return pal;
	}
	
	var pal    = [];
	var _t	   = file_text_open_read(path);
	var _index = 0;
	
	while(!file_text_eof(_t)) {
		var _w = file_text_readln(_t);
		if(_w == "") continue;
			
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
	file_text_close(_t);
	
	return pal;
} #endregion
	
globalvar PALETTES;
PALETTES = [];

function __initPalette() {
	PALETTES = [];
	
	var path = DIRECTORY + "Palettes/"
	var file = file_find_first(path + "*", 0);
	while(file != "") {
		if(isPaletteFile(file)) {
			array_push(PALETTES, {
				name:    filename_name_only(file),
				path:    path + file,
				palette: loadPalette(path + file)
			});
		}
		file = file_find_next();
	}
	file_find_close();
}
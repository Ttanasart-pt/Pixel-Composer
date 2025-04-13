function isPaletteFile(path) {
	var ext = string_lower(filename_ext(path));
	switch(ext) {
		case ".hex" : 
		case ".gpl" : 
		case ".pal" : 
		case ".png" : 
			return true;
	}
	
	return false;
}

function loadPalette(path) {
	if(!file_exists_empty(path)) return [];
	if(!isPaletteFile(path))     return [];
	
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
			pal[i * _sh + j] = cola(surface_getpixel(_s, j, i));
		
		surface_free(_s);
		
		return pal;
	}
	
	var pal    = [];
	var _t	   = file_text_open_read(path);
	var _index = 0;
	
	while(!file_text_eof(_t)) {
		var _w = file_text_readln(_t);
		    _w = string_trim(_w);
		    _w = string_replace_all(_w, "\t", " ");
		if(_w == "") continue;
		
		switch(ext) {
			case ".hex" :
				var _r = string_hexadecimal(string_copy(_w, 1, 2));
				var _g = string_hexadecimal(string_copy(_w, 3, 2));
				var _b = string_hexadecimal(string_copy(_w, 5, 2));
				var _a = string_length(_w) > 6? string_hexadecimal(string_copy(_w, 7, 2)) : 255;
				
				pal[_index++] = make_color_rgba(_r, _g, _b, _a);
				break;
				
			case ".gpl" :
			case ".pal" :
				if(string_char_at(_w, 1) == "#") break;
				var _c = string_splice(_w, " ", false);
				    _c = array_filter(_c, function(s) { return s != ""; });
				
				if(array_length(_c) == 3) 
					pal[_index++] = make_color_rgba(toNumber(_c[0]), toNumber(_c[1]), toNumber(_c[2]), 255);
				else if(array_length(_c) >= 4) 
					pal[_index++] = make_color_rgba(toNumber(_c[0]), toNumber(_c[1]), toNumber(_c[2]), toNumber(_c[3]));
				break;
		}
	}
	file_text_close(_t);
	
	return pal;
}
	
globalvar PALETTES, PALETTE_LOSPEC;

PALETTES = [];
PALETTE_LOSPEC = 0;

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
	
	with(o_dialog_palette)  initPalette();
	with(o_dialog_gradient) initPalette();
}

function palette_string_hex(palette, alpha = true) { //palette generate
	var _str = "";
	
	for (var i = 0, n = array_length(palette); i < n; i++) {
		var _c = palette[i];
		_str += $"{color_get_hex(_c, alpha)}\n";
	}
	
	return _str;
}

#region comparison
	function palette_hue(p)  { return array_empty(p)? 0 : array_reduce(p, function(h, c) /*=>*/ {return h + color_get_hue(c)}, 0) / array_length(p); }
	function palette_hue_var(p) { 
		if(array_empty(p)) return 0;
		
		__avg = palette_hue(p);
		return array_reduce(p, function(h, c) /*=>*/ {return h + sqr(color_get_hue(c) - __avg)}, 0);
	}
	
	function palette_compare_hue_var(p0, p1) { return palette_hue(p0) - palette_hue(p1); }
	
	function palette_sat(p)  { return array_empty(p)? 0 : array_reduce(p, function(h, c) /*=>*/ {return h + color_get_saturation(c)}, 0) / array_length(p); }
	function palette_compare_sat(p0, p1) { return palette_sat(p0) - palette_sat(p1); }
	
	function palette_val(p)  { return array_empty(p)? 0 : array_reduce(p, function(h, c) /*=>*/ {return h + color_get_value(c)}, 0) / array_length(p); }
	function palette_compare_val(p0, p1) { return palette_val(p0) - palette_val(p1); }
	
#endregion
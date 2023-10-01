//draw
function draw_surface_safe(surface, _x = 0, _y = 0) {
	gml_pragma("forceinline");
	
	if(is_struct(surface) && is_instanceof(surface, dynaSurf)) {
		surface.draw(_x, _y);
		return;
	}
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface(surface, _x, _y);
	__channel_pos(surface);
}

function draw_surface_stretched_safe(surface, _x, _y, _w, _h) {
	gml_pragma("forceinline");
	
	if(is_struct(surface) && is_instanceof(surface, dynaSurf)) {
		surface.drawStretch(_x, _y, _w, _h);
		return;
	}
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_stretched(surface, _x, _y, _w, _h);
	__channel_pos(surface);
}

function draw_surface_ext_safe(surface, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
	gml_pragma("forceinline");
	
	if(is_struct(surface) && is_instanceof(surface, dynaSurf)) {
		surface.draw(_x, _y, _xs, _ys, _rot, _col, _alpha);
		return;
	}
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_ext(surface, _x, _y, _xs, _ys, _rot, _col, _alpha);
	__channel_pos(surface);
}

function draw_surface_tiled_safe(surface, _x, _y) {
	gml_pragma("forceinline");
	
	if(is_struct(surface) && is_instanceof(surface, dynaSurf)) {
		surface.drawTile(_x, _y);
		return;
	}
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_tiled(surface, _x, _y);
	__channel_pos(surface);
}

function draw_surface_tiled_ext_safe(surface, _x, _y, _xs = 1, _ys = 1, _col = c_white, _alpha = 1) {
	gml_pragma("forceinline");
	
	if(is_struct(surface) && is_instanceof(surface, dynaSurf)) {
		surface.drawTile(_x, _y, _xs, _ys, _col, _alpha);
		return;
	}
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_tiled_ext(surface, _x, _y, _xs, _ys, _col, _alpha);
	__channel_pos(surface);
}

function draw_surface_part_ext_safe(surface, _l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
	gml_pragma("forceinline");
	
	if(is_struct(surface) && is_instanceof(surface, dynaSurf)) {
		surface.drawPart(_l, _t, _w, _h, _x, _y, _xs, _ys, _rot, _col, _alpha);
		return;
	}
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_part_ext(surface, _l, _t, _w, _h, _x, _y, _xs, _ys, _col, _alpha);
	__channel_pos(surface);
}

#macro surface_free surface_free_safe
#macro __surface_free surface_free 

function surface_free_safe(surface) {
	gml_pragma("forceinline");
	
	if(!is_surface(surface)) return;
	__surface_free(surface);
}

function surface_save_safe(surface, path) {
	if(!is_surface(surface)) return;
	var f = surface_get_format(surface);
	
	if(f == surface_rgba8unorm) {
		surface_save(surface, path);
		return;
	}
	
	var w = surface_get_width_safe(surface);
	var h = surface_get_height_safe(surface);
	var s = surface_create(w, h, surface_rgba8unorm);
	
	switch(f) {
		case surface_rgba4unorm  :
		case surface_rgba8unorm	 :
		case surface_rgba16float :
		case surface_rgba32float :
			surface_set_shader(s, sh_draw_normal);
				draw_surface(surface, 0, 0);
			surface_reset_shader();
			surface_save(s, path);
			return;
		case surface_r8unorm	 : s = surface_create(w, h, surface_rgba8unorm);	break;
		case surface_r16float	 : s = surface_create(w, h, surface_rgba16float);	break;
		case surface_r32float	 : s = surface_create(w, h, surface_rgba32float);	break;
		default: return;
	}
	
	surface_set_shader(s, sh_draw_single_channel);
		draw_surface(surface, 0, 0);
	surface_reset_shader();
	
	surface_save(s, path);
	surface_free(s);
	return;
}

function surface_get_width_safe(s) {
	gml_pragma("forceinline");
	
	return (is_struct(s) && is_instanceof(s, dynaSurf))? s.getWidth() : surface_get_width(s);
}

function surface_get_height_safe(s) {
	gml_pragma("forceinline");
	
	return (is_struct(s) && is_instanceof(s, dynaSurf))? s.getHeight() : surface_get_height(s);
}

//check
function is_surface(s) {
	gml_pragma("forceinline");
	
	if(is_undefined(s)) return false;
	if(is_array(s)) return false;
	if(is_struct(s) && is_instanceof(s, dynaSurf)) return true;
	if(!is_real(s)) return false;
	if(!s) return false;
	if(!surface_exists(s)) return false;
	
	if(surface_get_width_safe(s) <= 0) return false;
	if(surface_get_height_safe(s) <= 0) return false;
	
	return true;
}

function surface_verify(surf, w, h, format = surface_rgba8unorm) {
	gml_pragma("forceinline");
	w = round(w);
	h = round(h);
	var s = is_surface(surf);
	
	if(!s) return surface_create_valid(w, h, format);
	return surface_size_to(surf, w, h, format, true);
}

//get
function surface_get_pixel(surface, _x, _y) {
	gml_pragma("forceinline");
	
	if(!is_surface(surface)) return;
	var f  = surface_get_format(surface);
	var px = surface_getpixel(surface, _x, _y);
	
	if(is_real(px)) return px;
	return round(px[0] * (255 * power(256, 0))) + round(px[1] * (255 * power(256, 1))) + round(px[2] * (255 * power(256, 2)));
}

function surface_get_pixel_ext(surface, _x, _y) {
	gml_pragma("forceinline");
	
	if(!is_surface(surface)) return;
	var px = surface_getpixel_ext(surface, _x, _y);
	
	if(is_real(px)) return px;
	return round(px[0] * (255 * power(256, 0))) + round(px[1] * (255 * power(256, 1))) + round(px[2] * (255 * power(256, 2))) + round(px[3] * (255 * power(256, 3)));
}

//create
function surface_create_empty(w, h, format = surface_rgba8unorm) {
	gml_pragma("forceinline");
	
	var s = surface_create(w, h, format);
	surface_clear(s);
	return s;
}

function surface_create_size(surface, format = surface_rgba8unorm) {
	gml_pragma("forceinline");
	
	return surface_create_valid(surface_get_width_safe(surface), surface_get_height_safe(surface), format);
}

function surface_create_valid(w, h, format = surface_rgba8unorm) {
	gml_pragma("forceinline");
	
	return surface_create_empty(surface_valid_size(w), surface_valid_size(h), format);
}

function surface_create_from_buffer(w, h, buff, format = surface_rgba8unorm) {
	gml_pragma("forceinline");
	
	if(buff < 0) return;
	var s = surface_create_valid(surface_valid_size(w), surface_valid_size(h), format);
	buffer_set_surface(buff, s, 0);
	return s;
}

function surface_from_buffer(buff) {
	static header_length = 24;
	if(!buffer_exists(buff)) return noone;
	
	buffer_seek(buff, buffer_seek_start, 0);
	var text = "";
	repeat(4) text += chr(buffer_read(buff, buffer_u8));
	if(text != "PXCS") return noone;
	
	var w = buffer_read(buff, buffer_u16);
	var h = buffer_read(buff, buffer_u16);
	var format = buffer_read(buff, buffer_u8);
	//print($"Creating surface from buffer {buff}: size {buffer_get_size(buff) - 4}: w = {w}, h = {h}");
	if(w < 1 || h < 1) return noone;
	
	var s = surface_create(w, h, format);
	buffer_set_surface(buff, s, header_length);
	return s;
}

function surface_create_from_sprite(spr) {
	if(!sprite_exists(spr)) return noone;
	
	if(sprite_get_number(spr) == 1)
		return surface_create_from_sprite_ext(spr, 0);
	
	var s = [];
	for( var i = 0; i < sprite_get_number(spr); i++ ) {
		array_push(s, surface_create_from_sprite_ext(spr, i));
	}
	
	return s;
}

function surface_create_from_sprite_ext(spr, ind, format = surface_rgba8unorm) {
	if(!sprite_exists(spr)) return noone;
	var sw = sprite_get_width(spr);
	var sh = sprite_get_height(spr);
	
	var s = surface_create_valid(sw, sh, format);
	surface_set_target(s);
		BLEND_OVERRIDE;
		DRAW_CLEAR
		draw_sprite(spr, ind, sprite_get_xoffset(spr), sprite_get_yoffset(spr));
		BLEND_NORMAL
	surface_reset_target();
	
	return s;
}

function surface_size_lim(surface, width, height) {
	var sw = surface_get_width_safe(surface);
	var sh = surface_get_height_safe(surface);
	if(sw <= width && sh <= height) return surface;
	
	var ss = min(width / sw, height / sh);
	var s  = surface_create(sw * ss, sh * ss);
	surface_set_target(s);
	DRAW_CLEAR;
	draw_surface_ext_safe(surface, 0, 0, ss, ss, 0, c_white, 1);
	surface_reset_target();
	return s;
}

function surface_size_to(surface, width, height, format = noone, skipCheck = false) {
	if(!skipCheck && !is_surface(surface)) return surface;
	if(width < 1 && height < 1) return surface;
	
	if(format != noone && format != surface_get_format(surface)) {
		surface_free(surface);
		return surface_create(width, height, format);
	}
	
	width  = surface_valid_size(width);
	height = surface_valid_size(height);
	
	var ww = surface_get_width_safe(surface);
	var hh = surface_get_height_safe(surface);
	
	if(ww == width && hh == height) return surface;
	//print($"Reset surface {ww}, {width} | {hh}, {height}");
	
	surface_resize(surface, width, height);
	surface_clear(surface);
	
	return surface;
}

function surface_clear(surface) {
	gml_pragma("forceinline");
	
	if(!is_surface(surface)) return;
	surface_set_target(surface);
		DRAW_CLEAR
	surface_reset_target();
}

function surface_copy_from(dst, src, format = noone) {
	gml_pragma("forceinline");
	
	surface_set_target(dst);
	DRAW_CLEAR
	BLEND_OVERRIDE;
		draw_surface_safe(src, 0, 0);
	BLEND_NORMAL
	surface_reset_target();
}

function surface_clone(surface, destination = noone, format = noone) {
	gml_pragma("forceinline");
	
	if(is_struct(surface) && is_instanceof(surface, dynaSurf)) 
		return surface.clone();
	if(!is_surface(surface)) return noone;
	
	destination = surface_verify(destination, surface_get_width_safe(surface), surface_get_height_safe(surface), format == noone? surface_get_format(surface) : format);
	
	surface_set_target(destination);
	DRAW_CLEAR
	BLEND_OVERRIDE;
		draw_surface_safe(surface, 0, 0);
	BLEND_NORMAL
	surface_reset_target();
	
	return destination;
}

//in-place modification
function surface_stretch(surf, _w, _h) {
	gml_pragma("forceinline");
	
	if(!is_surface(surf)) return noone;
	
	_w = surface_valid_size(_w);
	_h = surface_valid_size(_h);
	
	var _surf = surface_create(_w, _h);
	surface_set_target(_surf);
		DRAW_CLEAR
		draw_surface_stretched(surf, 0, 0, _w, _h);
	surface_reset_target();
	
	surface_free(surf);
	return _surf;
}

function surface_mirror(surf, _h, _v) {
	gml_pragma("forceinline");
	
	if(!is_surface(surf)) return noone;
	var _surf = surface_create_size(surf);
	
	surface_set_target(_surf);
		DRAW_CLEAR
		
		var x0 = _h * surface_get_width_safe(_surf);
		var y0 = _v * surface_get_height_safe(_surf);
		
		draw_surface_ext_safe(surf, x0, y0, _h * 2 - 1, _v * 2 - 1, 0, c_white, 1);
	surface_reset_target();
	surface_free(surf);
	
	return _surf;
}

//others
function surface_copy_size(dest, source, format = noone) {
	gml_pragma("forceinline");
	
	if(!is_surface(dest)) return;
	if(!is_surface(source)) return;
	
	surface_size_to(dest, surface_get_width_safe(source), surface_get_height_safe(source), format);
	surface_set_target(dest);
	DRAW_CLEAR
	surface_reset_target();
	
	surface_copy_from(dest, source);
}

function surface_valid_size(s) {
	gml_pragma("forceinline");
	
	if(is_infinity(s)) return 1;
	s = toNumber(s);
	if(!is_real(s)) return 1;
	return clamp(s, 1, 8196);
}

function surface_array_free(arr) {
	gml_pragma("forceinline");
	
	if(!is_array(arr)) {
		if(is_surface(arr)) surface_free(arr);
		return;
	}
	
	for( var i = 0, n = array_length(arr); i < n; i++ ) 
		surface_array_free(arr[i]);
}

function surface_array_clone(arr) {
	if(!is_array(arr)) {
		if(is_surface(arr)) 
			return surface_clone(arr);
		else
			return arr;
	}
	
	var _arr = [];
	
	for( var i = 0, n = array_length(arr); i < n; i++ ) 
		_arr[i] = surface_array_clone(arr[i]);
	
	return _arr;
}

function surface_array_serialize(arr) {
	gml_pragma("forceinline");
	
	var _arr = __surface_array_serialize(arr);
	return json_stringify(_arr);
}

function __surface_array_serialize(arr) {
	if(!is_array(arr)) {
		if(is_surface(arr)) {
			var buff = buffer_create(surface_get_width_safe(arr) * surface_get_height_safe(arr) * 4, buffer_fixed, 1);
			buffer_get_surface(buff, arr, 0);
			var comp = buffer_compress(buff, 0, buffer_get_size(buff));
			var enc  = buffer_base64_encode(comp, 0, buffer_get_size(comp));
			buffer_delete(buff);
			return { width: surface_get_width_safe(arr), height: surface_get_height_safe(arr), buffer: enc };
		} else
			return arr;
	}
	
	var _arr = [];
	
	for( var i = 0, n = array_length(arr); i < n; i++ ) 
		_arr[i] = __surface_array_serialize(arr[i]);
	
	return _arr;
}

function surface_array_deserialize(arr, index = -1) {
	gml_pragma("forceinline");
	
	var _arr = json_try_parse(arr);
	return index == -1? __surface_array_deserialize(_arr) : __surface_array_deserialize(_arr[index]);
}
	
function __surface_array_deserialize(arr) {
	if(!is_array(arr)) {
		if(!is_struct(arr) || !struct_has(arr, "buffer")) 
			return noone;
			
		var buff = buffer_base64_decode(arr.buffer);
		    buff = buffer_decompress(buff);
		return surface_create_from_buffer(arr.width, arr.height, buff);
	}
	
	var _arr = [];
	
	for( var i = 0, n = array_length(arr); i < n; i++ ) 
		_arr[i] = __surface_array_deserialize(arr[i]);
	
	return _arr;
}

function surface_encode(surface) {
	if(!is_surface(surface)) return "";
	
	var buff = buffer_create(surface_get_width_safe(surface) * surface_get_height_safe(surface) * 4, buffer_fixed, 1);
	buffer_get_surface(buff, surface, 0);
	var comp = buffer_compress(buff, 0, buffer_get_size(buff));
	var enc = buffer_base64_encode(comp, 0, buffer_get_size(comp));
	buffer_delete(buff);
	var str = { width: surface_get_width_safe(surface), height: surface_get_height_safe(surface), buffer: enc };
	return json_stringify(str);
}

function surface_decode(struct) {
	var buff = buffer_base64_decode(struct.buffer);
	var buff = buffer_decompress(buff);
	return surface_create_from_buffer(struct.width, struct.height, buff);
}

function surface_format_get_bytes(format) {
	switch(format) {
		case surface_rgba4unorm :  return 4 * 0.5; break;
		case surface_rgba8unorm :  return 4 * 1; break;
		case surface_rgba16float : return 4 * 2; break;
		case surface_rgba32float : return 4 * 4; break;
		
		case surface_r8unorm  : return 1 * 1; break;
		case surface_r16float : return 1 * 2; break;
		case surface_r32float : return 1 * 3; break;
	}
	return 1;
}

function surface_get_size(surface) {
	gml_pragma("forceinline");
	
	var sw = surface_get_width_safe(surface);
	var sh = surface_get_height_safe(surface);
	var sz = sw * sh * surface_format_get_bytes(surface_get_format(surface));
	return sz;
}

function surface_texture(surface) {
	gml_pragma("forceinline");
	
	if(!is_surface(surface)) return -1;
	return surface_get_texture(surface);
}
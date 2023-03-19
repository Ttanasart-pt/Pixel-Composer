//draw
function draw_surface_safe(surface, _x, _y) {
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface(surface, _x, _y);
	__channel_pos(surface);
}
function draw_surface_stretched_safe(surface, _x, _y, _w, _h) {
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_stretched(surface, _x, _y, _w, _h);
	__channel_pos(surface);
}
function draw_surface_ext_safe(surface, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_ext(surface, _x, _y, _xs, _ys, _rot, _col, _alpha);
	__channel_pos(surface);
}
function draw_surface_tiled_safe(surface, _x, _y) {
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_tiled(surface, _x, _y);
	__channel_pos(surface);
}
function draw_surface_tiled_ext_safe(surface, _x, _y, _xs = 1, _ys = 1, _col = c_white, _alpha = 1) {
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_tiled_ext(surface, _x, _y, _xs, _ys, _col, _alpha);
	__channel_pos(surface);
}
function draw_surface_part_ext_safe(surface, _l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
	if(!is_surface(surface)) return;
	
	__channel_pre(surface);
		draw_surface_part_ext(surface, _l, _t, _w, _h, _x, _y, _xs, _ys, _col, _alpha);
	__channel_pos(surface);
}

function surface_save_safe(surface, path) {
	if(!is_surface(surface)) return;
	var f = surface_get_format(surface);
	var w = surface_get_width(surface);
	var h = surface_get_height(surface);
	var s = noone;
	
	switch(f) {
		case surface_rgba4unorm  :
		case surface_rgba8unorm	 :
		case surface_rgba16float :
		case surface_rgba32float :
			surface_save(surface, path);
			return;
		case surface_r8unorm	 :
			s = surface_create(w, h, surface_rgba8unorm);
			break;
		case surface_r16float	 :
			s = surface_create(w, h, surface_rgba16float);
			break;
		case surface_r32float	 :
			s = surface_create(w, h, surface_rgba32float);
			break;
		default:
			return;
	}
	
	surface_set_target(s);
	shader_set(sh_draw_single_channel);
		DRAW_CLEAR
		BLEND_OVERRIDE
		draw_surface(s, 0, 0);
		BLEND_NORMAL
	shader_reset();
	surface_reset_target();
	
	surface_save(s, path);
	surface_free(s);
	return;
}

//check
gml_pragma("forceinline");
function is_surface(s) {
	if(is_undefined(s)) return false;
	if(is_array(s)) return false;
	if(!is_real(s)) return false;
	if(!s) return false;
	if(!surface_exists(s)) return false;
	
	if(surface_get_width(s) <= 0) return false;
	if(surface_get_height(s) <= 0) return false;
	
	return true;
}

gml_pragma("forceinline");
function surface_verify(surf, w, h, format = surface_rgba8unorm) {
	if(!is_surface(surf))
		return surface_create_valid(w, h, format);
	return surface_size_to(surf, w, h, format);
}

//create
function surface_create_size(surface, format = surface_rgba8unorm) {
	var s = surface_create_valid(surface_get_width(surface), surface_get_height(surface), format);
	surface_set_target(s);
	DRAW_CLEAR
	surface_reset_target();
	return s;
}

function surface_create_valid(w, h, format = surface_rgba8unorm) {
	var s = surface_create(surface_valid_size(w), surface_valid_size(h), format);
	surface_set_target(s);
	DRAW_CLEAR
	surface_reset_target();
	return s;
}

function surface_create_from_buffer(w, h, buff, format = surface_rgba8unorm) {
	var s = surface_create_valid(surface_valid_size(w), surface_valid_size(h), format);
	buffer_set_surface(buff, s, 0);
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

function surface_size_to(surface, width, height, format = noone) {
	if(!is_surface(surface))	return surface;
	if(width < 1 && height < 1) return surface;
	
	if(format != noone && surface_get_format(surface) != format) {
		surface_free(surface);
		return surface_create_valid(width, height, format);
	}
	
	width  = surface_valid_size(width);
	height = surface_valid_size(height);
	
	var ww = surface_get_width(surface);	
	var hh = surface_get_height(surface);	
	
	if(ww == width && hh == height) return surface;
	
	surface_resize(surface, width, height);
	return surface;
}

function surface_copy_from(dst, src, format = noone) {
	surface_set_target(dst);
	DRAW_CLEAR
	BLEND_OVERRIDE;
		draw_surface_safe(src, 0, 0);
	BLEND_NORMAL
	surface_reset_target();
}

function surface_clone(surface, source = noone, format = noone) {
	if(!is_surface(surface)) return noone;
	
	source = surface_verify(source, surface_get_width(surface), surface_get_height(surface), format == noone? surface_get_format(surface) : format);
	
	surface_set_target(source);
	DRAW_CLEAR
	BLEND_OVERRIDE;
		draw_surface_safe(surface, 0, 0);
	BLEND_NORMAL
	surface_reset_target();
	
	return source;
}

function surface_copy_size(dest, source, format = noone) {
	if(!is_surface(dest)) return;
	if(!is_surface(source)) return;
	
	surface_size_to(dest, surface_get_width(source), surface_get_height(source), format);
	surface_set_target(dest);
	DRAW_CLEAR
	surface_reset_target();
	
	surface_copy_from(dest, source);
}

function surface_valid_size(s) {
	if(is_infinity(s)) return 1;
	return max(1, s);	
}

function surface_array_free(arr) {
	if(!is_array(arr)) {
		if(is_surface(arr)) surface_free(arr);
		return;
	}
	
	for( var i = 0; i < array_length(arr); i++ ) 
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
	
	for( var i = 0; i < array_length(arr); i++ ) 
		_arr[i] = surface_array_clone(arr[i]);
	
	return _arr;
}

function surface_array_serialize(arr) {
	var _arr = __surface_array_serialize(arr);
	return json_stringify(_arr);
}

function __surface_array_serialize(arr) {
	if(!is_array(arr)) {
		if(is_surface(arr)) {
			var buff = buffer_create(surface_get_width(arr) * surface_get_height(arr) * 4, buffer_fixed, 1);
			buffer_get_surface(buff, arr, 0);
			var comp = buffer_compress(buff, 0, buffer_get_size(buff));
			var enc  = buffer_base64_encode(comp, 0, buffer_get_size(comp));
			buffer_delete(buff);
			return { width: surface_get_width(arr), height: surface_get_height(arr), buffer: enc };
		} else
			return arr;
	}
	
	var _arr = [];
	
	for( var i = 0; i < array_length(arr); i++ ) 
		_arr[i] = __surface_array_serialize(arr[i]);
	
	return _arr;
}

function surface_array_deserialize(arr, index = -1) {
	var _arr = json_try_parse(arr);
	return index == -1? __surface_array_deserialize(_arr) : __surface_array_deserialize(_arr[index]);
}
	
function __surface_array_deserialize(arr) {
	if(!is_array(arr)) {
		var buff = buffer_base64_decode(arr.buffer);
		    buff = buffer_decompress(buff);
		return surface_create_from_buffer(arr.width, arr.height, buff);
	}
	
	var _arr = [];
	
	for( var i = 0; i < array_length(arr); i++ ) 
		_arr[i] = __surface_array_deserialize(arr[i]);
	
	return _arr;
}

function surface_encode(surface) {
	if(!is_surface(surface)) return "";
	
	var buff = buffer_create(surface_get_width(surface) * surface_get_height(surface) * 4, buffer_fixed, 1);
	buffer_get_surface(buff, surface, 0);
	var comp = buffer_compress(buff, 0, buffer_get_size(buff));
	var enc = buffer_base64_encode(comp, 0, buffer_get_size(comp));
	buffer_delete(buff);
	var str = { width: surface_get_width(surface), height: surface_get_height(surface), buffer: enc };
	return json_stringify(str);
}

function surface_decode(struct) {
	var buff = buffer_base64_decode(struct.buffer);
	var buff = buffer_decompress(buff);
	return surface_create_from_buffer(struct.width, struct.height, buff);
}

function surface_bit_size(format) {
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
	var sw = surface_get_width(surface);
	var sh = surface_get_height(surface);
	var sz = sw * sh * surface_bit_size(surface_get_format(surface));
	return sz;
}
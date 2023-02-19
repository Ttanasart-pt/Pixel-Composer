//draw
function draw_surface_safe(surface, _x, _y) {
	if(!is_surface(surface)) return;
	draw_surface(surface, _x, _y);
}
function draw_surface_stretched_safe(surface, _x, _y, _w, _h) {
	if(!is_surface(surface)) return;
	draw_surface_stretched(surface, _x, _y, _w, _h);
}
function draw_surface_ext_safe(surface, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
	if(!is_surface(surface)) return;
	draw_surface_ext(surface, _x, _y, _xs, _ys, _rot, _col, _alpha);
}
function draw_surface_tiled_ext_safe(surface, _x, _y, _xs = 1, _ys = 1, _col = c_white, _alpha = 1) {
	if(!is_surface(surface)) return;
	draw_surface_tiled_ext(surface, _x, _y, _xs, _ys, _col, _alpha);
}
function draw_surface_part_ext_safe(surface, _l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
	if(!is_surface(surface)) return;
	draw_surface_part_ext(surface, _l, _t, _w, _h, _x, _y, _xs, _ys, _col, _alpha);
}

//check
function is_surface(s) {
	if(is_array(s)) return false;
	if(!is_real(s)) return false;
	if(!s) return false;
	if(!surface_exists(s)) return false;
	
	if(surface_get_width(s) <= 0) return false;
	if(surface_get_height(s) <= 0) return false;
	
	return true;
}

function surface_verify(surf, w, h) {
	if(!is_surface(surf))
		return surface_create_valid(w, h);
	surface_size_to(surf, w, h);
	return surf;
}

//create
function surface_create_size(surface) {
	var s = surface_create_valid(surface_get_width(surface), surface_get_height(surface));
	surface_set_target(s);
	draw_clear_alpha(0, 0);
	surface_reset_target();
	return s;
}

function surface_create_valid(w, h) {
	var s = surface_create(surface_valid_size(w), surface_valid_size(h));
	surface_set_target(s);
	draw_clear_alpha(0, 0);
	surface_reset_target();
	return s;
}

function surface_create_from_buffer(w, h, buff) {
	var s = surface_create_valid(surface_valid_size(w), surface_valid_size(h));
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

function surface_create_from_sprite_ext(spr, ind) {
	if(!sprite_exists(spr)) return noone;
	var sw = sprite_get_width(spr);
	var sh = sprite_get_height(spr);
	
	var s = surface_create_valid(sw, sh);
	surface_set_target(s);
		BLEND_OVERRIDE;
		draw_clear_alpha(0, 0);
		draw_sprite(spr, ind, sprite_get_xoffset(spr), sprite_get_yoffset(spr));
		BLEND_NORMAL
	surface_reset_target();
	
	return s;
}

function surface_size_to(surface, width, height) {
	if(!is_surface(surface)) return false;
	if(width < 1 && height < 1) return false;
	
	width = surface_valid_size(width);
	height = surface_valid_size(height);
	
	var ww = surface_get_width(surface);	
	var hh = surface_get_height(surface);	
	
	if(ww == width && hh == height) return false;
	
	surface_resize(surface, width, height);
	return true;
}

function surface_copy_from(dst, src) {
	surface_set_target(dst);
	draw_clear_alpha(0, 0);
	BLEND_OVERRIDE;
		draw_surface_safe(src, 0, 0);
	BLEND_NORMAL
	surface_reset_target();
}

function surface_clone(surface, source = noone) {
	if(!is_surface(surface)) return noone;
	
	source = surface_verify(source, surface_get_width(surface), surface_get_height(surface));
	
	surface_set_target(source);
	draw_clear_alpha(0, 0);
	BLEND_OVERRIDE;
		draw_surface_safe(surface, 0, 0);
	BLEND_NORMAL
	surface_reset_target();
	
	return source;
}

function surface_copy_size(dest, source) {
	if(!is_surface(dest)) return;
	if(!is_surface(source)) return;
	
	surface_size_to(dest, surface_get_width(source), surface_get_height(source));
	surface_set_target(dest);
	draw_clear_alpha(0, 0);
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
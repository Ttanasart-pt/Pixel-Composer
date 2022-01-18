function draw_surface_safe(surface, _x, _y) {
	if(is_surface(surface)) draw_surface(surface, _x, _y);
}
function draw_surface_ext_safe(surface, _x, _y, _xs, _ys, _rot, _col, _alpha) {
	if(is_surface(surface)) draw_surface_ext(surface, _x, _y, _xs, _ys, _rot, _col, _alpha);
}
function draw_surface_tiled_ext_safe(surface, _x, _y, _xs, _ys, _col, _alpha) {
	if(is_surface(surface)) draw_surface_tiled_ext(surface, _x, _y, _xs, _ys, _col, _alpha);
}

function surface_size_to(surface, width, height) {
	if(width <= 1 || height <= 1) return false;
	if(is_infinity(width) || is_infinity(height)) return false;
	
	if(!surface_exists(surface)) return false;
	
	var ww = surface_get_width(surface);	
	var hh = surface_get_height(surface);	
	
	if(ww != width || hh != height) {
		surface_resize(surface, width, height);
		return true;
	}
	
	return false;
}

function surface_clone(surface) {
	var s = surface_create(surface_get_width(surface), surface_get_height(surface));
	surface_set_target(s);
	draw_clear_alpha(0, 0);
	surface_reset_target();
	surface_copy(s, 0, 0, surface);
	
	return s;
}

function surface_copy_size(dest, source) {
	surface_size_to(dest, surface_get_width(source), surface_get_height(source));
	surface_set_target(dest);
	draw_clear_alpha(0, 0);
	surface_reset_target();
	surface_copy(dest, 0, 0, source);
}

function surface_valid(s) {
	if(is_infinity(s)) return 1;
	return max(1, s);	
}

function is_surface(s) {
	if(is_array(s)) return false;
	if(!s) return false;
	if(!surface_exists(s)) return false;
	
	if(surface_get_width(s) <= 0) return false;
	if(surface_get_height(s) <= 0) return false;
	
	return true;
}
function get_point_from_dist(distMap, attempt = 4) {
	if(!is_surface(distMap)) return noone;
	
	var w = surface_get_width(distMap);
	var h = surface_get_height(distMap);
	var v = 0;
	var res = noone;
	
	repeat(attempt) {
		var _x = irandom(w - 1);
		var _y = irandom(h - 1);
		
		var p = surface_getpixel(distMap, _x, _y);
		var r = color_get_red(p);
		
		if(r > v) {
			v = r;	
			res = [_x / w, _y / h];
		}
	}
	
	return res;
}

function get_points_from_dist(distMap, amount, seed = 0, attempt = 8) {
	if(amount < 1) return [];
	if(!is_surface(distMap)) return [];
	
	var surf = surface_create_valid(amount, 1);
	
	surface_set_target(surf);
	draw_clear_alpha(0, 0);
	BLEND_OVERRIDE;
		shader_set(sh_sample_points);
		shader_set_uniform_f(shader_get_uniform(sh_sample_points, "dimension"), 
			surface_get_width(distMap) / amount, surface_get_height(distMap));
		shader_set_uniform_i(shader_get_uniform(sh_sample_points, "attempt"), attempt);
		shader_set_uniform_f(shader_get_uniform(sh_sample_points, "seed"), seed);
		
			draw_surface_stretched(distMap, 0, 0, amount, 1);
		shader_reset();
	BLEND_NORMAL;
	surface_reset_target();
	
	var b = buffer_create(amount * 4, buffer_fixed, 4);
	buffer_get_surface(b, surf, 0);
	buffer_seek(b, buffer_seek_start, 0);
	
	var pos = array_create(amount);
	var w = surface_get_width(distMap);
	var h = surface_get_height(distMap);
	
	for( var i = 0; i < amount; i++ ) {
		var cc = buffer_read(b, buffer_u32);
		if(cc == 0) pos[i] = 0;
		else {
			var _x = color_get_red(cc) / 255;
			var _y = color_get_green(cc) / 255;
			var _v = color_get_blue(cc) / 255;
			pos[i] = [_x, _y, _v];
		}
	}
	
	buffer_delete(b);
	surface_free(surf);
	
	return pos;
}
function get_point_from_dist(distMap, attempt = 4) {
	if(!is_surface(distMap)) return noone;
	
	var w = surface_get_width_safe(distMap);
	var h = surface_get_height_safe(distMap);
	var v = 0;
	var res = noone;
	
	repeat(attempt) {
		var _x = irandom(w - 1);
		var _y = irandom(h - 1);
		
		var p = surface_get_pixel(distMap, _x, _y);
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
	
	//print($"===== Get points from dist {amount} =====");
	
	if(!struct_has(self, "__dist_surf"))
		__dist_surf = surface_create_valid(amount, 1);
	else 
		__dist_surf = surface_verify(__dist_surf, amount, 1);
	
	var _sw = surface_get_width_safe(distMap);
	var _sh = surface_get_height_safe(distMap);
	
	surface_set_shader(__dist_surf, sh_sample_points);
		shader_set_f("dimension", _sw / amount, _sh);
		shader_set_i("attempt",   attempt);
		shader_set_f("seed",      seed);
		
		draw_surface_stretched_safe(distMap, 0, 0, amount, 1);
	surface_reset_shader();
	
	var b = buffer_create(amount * 4, buffer_fixed, 4);
	buffer_get_surface(b, __dist_surf, 0);
	buffer_seek(b, buffer_seek_start, 0);
	
	var pos = array_create(amount);
	
	for( var i = 0; i < amount; i++ ) {
		//print($"    Reading buffer {i}");
		var cc = buffer_read(b, buffer_u32);
		
		if(cc == 0) pos[i] = 0;
		else {
			var _x = _color_get_red(cc);
			var _y = _color_get_green(cc);
			var _v = _color_get_blue(cc);
			pos[i] = [_x, _y, _v];
		}
	}
	
	buffer_delete(b);
	
	return pos;
}
function vct_slider(pressing, spr, sx, sy, ex, ey, val) {
	var _s = sprite_scale;
	
	var _val	= val.get();
	var min_val = val.disp_data[0];
	var max_val = val.disp_data[1];
	var _step   = val.disp_data[2];
	
	var prog = clamp((_val - min_val) / (max_val - min_val), 0, 1);
	var _sx  = lerp(sx, ex, prog);
	var _sy  = lerp(sy, ey, prog);
	
	var pres = pressing;
	
	var bw = sprite_get_width(spr);
	var bh = sprite_get_height(spr);
			
	var ox = sprite_get_xoffset(spr);
	var oy = sprite_get_yoffset(spr);
	
	_sx -= (bw / 2 - ox) * _s;
	_sy -= (bh / 2 - oy) * _s;
	
	var _x0 = _sx - ox * _s;
	var _y0 = _sy - oy * _s;
	var _x1 = _x0 + bw * _s;
	var _y1 = _y0 + bh * _s;
	
	draw_sprite_ext(spr, pressing, _sx, _sy, _s, _s, 0, c_white, 1);
	
	if(pressing) {
		var _v = dot_product(ex - sx, ey - sy, mx - sx, my - sy) / (point_distance(sx, sy, ex, ey) * point_distance(sx, sy, ex, ey));
		_v = lerp(min_val, max_val, clamp(_v, 0, 1));
		_v = round(_v / _step) * _step;
		val.set(_v);
		
		if(mouse_release(mb_left))
			pres = false;
	} else {
		if(pHOVER && point_in_rectangle(mx, my, _x0, _y0, _x1, _y1)) {
			draw_sprite_ext_add(spr, 0, _sx, _sy, _s, _s, 0, c_white, 0.4);
			
			if(mouse_press(mb_left, pFOCUS))
				pres = true;
		}
	}
	
	return pres;
}
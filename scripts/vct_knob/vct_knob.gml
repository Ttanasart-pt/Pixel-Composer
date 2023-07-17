function vct_knob(pressing, spr, sx, sy, val, angle_min = -135, angle_max = 135, inv = true) {
	var _s = sprite_scale;
	
	var _val	= val.get();
	var min_val = val.disp_data[0];
	var max_val = val.disp_data[1];
	var _step   = val.disp_data[2];
	
	var prog = clamp((_val - min_val) / (max_val - min_val), 0, 1); 
	var ind  = prog * (sprite_get_number(spr) - 1);
	
	var _sx  = sx;
	var _sy  = sy;
	
	var pres = pressing;
	
	var bw = sprite_get_width(spr);
	var bh = sprite_get_height(spr);
			
	var ox = sprite_get_xoffset(spr);
	var oy = sprite_get_yoffset(spr);
	
	var _x0 = _sx - ox * _s;
	var _y0 = _sy - oy * _s;
	var _x1 = _x0 + bw * _s;
	var _y1 = _y0 + bh * _s;
	
	draw_sprite_ext(spr, ind, _sx, _sy, _s, _s, 0, c_white, 1);
	
	if(pressing) {
		var _v = point_direction(_sx, _sy, mx, my) - 90;
		if(_v > 180) _v = _v - 360;
		if(inv)      _v *= -1;
		
		_v = (clamp(_v, angle_min, angle_max) - angle_min) / (angle_max - angle_min);
		_v = lerp(min_val, max_val, clamp(_v, 0, 1));
		_v = round(_v / _step) * _step;
		val.set(_v);
		
		if(mouse_release(mb_left))
			pres = false;
	} else {
		if(pHOVER && point_in_circle(mx, my, sx, sy, bw / 2 * _s)) {
			draw_sprite_ext_add(spr, ind, _sx, _sy, _s, _s, 0, c_white, 0.4);
			
			if(mouse_press(mb_left, pFOCUS))
				pres = true;
		}
	}
	
	return pres;
}
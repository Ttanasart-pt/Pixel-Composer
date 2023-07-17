function vct_toggle(spr, sx, sy, val) {
	var _s = sprite_scale;
	
	var _val = val.get();
	
	var bw = sprite_get_width(spr);
	var bh = sprite_get_height(spr);
			
	var ox = sprite_get_xoffset(spr);
	var oy = sprite_get_yoffset(spr);
	
	var _x0 =  sx - ox * _s;
	var _y0 =  sy - oy * _s;
	var _x1 = _x0 + bw * _s;
	var _y1 = _y0 + bh * _s;
	
	draw_sprite_ext(spr, _val, sx, sy, _s, _s, 0, c_white, 1);
	
	if(pHOVER && point_in_rectangle(mx, my, _x0, _y0, _x1, _y1)) {
		draw_sprite_ext_add(spr, _val, sx, sy, _s, _s, 0, c_white, 0.4);
			
		if(mouse_press(mb_left, pFOCUS))
			val.set(!_val);
	}
}
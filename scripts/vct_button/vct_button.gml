function vct_button(bx, by, press, sprs, ind = 0, icon = noone, icon_ind = 0, icon_drop = [-2, 0]) {
	var _s = sprite_scale;
	
	var hover    = false;
	var useIndex = !is_array(sprs);
	
	var ss = useIndex? sprs : sprs[0];
	var bw = sprite_get_width(ss);
	var bh = sprite_get_height(ss);
			
	var ox = sprite_get_xoffset(ss);
	var oy = sprite_get_yoffset(ss);
	
	var _x0 = bx - ox * _s;
	var _y0 = by - oy * _s;
	var _x1 = _x0 + bw * _s;
	var _y1 = _y0 + bh * _s;
	
	var res = false;
	var pes = false;
	
	if(pHOVER && point_in_rectangle(mx, my, _x0, _y0, _x1 - 1, _y1)) {
		hover = true;
		if(mouse_press(mb_left, pFOCUS))
			res = true;
				
		if(mouse_click(mb_left, pFOCUS)) {
			if(press)
				res = true;
			pes = true;
			if(useIndex)	ind = 1;
			else			ss = sprs[1];
		}
	}
			
	draw_sprite_ext(ss, ind, bx, by, _s, _s, 0, c_white, 1);
	if(hover) draw_sprite_ext_add(ss, ind, bx, by, _s, _s, 0, c_white, 0.4);
	
	if(icon) draw_sprite_ext(icon, icon_ind, (_x0 + _x1) / _s, (_y0 + _y1) / _s + icon_drop[pes], _s, _s, 0, c_white, 1);
		
	return res;
}
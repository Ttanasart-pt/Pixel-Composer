function vct_button(bx, by, sprs, ind = 0, icon = noone, icon_ind = 0, icon_drop = [-2, 0]) {
	var hover    = false;
	var useIndex = !is_array(sprs);
	
	var ss = useIndex? sprs : sprs[0];
	var bw = sprite_get_width(ss);
	var bh = sprite_get_height(ss);
			
	var ox = sprite_get_xoffset(ss);
	var oy = sprite_get_yoffset(ss);
	
	var _x0 = bx - ox * 2;
	var _y0 = by - oy * 2;
	var _x1 = _x0 + bw * 2;
	var _y1 = _y0 + bh * 2;
	
	var res = false;
	var pes = false;
	
	if(pHOVER && point_in_rectangle(mx, my, _x0, _y0, _x1 - 1, _y1)) {
		hover = true;
		if(mouse_press(mb_left, pFOCUS))
			res = true;
				
		if(mouse_click(mb_left, pFOCUS)) {
			pes = true;
			if(useIndex)	ind = 1;
			else			ss = sprs[1];
		}
	}
			
	draw_sprite_ext(ss, ind, bx, by, 2, 2, 0, c_white, 1);
	if(hover) draw_sprite_ext_add(ss, ind, bx, by, 2, 2, 0, c_white, 0.4);
	
	if(icon) draw_sprite_ext(icon, icon_ind, (_x0 + _x1) / 2, (_y0 + _y1) / 2 + icon_drop[pes], 2, 2, 0, c_white, 1);
		
	return res;
}
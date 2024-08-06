/// @description 
#region base
	var pal = DEF_PALETTE;
	var col = min(array_length(pal), 8);
	var row = ceil(array_length(pal) / col);
	
	var ss  = ui(24);
	var ww  = ui(16) + ss * col;
	var hh  = ui(16) + ss * row;
	
	var x0  = min(x, WIN_W - ww);
	var y0  = min(y, WIN_H - hh);
	
	var x1  = x0 + ww;
	var y1  = y0 + hh;
	
	draw_sprite_stretched(THEME.dialog, 0, x0 - ui(8), y0 - ui(8), ww + ui(8) * 2, hh + ui(8) * 2);
	
	for( var i = 0, n = array_length(pal); i < n; i++ ) {
		var r = floor(i / col);
		var c = i % col;
		
		var _x = x0 + ui(8) + c * ss;
		var _y = y0 + ui(8) + r * ss;
		
		draw_set_color(pal[i]);
		draw_rectangle(_x + 2, _y + 2, _x + ss - 2, _y + ss - 2, false);
		
		if(point_in_rectangle(mouse_mx, mouse_my, _x, _y, _x + ss - 1, _y + ss - 1)) {
			draw_set_color(c_white);
			draw_rectangle_border(_x + 2, _y + 2, _x + ss - 2, _y + ss - 2, 2);
			
			if(selecting != i) {
				if(onApply) onApply(pal[i]);
			}
			selecting = i;
		}
	}
	
	if(mouse_release(mb_left))
		instance_destroy();
#endregion
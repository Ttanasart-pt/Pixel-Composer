function draw_line_feedback(x0, y0, x1, y1, th, c1, c0, _s) { #region
	var _y0 = y0 - 12 * _s;
	var _y1 = y1 - 12 * _s;
	
	draw_line_dashed_color(x0, _y0, x1, _y1, th, c1, c0, 6 * _s);
	
	var cr = 12 / 2 * _s;
	var cx = max(x0, x1);
	var cy = (cx == x0? y0 : y1) - cr;
	var ox, oy, nx, ny;
	
	draw_set_color(c0);
	
	for( var i = 0; i <= 1; i += 0.1 ) {
		var a = lerp(-90, 90, i);
		
		nx = cx + lengthdir_x(cr, a);
		ny = cy + lengthdir_y(cr, a);
		
		if(i > 0) draw_line_width(ox, oy, nx, ny, th);
		
		ox = nx;
		oy = ny;
	}
	
	var cx = min(x0, x1);
	var cy = (cx == x0? y0 : y1) - cr;
	
	draw_set_color(c1);
	
	for( var i = 0; i <= 1; i += 0.1 ) {
		var a = lerp(90, 270, i);
		
		nx = cx + lengthdir_x(cr, a);
		ny = cy + lengthdir_y(cr, a);
		
		if(i > 0) draw_line_width(ox, oy, nx, ny, th);
		
		ox = nx;
		oy = ny;
	}
} #endregion

function distance_line_feedback(mx, my, x0, y0, x1, y1, _s) { #region
	var _y0 = y0 - 12 * _s;
	var _y1 = y1 - 12 * _s;
	
	var dd = 99999999;
	
	dd = min(dd, distance_to_line(mx, my, x0, _y0, x1, _y1));
	
	return dd;
} #endregion
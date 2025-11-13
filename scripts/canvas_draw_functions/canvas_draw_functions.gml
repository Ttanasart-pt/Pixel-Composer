global.canvas_brush_surface = undefined;

function canvas_draw_line(_x0, _y0, _x1, _y1, _th = 1) {
	if(_th < global.FIX_POINTS_AMOUNT) {
		if(_x1 > _x0) _x0--;
		if(_x1 < _x0) _x1--;
		
		if(_y1 > _y0) _y0--;
		if(_y1 < _y0) _y1--;
	}
		
	if(_th == 1) {
		draw_line(_x0, _y0, _x1, _y1);
			
	} else if(_th < global.FIX_POINTS_AMOUNT) { 
			
		var fx = global.FIX_POINTS[_th];
		for( var i = 0, n = array_length(fx); i < n; i++ )
			draw_line(_x0 + fx[i][0], _y0 + fx[i][1], _x1 + fx[i][0], _y1 + fx[i][1]);	
				
	} else
		draw_line_width(_x0, _y0, _x1, _y1, _th);
}

function canvas_draw_triangle(x1, y1, x2, y2, x3, y3, outline = false) { 
	INLINE 
	draw_triangle(round(x1), round(y1), round(x2), round(y2), round(x3), round(y3), outline); 
}
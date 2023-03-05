function draw_line_zigzag_color(x0, y0, x1, y1, _s = 1, thick = 1, col1 = c_white, col2 = c_white, type = LINE_STYLE.solid) {
	if(x0 - x1) {
		var xx0 = x0 + 16 * _s;
		var xx1 = x1 - 16 * _s;
		var yy0 = y0 +  8 * _s * sign(y1 - y0);
		var yy1 = y1 -  8 * _s * sign(y1 - y0);
		
		draw_line_round_color(x0, y0, xx0, yy0, thick, col1, col1);
		draw_line_round_color(x1, y1, xx1, yy1, thick, col2, col2);
		
		if(type == LINE_STYLE.solid)
			draw_line_round_color(xx0, yy0, xx1, yy1, thick, col1, col2);
		else 
			draw_line_dashed_color(xx0, yy0, xx1, yy1, thick, col1, col2, 12);
	} else {
		if(type == LINE_STYLE.solid)
			draw_line_round_color(x0, y0, x1, y1, thick, col1, col2);
		else 
			draw_line_dashed_color(x0, y0, x1, y1, thick, col1, col2, 12);
	}
}

function distance_to_zigzag(mx, my, x0, y0, x1, y1, _s) {
	var inv = x1 - 16 * _s <= x0 + 16 * _s;
	if(inv) {
		var dist =	     distance_to_line(mx, my, x0, y0, x0, cy);
		dist = min(dist, distance_to_line(mx, my, x0, cy, x1, cy));
		dist = min(dist, distance_to_line(mx, my, x1, cy, x1, y1));
	
		return dist;
	} else {
		var dist =		 distance_to_line(mx, my, cx, y0, cx, y1);
		dist = min(dist, distance_to_line(mx, my, x0, y0, cx, y0));
		dist = min(dist, distance_to_line(mx, my, cx, y1, x1, y1));
	
		return dist;
	}
}
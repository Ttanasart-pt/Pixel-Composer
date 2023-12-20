function draw_line_feedback(x0, y0, x1, y1, th, c1, c0, _s) { #region
	draw_line_dashed_color(x0, y0, x1, y1, th, c1, c0, 6 * _s);
	return;
	
	var _y0 = y0 - 12 * _s;
	var _y1 = y1 - 12 * _s;
	
	var x0e = x0 + 12 * _s * sign(x0 - x1);
	var x1e = x1 - 12 * _s * sign(x0 - x1);
	
	draw_line_dashed_color(x0e, y0, x0e, _y0, th, c0, c0, 6 * _s);
	draw_line_dashed_color(x0,  y0, x0e,  y0, th, c0, c0, 6 * _s);
	
	draw_line_dashed_color(x0e, _y0, x1e, _y1, th, c1, c0, 6 * _s);
	
	draw_line_dashed_color(x1e, y1, x1e, _y1, th, c1, c1, 6 * _s);
	draw_line_dashed_color(x1e, y1, x1,   y1, th, c1, c1, 6 * _s);
} #endregion

function distance_line_feedback(mx, my, x0, y0, x1, y1) { #region
	return distance_to_line(mx, my, x0, y0, x1, y1);
} #endregion
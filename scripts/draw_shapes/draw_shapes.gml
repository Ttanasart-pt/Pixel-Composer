function draw_rectangle_width(x0, y0, x1, y1, th = 1) {
	draw_line_width(x0 - th / 2, y0, x1 + th / 2, y0, th);
	draw_line_width(x0 - th / 2, y1, x1 + th / 2, y1, th);
	
	draw_line_width(x0, y0 - th / 2, x0, y1 + th / 2, th);
	draw_line_width(x1, y0 - th / 2, x1, y1 + th / 2, th);
}

function draw_rectangle_dashed(x0, y0, x1, y1, th = 1, dash = 8, shift = 0) {
	draw_line_dashed(x0 - th / 2, y0, x1 + th / 2, y0, th, dash, shift);
	draw_line_dashed(x0 - th / 2, y1, x1 + th / 2, y1, th, dash, shift);
	
	draw_line_dashed(x0, y0 - th / 2, x0, y1 + th / 2, th, dash, shift);
	draw_line_dashed(x1, y0 - th / 2, x1, y1 + th / 2, th, dash, shift);
}

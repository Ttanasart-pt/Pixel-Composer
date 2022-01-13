function draw_line_round(x1, y1, x2, y2, w) {
	draw_line_width(x1, y1, x2, y2, w);

	draw_circle(x1, y1, w/2, false);
	draw_circle(x2, y2, w/2, false);
}
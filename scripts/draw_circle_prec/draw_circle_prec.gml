function draw_circle_prec(x, y, r, border, precision = 32) {
	draw_set_circle_precision(precision);
	draw_circle(x, y, r, border);
}
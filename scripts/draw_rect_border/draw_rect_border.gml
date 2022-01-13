function draw_rectangle_border(x1, y1, x2, y2, thick) {
	draw_line_width(x1 - thick / 2, y1, x2 + thick / 2, y1, thick);
	draw_line_width(x1 - thick / 2, y2, x2 + thick / 2, y2, thick);
	draw_line_width(x1, y1 - thick / 2, x1, y2 + thick / 2, thick);
	draw_line_width(x2, y1 - thick / 2, x2, y2 + thick / 2, thick);
}
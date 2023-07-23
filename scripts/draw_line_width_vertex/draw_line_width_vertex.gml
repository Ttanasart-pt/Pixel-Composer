function draw_line_width_vertex(xs, ys, xe, ye, thick, c0, c1) {
	draw_primitive_begin(pr_trianglestrip);

	// Calculate the direction and perpendicular vector of the line
	var dx = xe - xs;
	var dy = ye - ys;
	var line_length = point_distance(xs, ys, xe, ye);
	var px = -dy / line_length * thick / 2;
	var py = dx / line_length * thick / 2;
	
	// Calculate vertices of the rectangle
	var x0 = xs + px;
	var y0 = ys + py;
	var x1 = xs - px;
	var y1 = ys - py;
	var x2 = xe + px;
	var y2 = ye + py;
	var x3 = xe - px;
	var y3 = ye - py;

	// Draw vertices
	draw_vertex_color(x0, y0, c0, 1);
	draw_vertex_color(x1, y1, c0, 1);
	draw_vertex_color(x2, y2, c1, 1);
	draw_vertex_color(x3, y3, c1, 1);

	draw_primitive_end();
}

function draw_line_width2(x0, y0, x1, y1, w0, w1, cap = false) {
	var aa = point_direction(x0, y0, x1, y1) + 90;
	var _x0 = x0 + lengthdir_x(w0 / 2, aa);
	var _y0 = y0 + lengthdir_y(w0 / 2, aa);
	var _x1 = x0 + lengthdir_x(w0 / 2, aa + 180);
	var _y1 = y0 + lengthdir_y(w0 / 2, aa + 180);
	var _x2 = x1 + lengthdir_x(w1 / 2, aa);
	var _y2 = y1 + lengthdir_y(w1 / 2, aa);
	var _x3 = x1 + lengthdir_x(w1 / 2, aa + 180);
	var _y3 = y1 + lengthdir_y(w1 / 2, aa + 180);
					
	draw_primitive_begin(pr_trianglestrip);
		draw_vertex(round(_x0), round(_y0));
		draw_vertex(round(_x1), round(_y1));
		draw_vertex(round(_x2), round(_y2));
		draw_vertex(round(_x3), round(_y3));
	draw_primitive_end();
	
	if(cap && w0 / 2 - 1 > 0) {
		//draw_set_color(c_red);
		draw_circle(round(x0) - 1, round(y0) - 1, w0 / 2 - 1, 0);
		draw_circle(round(x1) - 1, round(y1) - 1, w1 / 2 - 1, 0);
	}
}

function draw_line_width2_angle(x0, y0, x1, y1, w0, w1, a0 = 0, a1 = 0) {
	var _x0 = x0 + lengthdir_x(w0 / 2, a0);
	var _y0 = y0 + lengthdir_y(w0 / 2, a0);
	var _x1 = x1 + lengthdir_x(w1 / 2, a1);
	var _y1 = y1 + lengthdir_y(w1 / 2, a1);
	
	draw_primitive_begin(pr_trianglestrip);
		draw_vertex(round(x0), round(y0));
		draw_vertex(round(x1), round(y1));
		draw_vertex(round(_x0), round(_y0));
		draw_vertex(round(_x1), round(_y1));
	draw_primitive_end();
	
	var _x0 = x0 + lengthdir_x(w0 / 2, a0 + 180);
	var _y0 = y0 + lengthdir_y(w0 / 2, a0 + 180);
	var _x1 = x1 + lengthdir_x(w1 / 2, a1 + 180);
	var _y1 = y1 + lengthdir_y(w1 / 2, a1 + 180);
	
	draw_primitive_begin(pr_trianglestrip);
		draw_vertex(round(x0), round(y0));
		draw_vertex(round(x1), round(y1));
		draw_vertex(round(_x0), round(_y0));
		draw_vertex(round(_x1), round(_y1));
	draw_primitive_end();
}
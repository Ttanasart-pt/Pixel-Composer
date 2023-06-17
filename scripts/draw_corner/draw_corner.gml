function draw_corner(x1, y1, xc, yc, x3, y3, thick = 1, col = c_white, sample = 10) {
	var dir0 = point_direction(x1, y1, xc, yc);
	var dir1 = point_direction(x3, y3, xc, yc);
	
	var p2 = point_rotate(xc, yc, x1, y1, -90);
	var x2 = p2[0];
	var y2 = p2[1];
	
	var p4 = point_rotate(xc, yc, x3, y3, 90);
	var x4 = p4[0];
	var y4 = p4[1];
	
	//draw_circle_prec(x1, y1, 3, false);
	//draw_circle_prec(xc, yc, 3, false);
	//draw_circle_prec(x3, y3, 3, false);
	
	var ra = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	if(ra == 0) return;
	
	var px = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ra;
	var py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ra;
	
	var r  = point_distance(px, py, x1, y1);
	var d0 = point_direction(px, py, x1, y1);
	var d1 = point_direction(px, py, x3, y3);
		
	draw_set_color(col);
	var ox, oy, nx, ny;
	var st = 1 / round(sample);
	for( var i = 0; i <= 1; i += st ) {
		var a = d0 + angle_difference(d1, d0) * i;
		nx = px + lengthdir_x(r, a);
		ny = py + lengthdir_y(r, a);
		
		if(i > 0) draw_line_round(ox, oy, nx, ny, thick);
		
		ox = nx;
		oy = ny;
	}
}
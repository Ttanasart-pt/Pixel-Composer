function draw_line_dashed(x0, y0, x1, y1, th = 1, dash_distance = 8) {
	var dis = point_distance(x0, y0, x1, y1);
	var dir = point_direction(x0, y0, x1, y1);
	var part = ceil(dis / dash_distance);
	
	var dx = lengthdir_x(1, dir);
	var dy = lengthdir_y(1, dir);
	
	var ox, oy, nx, ny;
	var dd = 0;
	
	for( var i = 0; i <= part; i++ ) {
		dd = min(dis, i * dash_distance);
		nx = x0 + dx * dd;
		ny = y0 + dy * dd;
		
		if(i && i % 2)
			draw_line_width(ox, oy, nx, ny, th);
		
		ox = nx;
		oy = ny;
	}
}

function draw_line_dashed_color(x0, y0, x1, y1, th, c0, c1, dash_distance = 8) {
	var dis = point_distance(x0, y0, x1, y1);
	var dir = point_direction(x0, y0, x1, y1);
	var part = ceil(dis / dash_distance);
	
	var dx = lengthdir_x(1, dir);
	var dy = lengthdir_y(1, dir);
	
	var ox, oy, nx, ny, oc, nc;
	var dd = 0;
	
	for( var i = 0; i <= part; i++ ) {
		dd = min(dis, i * dash_distance);
		nx = x0 + dx * dd;
		ny = y0 + dy * dd;
		nc = merge_color(c0, c1, i / part);
		
		if(i && i % 2) {
			draw_line_width_color(ox, oy, nx, ny, th, oc, nc);
		}
		
		oc = nc;
		ox = nx;
		oy = ny;
	}
}
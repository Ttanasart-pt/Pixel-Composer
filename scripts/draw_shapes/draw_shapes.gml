function draw_rectangle_width(x0, y0, x1, y1, th = 1) {
	draw_line_width(x0 - th / 2, y0, x1 + th / 2, y0, th);
	draw_line_width(x0 - th / 2, y1, x1 + th / 2, y1, th);
	
	draw_line_width(x0, y0 - th / 2, x0, y1 + th / 2, th);
	draw_line_width(x1, y0 - th / 2, x1, y1 + th / 2, th);
}

function draw_rectangle_dashed(x0, y0, x1, y1, th = 1, dash = 8) {
	draw_line_dashed(x0 - th / 2, y0, x1 + th / 2, y0, th, dash);
	draw_line_dashed(x0 - th / 2, y1, x1 + th / 2, y1, th, dash);
	
	draw_line_dashed(x0, y0 - th / 2, x0, y1 + th / 2, th, dash);
	draw_line_dashed(x1, y0 - th / 2, x1, y1 + th / 2, th, dash);
}

function draw_ellipse_width(x0, y0, x1, y1, th = 1) {
	var cx = (x0 + x1) / 2;
	var cy = (y0 + y1) / 2;
	var ww = abs(x0 - x1) / 2;
	var hh = abs(y0 - y1) / 2;
	
	var samp = 32;
	var ox, oy, nx, ny;
	
	for( var i = 0; i < samp; i++ ) {
		nx = cx + lengthdir_x(ww, i * 360 / samp);
		ny = cy + lengthdir_y(hh, i * 360 / samp);
		
		if(i)
			draw_line_width(ox, oy, nx, ny, th);
		
		ox = nx;
		oy = ny;
	}
}

function draw_ellipse_dash(x0, y0, x1, y1, th = 1, dash = 8) {
	var cx = (x0 + x1) / 2;
	var cy = (y0 + y1) / 2;
	var ww = abs(x0 - x1) / 2;
	var hh = abs(y0 - y1) / 2;
	var rd = max(ww, hh);
	
	var dash_dist = 0, is_dash = true;
	var samp = 64;
	var ox, oy, nx, ny;
	
	for( var i = 0; i < samp; i++ ) {
		nx = cx + lengthdir_x(ww, i * 360 / samp);
		ny = cy + lengthdir_y(hh, i * 360 / samp);
		
		if(i) {
			dash_dist += point_distance(ox, oy, nx, ny);
			if(dash_dist >= dash) {
				dash_dist -= dash;
				is_dash = !is_dash;
			}
			
			if(is_dash)
				draw_line_width(ox, oy, nx, ny, th);
		}
		
		ox = nx;
		oy = ny;
	}
}

function draw_circle_dash(_x, _y, rad, th = 1, dash = 8) {
	draw_ellipse_dash(_x - rad, _y - rad, _x + rad, _y + rad, th, dash);
}
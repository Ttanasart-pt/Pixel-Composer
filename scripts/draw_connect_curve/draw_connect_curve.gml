function draw_line_curve_color(x0, y0, x1, y1, xc = noone, yc = noone, _s = 1, thick = 1, col1 = c_white, col2 = c_white, type = LINE_STYLE.solid) {
	if(xc == noone) xc = (x0 + x1) / 2;
	if(yc == noone) yc = (y0 + y1) / 2;
	
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 32 * PROJECT.graphConnection.line_sample);
	sample = clamp(sample, 2, 128);
	if(type == LINE_STYLE.dashed) sample *= 2;
	
	var x2 = lerp(x0, x1, 0. - sign(x1 - x0) * 0.2) - abs(y1 - y0) * 0.1;
	var x3 = lerp(x0, x1, 1. + sign(x1 - x0) * 0.2) + abs(y1 - y0) * 0.1;
	var y2 = y0;
	var y3 = y1;
	
	var c   = draw_get_color();
	var ox, oy, nx, ny, t, it, oc, nc;
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx =      x0 *				  power(t, 4) 
			+ 4 * x2 * power(it, 1) * power(t, 3) 
			+ 6 * xc * power(it, 2) * power(t, 2) 
			+ 4 * x3 * power(it, 3) * power(t, 1) 
			+     x1 * power(it, 4);
			
		ny =      y0 *                power(t, 4) 
			+ 4 * y2 * power(it, 1) * power(t, 3) 
			+ 6 * yc * power(it, 2) * power(t, 2) 
			+ 4 * y3 * power(it, 3) * power(t, 1) 
			+     y1 * power(it, 4);
			
		nc = merge_color(col1, col2, t);
		
		if(i) {
			switch(type) {
				case LINE_STYLE.solid :
					draw_line_round_color(ox, oy, nx, ny, thick, oc, nc, i == 1, i == sample);
					break;
				case LINE_STYLE.dashed :
					if(floor(i % 2))
						draw_line_round_color(ox, oy, nx, ny, thick, oc, nc);
					break;
			}
		}
		
		ox = nx;
		oy = ny;
		oc = nc;
	}
}

function draw_line_curve_corner(x0, y0, x1, y1, _s = 1, thick = 1, col1 = c_white, col2 = c_white) {
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 32 * PROJECT.graphConnection.line_sample);
	sample = clamp(sample, 2, 128);
	
	var x2 = lerp(x0, x1, 0.9);
	var x3 = x1;
	var y2 = lerp(y0, y1, 0.1);
	var y3 = y1;
	
	var c   = draw_get_color();
	var ox, oy, nx, ny, t, it, oc, nc;
	
	for( var i = 0; i <= sample; i++ )  {
		t  = i / sample;
		it = 1 - t;
		
		nx =      x0 *				  power(t, 3) 
			+ 3 * x2 * power(it, 1) * power(t, 2) 
			+ 3 * x3 * power(it, 2) * power(t, 1) 
			+     x1 * power(it, 3);
			
		ny =      y0 *                power(t, 3) 
			+ 3 * y2 * power(it, 1) * power(t, 2) 
			+ 3 * y3 * power(it, 2) * power(t, 1) 
			+     y1 * power(it, 3);
			
		nc = merge_color(col1, col2, t);
		
		if(i) draw_line_round_color(ox, oy, nx, ny, thick, oc, nc, i == 1, i == sample);
		
		ox = nx;
		oy = ny;
		oc = nc;
	}
}

function point_to_curve(mx, my, x0, y0, x1, y1, xc, yc, _s, _p = undefined) {
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 32 * PROJECT.graphConnection.line_sample);
	sample = clamp(sample, 2, 128);
	
	var dist = infinity;
	var ox, oy, nx, ny, t, it;
	
	var x2 = lerp(x0, x1, 0. - sign(x1 - x0) * 0.2);
	var x3 = lerp(x0, x1, 1. + sign(x1 - x0) * 0.2);
	var y2 = y0;
	var y3 = y1;
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx =      x0 *				  power(t, 4) 
			+ 4 * x2 * power(it, 1) * power(t, 3) 
			+ 6 * xc * power(it, 2) * power(t, 2) 
			+ 4 * x3 * power(it, 3) * power(t, 1) 
			+     x1 * power(it, 4);
			
		ny =      y0 *                power(t, 4) 
			+ 4 * y2 * power(it, 1) * power(t, 3) 
			+ 6 * yc * power(it, 2) * power(t, 2) 
			+ 4 * y3 * power(it, 3) * power(t, 1) 
			+     y1 * power(it, 4);
			
		if(i) dist = point_closer(_p, dist, mx, my, ox, oy, nx, ny);
		
		ox = nx;
		oy = ny;
	}
	
	return _p;
}

function point_to_curve_corner(mx, my, x0, y0, x1, y1, _s, _p = undefined) {
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 32 * PROJECT.graphConnection.line_sample);
	sample = clamp(sample, 2, 128);
	
	var dist = infinity;
	var ox, oy, nx, ny, t, it;
	
	var x2 = lerp(x0, x1, 0.9);
	var x3 = x1;
	var y2 = lerp(y0, y1, 0.1);
	var y3 = y1;
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx =      x0 *				  power(t, 3) 
			+ 3 * x2 * power(it, 1) * power(t, 2) 
			+ 3 * x3 * power(it, 2) * power(t, 1) 
			+     x1 * power(it, 3);
			
		ny =      y0 *                power(t, 3) 
			+ 3 * y2 * power(it, 1) * power(t, 2) 
			+ 3 * y3 * power(it, 2) * power(t, 1) 
			+     y1 * power(it, 3);
		
		if(i) dist = point_closer(_p, dist, mx, my, ox, oy, nx, ny);
		
		ox = nx;
		oy = ny;
	}
	
	return _p;
}
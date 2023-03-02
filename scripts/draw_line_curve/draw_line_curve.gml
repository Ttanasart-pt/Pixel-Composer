enum LINE_STYLE {
	solid,
	dashed
}

function draw_line_curve(x0, y0, x1, y1, thick = 1) {
	var xc = (x0 + x1) / 2;
	var sample = max(8, ceil((abs(x0 - x1) + abs(y0 - y1)) / 4));
	
	//var buff = vertex_create_buffer();
	//vertex_begin(buff, global.format_pc);
	
	var c = draw_get_color();
	var ox, oy, nx, ny, t, it;
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx = x0 * t * t * t + 3 * xc * it * t * t + 3 * xc * it * it * t + x1 * it * it * it;
		ny = y0 * t * t * t + 3 * y0 * it * t * t + 3 * y1 * it * it * t + y1 * it * it * it;
		
		if(i) {
			draw_line_width(ox, oy, nx, ny, thick);
			//vertex_position(buff, ox, oy); vertex_color(buff, c, 1);
			//vertex_position(buff, nx, ny); vertex_color(buff, c, 1);
		}
		
		ox = nx;
		oy = ny;
	}
	
	//vertex_end(buff);
	//vertex_submit(buff, pr_linelist, -1);
	
	//buffer_delete(buff);
}

function draw_line_curve_color(x0, y0, x1, y1, xc, yc, _s, thick, col1, col2, type = LINE_STYLE.solid) {
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 16 * PREF_MAP[? "connection_line_sample"]);
	sample = clamp(sample, 8, 128);
	
	var x2 = lerp(x0, x1, 0. - sign(x1 - x0) * 0.2) - abs(y1 - y0) * 0.1;
	var x3 = lerp(x0, x1, 1. + sign(x1 - x0) * 0.2) + abs(y1 - y0) * 0.1;
	var y2 = y0;
	var y3 = y1;
	
	var c   = draw_get_color();
	var ox, oy, nx, ny, t, it, oc, nc;
	var dash_distance = 2;
	
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
					draw_line_width_color(ox, oy, nx, ny, thick, oc, nc);
					break;
				case LINE_STYLE.dashed :
					if(floor(i / dash_distance) % 2)
						draw_line_width_color(ox, oy, nx, ny, thick, oc, nc);
					break;
			}
		}
		
		ox = nx;
		oy = ny;
		oc = nc;
	}
}

function distance_to_curve(mx, my, x0, y0, x1, y1, xc, yc, _s) {
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 16 * PREF_MAP[? "connection_line_sample"]);
	sample = clamp(sample, 8, 128);
	
	var dist = 999999;
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
			
		if(i)
			dist = min(dist, distance_to_line(mx, my, ox, oy, nx, ny));
		
		ox = nx;
		oy = ny;
	}
	
	return dist;
}

function draw_line_elbow(x0, y0, x1, y1, thick = 1, type = LINE_STYLE.solid) {
	var cx = (x0 + x1) / 2;
	draw_line_width(x0, y0, cx, y0, thick);
	draw_line_width(cx, y0 - thick / 2 * sign(y1 - y0), cx, y1 + thick / 2 * sign(y1 - y0), thick);
	draw_line_width(cx, y1, x1, y1, thick);
}

function draw_line_elbow_color(x0, y0, x1, y1, cx, thick, col1, col2, type = LINE_STYLE.solid) {
	var _x0 = min(x0, x1);
	var _x1 = max(x0, x1);
	var rat = (cx - _x0) / (_x1 - _x0);
	var cm  = merge_color(col1, col2, rat);
	
	if(type == LINE_STYLE.solid) {
		draw_line_width_color(x0, y0, cx, y0, thick, col1, cm);
		draw_line_width_color(cx, y0 - thick / 2 * sign(y1 - y0), cx, y1 + thick / 2 * sign(y1 - y0), thick, cm, cm);
		draw_line_width_color(cx, y1, x1, y1, thick, cm, col2);
	} else {
		draw_line_dashed_color(x0, y0, cx, y0, thick, col1, cm, 12);
		draw_line_dashed_color(cx, y0 - thick / 2 * sign(y1 - y0), cx, y1 + thick / 2 * sign(y1 - y0), thick, cm, cm, 12);
		draw_line_dashed_color(cx, y1, x1, y1, thick, cm, col2, 12);
	}	
}
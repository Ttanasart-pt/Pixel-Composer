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

function draw_line_curve_color(x0, y0, x1, y1, thick = 1, col1, col2) {
	var xc = (x0 + x1) / 2;
	var sample = max(8, ceil((abs(x0 - x1) + abs(y0 - y1)) / 4));
	
	var c = draw_get_color();
	var ox, oy, nx, ny, t, it, oc, nc;
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx = x0 * t * t * t + 3 * xc * it * t * t + 3 * xc * it * it * t + x1 * it * it * it;
		ny = y0 * t * t * t + 3 * y0 * it * t * t + 3 * y1 * it * it * t + y1 * it * it * it;
		nc = merge_color(col1, col2, t);
		
		if(i) {
			draw_line_width_color(ox, oy, nx, ny, thick, oc, nc);
		}
		
		ox = nx;
		oy = ny;
		oc = nc;
	}
}

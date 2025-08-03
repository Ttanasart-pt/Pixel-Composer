function draw_arc(_x, _y, _r, _as, _at, _th = 1, _pr = 32, _cap = false) {
	var ox, oy, nx, ny;
	var ast = 360 / _pr;
	var ad  = angle_difference(_at, _as);
	var sgn = sign(ad);
	var ar  = round(abs(ad) / 360 * _pr);
	
	for( var i = 0; i <= ar; i++ ) {
		var a = _as + ast * i * sgn;
		
		nx = _x + lengthdir_x(_r, a);
		ny = _y + lengthdir_y(_r, a);
		
		if(_cap && (i == 0 || i == ar)) draw_line_round(_x, _y, nx, ny, _th);
		
		if(i) draw_line_round(ox, oy, nx, ny, _th);
		
		ox = nx;
		oy = ny;
	}
}

function draw_arc_fill(_x, _y, _r, _as, _at, _pr = 32) {
	var ox, oy, nx, ny;
	var ast = 360 / _pr;
	var ad  = angle_difference(_at, _as);
	var sgn = sign(ad);
	var ar  = abs(ad) / 360 * _pr;
	
	draw_primitive_begin(pr_trianglelist);
	for( var i = 0; i <= ar; i++ ) {
		var a = _as + ast * i * sgn;
		
		nx = _x + lengthdir_x(_r, a);
		ny = _y + lengthdir_y(_r, a);
		
		if(i) {
			draw_vertex(_x, _y);
			draw_vertex(ox, oy);
			draw_vertex(nx, ny);
		}
		
		ox = nx;
		oy = ny;
	}
	draw_primitive_end();
}

function draw_arc_fast(_x, _y, _r, _as, _at, _th = 1, _pr = 8) {
	var ox, oy, nx, ny;
	var ast = 360 / _pr;
	var sgn = sign(_at - _as);
	var ar  = abs(_at - _as) / 360 * _pr;
	
	for( var i = 0; i < ar; i++ ) {
		var a = _as + ast * i * sgn;
		
		nx = _x + lengthdir_x(_r, a);
		ny = _y + lengthdir_y(_r, a);
		
		if(i) draw_line(ox, oy, nx, ny);
		
		ox = nx;
		oy = ny;
	}
}
function draw_circle_prec(x, y, r, border, precision = 32) {
	draw_set_circle_precision(precision);
	draw_circle(x, y, r, border);
}

function draw_circle_border(xx, yy, r, w) {
	var step = 32;
	var angle_step = 360 / step;

	var px, py, _px, _py;

	for(var i = 0; i <= step; i++){
		var px = xx + lengthdir_x(r, i * angle_step);
		var py = yy + lengthdir_y(r, i * angle_step);
	
		if(i) draw_line_round(_px, _py, px, py, w);
		
		_px = px;
		_py = py;
	}
}

function draw_ellipse_border(x0, y0, x1, y1, w) {
	var step = 32;
	var angle_step = 360 / step;
	
	var px, py, _px, _py;
	var cx = (x0 + x1) / 2;
	var cy = (y0 + y1) / 2;
	
	var ww = abs(x0 - x1) / 2;
	var hh = abs(y0 - y1) / 2;

	for(var i = 0; i <= step; i++){
		var px = cx + lengthdir_x(ww, i * angle_step);
		var py = cy + lengthdir_y(hh, i * angle_step);
	
		if(i)
			draw_line_round(_px, _py, px, py, w);
	
		_px = px;
		_py = py;
	}
}

function draw_circle_angle(_x, _y, _r, _angSt, _angEd, precision = 32) {
	var ox, oy, nx, ny, oa, na;
	
	draw_primitive_begin(pr_trianglelist);
	
	for( var i = 0; i <= precision; i++ ) {
		na = lerp(_angSt, _angEd, i / precision);
		nx = _x + lengthdir_x(_r, na);
		ny = _y + lengthdir_y(_r, na);
		
		if(i) {
			draw_vertex(_x, _y);
			draw_vertex(ox, oy);
			draw_vertex(nx, ny);
		}
		
		oa = na;
		ox = nx;
		oy = ny;
	}
	
	draw_primitive_end();
}

function draw_arc_width(_x, _y, _r, _th, _angSt, _angEd) {
	draw_primitive_begin(pr_trianglelist);
	var oxI, oyI, oxO, oyO;
	
	_angSt = _angSt % 360;
	_angEd = _angEd % 360;		
	var diff = _angEd >= _angSt? _angEd - _angSt : _angEd + 360 - _angSt;
	
	for(var i = 0; i <= abs(diff); i += 4) {
		var as = _angSt + i * sign(diff);
		var nxI = _x + lengthdir_x(_r - _th / 2, as);
		var nyI = _y + lengthdir_y(_r - _th / 2, as);
		var nxO = _x + lengthdir_x(_r + _th / 2, as);
		var nyO = _y + lengthdir_y(_r + _th / 2, as);
		
		if(i) {
			draw_vertex(oxI, oyI);
			draw_vertex(oxO, oyO);
			draw_vertex(nxI, nyI);
			
			draw_vertex(oxO, oyO);
			draw_vertex(nxI, nyI);
			draw_vertex(nxO, nyO);
		}
		
		oxI = nxI;
		oyI = nyI;
		oxO = nxO;
		oyO = nyO;
	}
	
	draw_primitive_end();
}
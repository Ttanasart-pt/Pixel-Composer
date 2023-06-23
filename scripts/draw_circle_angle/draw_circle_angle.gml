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

function draw_arc_th(_x, _y, _r, _th, _angSt, _angEd) {
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
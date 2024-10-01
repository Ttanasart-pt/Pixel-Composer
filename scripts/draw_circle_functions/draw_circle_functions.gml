function draw_circle_prec(x, y, r, border, precision = 32) {
	draw_set_circle_precision(precision);
	draw_circle(x, y, r, border);
}

function draw_polygon(x, y, r, sides, a = 0) {
	draw_primitive_begin(pr_trianglelist);
		for( var i = 0; i < sides; i++ ) {
			var a0 = (i + 0) / sides * 360 + a;
			var a1 = (i + 1) / sides * 360 + a;
			
			draw_vertex(x, y);
			draw_vertex(x + lengthdir_x(r, a0), y + lengthdir_y(r, a0));
			draw_vertex(x + lengthdir_x(r, a1), y + lengthdir_y(r, a1));
		}
	draw_primitive_end();
}

function draw_circle_color_alpha(_x, _y, _r, colI, colO, alpI, alpO) {
	var _step = 32;
	var angle_step = 360 / _step;
	
	draw_primitive_begin(pr_trianglestrip);
	for(var i = 0; i <= _step; i++) {
		var a0 = i * angle_step;
		var a1 = i * angle_step + angle_step;
		
		var p0x = _x + lengthdir_x(_r, a0);
		var p0y = _y + lengthdir_y(_r, a0);
		var p1x = _x + lengthdir_x(_r, a1);
		var p1y = _y + lengthdir_y(_r, a1);
		
		draw_vertex_color(_x, _y, colI, alpI);
		draw_vertex_color(p0x, p0y, colO, alpO);
		draw_vertex_color(p1x, p1y, colO, alpO);
	}
	draw_primitive_end();
}

function draw_circle_border(xx, yy, r, w) {
	var _step = 32;
	var angle_step = 360 / _step;
	
	draw_primitive_begin(pr_trianglestrip);
	for(var i = 0; i <= _step; i++){
		var p0x = xx + lengthdir_x(r - w / 2, i * angle_step);
		var p0y = yy + lengthdir_y(r - w / 2, i * angle_step);
		var p1x = xx + lengthdir_x(r + w / 2, i * angle_step);
		var p1y = yy + lengthdir_y(r + w / 2, i * angle_step);
		
		draw_vertex(p0x, p0y);
		draw_vertex(p1x, p1y);
	}
	draw_primitive_end();
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

function draw_ellipse_angle_color(cx, cy, rx, ry, ang, color0, color1) {
    var n    = ceil(max(cx, cy));
    var step = 360 / n;
    var ox, oy, nx, ny;
    
    draw_primitive_begin(pr_trianglelist);
    for (var i = 0; i <= n; i++) {
        var nx = cx + rx * dcos(i * step);
        var ny = cy + ry * dsin(i * step);
        
        var p0 = point_rotate(nx, ny, cx, cy, ang);
        nx = p0[0];
        ny = p0[1];
        
        if(i) {
	        draw_vertex_color(cx, cy, color0, 1);
	        draw_vertex_color(ox, oy, color1, 1);
	        draw_vertex_color(nx, ny, color1, 1);
        }
		
		ox = nx;
		oy = ny;
    }
    draw_primitive_end();
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

function draw_ellipse_dash(cx, cy, ww, hh, th = 1, dash = 8, ang = 0) {
	var rd = max(ww, hh);
	
	var dash_dist = 0, is_dash = true;
	var samp = dash * max(cx, cy);
	var ox, oy, nx, ny;
	
	for( var i = 0; i < samp; i++ ) {
		nx = cx + lengthdir_x(ww, i * 360 / samp);
		ny = cy + lengthdir_y(hh, i * 360 / samp);
		
        var p0 = point_rotate(nx, ny, cx, cy, ang);
        nx = p0[0];
        ny = p0[1];
        
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

function draw_circle_dash(_x, _y, rad, th = 1, dash = 8, ang = 0) { draw_ellipse_dash(_x, _y, rad, rad, th, dash, ang); }

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
		var _as = _angSt + i * sign(diff);
		var nxI = _x + lengthdir_x(_r - _th / 2, _as);
		var nyI = _y + lengthdir_y(_r - _th / 2, _as);
		var nxO = _x + lengthdir_x(_r + _th / 2, _as);
		var nyO = _y + lengthdir_y(_r + _th / 2, _as);
		
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

function draw_arc_forward(_x, _y, _r, _th, _angSt, _angEd) {
	draw_primitive_begin(pr_trianglelist);
	var oxI, oyI, oxO, oyO;
	
	var _aSt = min(_angSt, _angEd);
	var _aEd = max(_angSt, _angEd);
	var diff = _aEd - _aSt;
	
	for(var i = 0; i <= abs(diff); i += 4) {
		var _as = _aSt + i * sign(diff);
		var nxI = _x + lengthdir_x(_r - _th / 2, _as);
		var nyI = _y + lengthdir_y(_r - _th / 2, _as);
		var nxO = _x + lengthdir_x(_r + _th / 2, _as);
		var nyO = _y + lengthdir_y(_r + _th / 2, _as);
		
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function draw_circle_ui(_x, _y, _r, _o, _c = c_white, _a = 1) {
	shader_set(sh_node_circle);
		shader_set_color("color", _c, _a);
		shader_set_f("thickness", _o);
		shader_set_f("antialias", 1 / _r);
		shader_set_i("fill", _o == 0);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
}
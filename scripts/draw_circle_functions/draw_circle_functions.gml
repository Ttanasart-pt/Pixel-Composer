function draw_circle_prec(x, y, r, border, precision = 32) {
	draw_set_circle_precision(precision);
	draw_circle(x, y, r, border);
}

function draw_polygon(x, y, r, sides, a = 0) {
	var aa = 360 / sides;
	
	draw_primitive_begin(pr_trianglelist);
		for( var i = 0; i < sides; i++ ) {
			var a0 = a + i * aa;
			var a1 = a0 + aa;
			
			draw_vertex(x, y);
			draw_vertex(x + lengthdir_x(r, a0), y + lengthdir_y(r, a0));
			draw_vertex(x + lengthdir_x(r, a1), y + lengthdir_y(r, a1));
		}
	draw_primitive_end();
}

function draw_polygon_rect(x, y, w, h, sides, a = 0) {
	var aa = 360 / sides;
	
	draw_primitive_begin(pr_trianglelist);
		for( var i = 0; i < sides; i++ ) {
			var a0 = a + i * aa;
			var a1 = a0 + aa;
			
			draw_vertex(x, y);
			draw_vertex(x + lengthdir_x(w, a0), y + lengthdir_y(h, a0));
			draw_vertex(x + lengthdir_x(w, a1), y + lengthdir_y(h, a1));
		}
	draw_primitive_end();
}

function draw_polygon_rect_border(x, y, w, h, sides, thick = 1, a = 0) {
	var aa = 360 / sides;
	
	for( var i = 0; i < sides; i++ ) {
		var a0 = a + i * aa;
		var a1 = a0 + aa;
		
		draw_line_round(x + lengthdir_x(w, a0), y + lengthdir_y(h, a0), 
		                x + lengthdir_x(w, a1), y + lengthdir_y(h, a1), thick);
	}
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

function draw_circle_dash(_x, _y, rad, th = 1, dash = 8, ang = 0) { draw_ellipse_dash(_x, _y, rad, rad, th, dash, ang); }

function draw_circle_angle(_x, _y, _r, _angSt, _angEd, precision = 32, cin = draw_get_color(), cout = draw_get_color()) {
	var ox, oy, nx, ny, oa, na;
	var _aa = draw_get_alpha();
		
	draw_primitive_begin(pr_trianglelist);
	
	for( var i = 0; i <= precision; i++ ) {
		na = lerp(_angSt, _angEd, i / precision);
		nx = _x + lengthdir_x(_r, na);
		ny = _y + lengthdir_y(_r, na);
		
		if(i) {
			draw_vertex_color(_x, _y,  cin, _aa);
			draw_vertex_color(ox, oy, cout, _aa);
			draw_vertex_color(nx, ny, cout, _aa);
		}
		
		oa = na;
		ox = nx;
		oy = ny;
	}
	
	draw_primitive_end();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function draw_ellipse_prec(x0, y0, x1, y1, border, precision = 32) {
	draw_set_circle_precision(precision);
	draw_ellipse(x0, y0, x1, y1, border);
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

function draw_ellipse_dash(cx, cy, ww, hh, th = 1, dash = 8, ang = 0, shift = 0) {
	var step = 64;
	var astp = 360 / step;
	var shft = shift;
	
	var px, py, _px, _py;
	
	shader_set(sh_ui_line_dashed);
		shader_set_2( "worldPos",   [cx, cy]);
		shader_set_f( "dash",       dash);
		
		for(var i = 0; i <= step; i++) {
			var an = i * astp;
			var px = cx + lengthdir_x(ww, an);
			var py = cy + lengthdir_y(hh, an);
		
			if(i) {
				shader_set_f( "dashShift",  shft);
				shader_set_f( "direction",  degtorad(an + astp / 2 + 90));
				draw_line(_px, _py, px, py);
				shft = (shft + point_distance(_px, _py, px, py)) % (dash * 2);
			}
			
			_px = px;
			_py = py;
		}
		
	shader_reset();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

function draw_donut(_x, _y, _ri, _ro) {
    var step = 64;
    var angle_step = 360 / step;
    
    var pxI, pyI, pxO, pyO;
    var _pxI, _pyI, _pxO, _pyO;
    
    draw_primitive_begin(pr_trianglestrip);
    for(var i = 0; i <= step; i++){
        pxI = _x + lengthdir_x(_ri, i * angle_step);
        pyI = _y + lengthdir_y(_ri, i * angle_step);
        pxO = _x + lengthdir_x(_ro, i * angle_step);
        pyO = _y + lengthdir_y(_ro, i * angle_step);
        
        if(i) {
            draw_vertex(_pxI, _pyI);
            draw_vertex(_pxO, _pyO);
            draw_vertex(pxI, pyI);
            
            draw_vertex(_pxO, _pyO);
            draw_vertex(pxI, pyI);
            draw_vertex(pxO, pyO);
        }
        
        _pxI = pxI;
        _pyI = pyI;
        _pxO = pxO;
        _pyO = pyO;
    }
    draw_primitive_end();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function draw_circle_ui(_x, _y, _r, _th = 0, _c = c_white, _a = 1) {
	shader_set(sh_node_circle);
		shader_set_color("color", _c, _a);
		shader_set_f("thickness", _th);
		shader_set_f("antialias", 1 / _r);
		shader_set_i("fill", _th == 0);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
}

function draw_circle_arc_ui(_x, _y, _rad, _r, _th = 0, _c = c_white, _a = 1) {
	shader_set(sh_node_circle_arc);
		shader_set_color("color", _c, _a);
		shader_set_f("thickness", _th);
		shader_set_f("antialias", 1 / _r);
		shader_set_2("arcRad", [ degtorad(_rad[0]), degtorad(_rad[1])]);
		shader_set_i("fill", _th == 0);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
}
function __verlet_vec2() : __vec2() constructor {
	px = 0; py = 0;
	sx = 0; sy = 0;
	vx = 0; vy = 0;
	u  = 0; v  = 0;
	
	dx = undefined; 
	dy = undefined;
	
	drag = 0;
	pin  = false;
	
	blend = c_white;
	
	static set2 = function(_v2) {
		x  = _v2.x; y  = _v2.y;
		px = _v2.x; py = _v2.y;
		sx = _v2.x; sy = _v2.y;
		return self;
	}
}

function __verlet_edge(_p0, _p1, _k) constructor {
	p0 = _p0;
	p1 = _p1;
	k  = _k;
	
	active   = true;
	distance = point_distance(p0.x, p0.y, p1.x, p1.y);
	
	static toString = function() { return p0.lessThan(p1)? $"{p0}-{p1}" : $"{p1}-{p0}"; }
}

function __verlet_triangle(_p0, _p1, _p2) constructor {
	p0 = _p0;
	p1 = _p1;
	p2 = _p2;
	
	e0 = undefined;
	e1 = undefined;
	e2 = undefined;
	
	static submitVertex = function() {
		if(e0 != undefined && !e0.active) return;
		if(e1 != undefined && !e1.active) return;
		if(e2 != undefined && !e2.active) return;
		
		draw_vertex_texture_color(p0.dx ?? p0.x, p0.dy ?? p0.y, p0.u, p0.v, p0.blend, 1);
		draw_vertex_texture_color(p1.dx ?? p1.x, p1.dy ?? p1.y, p1.u, p1.v, p1.blend, 1);
		draw_vertex_texture_color(p2.dx ?? p2.x, p2.dy ?? p2.y, p2.u, p2.v, p2.blend, 1);
	}
}

function __verlet_quad(_t0, _t1) constructor {
	t0 = _t0;
	t1 = _t1;
	
	var _es = array_union([t0.e0, t0.e1, t0.e2], [t1.e0, t1.e1, t1.e2]);
	e0 = array_length(_es) > 0? _es[0] : undefined;
	e1 = array_length(_es) > 1? _es[1] : undefined;
	e2 = array_length(_es) > 2? _es[2] : undefined;
	e3 = array_length(_es) > 3? _es[3] : undefined;
	
	static submitVertex = function() {
		if(e0 != undefined && !e0.active) return;
		if(e1 != undefined && !e1.active) return;
		if(e2 != undefined && !e2.active) return;
		if(e3 != undefined && !e3.active) return;
		
		draw_vertex_texture_color(t0.p0.dx ?? t0.p0.x, t0.p0.dy ?? t0.p0.y, t0.p0.u, t0.p0.v, t0.p0.blend, 1);
		draw_vertex_texture_color(t0.p1.dx ?? t0.p1.x, t0.p1.dy ?? t0.p1.y, t0.p1.u, t0.p1.v, t0.p1.blend, 1);
		draw_vertex_texture_color(t0.p2.dx ?? t0.p2.x, t0.p2.dy ?? t0.p2.y, t0.p2.u, t0.p2.v, t0.p2.blend, 1);
		
		draw_vertex_texture_color(t1.p0.dx ?? t1.p0.x, t1.p0.dy ?? t1.p0.y, t1.p0.u, t1.p0.v, t1.p0.blend, 1);
		draw_vertex_texture_color(t1.p1.dx ?? t1.p1.x, t1.p1.dy ?? t1.p1.y, t1.p1.u, t1.p1.v, t1.p1.blend, 1);
		draw_vertex_texture_color(t1.p2.dx ?? t1.p2.x, t1.p2.dy ?? t1.p2.y, t1.p2.u, t1.p2.v, t1.p2.blend, 1);
	}
}

function __verlet_Mesh() : Mesh() constructor {
	vedges     = [];
	vtriangles = [];
	vquads     = undefined;
	
	////- Draw
	
	static draw = function(_x, _y, _s) {
		draw_primitive_begin(pr_linelist);
		var _vtx = 0;
		
		if(array_empty(vtriangles)) {
			for( var i = 0, n = array_length(vedges); i < n; i++ ) {
				var e  = vedges[i];
				if(e != undefined && !e.active) continue;
				
				var p0 = e.p0;
				var p1 = e.p1;
				
				var x0 = _x + p0.x * _s, y0 = _y + p0.y * _s;
				var x1 = _x + p1.x * _s, y1 = _y + p1.y * _s;
				
				draw_vertex(x0, y0); draw_vertex(x1, y1);
				
				if(++_vtx > 32) {
					draw_primitive_end();
					draw_primitive_begin(pr_linelist);
				}
			}
			
		} else {
			for( var i = 0, n = array_length(vtriangles); i < n; i++ ) {
				var t  = vtriangles[i];
				
				if(t.e0 != undefined && !t.e0.active) continue;
				if(t.e1 != undefined && !t.e1.active) continue;
				if(t.e2 != undefined && !t.e2.active) continue;
				
				var p0 = t.p0;
				var p1 = t.p1;
				var p2 = t.p2;
				
				var x0 = _x + p0.x * _s, y0 = _y + p0.y * _s;
				var x1 = _x + p1.x * _s, y1 = _y + p1.y * _s;
				var x2 = _x + p2.x * _s, y2 = _y + p2.y * _s;
				
				draw_vertex(x0, y0); draw_vertex(x1, y1);
				draw_vertex(x1, y1); draw_vertex(x2, y2);
				draw_vertex(x0, y0); draw_vertex(x2, y2);
				
				if(++_vtx > 16) {
					draw_primitive_end();
					draw_primitive_begin(pr_linelist);
				}
			}
		}
		
		draw_primitive_end();
	}
	
	static drawVertex = function(_x, _y, _s) {
		draw_set_circle_precision(4);
		var ds = min(1 * _s, ui(4));
		
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			var p = points[i];
			
			var px = _x + p.x * _s - 1;
			var py = _y + p.y * _s - 1;
			
			draw_set_color(p.pin? COLORS._main_accent : COLORS._main_icon);
			draw_circle(px, py, ds, false);
		}
	}
	
}
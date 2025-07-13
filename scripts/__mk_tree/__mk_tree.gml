function __MK_Tree_Leaf(_shp, _x, _y, _dir, _sx, _sy, _span) constructor {
	shape = _shp;
	
	sx = _sx;
	sy = _sy;
	
	dir = _dir;
	
	dx = lengthdir_x(sx, dir);
	dy = lengthdir_y(sx, dir);
	
	dsx = lengthdir_x(sy, dir + 90);
	dsy = lengthdir_y(sy, dir + 90);
	
	x = _x;
	y = _y;
	
	x1 = x + dx;
	y1 = y + dy;
	
	x2 = x + dx * _span;
	y2 = y + dy * _span;
	
	surface = noone;
	color   = c_white;
	colorE  = c_white;
	
	static drawOverlay = function(_x, _y, _s) { draw_circle(_x + x * _s, _y + y * _s, 3, false); }
	
	static draw = function() {
		draw_set_color(color);
		
		switch(shape) {
			case 0 : 
				draw_primitive_begin(pr_trianglelist);
					draw_vertex_color(x,        y,        color, 1);
					draw_vertex_color(x1,       y1,       colorE, 1);
					draw_vertex_color(x2 + dsx, y2 + dsy, colorE, 1);
					
					draw_vertex_color(x,        y,        color, 1);
					draw_vertex_color(x1,       y1,       colorE, 1);
					draw_vertex_color(x2 - dsx, y2 - dsy, colorE, 1);
				draw_primitive_end();
				break;
				
			case 1 :
				draw_set_circle_precision(16)
				draw_circle_color(x2, y2, sx, color, colorE, false);
				break;
				
			case 2 :
				draw_surface_ext_safe(surface, x, y, sx, sy, dir, color);
				break;
			
		}
	}
}

function __MK_Tree_Segment(_x, _y, _t) constructor {
	x = _x;
	y = _y;
	thickness = _t;
}

function __MK_Tree() constructor {
	root = self;
	
	x = 0;
	y = 0;
	
	rootPosition   = 0;
	amount         = 1;
	segments       = [];
	segmentLengths = [];
	segmentRatio   = [];
	totalLength    = 0;
	
	children = [];
	leaves   = [];
	color    = c_white;
	colorOut = c_white;
	
	////- Get
	
	static getPosition = function(rat, res) {
		rat = clamp(rat, 0, 1);
		
		var ox, oy, nx, ny;
		var ox = segments[0].x;
		var oy = segments[0].y;
			
		for( var i = 1, n = array_length(segmentRatio); i < n; i++ ) {
			nx = segments[i].x;
			ny = segments[i].y;
			
			if(segmentRatio[i] >= rat) {
				var _rr = (rat - segmentRatio[i - 1]) / (segmentRatio[i] - segmentRatio[i - 1]);
				
				res[0] = lerp(ox, nx, _rr);
				res[1] = lerp(oy, ny, _rr);
				res[2] = point_direction(ox, oy, nx, ny);
				return res;
			}
			
			ox = nx;
			oy = ny;
		}
		
		return res;
	}
	
	////- Build
	
	static getLength = function() {
		if(array_empty(segments)) return;
		
		segmentLengths = array_create(amount + 1);
		segmentRatio   = array_create(amount + 1);
		totalLength    = 0;
		
		var sg, nx, ny;
		var ox = segments[0].x;
		var oy = segments[0].y;
		
		for( var i = 1, n = array_length(segments); i < n; i++ ) {
			var sg = segments[i];
			nx = sg.x;
			ny = sg.y;
			
			var ll = point_distance(ox, oy, nx, ny);
			segmentLengths[i] = ll;
			totalLength += ll;
			
			ox = nx;
			oy = ny;
		}
		
		var l = 0;
		for( var i = 0, n = array_length(segmentLengths); i < n; i++ ) {
			l += segmentLengths[i];
			segmentRatio[i] = l / totalLength;
		}
	}
	
	static grow = function(_length, _angle, _angleW, _grav, _gravC, _thick, _thickC) {
		segments       = array_create(amount + 1);
		segmentLengths = array_create(amount + 1);
		segmentRatio   = array_create(amount + 1);
		totalLength    = 0;
		
		var ox = x, oy = y;
		
		var t = _thick * (_thickC? _thickC.get(0) : 1);
		
		segments[0] = new __MK_Tree_Segment(ox, oy, t);
		var _a = _angle;
		var ll = _length / amount;
		
		for( var i = 1; i <= amount; i++ ) {
			var p = i / amount;
			var t  = _thick * (_thickC? _thickC.get(p) : 1);
			
			var aa = _a + random_range(_angleW[0], _angleW[1]) * choose(-1, 1);
			var dx = lengthdir_x(ll, aa);
			var dy = lengthdir_y(ll, aa);
			
			ox += dx;
			oy += dy;
			
			segments[i] = new __MK_Tree_Segment(ox, oy, t);
			segmentLengths[i] = ll;
			totalLength += ll;
			
			dy += _grav * ll * (_gravC? _gravC.get(p) : 1);
			_a = point_direction(0, 0, dx, dy);
		}
		
		var l = 0;
		for( var i = 0, n = array_length(segmentLengths); i < n; i++ ) {
			l += segmentLengths[i];
			segmentRatio[i] = l / totalLength;
		}
	}
	
	////- Draw
	
	static drawOverlay = function(_x, _y, _s) {
		var ox, oy, nx, ny;
		
		draw_set_color(COLORS._main_icon)
		for( var i = 0, n = array_length(segments); i < n; i++ ) {
			var _seg = segments[i];
			
			nx = _x + _seg.x * _s;
			ny = _y + _seg.y * _s;
			
			if(i) { draw_line(ox, oy, nx, ny); }
			
			ox = nx;
			oy = ny;
		}
		
		__x = _x;
		__y = _y;
		__s = _s;
		
		draw_set_circle_precision(4);
		array_foreach(leaves,   function(l) /*=>*/ {return l.drawOverlay(__x, __y, __s)});
		array_foreach(children, function(c) /*=>*/ {return c.drawOverlay(__x, __y, __s)});
	}
	
	static draw = function() {
		var ox, oy, ot, oa = 0;
		var nx, ny, nt, na;
		
		draw_set_circle_precision(16);
		draw_primitive_begin(pr_trianglestrip);
		
		var len = array_length(segments);
		var ang = array_create(len);
		
		for( var i = 1; i < len; i++ ) {
			var _s0 = segments[i - 1];
			var _s1 = segments[i];
			
			ang[i] = point_direction(_s0.x, _s0.y, _s1.x, _s1.y) - 90;
		}
		
		for( var i = 0; i < len; i++ ) {
			var _seg = segments[i];
			
			nx = _seg.x;
			ny = _seg.y;
			nt = _seg.thickness;
			na = ang[i];
			if(i > 0 && i < len - 1) na = lerp_angle_direct(ang[i], ang[i + 1], .5);
			
			if(i) {
				draw_line_width2_angle_width(ox, oy, nx, ny, ot, nt, oa, na, color, color, colorOut, colorOut);
				
				// draw_line_width2(ox, oy, nx, ny, ot, nt, true, color, color);
			}
			
			oa = na;
			ox = nx;
			oy = ny;
			ot = nt;
			
			if(i % 32 == 0) {
				draw_primitive_end();
				draw_primitive_begin(pr_trianglestrip);
			}
		}
		
		draw_primitive_end();
		
		array_foreach(leaves,   function(l) /*=>*/ {return l.draw()});
		array_foreach(children, function(c) /*=>*/ {return c.draw()});
		
	}
	
}
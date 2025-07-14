function __MK_Tree_Leaf(_pos, _shp, _x, _y, _dir, _sx, _sy, _span) constructor {
	rootPosition = _pos;
	shape        = _shp;
	
	x  = _x;
	y  = _y;
	
	startx = _x;
	starty = _y;
	
	scale = 1;
	sx  = _sx;
	sy  = _sy;
	dir = _dir;
	sp  = _span;
	
	dx = lengthdir_x(sx, dir);
	dy = lengthdir_y(sx, dir);
	
	dsx = lengthdir_x(sy, dir + 90);
	dsy = lengthdir_y(sy, dir + 90);
	
	surface   = noone;
	color     = c_white;
	colorE    = c_white;
	colorU    = undefined;
	
	growShift = 0;
	growSpeed = 1;
	
	static drawOverlay = function(_x, _y, _s) { draw_circle(_x + x * _s, _y + y * _s, 3, false); }
	
	static draw = function() {
		if(scale <= 0) return;
		
		var x0 = x;
		var y0 = y;
		
		var x1 = x + dx * scale;
		var y1 = y + dy * scale;
		
		var x2 = x + dx * sp * scale;
		var y2 = y + dy * sp * scale;
		
		switch(shape) {
			case 0 : 
				var _sg   = -sign(dsy);
				var _cTop = colorU? colorU : colorE;
				var _cBot = colorE;
				var _scsg = scale * _sg;
				
				draw_primitive_begin(pr_trianglelist);
					draw_vertex_color(x0, y0, color, 1);
					draw_vertex_color(x1, y1, _cTop, 1);
					draw_vertex_color(x2 + dsx * _scsg, y2 + dsy * _scsg, _cTop, 1);
					
					draw_vertex_color(x0, y0, color, 1);
					draw_vertex_color(x1, y1, _cBot, 1);
					draw_vertex_color(x2 - dsx * _scsg, y2 - dsy * _scsg, _cBot, 1);
				draw_primitive_end();
				
				break;
				
			case 1 : 
				draw_set_circle_precision(16)
				draw_circle_color(x2, y2, sx * scale, color, colorE, false);
				break;
				
			case 2 : 
				draw_surface_ext_safe(surface, x, y, sx * scale, sy * scale, dir, color); 
				break;
			
		}
	}
	
	static copy = function(_l) {
		surface = _l.surface;
		color   = _l.color;
		colorE  = _l.colorE;
		colorU  = _l.colorU;
		
		growShift = _l.growShift;
		return self;
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
	
	children  = [];
	leaves    = [];
	color     = c_white;
	colorOut  = c_white;
	
	growShift = 0;
	growSpeed = 1;
	
	////- Get
	
	static getPosition = function(rat, res) {
		if(array_empty(segments)) {
			res[0] = x;
			res[1] = y;
			return res;
		}
		
		rat = clamp(rat, 0, 1);
		
		var amo  = array_length(segmentRatio);
		var low  = 0;
		var high = amo - 1;
		
		while(low < high) {
			var mid = (low + high) >> 1;
			if(segmentRatio[mid] < rat)
				low = mid + 1;
			else
				high = mid;
		}
		
		if(low == 0) {
			res[0] = segments[0].x;
			res[1] = segments[0].y;
			res[2] = point_direction(segments[0].x, segments[0].y, segments[1].x, segments[1].y);
			return res;

		} else if(low >= amo) {
			res[0] = segments[amo - 1].x;
			res[1] = segments[amo - 1].y;
			res[2] = point_direction(segments[amo - 2].x, segments[amo - 2].y, segments[amo - 1].x, segments[amo - 1].y);
			return res;
		}
		
		var ox = segments[low - 1];
		var nx = segments[low];
		
		var _rr = (rat - segmentRatio[low - 1]) / (segmentRatio[low] - segmentRatio[low - 1]);
		
		res[0] = lerp(ox.x, nx.x, _rr);
		res[1] = lerp(ox.y, nx.y, _rr);
		res[2] = point_direction(ox.x, ox.y, nx.x, nx.y);
		
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
	
	static grow = function(_param) {
		var _length = _param.length;
		var _angle  = _param.angle;
		var _angleW = _param.angleW;
		var _grav   = _param.grav;
		var _gravC  = _param.gravC;
		var _thick  = _param.thick;
		var _thickC = _param.thickC;
		
		var _spirS  = _param.spirS;
		var _spirP  = _param.spirP;
		var _wave   = _param.wave;
		var _waveC  = _param.waveC;
		var _curl   = _param.curl;
		var _curlC  = _param.curlC;
		
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
			
			var _wav = _wave * (_waveC? _waveC.get(p) : 1);
			if(_wav != 0) {
				var _wLen = cos(_spirP + p * pi * _spirS) * _wav;
				ox += lengthdir_x(_wLen, aa + 90);
				oy += lengthdir_y(_wLen, aa + 90);
			}
			
			
			var _crl = _curl * (_curlC? _curlC.get(p) : 1);
			if(_crl != 0) {
				var _cLen = sin(_spirP + p * pi * _spirS) * _crl;
				ox += lengthdir_x(_cLen, aa);
				oy += lengthdir_y(_cLen, aa);
			}
			
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
			
			if(i) draw_line_width2_angle_width(ox, oy, nx, ny, ot, nt, oa, na, color, color, colorOut, colorOut);
			
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
		
		array_foreach(leaves,   function(l) /*=>*/ { if(is(l, __MK_Tree_Leaf)) l.draw(); });
		array_foreach(children, function(c) /*=>*/ { if(is(c, __MK_Tree))      c.draw(); });
		
	}
	
}
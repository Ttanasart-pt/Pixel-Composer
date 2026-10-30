function PathPoint(_x=0, _y=0, _z=0, _w=0) constructor {
	x = _x;
	y = _y;
	z = _z;
	w = _w;
	
	static reset = function( ) /*=>*/ { x =   0; y =   0; z =   0; w =   0; return self; }
	static apply = function(b) /*=>*/ { x = b.x; y = b.y; z = b.z; w = b.w; return self; }
	static clone = function( ) /*=>*/ {return new PathPoint(x, y, z, w)};
	
	static toArray = function(d3d=false) /*=>*/ {return d3d? [x,y,z] : [x,y]};
}

function Path(_node) constructor {
	node = _node;
	
	lengthTotal = 0;
	lengths     = [];
	lengthAccs  = [];
	boundary    = new BoundingBox();
	loop		= false;
	
	__temp_p    = new PathPoint();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		if(!is(node, Node)) return false;
		
		var hv = node.doDrawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
		return (hv ?? false) || node.w_hovering;
	}
	
	static drawUI = function(_x, _y, _s) {
		static res = 32;
		var ox, oy, nx, ny;
		
		var _amo = getLineCount();
		var _ind = 0;
		
		draw_set_color(COLORS._main_icon);
		for( var j = 0; j < _amo; j++ )
		for( var i = 0; i <  res; i++ ) {
			var _r = i / res;
			getPointRatio(_r, j, __temp_p);
			
			nx = _x + __temp_p.x * _s;
			ny = _y + __temp_p.y * _s;
			
			if(i) draw_line(ox, oy, nx, ny);
			
			ox = nx;
			oy = ny;
		}
	}
	
	static getLoop          = function() /*=>*/ {return loop};
	
	static getBoundary      = function() /*=>*/ {return boundary};
	static getAccuLength    = function() /*=>*/ {return lengthAccs};
	static getLength        = function() /*=>*/ {return lengthTotal};
	static getSegmentCount  = function() /*=>*/ {return 1};
	static getLineCount     = function() /*=>*/ {return 1};
	static getTangentRatio  = function(_rat) /*=>*/ {return 0};
	
	static getPointDistance = function(_dis, _ind = 0, out = undefined) { return new PathPoint(); }
	static getPointRatio    = function(_rat, _ind = 0, out = undefined) { return getPointDistance(frac(_rat) * lengthTotal, _ind, out); }
	
	static getPointTangent  = function(_rat, _ind = 0) {
		var _r0 = loop? pfract(_rat - .01) : clamp(_rat - .01, .0, 0.999); 
		var _r2 = loop? pfract(_rat + .01) : clamp(_rat + .01, .0, 0.999); 
		
		getPointRatio(_r0, _ind, __temp_p);
		var _p0x = __temp_p.x;
		var _p0y = __temp_p.y;
		
		getPointRatio(_r2, _ind, __temp_p);
		var _p1x = __temp_p.x;
		var _p1y = __temp_p.y;
		
		var _dir = point_direction(_p0x, _p0y, _p1x, _p1y);
		return _dir;
	}
}

function PathSegment() : Path() constructor {
	segments = [];
	
	static getBoundary      = function() /*=>*/ {return boundary};
	static getSegmentCount  = function() /*=>*/ {return array_length(segments)};
	static getLineCount		= function() /*=>*/ {return 1};
	
	static setBoundary = function() {
		boundary = new BoundingBox( 0, 0, 0, 0 );
		if(getSegmentCount() == 0) return;
		
		var minx = segments[0].x, maxx = segments[0].x;
		var miny = segments[0].y, maxy = segments[0].y;
		
		for( var i = 0, n = array_length(segments); i < n; i++ ) {
			var s = segments[i];
			minx = min(minx, s.x);
			maxx = max(maxx, s.x);
			miny = min(miny, s.y);
			maxy = max(maxy, s.y);
		}
		
		boundary = new BoundingBox( minx, miny, maxx, maxy ); 
	}
	static setSegment  = function(segment) {
		self.segments = segment;
		lengths		  = [];
		lengthAccs    = [];
		lengthTotal   = 0;
		
		var op, np;
		for( var i = 0, n = array_length(segment); i < n; i++ ) {
			np = segment[i];
			if(i) {
				lengths[i - 1]    = point_distance(op.x, op.y, np.x, np.y);
				lengthTotal      += lengths[i - 1];
				lengthAccs[i - 1] = lengthTotal;
			}
			
			op = np;
		}
	}
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(!is(out, PathPoint)) out = new PathPoint(); else { out.x = 0; out.y = 0; }
		
		for( var i = 0; i < array_length(lengths); i++ ) {
			if(_dist <= lengths[i]) {
				var rat = _dist / lengths[i];
				
				out.x = lerp(segments[i].x, segments[i + 1].x, rat);
				out.y = lerp(segments[i].y, segments[i + 1].y, rat);
				
				return out;
			}
			
			_dist -= lengths[i];
		}
		
		out.x = segments[i].x;
		out.y = segments[i].y;
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { return getPointDistance(frac(_rat) * lengthTotal, _ind, out); }
		
	static getTangentRatio = function(_rat) {
		_rat = frac(_rat);
		var l = _rat * lengthTotal;
		
		for( var i = 1; i < array_length(lengths); i += 1 ) {
			if(l <= lengths[i]) {
				var rat = l / lengths[i];
				return segments[i - 1].directionTo(segments[i]);
			}
			
			l -= lengths[i];
		}
		
		return 0;
	}
	
	static draw = function(_x, _y, _s) {
		var ox, oy, nx, ny;
		
		for( var i = 0, n = array_length(segments); i < n; i++ ) {
			nx = _x + segments[i].x * _s;
			ny = _y + segments[i].y * _s;
			
			if(i) draw_line(ox, oy, nx, ny);
			
			ox = nx;
			oy = ny;
		}
	}
}

function PathDrawOverlay(_path, _x, _y, _s) {
	if(!is_path(_path)) return;
	draw_set_color(COLORS._main_icon);
	
	var _amo = _path.getLineCount();
	var _p   = new PathPoint();
	var _sam = 16;
	var _stp = 1 / _sam;
	
	for( var i = 0; i < _amo; i++ ) {
		var ox, oy, nx, ny;
		var j = 0;
		
		repeat(_sam) {
			_p = _path.getPointRatio(j, i, _p);
			nx = _x + _p.x * _s;
			ny = _y + _p.y * _s;
			
			if(j > 0) draw_line_width(ox, oy, nx, ny, 3);
			
			ox = nx;
			oy = ny;
			
			j += _stp;
		}
	}
	
}
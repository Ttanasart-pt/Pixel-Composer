function PathPoint(_x=0, _y=0, _z=0, _w=0) constructor {
	x = _x;
	y = _y;
	z = _z;
	w = _w;
	
	static reset = function( ) /*=>*/ { x =   0; y =   0; z =   0; w =   0; return self; }
	static apply = function(b) /*=>*/ { x = b.x; y = b.y; z = b.z; w = b.w; return self; }
	
	static equal = function(b) /*=>*/ { return x == b.x && y == b.y && z == b.z && w == b.w; }
	
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
	
	static getBoundary      = function(i) /*=>*/ {return boundary};
	static getAccuLength    = function(i) /*=>*/ {return lengthAccs};
	static getLength        = function(i) /*=>*/ {return lengthTotal};
	static getSegmentCount  = function(i) /*=>*/ {return 1};
	static getLineCount     = function( ) /*=>*/ {return 1};
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

function PathSegment(_node) : Path(_node) constructor {
	segments      = [];
	segment_count = 0;
	
	static getBoundary      = function(i) /*=>*/ {return boundary[i]};
	static getAccuLength    = function(i) /*=>*/ {return lengthAccs[i]};
	static getLength        = function(i) /*=>*/ {return lengthTotal[i]};
	static getSegmentCount  = function(i) /*=>*/ {return array_length(segments[i])};
	static getLineCount		= function( ) /*=>*/ {return segment_count};
	
	static setBoundary = function() {
		boundary = [];
		if(getLineCount() == 0) return;
		
		for( var j = 0, m = array_length(segments); j < m; j++ ) {
			var _seg = segments[j];
			var minx = _seg[0].x, maxx = _seg[0].x;
			var miny = _seg[0].y, maxy = _seg[0].y;
			
			for( var i = 1, n = array_length(_seg); i < n; i++ ) {
				var s = _seg[i];
				minx = min(minx, s.x);
				maxx = max(maxx, s.x);
				miny = min(miny, s.y);
				maxy = max(maxy, s.y);
			}
			
			boundary[j] = new BoundingBox( minx, miny, maxx, maxy );
		}
	}
	
	static setSegment  = function(_segment) {
		segments = array_get_depth(_segment) == 2? _segment : [_segment];
		segment_count = array_length(segments);
		
		lengths		  = [];
		lengthAccs    = [];
		lengthTotal   = [];
		
		for( var j = 0, m = array_length(segments); j < m; j++ ) {
			var _seg = segments[j];
			var _lengths     = [];
			var _lengthAccs  = [];
			var _lengthTotal = 0;
			
			var op, np;
			for( var i = 0, n = array_length(_seg); i < n; i++ ) {
				np = _seg[i];
				if(i) {
					_lengths[i - 1]    = point_distance(op.x, op.y, np.x, np.y);
					_lengthTotal      += _lengths[i - 1];
					_lengthAccs[i - 1] = _lengthTotal;
				}
				
				op = np;
			}
				
			lengths[j]     = _lengths;
			lengthAccs[j]  = _lengthAccs;
			lengthTotal[j] = _lengthTotal;
			
		}
			
		setBoundary();
	}
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(!is(out, PathPoint)) out = new PathPoint(); else { out.x = 0; out.y = 0; }
		
		var _seg = segments[_ind];
		var _len = lengths[_ind];
		
		for( var i = 0; i < array_length(_len); i++ ) {
			if(_dist <= _len[i]) {
				var rat = _dist / _len[i];
				
				out.x = lerp(_seg[i].x, _seg[i + 1].x, rat);
				out.y = lerp(_seg[i].y, _seg[i + 1].y, rat);
				
				return out;
			}
			
			_dist -= _len[i];
		}
		
		out.x = _seg[i].x;
		out.y = _seg[i].y;
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { return getPointDistance(frac(_rat) * lengthTotal[_ind], _ind, out); }
		
	static getTangentRatio = function(_rat, _ind = 0) {
		_rat = frac(_rat);
		
		var _seg = segments[_ind];
		var _len = lengths[_ind];
		
		var l = _rat * lengthTotal[_ind];
		
		for( var i = 1; i < array_length(_len); i += 1 ) {
			if(l <= _len[i]) {
				var rat = l / _len[i];
				return _seg[i-1].directionTo(_seg[i]);
			}
			
			l -= _len[i];
		}
		
		return 0;
	}
	
	static draw = function(_x, _y, _s) {
		var ox, oy, nx, ny;
		
		for( var j = 0, m = array_length(segments); j < m; j++ ) {
			var _segs = segments[j];
			
			for( var i = 0, n = array_length(_segs); i < n; i++ ) {
				nx = _x + _segs[i].x * _s;
				ny = _y + _segs[i].y * _s;
				
				if(i) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
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
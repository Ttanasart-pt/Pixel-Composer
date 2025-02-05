function Mesh() constructor {
	triangles = [];
	center    = [ 0, 0 ];
	bbox      = [ 0, 0, 1, 1 ];
	
	static getRandomPoint = function(seed) {
		random_set_seed(seed);
		if(array_length(triangles) == 0) return [ 0, 0 ];
		
		var tri = triangles[irandom(array_length(triangles) - 1)];
		var p0  = tri[0];
		var p1  = tri[1];
		var p2  = tri[2];
		
		var a1  = random1D(seed); seed++;
		var a2  = random1D(seed); seed++;
		
		var _x = (1 - sqrt(a1)) * p0.x + (sqrt(a1) * (1 - a2)) * p1.x + (sqrt(a1) * a2) * p2.x;
		var _y = (1 - sqrt(a1)) * p0.y + (sqrt(a1) * (1 - a2)) * p1.y + (sqrt(a1) * a2) * p2.y;
		
		return new __vec2( _x, _y );
	}
	
	static draw = function(_x, _y, _s) {
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var t = triangles[i];
			
			draw_line(_x + t[0].x * _s, _y + t[0].y * _s, _x + t[1].x * _s, _y + t[1].y * _s);
			draw_line(_x + t[1].x * _s, _y + t[1].y * _s, _x + t[2].x * _s, _y + t[2].y * _s);
			draw_line(_x + t[0].x * _s, _y + t[0].y * _s, _x + t[2].x * _s, _y + t[2].y * _s);
		}
	}
	
	static pointIn = function(_x, _y) {
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var t = triangles[i];
			
			if(point_in_triangle(_x, _y, t[0].x, t[0].y, t[1].x, t[1].y, t[2].x, t[2].y))
				return true;
		}
		
		return false;
	}
	
	static mergePath = function(_conn = true) {
		if(array_length(triangles) == 0) return [];
		
		var segments	= [];
		var pointsPairs = {};
		
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var t = triangles[i];
			
			for( var j = 0; j < 3; j++ ) {
				var p0 = t[(j + 0) % 3];
				var p1 = t[(j + 1) % 3];
				
				var overlap = false;
				var ind = -1;
				var amo = array_length(segments);
				
				for( var k = 0; k < amo; k ++ ) {
					if( (segments[k][0].equal(p0) && segments[k][1].equal(p1)) ||
					    (segments[k][0].equal(p1) && segments[k][1].equal(p0)) ) {
						  
						overlap = true;
						ind = k;
						break;
					}
				}
				
				if(overlap) array_delete(segments, ind, 1);
				else		array_push(segments, [ p0, p1 ]);
			}
		}
		
		if(!_conn) return segments;
		
		for( var i = 0, n = array_length(segments); i < n; i++ ) {
			var _s = segments[i];
			pointsPairs[$ _s[0]] = _s[1];
			pointsPairs[$ _s[1]] = _s[0];
		}
		
		var path = [ segments[0][0], segments[0][1] ];
		var indx = 1;
		
		for( var i = 0, n = array_length(segments); i < n; i++ ) {
			var last_point = path[indx];
	        var next_point = pointsPairs[$ last_point];
			if(next_point == undefined) break;
			
			struct_remove(pointsPairs, last_point);
			array_push(path, next_point);
			indx++;
		}
		
		return path;
	}
	
	static clone = function() {
		var msh = new Mesh();
		
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			msh.triangles[i] = [
				triangles[i][0].clone(),
				triangles[i][1].clone(),
				triangles[i][2].clone(),
			];
		}
		
		msh.center = [ center[0], center[1] ];
		
		return msh;
	}
	
	static calcCoM = function() {
		var _ax   = 0;
		var _ay   = 0;
		var _p    = 0;
		var _minx =  infinity;
		var _miny =  infinity;
		var _maxx = -infinity;
		var _maxy = -infinity;
		
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var _tr = triangles[i];
			
			for( var j = 0; j < 3; j++ ) {
				_ax += _tr[j].x; 
				_ay += _tr[j].y;
				
				_minx = min(_minx, _tr[j].x);
				_miny = min(_miny, _tr[j].y);
				_maxx = max(_maxx, _tr[j].x);
				_maxy = max(_maxy, _tr[j].y);
				_p++;
			}
		}
		
		center = [ 0, 0 ];
		if(_p == 0) return;
		
		center = [ _ax / _p, _ay / _p ];
		bbox   = [ _minx, _miny, _maxx, _maxy ];
	}
	
	static serialize   = function()  { return ""; }
	static deserialize = function(s) { return self; }
}
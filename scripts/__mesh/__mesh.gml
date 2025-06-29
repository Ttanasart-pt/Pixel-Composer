function Mesh() constructor {
	points    = [];
	edges     = [];
	triangles = [];
	
	center    = [ 0, 0 ];
	bbox      = [ 0, 0, 1, 1 ];
	
	////- Functions
	
	static getRandomPoint = function(seed) {
		random_set_seed(seed);
		if(array_length(triangles) == 0) return new __vec2();
		
		var tri = triangles[irandom(array_length(triangles) - 1)];
		var p0  = points[tri[0]];
		var p1  = points[tri[1]];
		var p2  = points[tri[2]];
		
		var a1  = random1D(seed); seed++;
		var a2  = random1D(seed); seed++;
		
		var _x = (1 - sqrt(a1)) * p0.x + (sqrt(a1) * (1 - a2)) * p1.x + (sqrt(a1) * a2) * p2.x;
		var _y = (1 - sqrt(a1)) * p0.y + (sqrt(a1) * (1 - a2)) * p1.y + (sqrt(a1) * a2) * p2.y;
		
		return new __vec2( _x, _y );
	}
	
	static pointIn = function(_x, _y) {
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var t  = triangles[i];
			var p0 = points[t[0]];
			var p1 = points[t[1]];
			var p2 = points[t[2]];
			
			if(point_in_triangle(_x, _y, p0.x, p0.y, p1.x, p1.y, p2.x, p2.y))
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
				var p0 = points[t[(j + 0) % 3]];
				var p1 = points[t[(j + 1) % 3]];
				
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
		
		var _smap   = array_create(array_length(segments));
		var _pntMap = {};
		var _pntInv = {};
		var _pntInd = 0;
		
		for( var i = 0, n = array_length(segments); i < n; i++ ) {
			var _s = segments[i];
			
			if(!struct_has(_pntInv, _s[0])) {
				_pntInv[$ _s[0]]   = _pntInd;
				_pntMap[$ _pntInd] = _s[0];
				_pntInd++;
			}
			
			if(!struct_has(_pntInv, _s[1])) {
				_pntInv[$ _s[1]]   = _pntInd;
				_pntMap[$ _pntInd] = _s[1];
				_pntInd++;
			}
			
			_smap[i] = [ _pntInv[$ _s[0]], _pntInv[$ _s[1]] ];
		}
		
		var _spath = connect_index_pairs(_smap);
		if(_spath[0] == array_last(_spath)) array_pop(_spath);
		
		var   path = array_create(array_length(_spath));
		for( var i = 0, n = array_length(_spath); i < n; i++ )
			path[i] = _pntMap[$ _spath[i]];
		
		return path;
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
				var p = points[_tr[j]];
				
				_ax += p.x; 
				_ay += p.y;
				
				_minx = min(_minx, p.x);
				_miny = min(_miny, p.y);
				_maxx = max(_maxx, p.x);
				_maxy = max(_maxy, p.y);
				_p++;
			}
		}
		
		center = [ 0, 0 ];
		if(_p == 0) return;
		
		center = [ _ax / _p, _ay / _p ];
		bbox   = [ _minx, _miny, _maxx, _maxy ];
	}
	
	////- Draw
	
	static draw = function(_x, _y, _s) {
		draw_primitive_begin(pr_linelist);
		var _vtx = 0;
		
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var t  = triangles[i];
			var p0 = points[t[0]];
			var p1 = points[t[1]];
			var p2 = points[t[2]];
			
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
		
		draw_primitive_end();
	}
	
	////- Serialize
	
	static serialize   = function()  { return ""; }
	static deserialize = function(s) { return self; }
	
	////- Actions
	
	static clone = function() {
		var msh = new Mesh();
		
		msh.triangles = array_clone(triangles);
		msh.edges     = array_clone(edges);
		msh.points    = array_create_ext(array_length(points), function(i) /*=>*/ {return points[i].clone()});
		msh.center    = [ center[0], center[1] ];
		
		return msh;
	}
	
}

function connect_index_pairs(index_pairs) {
    var result = [];
    if (array_empty(index_pairs)) return result;
	
    result[0] = index_pairs[0][0];
    result[1] = index_pairs[0][1];
	array_delete(index_pairs, 0, 1);
    
    while (array_length(index_pairs) > 0) {
        var connected = false;

        for( var i = 0, n = array_length(index_pairs); i < n; i++ ) {
            var current_pair = index_pairs[i];
            var first_value  = current_pair[0];
            var second_value = current_pair[1];

            if (result[0] == second_value) {
                array_insert(result, 0, first_value);
                array_delete(index_pairs, i, 1);
                connected = true;
                break;
                
            } else if (result[0] == first_value) {
                array_insert(result, 0, second_value);
                array_delete(index_pairs, i, 1);
                connected = true;
                break;
                
            } else if (array_last(result) == first_value) {
                array_push(result, second_value);
                array_delete(index_pairs, i, 1);
                connected = true;
                break;
                
            } else if (array_last(result) == second_value) {
                array_push(result, first_value);
                array_delete(index_pairs, i, 1);
                connected = true;
                break;
                
            }
        }

        if (!connected) break;
    }

    return result;
}
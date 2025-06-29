function delaunay_triangulation(points, polygons = noone) {
	if(array_length(points) < 3) return [];
	
    var super_triangle = _create_super_triangle(points);
    var triangles = [];
    array_push(triangles, super_triangle);
	
	var _len = array_length(points);
	
    for (var i = 0; i < _len; i++) {
        var _point = points[i];
        var bad_triangles = [];

        for( var j = 0, n = array_length(triangles); j < n; j++ ) {
            var _triangle = triangles[j];
            
            if (_point_in_circumcircle(_point, _triangle))
                array_push(bad_triangles, _triangle);
        }
		
        var polygon = _find_polygon_edges(bad_triangles);
		
		for( var j = 0, n = array_length(bad_triangles); j < n; j++ )
            array_remove_triangles(triangles, bad_triangles[j]);
		
		for( var j = 0, n = array_length(polygon); j < n; j += 2 )
            array_push(triangles, [ _point, polygon[j], polygon[j + 1] ]);
    }

	if(polygons == noone) {
	    for (var i = array_length(triangles) - 1; i >= 0; i--) {
	        var _triangle = triangles[i];
	        if (_shares_vertex(super_triangle, _triangle))
	            array_delete(triangles, i, 1);
	    }
	    
	} else {
		for (var i = array_length(triangles) - 1; i >= 0; i--) {
	        var _triangle = triangles[i];
	        if (_shares_vertex(super_triangle, _triangle) || !delaunay_triangle_in_polygon(polygons, _triangle))
	            array_delete(triangles, i, 1);
	    }
	    
	}
	
    return triangles;
}

function delaunay_triangulation_c(points, polygons = noone, index = false) {
	var _pointAmount  = array_length(points);
	var _pointBuffer  = buffer_create(_pointAmount * 8 * 2, buffer_fixed, 8); 
	var _resultBuffer = buffer_create(_pointAmount * 8 * 6, buffer_fixed, 4); 
	
	buffer_to_start(_pointBuffer);
	for( var i = 0; i < _pointAmount; i++ ) {
		var _p = points[i];
		buffer_write(_pointBuffer, buffer_f64, _p.x);
		buffer_write(_pointBuffer, buffer_f64, _p.y);
	}
	
	var _triangleAmount = delaunay_triangulation_ext(buffer_get_address(_pointBuffer), _pointAmount, buffer_get_address(_resultBuffer));
	var _triangles      = array_create(_triangleAmount);
	var i = 0;
	
	buffer_to_start(_resultBuffer);
	repeat(_triangleAmount) {
		var p1 = buffer_read(_resultBuffer, buffer_s32);
		var p2 = buffer_read(_resultBuffer, buffer_s32);
		var p3 = buffer_read(_resultBuffer, buffer_s32);
		
		_triangles[i++] = [ p1, p2, p3 ];
	}
	
	buffer_delete(_pointBuffer);
	buffer_delete(_resultBuffer);
	
	if(polygons != noone) {
		for (var i = array_length(_triangles) - 1; i >= 0; i--) {
	        var _triangle = _triangles[i];
	        if (!delaunay_triangle_in_polygon(polygons, [ points[_triangle[0]], points[_triangle[1]], points[_triangle[2]] ])) 
	        	array_delete(_triangles, i, 1);
	    }
	}
	
	if(!index) {
		for( var i = 0, n = array_length(_triangles); i < n; i++ ) {
			var _triangle = _triangles[i];
			_triangles[i] = [ points[_triangle[0]], points[_triangle[1]], points[_triangle[2]] ];
		}
	}
	
	return _triangles;
}
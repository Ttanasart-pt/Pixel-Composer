function delaunay_triangulation(points) { #region
	if(array_length(points) < 3) return [];
	
    var super_triangle = _create_super_triangle(points);
    var triangles = [];
    array_push(triangles, super_triangle);

    for (var i = 0; i < array_length(points); i++) {
        var _point = points[i];
        var bad_triangles = [];

        for (var j = 0; j < array_length(triangles); j++) {
            var _triangle = triangles[j];
            if (_point_in_circumcircle(_point, _triangle))
                array_push(bad_triangles, _triangle);
        }
		
        var polygon = _find_polygon_edges(bad_triangles);
		
        for (var j = 0; j < array_length(bad_triangles); j++)
            array_remove_triangles(triangles, bad_triangles[j]);
		
        for (var j = 0; j < array_length(polygon); j += 2) {
            var new_triangle = [_point, polygon[j], polygon[j + 1]];
            array_push(triangles, new_triangle);
        }
    }

    for (var i = array_length(triangles) - 1; i >= 0; i--) {
        var _triangle = triangles[i];
        if (_shares_vertex(super_triangle, _triangle))
            array_delete(triangles, i, 1);
    }
	
    return triangles;
} #endregion
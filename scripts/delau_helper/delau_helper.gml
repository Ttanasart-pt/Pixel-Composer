
	////- Utils 

function _triangle_is_ccw(triangle) {
	var a = triangle[0], b = triangle[1], c = triangle[2];
    return ((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) > 0;
}

function _triangle_is_equal(tri0, tri1) {
	return (tri0[0] == tri1[0] || tri0[0] == tri1[1] || tri0[0] == tri1[2]) && 
		   (tri0[1] == tri1[0] || tri0[1] == tri1[1] || tri0[1] == tri1[2]) && 
		   (tri0[2] == tri1[0] || tri0[2] == tri1[1] || tri0[2] == tri1[2]);
}

function _shares_vertex(triangle1, triangle2) {
	if (triangle1[0].equal(triangle2[0]) || triangle1[0].equal(triangle2[1]) || triangle1[0].equal(triangle2[2])) return true;
	if (triangle1[1].equal(triangle2[0]) || triangle1[1].equal(triangle2[1]) || triangle1[1].equal(triangle2[2])) return true;
	if (triangle1[2].equal(triangle2[0]) || triangle1[2].equal(triangle2[1]) || triangle1[2].equal(triangle2[2])) return true;
    return false;
}

function _shares_edge(triangle, edge_start, edge_end) {
    var count = 0;
	if (triangle[0].equal(edge_start) || triangle[0].equal(edge_end)) count++;
    if (triangle[1].equal(edge_start) || triangle[1].equal(edge_end)) count++;
    if (triangle[2].equal(edge_start) || triangle[2].equal(edge_end)) count++;
	return count == 2;
}

function _point_in_circumcircle(point, triangle) {
    var a = triangle[0], b = triangle[1], c = triangle[2];
	if(!_triangle_is_ccw(triangle)) {
		b = triangle[2];
		c = triangle[1];
	}
	
    // Calculate the determinant
    var ax = a.x - point.x, ay = a.y - point.y;
    var bx = b.x - point.x, by = b.y - point.y;
    var cx = c.x - point.x, cy = c.y - point.y;

    var det = (ax * ax + ay * ay) * (bx * cy - cx * by)
            - (bx * bx + by * by) * (ax * cy - cx * ay)
            + (cx * cx + cy * cy) * (ax * by - bx * ay);

    return det > 0;
}

	////- Operations

function _find_polygon_edges(triangles) {
    var polygon = [];
	var _len = array_length(triangles);
	
    for (var i = 0; i < _len; i++) {
        var triangle = triangles[i];
        
        var shared = false;
        for (var k = 0; k < _len; k++) if(k != i && _shares_edge(triangles[k], triangle[0], triangle[1])) { shared = true; break; }
        if (!shared) array_push(polygon, triangle[0], triangle[1]);
		
        var shared = false;
        for (var k = 0; k < _len; k++) if(k != i && _shares_edge(triangles[k], triangle[1], triangle[2])) { shared = true; break; }
        if (!shared) array_push(polygon, triangle[1], triangle[2]);
		
        var shared = false;
        for (var k = 0; k < _len; k++) if(k != i && _shares_edge(triangles[k], triangle[2], triangle[0])) { shared = true; break; }
        if (!shared) array_push(polygon, triangle[2], triangle[0]);
		
    }

    return polygon;
}

function _create_super_triangle(points) {
    var min_x = points[0].x, max_x = min_x, min_y = points[0].y, max_y = min_y;

    for (var i = 1; i < array_length(points); i++) {
        var point = points[i];
        min_x = min(min_x, point.x);
        max_x = max(max_x, point.x);
        min_y = min(min_y, point.y);
        max_y = max(max_y, point.y);
    }

    var dx = max_x - min_x, dy = max_y - min_y;
    var d_max = max(dx, dy);
    var center_x = (min_x + max_x) / 2, center_y = (min_y + max_y) / 2;

    return [
        new __vec2(center_x - 2 * d_max, center_y - d_max),
        new __vec2(center_x, center_y + 2 * d_max),
        new __vec2(center_x + 2 * d_max, center_y - d_max)
    ];
}

	////- Clean

function array_remove_triangles(arr, target) {
    for (var i = array_length(arr) - 1; i >= 0; i--) {
        if (_triangle_is_equal(arr[i], target)) 
            array_delete(arr, i, 1);
    }
}

function delaunay_triangle_in_polygon(points, triangle) {
	var xc = (triangle[0].x + triangle[1].x + triangle[2].x) / 3;
	var yc = (triangle[0].y + triangle[1].y + triangle[2].y) / 3;
	var ins = 0;
	
	for( var i = 0, n = array_length(points); i < n; i++ ) {
		var p0 = points[i];
		var p1 = points[(i + 1) % n];
		
		ins += line_is_intersect(xc, yc, xc + 10000, yc, p0[0], p0[1], p1[0], p1[1]);
	}
	
	return ins % 2;
}
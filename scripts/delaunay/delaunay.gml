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
	
	var _triangleAmount = delaunay_triangulation_ext_c(buffer_get_address(_pointBuffer), _pointAmount, buffer_get_address(_resultBuffer));
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

#region 
/*[cpp]
	#include <vector>
	#include <unordered_map>
	#include <algorithm>
	
	using namespace std;
	
	struct Point {
		double x;
		double y;
	};
	
	struct Triangle {
		Point p1;
		Point p2;
		Point p3;
	};
	
		////- Utils
	
	bool points_equal(const Point& p1, const Point& p2) { return (p1.x == p2.x && p1.y == p2.y); }
	
	bool triangle_is_ccw(const Triangle& triangle) {
		double area = (triangle.p2.x - triangle.p1.x) * (triangle.p3.y - triangle.p1.y) - (triangle.p3.x - triangle.p1.x) * (triangle.p2.y - triangle.p1.y);
		return area > 0;
	}
	
	bool triangle_equal(const Triangle& t1, const Triangle& t2) {
		return (points_equal(t1.p1, t2.p1) && points_equal(t1.p2, t2.p2) && points_equal(t1.p3, t2.p3)) ||
			   (points_equal(t1.p1, t2.p2) && points_equal(t1.p2, t2.p3) && points_equal(t1.p3, t2.p1)) ||
			   (points_equal(t1.p1, t2.p3) && points_equal(t1.p2, t2.p1) && points_equal(t1.p3, t2.p2));
	}
	
	bool share_vertexs(const Triangle& t1, const Triangle& t2) {
		return (points_equal(t1.p1, t2.p1) || points_equal(t1.p1, t2.p2) || points_equal(t1.p1, t2.p3) ||
			    points_equal(t1.p2, t2.p1) || points_equal(t1.p2, t2.p2) || points_equal(t1.p2, t2.p3) ||
			    points_equal(t1.p3, t2.p1) || points_equal(t1.p3, t2.p2) || points_equal(t1.p3, t2.p3));
	}
	
	bool share_edge(const Triangle& triangle, const Point& p1, const Point& p2) {
		int count = 0;
		if (points_equal(triangle.p1, p1) || points_equal(triangle.p1, p2)) count++;
		if (points_equal(triangle.p2, p1) || points_equal(triangle.p2, p2)) count++;
		if (points_equal(triangle.p3, p1) || points_equal(triangle.p3, p2)) count++;
		return count == 2;
	}
	
	bool point_in_circumcircle(const Triangle& triangle, const Point& point) {
		Point a = triangle.p1;
		Point b = triangle.p2;
		Point c = triangle.p3;
	
		if (!triangle_is_ccw(triangle)) {
			b = triangle.p3;
			c = triangle.p2;
		}
	
		double ax = a.x - point.x;
		double ay = a.y - point.y;
		double bx = b.x - point.x;
		double by = b.y - point.y;
		double cx = c.x - point.x;
		double cy = c.y - point.y;
	
		double det = (ax * ax + ay * ay) * (bx * cy - cx * by)
	               - (bx * bx + by * by) * (ax * cy - cx * ay)
	               + (cx * cx + cy * cy) * (ax * by - bx * ay);
	
		return det > 0;
	}
	
	int point_hash(const Point& point) {
		return ((int)point.x << 16) + (int)point.y;
	}
	
	int point_pair_hash(const Point& p1, const Point& p2) {
		Point _p1 = p1;
		Point _p2 = p2;
	
		if (_p1.x > _p2.x) swap(_p1, _p2);
		else if (_p1.x == _p2.x && _p1.y > _p2.y) swap(_p1, _p2);
	
		return ((int)_p1.x << 16) + (int)_p1.y + ((int)_p2.x << 8) + (int)_p2.y;
	}
	
		////- Operations
	
	vector<Point> find_polygon_edges(const vector<Triangle>& triangles) {
		vector<Point> edges;
		unordered_map<int, int> edge_count;
		unordered_map<int, pair<Point, Point>> edge_map;
	
		for (const auto& triangle : triangles) {
			edge_map[point_pair_hash(triangle.p1, triangle.p2)] = { triangle.p1, triangle.p2 };
			edge_map[point_pair_hash(triangle.p2, triangle.p3)] = { triangle.p2, triangle.p3 };
			edge_map[point_pair_hash(triangle.p3, triangle.p1)] = { triangle.p3, triangle.p1 };
	
			edge_count[point_pair_hash(triangle.p1, triangle.p2)]++;
			edge_count[point_pair_hash(triangle.p2, triangle.p3)]++;
			edge_count[point_pair_hash(triangle.p3, triangle.p1)]++;
		}
	
		for (const auto& edge : edge_count) {
			if (edge.second == 1) {
				auto it = edge_map.find(edge.first);
				if (it != edge_map.end()) {
					edges.emplace_back(it->second.first);
					edges.emplace_back(it->second.second);
				}
			}
		}
		
		return edges;
	}
	
	Triangle super_triangle(const vector<Point>& points) {
		double min_x = points[0].x;
		double min_y = points[0].y;
		double max_x = points[0].x;
		double max_y = points[0].y;
	
		for (const auto& point : points) {
			if (point.x < min_x) min_x = point.x;
			if (point.y < min_y) min_y = point.y;
			if (point.x > max_x) max_x = point.x;
			if (point.y > max_y) max_y = point.y;
		}
	
		double dx = max_x - min_x;
		double dy = max_y - min_y;
		double delta_max = dx > dy ? dx : dy;
	
		double center_x = (min_x + max_x) / 2;
		double center_y = (min_y + max_y) / 2;
	
		Point p1 = { center_x - 2 * delta_max, center_y - delta_max };
		Point p2 = { center_x, center_y + 2 * delta_max };
		Point p3 = { center_x + 2 * delta_max, center_y - delta_max };
	
		return { p1, p2, p3 };
	}
	
		////- Clean
	
	void vector_remove_triangle(vector<Triangle>& triangles, const Triangle& triangle) {
	    triangles.erase(remove_if(triangles.begin(), triangles.end(), 
			[&](const Triangle& t) { return triangle_equal(t, triangle); }), 
			triangles.end());
	}
	
		////- Main
	
	cfunction double delaunay_triangulation_ext_c(void* points, double _pointAmount, void* result) {
		int pointAmount = (int)_pointAmount;
		if (pointAmount < 3) return 0.0;
	
		vector<Point> points_vector;
		unordered_map<int, int> point_map;
	
		points_vector.reserve(pointAmount);
	
		for (int i = 0; i < pointAmount; i++) {
			points_vector.push_back({ ((Point*)points)[i].x, ((Point*)points)[i].y });
			point_map[point_hash(points_vector[i])] = i;
		}
	
		Triangle super_triangle_ = super_triangle(points_vector);
		vector<Triangle> triangles;
		triangles.emplace_back(super_triangle_);
	
		for (const auto& point : points_vector) {
			vector<Triangle> bad_triangles;
			for (const auto& triangle : triangles) {
				if (point_in_circumcircle(triangle, point))
					bad_triangles.emplace_back(triangle);
			}
			vector<Point> polygon_edges = find_polygon_edges(bad_triangles);
			for (const auto& triangle : bad_triangles)
				vector_remove_triangle(triangles, triangle);
			
			for (size_t i = 0; i < polygon_edges.size(); i += 2) {
				Triangle new_triangle{ polygon_edges[i], polygon_edges[i + 1], point };
				triangles.emplace_back(new_triangle);
			}
		}
	
		for (auto it = triangles.begin(); it != triangles.end();) {
			if (share_vertexs(*it, super_triangle_))
				it = triangles.erase(it);
			else
				it++;
		}
	
		for (size_t i = 0; i < triangles.size(); i++) {
			int indx = (int)i * 3;
	
			((int*)result)[indx + 0] = point_map[point_hash(triangles[i].p1)];
			((int*)result)[indx + 1] = point_map[point_hash(triangles[i].p2)];
			((int*)result)[indx + 2] = point_map[point_hash(triangles[i].p3)];
		}
	
		return triangles.size();
	}
*/
#endregion


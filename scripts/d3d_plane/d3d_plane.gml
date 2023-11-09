function __plane(origin, normal) constructor {
	self.origin = origin;
	self.normal = normal.normalize();
}

#region functions
	function d3d_intersect_ray_plane(ray, plane) {
		//print($"Intersect {ray}\n\tto {plane}");
		
		var det = plane.normal.dot(ray.direction);
		if(det == 0) return new __vec3();
		
		var rayToPlane = plane.origin.subtract(ray.origin);
		var t = rayToPlane.dot(plane.normal) / det;
		
		if(t < 0) return new __vec3();
		
		return ray.sampleDistance(t);
	}
	
	function d3d_point_to_plane(plane_origin, plane_normal, point) {
		var plane_to_point = [
			point[0] - plane_origin[0],
			point[1] - plane_origin[1],
			point[2] - plane_origin[2],
		];
		
		var _dot = dot_product_3d(plane_to_point[0], plane_to_point[1], plane_to_point[2], plane_normal[0], plane_normal[1], plane_normal[2]);
		var _distance = _dot / point_distance_3d(0, 0, 0, plane_normal[0], plane_normal[1], plane_normal[2]);
		return _distance;
	}
#endregion
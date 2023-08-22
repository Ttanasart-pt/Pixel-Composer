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
#endregion
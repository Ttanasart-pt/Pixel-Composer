function __ray(origin, direction) constructor {
	self.origin = origin;
	self.direction = direction.normalize();
	
	static sampleDistance = function(t) {
		gml_pragma("forceinline");
		return origin.add(direction.multiply(t));
	}
}
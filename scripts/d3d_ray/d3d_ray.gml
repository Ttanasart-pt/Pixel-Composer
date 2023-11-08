function __ray(origin, direction) constructor {
	self.origin = origin;
	self.direction = direction.normalize();
	
	static sampleDistance = function(t) {
		INLINE
		return origin.add(direction.multiply(t));
	}
}
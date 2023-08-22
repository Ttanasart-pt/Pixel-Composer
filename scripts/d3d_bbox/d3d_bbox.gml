function __bbox3D(first, second) constructor {
	self.first  = first;
	self.second = second;
	
	static getScale = function() {
		gml_pragma("forceinline");
		return sqrt(
			sqr(first.x - second.x) +
			sqr(first.y - second.y) +
			sqr(first.z - second.z)
		);
	}
	
	static getMaximumScale = function() {
		gml_pragma("forceinline");
		return max(
			abs(first.x - second.x),
			abs(first.y - second.y),
			abs(first.z - second.z),
		);
	}
}
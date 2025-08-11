function __bbox3D(_first, _second) constructor {
	first  = _first;
	second = _second;
	
	static getScale = function() {
		INLINE
		return sqrt(
			sqr(first.x - second.x) +
			sqr(first.y - second.y) +
			sqr(first.z - second.z)
		);
	}
	
	static getMaximumScale = function() {
		INLINE
		return max(
			abs(first.x - second.x),
			abs(first.y - second.y),
			abs(first.z - second.z),
		);
	}
	
	static clone = function() { return new __bbox3D(first.clone(), second.clone()); }
}

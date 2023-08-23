function V3(_x = 0, _y = _x, _z = _x, color = c_white, alpha = 1) {
	return new __vertex(_x, _y, _z, color, alpha);
}

function __vertex(_x = 0, _y = _x, _z = _x, color = c_white, alpha = 1) : __vec3(_x, _y, _z) constructor {
	normal = new __vec3();
	uv     = new __vec2();
	
	self.color    = color;
	self.alpha    = alpha;
	
	static setNormal = function(_nx = 0, _ny = _nx, _nz = _nx) {
		normal.set(_nx, _ny, _nz)._normalize();
		return self;
	}
	
	static setUV = function(_u = 0, _v = _u) {
		uv.set(_u, _v);
		return self;
	}
	
	static toString = function() { return $"[ pos: ({x}, {y}, {z}), nor: {normal}, uv: {uv}, {color}, {alpha} ]"; }
	
	static clone = function() {
		gml_pragma("forceinline");
		return new __vertex(x, y, z, color, alpha);
	}
}
function __vertexA(_v, color = c_white, alpha = 1) { return new __vertex(_v[0], _v[1], _v[2], color, alpha); }

function __vertex(_x = 0, _y = _x, _z = _x, color = c_white, alpha = 1) constructor {
	x = _x;
	y = _y;
	z = _z;
	
	nx = 0;
	ny = 0;
	nz = 0;
	
	u = 0;
	v = 0;
	
	self.color    = color;
	self.alpha    = alpha;
	
	static set = function(_x, _y, _z, _nx, _ny, _nz, _u, _v) {
		INLINE
		x = _x;
		y = _y;
		z = _z;
		
		nx = _nx;
		ny = _ny;
		nz = _nz;
		
		u = _u;
		v = _v;
		return self;
	}
	
	static setNormal = function(_nx = 0, _ny = _nx, _nz = _nx) {
		INLINE
		nx = _nx;
		ny = _ny;
		nz = _nz;
		return self;
	}
	
	static setUV = function(_u = 0, _v = _u) {
		INLINE
		u = _u;
		v = _v;
		return self;
	}
	
	static toString = function() { return $"[__vertex] ( pos: ({x}, {y}, {z}), nor: ({nx}, {ny}, {nz}), uv: ({u}, {v}), {color}, {alpha} )"; }
	
	static toArrayPos = function() /*=>*/ {return [x,y,z]};
	
	static clone = function() {
		INLINE
		var _v = new __vertex(x, y, z, color, alpha);
		
		_v.nx = nx;
		_v.ny = ny;
		_v.nz = nz;
		
		_v.u  = u;
		_v.v  = v;
		
		return _v;
	}
}

function vertex_face_normal(v0, v1, v2) {
	var ax = v1.x - v0.x;
	var ay = v1.y - v0.y;
	var az = v1.z - v0.z;

	var bx = v2.x - v0.x;
	var by = v2.y - v0.y;
	var bz = v2.z - v0.z;

	var nx = ay * bz - az * by;
	var ny = az * bx - ax * bz;
	var nz = ax * by - ay * bx;

	var length = sqrt(nx*nx + ny*ny + nz*nz);
	if (length != 0) {
		nx /= length;
		ny /= length;
		nz /= length;
	}

	v0.nx = nx; v0.ny = ny; v0.nz = nz;
	v1.nx = nx; v1.ny = ny; v1.nz = nz;
	v2.nx = nx; v2.ny = ny; v2.nz = nz;
}
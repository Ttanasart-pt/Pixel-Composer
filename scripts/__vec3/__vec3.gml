#macro __vec3_forward new __vec3(1.0, 0.0, 0.0)
#macro __vec3_right   new __vec3(0.0, 1.0, 0.0)
#macro __vec3_up      new __vec3(0.0, 0.0, 1.0)

function __vec3(_x = 0, _y = _x, _z = _x) constructor {
	static set = function(_x = 0, _y = _x, _z = _x) { #region
		if(is_struct(_x) && is_instanceof(_x, __vec3)) {
			x = _x.x;
			y = _x.y;
			z = _x.z;
			return self;
		}
		
		if(is_struct(_x) && is_instanceof(_x, BBMOD_Vec3)) {
			x = _x.X;
			y = _x.Y;
			z = _x.Z;
			return self;
		}
		
		if(is_array(_x)) {
			x = _x[0];
			y = _x[1];
			z = _x[2];
			return self;
		}
		
		x = _x;
		y = _y;
		z = _z;
		return self;
	} set(_x, _y, _z); #endregion
	
	static isZero = function() { #region
		gml_pragma("forceinline");
		return x == 0 && y == 0 && z == 0;
	} #endregion
	
	static setIndex = function(index, value) { #region
		gml_pragma("forceinline");
		switch(index) {
			case 0 : x = value; break;
			case 1 : y = value; break;
			case 2 : z = value; break;
		}
		return self;
	} #endregion
	
	static getIndex = function(index) { #region
		switch(index) {
			case 0 : return x;
			case 1 : return y;
			case 2 : return z;
		}
		return 0;
	} #endregion

	static  add = function(_vec3) { #region
		gml_pragma("forceinline");
		return new __vec3(x + _vec3.x, y + _vec3.y, z + _vec3.z);
	} #endregion
	static _add = function(_vec3) { #region
		gml_pragma("forceinline");
		x += _vec3.x;
		y += _vec3.y;
		z += _vec3.z;
		return self;
	} #endregion

	static  subtract = function(_vec3) { #region
		gml_pragma("forceinline");
		return new __vec3(x - _vec3.x, y - _vec3.y, z - _vec3.z);
	} #endregion
	static _subtract = function(_vec3) { #region
		gml_pragma("forceinline");
		x -= _vec3.x;
		y -= _vec3.y;
		z -= _vec3.z;
		return self;
	} #endregion

	static  multiply = function(_scalar) { #region
		gml_pragma("forceinline");
		return new __vec3(x * _scalar, y * _scalar, z * _scalar);
	} #endregion
	static _multiply = function(_scalar) { #region
		gml_pragma("forceinline");
		x *= _scalar;
		y *= _scalar;
		z *= _scalar;
		return self;
	} #endregion

	static  multiplyVec = function(_vec) { #region
		gml_pragma("forceinline");
		return new __vec3(x * _vec.x, y * _vec.y, z * _vec.z);
	} #endregion
	static _multiplyVec = function(_vec) { #region
		gml_pragma("forceinline");
		x *= _vec.x;
		y *= _vec.y;
		z *= _vec.z;
		return self;
	} #endregion

	static  divide = function(_scalar) { #region
		gml_pragma("forceinline");
		if (_scalar != 0)
			return new __vec3(x / _scalar, y / _scalar, z / _scalar);
		
		return new __vec3(x, y, z); // Avoid division by zero
	} #endregion
	static _divide = function(_scalar) { #region
		gml_pragma("forceinline");
		if (_scalar != 0) {
			x /= _scalar;
			y /= _scalar;
			z /= _scalar;
		}
		return self;
	} #endregion

	static dot = function(_vec3) { #region
		gml_pragma("forceinline");
		return x * _vec3.x + y * _vec3.y + z * _vec3.z;
	} #endregion
	
	static cross = function(_vec3) { #region
		gml_pragma("forceinline");
	    var cross_x = y * _vec3.z - z * _vec3.y;
	    var cross_y = z * _vec3.x - x * _vec3.z;
	    var cross_z = x * _vec3.y - y * _vec3.x;
	    return new __vec3(cross_x, cross_y, cross_z);
	} #endregion

	static distance = function(_vec3) { #region
		gml_pragma("forceinline");
		var dx = _vec3.x - x;
		var dy = _vec3.y - y;
		var dz = _vec3.z - z;
		return sqrt(dx * dx + dy * dy + dz * dz);
	} #endregion
	
	static length = function() { #region
		gml_pragma("forceinline");
		return sqrt(x * x + y * y + z * z);
	} #endregion

	static  normalize = function() { #region
		gml_pragma("forceinline");
		return clone()._normalize();
	} #endregion
	static _normalize = function() { #region
		gml_pragma("forceinline");
		var _length = length();
		if (_length != 0) {
			x /= _length;
			y /= _length;
			z /= _length;
		}
		return self;
	} #endregion
	
	static _lerpTo = function(to, speed = 0.3) { #region
		gml_pragma("forceinline");
		x = lerp(x, to.x, speed);
		y = lerp(y, to.y, speed);
		z = lerp(z, to.z, speed);
	} #endregion
	
    static _lerp_float = function(to, speed = 5, pre = 0.01) { #region
        gml_pragma("forceinline");
        x = lerp_float(x, to.x, speed, pre);
        y = lerp_float(y, to.y, speed, pre);
        z = lerp_float(z, to.z, speed, pre);
    } #endregion

	static equal = function(to) { #region
		gml_pragma("forceinline");
		return x == to.x && y == to.y && z == to.z;
	} #endregion
	
	static minVal = function(vec) { #region
		gml_pragma("forceinline");
		return new __vec3(
			min(x, vec.x),
			min(y, vec.y),
			min(z, vec.z),
		);
	} #endregion
	
	static maxVal = function(vec) { #region
		gml_pragma("forceinline");
		return new __vec3(
			max(x, vec.x),
			max(y, vec.y),
			max(z, vec.z),
		);
	} #endregion
	
	static clone = function() { #region
		gml_pragma("forceinline");
		return new __vec3(x, y, z);
	} #endregion
	
	static toString = function() { return $"[__vec3] ({x}, {y}, {z})"; }
	
	static toBBMOD = function() { return new BBMOD_Vec3(x, y, z); }
	
	static toArray = function() { return [ x, y, z ]; }
}

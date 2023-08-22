function __vec4(_x = 0, _y = _x, _z = _x, _w = _x) constructor {
    static set = function(_x = 0, _y = _x, _z = _x, _w = _x) {
        if (is_struct(_x)) {
			if(is_instanceof(_x, __vec4)) {
	            x = _x.x;
	            y = _x.y;
	            z = _x.z;
	            w = _x.w;
			} else if(is_instanceof(_x, __vec3)) {
	            x = _x.x;
	            y = _x.y;
	            z = _x.z;
	            w = _y;
			} 
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
        w = _w;
		
		return  self;
    } set(_x, _y, _z, _w);
	
	static setIndex = function(index, value) {
		gml_pragma("forceinline");
		switch(index) {
			case 0 : x = value; break;
			case 1 : y = value; break;
			case 2 : z = value; break;
			case 3 : w = value; break;
		}
		
		return self;
	}

	static getIndex = function(index) {
		switch(index) {
			case 0 : return x;
			case 1 : return y;
			case 2 : return z;
			case 3 : return w;
		}
		return 0;
	}
	
    static add = function(_vec4) {
        gml_pragma("forceinline");
        return new __vec4(x + _vec4.x, y + _vec4.y, z + _vec4.z, w + _vec4.w);
    }

    static subtract = function(_vec4) {
        gml_pragma("forceinline");
        return new __vec4(x - _vec4.x, y - _vec4.y, z - _vec4.z, w - _vec4.w);
    }

    static multiply = function(_scalar) {
        gml_pragma("forceinline");
        return new __vec4(x * _scalar, y * _scalar, z * _scalar, w * _scalar);
    }

    static divide = function(_scalar) {
        gml_pragma("forceinline");
        if (_scalar != 0)
            return new __vec4(x / _scalar, y / _scalar, z / _scalar, w / _scalar);

        return new __vec4(x, y, z, w); // Avoid division by zero
    }

    static dot = function(_vec4) {
        gml_pragma("forceinline");
        return x * _vec4.x + y * _vec4.y + z * _vec4.z + w * _vec4.w;
    }

    // In-place computation functions
    static _add = function(_vec4) {
        gml_pragma("forceinline");
        x += _vec4.x;
        y += _vec4.y;
        z += _vec4.z;
        w += _vec4.w;
        return self;
    }

    static _subtract = function(_vec4) {
        gml_pragma("forceinline");
        x -= _vec4.x;
        y -= _vec4.y;
        z -= _vec4.z;
        w -= _vec4.w;
        return self;
    }

    static _multiply = function(_scalar) {
        gml_pragma("forceinline");
        x *= _scalar;
        y *= _scalar;
        z *= _scalar;
        w *= _scalar;
        return self;
    }

    static _divide = function(_scalar) {
        gml_pragma("forceinline");
        if (_scalar != 0) {
            x /= _scalar;
            y /= _scalar;
            z /= _scalar;
            w /= _scalar;
        }
        return self;
    }

    static distance = function(_vec4) {
        gml_pragma("forceinline");
        var dx = _vec4.x - x;
        var dy = _vec4.y - y;
        var dz = _vec4.z - z;
        var dw = _vec4.w - w;
        return sqrt(dx * dx + dy * dy + dz * dz + dw * dw);
    }

    static length = function() {
        gml_pragma("forceinline");
        return sqrt(x * x + y * y + z * z + w * w);
    }

    static _normalize = function() {
        gml_pragma("forceinline");
        var _length = length();
        if (_length != 0) {
            x /= _length;
            y /= _length;
            z /= _length;
            w /= _length;
        }
        return self;
    }

    static _lerp = function(to, speed = 0.3) {
        gml_pragma("forceinline");
        x = lerp(x, to.x, speed);
        y = lerp(y, to.y, speed);
        z = lerp(z, to.z, speed);
        w = lerp(w, to.w, speed);
    }

    static _lerp_float = function(to, speed = 5, pre = 0.01) {
        gml_pragma("forceinline");
        x = lerp_float(x, to.x, speed, pre);
        y = lerp_float(y, to.y, speed, pre);
        z = lerp_float(z, to.z, speed, pre);
        w = lerp_float(w, to.w, speed, pre);
    }

    static equal = function(to) {
        gml_pragma("forceinline");
        return x == to.x && y == to.y && z == to.z && w == to.w;
    }

	static minVal = function(vec) {
		gml_pragma("forceinline");
		return new __vec4(
			min(x, vec.x),
			min(y, vec.y),
			min(z, vec.z),
			min(w, vec.w),
		);
	}
	
	static maxVal = function(vec) {
		gml_pragma("forceinline");
		return new __vec4(
			max(x, vec.x),
			max(y, vec.y),
			max(z, vec.z),
			max(w, vec.w),
		);
	}
	
    static clone = function() {
        gml_pragma("forceinline");
        return new __vec4(x, y, z, w);
    }

    static toString = function() { return $"[{x}, {y}, {z}, {w}]"; }
	
	static toArray = function() { return [ x, y, z, w ]; }
}

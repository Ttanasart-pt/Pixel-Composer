function __vec2(_x = 0, _y = _x) constructor {
	static set = function(_x = 0, _y = _x) {
		if(is_struct(_x) && is_instanceof(_x, __vec2)) {
			x = _x.x;
			y = _x.y;
			return self;
		}
		
		if(is_struct(_x) && is_instanceof(_x, BBMOD_Vec2)) {
			x = _x.X;
			y = _x.Y;
			return self;
		}
		
		if(is_array(_x)) {
			x = _x[0];
			y = _x[1];
			return self;
		}
		
		x = _x;
		y = _y;
		return self;
	} set(_x, _y);
	
	ref = noone;
	static setRef = function(ref = noone) {
		self.ref = ref;
		return self;
	} 
	
	static setIndex = function(index, value) {
		INLINE
		switch(index) {
			case 0 : x = value; break;
			case 1 : y = value; break;
		}
		return self;
	}
	
	static getIndex = function(index) {
		switch(index) {
			case 0 : return x;
			case 1 : return y;
		}
		return 0;
	}

	static  addElement = function(_x, _y) {
		INLINE
		return new __vec2(x + _x, y + _y);
	}
	static _addElement = function(_x, _y) {
		INLINE
		x += _x;
		y += _y;
		return self;
	}
	
	static  add = function(_vec2) {
		INLINE
		return new __vec2(x + _vec2.x, y + _vec2.y);
	}
	static _add = function(_vec2) {
		INLINE
		x += _vec2.x;
		y += _vec2.y;
		return self;
	}
	
	static  addElement = function(_x, _y) {
		INLINE
		return new __vec2(x + _x, y + _y);
	}
	static _addElement = function(_x, _y) {
		INLINE
		x += _x;
		y += _y;
		return self;
	}

	static  subtract = function(_vec2) {
		INLINE
		return new __vec2(x - _vec2.x, y - _vec2.y);
	}
	static _subtract = function(_vec2) {
		INLINE
		x -= _vec2.x;
		y -= _vec2.y;
		return self;
	}

	static  subtractElement = function(_x, _y) {
		INLINE
		return new __vec2(x - _x, y - _y);
	}
	static _subtractElement = function(_x, _y) {
		INLINE
		x -= _x;
		y -= _y;
		return self;
	}

	static  multiply = function(_scalar) {
		INLINE
		return new __vec2(x * _scalar, y * _scalar);
	}
	static _multiply = function(_scalar) {
		INLINE
		x *= _scalar;
		y *= _scalar;
		return self;
	}

	static  multiplyVec = function(_vec) {
		INLINE
		return new __vec2(x * _vec.x, y * _vec.y);
	}
	static _multiplyVec = function(_vec) {
		INLINE
		x *= _vec.x;
		y *= _vec.y;
		return self;
	}

	static  multiplyElement = function(_x, _y) {
		INLINE
		return new __vec2(x * _x, y * _y);
	}
	static _multiplyElement = function(_x, _y) {
		INLINE
		x *= _x;
		y *= _y;
		return self;
	}
	
	static  divide = function(_scalar) {
		INLINE
		if (_scalar != 0)
			return new __vec2(x / _scalar, y / _scalar);
		
		return new __vec2(x, y, z); // Avoid division by zero
	}
	static _divide = function(_scalar) {
		INLINE
		if (_scalar != 0) {
			x /= _scalar;
			y /= _scalar;
		}
		return self;
	}

	static dot = function(_vec2) {
		INLINE
		return x * _vec2.x + y * _vec2.y;
	}
	
	static distance = function(_vec2) {
		INLINE
		var dx = _vec2.x - x;
		var dy = _vec2.y - y;
		return sqrt(dx * dx + dy * dy);
	}
	
	static directionTo = function(_vec2) {
		INLINE
		return point_direction(x, y, _vec2.x, _vec2.y);
	}
	
	static length = function() {
		INLINE
		return sqrt(x * x + y * y);
	}

	static  normalize = function() {
		INLINE
		return clone()._normalize();
	}
	static _normalize = function() {
		INLINE
		var _length = length();
		if (_length != 0) {
			x /= _length;
			y /= _length;
		}
		return self;
	}
	
	static  lerpTo = function(to, speed = 0.3) {
		INLINE
		return new __vec2(lerp(x, to.x, speed), lerp(y, to.y, speed));
	}
	static _lerpTo = function(to, speed = 0.3) {
		INLINE
		x = lerp(x, to.x, speed);
		y = lerp(y, to.y, speed);
	}
	
    static _lerp_float = function(to, speed = 5, pre = 0.01) {
        INLINE
        x = lerp_float(x, to.x, speed, pre);
        y = lerp_float(y, to.y, speed, pre);
    }

	static equal = function(to) {
		INLINE
		return x == to.x && y == to.y;
	}
	
	static clone = function() {
		INLINE
		return new __vec2(x, y);
	}
	
	static toString = function() { return $"[__vec2] ({x}, {y})"; }
	
	static toBBMOD = function() { return new BBMOD_Vec2(x, y); }
	
	static toArray = function() { return [ x, y ]; }
	
	static lessThan = function(p) { return y < p.y? true : (x < p.x); }
}
function __vec2(_x = 0, _y = _x) constructor {
	static set = function(_x = 0, _y = _x) { #region
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
	} set(_x, _y); #endregion
	
	ref = noone;
	static setRef = function(ref = noone) { #region
		self.ref = ref;
		return self;
	} #endregion 
	
	static setIndex = function(index, value) { #region
		INLINE
		switch(index) {
			case 0 : x = value; break;
			case 1 : y = value; break;
		}
		return self;
	} #endregion
	
	static getIndex = function(index) { #region
		switch(index) {
			case 0 : return x;
			case 1 : return y;
		}
		return 0;
	} #endregion

	static  addElement = function(_x, _y) { #region
		INLINE
		return new __vec2(x + _x, y + _y);
	} #endregion
	static _addElement = function(_x, _y) { #region
		INLINE
		x += _x;
		y += _y;
		return self;
	} #endregion
	
	static  add = function(_vec2) { #region
		INLINE
		return new __vec2(x + _vec2.x, y + _vec2.y);
	} #endregion
	static _add = function(_vec2) { #region
		INLINE
		x += _vec2.x;
		y += _vec2.y;
		return self;
	} #endregion
	
	static  addElement = function(_x, _y) { #region
		INLINE
		return new __vec2(x + _x, y + _y);
	} #endregion
	static _addElement = function(_x, _y) { #region
		INLINE
		x += _x;
		y += _y;
		return self;
	} #endregion

	static  subtract = function(_vec2) { #region
		INLINE
		return new __vec2(x - _vec2.x, y - _vec2.y);
	} #endregion
	static _subtract = function(_vec2) { #region
		INLINE
		x -= _vec2.x;
		y -= _vec2.y;
		return self;
	} #endregion

	static  subtractElement = function(_x, _y) { #region
		INLINE
		return new __vec2(x - _x, y - _y);
	} #endregion
	static _subtractElement = function(_x, _y) { #region
		INLINE
		x -= _x;
		y -= _y;
		return self;
	} #endregion

	static  multiply = function(_scalar) { #region
		INLINE
		return new __vec2(x * _scalar, y * _scalar);
	} #endregion
	static _multiply = function(_scalar) { #region
		INLINE
		x *= _scalar;
		y *= _scalar;
		return self;
	} #endregion

	static  multiplyVec = function(_vec) { #region
		INLINE
		return new __vec2(x * _vec.x, y * _vec.y);
	} #endregion
	static _multiplyVec = function(_vec) { #region
		INLINE
		x *= _vec.x;
		y *= _vec.y;
		return self;
	} #endregion

	static  multiplyElement = function(_x, _y) { #region
		INLINE
		return new __vec2(x * _x, y * _y);
	} #endregion
	static _multiplyElement = function(_x, _y) { #region
		INLINE
		x *= _x;
		y *= _y;
		return self;
	} #endregion
	
	static  divide = function(_scalar) { #region
		INLINE
		if (_scalar != 0)
			return new __vec2(x / _scalar, y / _scalar);
		
		return new __vec2(x, y, z); // Avoid division by zero
	} #endregion
	static _divide = function(_scalar) { #region
		INLINE
		if (_scalar != 0) {
			x /= _scalar;
			y /= _scalar;
		}
		return self;
	} #endregion

	static dot = function(_vec2) { #region
		INLINE
		return x * _vec2.x + y * _vec2.y;
	} #endregion
	
	static distance = function(_vec2) { #region
		INLINE
		var dx = _vec2.x - x;
		var dy = _vec2.y - y;
		return sqrt(dx * dx + dy * dy);
	} #endregion
	
	static directionTo = function(_vec2) { #region
		INLINE
		return point_direction(x, y, _vec2.x, _vec2.y);
	} #endregion
	
	static length = function() { #region
		INLINE
		return sqrt(x * x + y * y);
	} #endregion

	static  normalize = function() { #region
		INLINE
		return clone()._normalize();
	} #endregion
	static _normalize = function() { #region
		INLINE
		var _length = length();
		if (_length != 0) {
			x /= _length;
			y /= _length;
		}
		return self;
	} #endregion
	
	static  lerpTo = function(to, speed = 0.3) { #region
		INLINE
		return new __vec2(lerp(x, to.x, speed), lerp(y, to.y, speed));
	} #endregion
	static _lerpTo = function(to, speed = 0.3) { #region
		INLINE
		x = lerp(x, to.x, speed);
		y = lerp(y, to.y, speed);
	} #endregion
	
    static _lerp_float = function(to, speed = 5, pre = 0.01) { #region
        INLINE
        x = lerp_float(x, to.x, speed, pre);
        y = lerp_float(y, to.y, speed, pre);
    } #endregion

	static equal = function(to) { #region
		INLINE
		return x == to.x && y == to.y;
	} #endregion
	
	static clone = function() { #region
		INLINE
		return new __vec2(x, y);
	} #endregion
	
	static toString = function() { return $"[__vec2] ({x}, {y})"; }
	
	static toBBMOD = function() { return new BBMOD_Vec2(x, y); }
	
	static toArray = function() { return [ x, y ]; }
}
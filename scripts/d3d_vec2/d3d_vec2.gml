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
	
	static clone = function() {
		gml_pragma("forceinline");
		return new __vec2(x, y);
	}
	
	static toString = function() { return $"[{x}, {y}]"; }
	
	static toBBMOD = function() { return new BBMOD_Vec2(x, y); }
	
	static toArray = function() { return [ x, y ]; }
}
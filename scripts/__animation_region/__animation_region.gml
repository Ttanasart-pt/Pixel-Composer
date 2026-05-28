function animationRegion() constructor {
	label      = "Region";
	color      = c_white;
	frameStart = 0;
	frameEnd   = 0;
	
	static serialize = function() {
		var _map = {
			l  : label,
			c  : color, 
			fs : frameStart,
			fe : frameEnd,	
		};
		return _map;
	}
	
	static deserialize = function(_map) {
		label      = _map.l;
		color      = _map.c;
		frameStart = _map.fs;
		frameEnd   = _map.fe;
		return self;
	}
}
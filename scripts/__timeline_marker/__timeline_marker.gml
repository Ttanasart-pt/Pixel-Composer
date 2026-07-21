function timelineMarker(_frame = 0) constructor {
	frame = _frame;
	label = "";
	color = c_white;
	
	static serialize = function() {
		var _map = {};
		
		_map.f = frame;
		_map.l = label;
		_map.c = color;
		
		return _map;
	}
	
	static deserialize = function(_map) {
		frame = _map.f;
		label = _map.l;
		color = _map.c;
		
		return self;
	}
}
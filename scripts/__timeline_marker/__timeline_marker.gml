function timelineMarker(_frame = 0) constructor {
	frame = _frame;
	label = "";
	
	static serialize = function() {
		var _map = {};
		
		_map.f = frame;
		_map.l = label;
		
		return _map;
	}
	
	static deserialize = function(_map) {
		frame = _map.f;
		label = _map.l;
		
		return self;
	}
}
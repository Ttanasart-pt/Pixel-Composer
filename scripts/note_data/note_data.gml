function Note() constructor {
	content = [];
	w = 256;
	h = 256;
	
	static draw = function() {
		
	}
	
	static serialize = function() {
		var _dat = {};
		_dat.content = [];
		return _dat;
	}
	
	static deserialize = function(_dat) {
		content = _dat.content;
		return self;
	}
}
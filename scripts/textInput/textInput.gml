function textInput(_input, _onModify) : widget() constructor {
	input		= _input;
	onModify	= _onModify;
	side_button = noone;
	selecting   = false;
	
	static _resetFocus = function() { resetFocus();	}
	
	static onKey = function(key) {}
	
	static setSideButton = function(_button) {
		self.side_button = _button;
		return self;
	}
}
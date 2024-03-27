function textInput(_input, _onModify) : widget() constructor {
	input		= _input;
	onModify	= _onModify;
	selecting   = false;
	
	typing      = false;
	
	static _resetFocus = function() { resetFocus();	}
	
	static onKey = function(key) {}
	
	static setSideButton = function(_button) { #region
		self.side_button = _button;
		return self;
	} #endregion
	
	static breakCharacter = function(ch) { return ch == " " || ch == "\n"; }
}
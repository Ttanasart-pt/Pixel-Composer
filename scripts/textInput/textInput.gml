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
	
	static clone = function() { 
		var _onModify = onModify;
		onModify = noone;
		
		var cln = variable_clone(self); 
		cln.onModify = _onModify;
		    onModify = _onModify;
			
		return cln;
	}
}
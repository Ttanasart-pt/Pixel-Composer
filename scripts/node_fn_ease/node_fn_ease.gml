function Node_Fn_Ease(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name = "Ease";
	
	inputs[| inl + 0] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.slider_range );
		
	inputs[| inl + 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.1, 0.9 ] )
		.setDisplay(VALUE_DISPLAY.slider_range );
		
	inputs[| inl + 2] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Cubic poly", "Quadratic rat", "Cubic rat", "Cosine" ] );
		
	array_append(input_display_list, [
		["Value",	false], inl + 0, inl + 1, inl + 2, 
	]);
	
	rang  = [ 0, 1 ];
	ease  = [ 0, 1 ];
	type  = 0;
	
	static __smooth = function(_x = 0) {
		switch(type) {
			case 0 : return _x * _x * (3.0 - 2.0 * _x);
			case 1 : return _x * _x / (2.0 * _x * _x - 2.0 * _x + 1.0);
			case 2 : return _x * _x * _x / (3.0 * _x * _x - 3.0 * _x + 1.0);
			case 3 : return 0.5 - 0.5 * cos(pi * _x);
		}
		
		return _x;
	}
	
	static __fnEval = function(_x = 0) {
		if(_x < rang[0] || _x > rang[1]) return 0;
		
		var _eo = 1 - ease[1];
		
		var _v = clamp(min(
			ease[0] == 0? 1 : (_x - rang[0]) / ease[0],
			_eo     == 0? 1 : 1 - (_x - (rang[1] - _eo)) / _eo,
		), 0, 1);
		
		return __smooth(_v);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		rang = _data[inl + 0];
		ease = _data[inl + 1];
		type = _data[inl + 2];
		
		var val = __fnEval(CURRENT_FRAME / TOTAL_FRAMES);
		text_display = val;
		
		return val;
	} #endregion
	
}
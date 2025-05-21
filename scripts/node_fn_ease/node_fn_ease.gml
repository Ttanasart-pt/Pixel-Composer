function Node_Fn_Ease(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name = "Ease";
	
	newInput(inl + 0, nodeValue_Slider_Range("Range", [ 0, 1 ]  ));
		
	newInput(inl + 1, nodeValue_Slider_Range("Amount", [ 0.1, 0.9 ]  ));
		
	newInput(inl + 2, nodeValue_Enum_Scroll("Smooth",  0 , [ "Cubic poly", "Quadratic rat", "Cubic rat", "Cosine" ] ));
		
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
	
	static processData = function(_output, _data, _array_index = 0) { #region
		rang = _data[inl + 0];
		ease = _data[inl + 1];
		type = _data[inl + 2];
		
		var val = __fnEval(CURRENT_FRAME / TOTAL_FRAMES);
		text_display = val;
		
		return val;
	} #endregion
	
}
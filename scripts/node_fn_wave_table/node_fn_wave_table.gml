function Node_Fn_WaveTable(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name = "WaveTable";
	
	inputs[| inl + 0] = nodeValue_Float("Pattern", self, 0 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 3, 0.01] });
		
	inputs[| inl + 1] = nodeValue_Vector("Range", self, [ 0, 1 ]);
	
	inputs[| inl + 2] = nodeValue_Float("Frequency", self, 2 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 8, 0.01] });
	
	array_append(input_display_list, [
		["Wave",	false], inl + 0, inl + 1, inl + 2, 
	]);
	
	pattern   = 0;
	frequency = 0;
	range_min = 0;
	range_max = 0;
	
	function getPattern(_patt, _x) {
		switch(_patt % 3) {
			case 0 : return sin(_x * pi * 2);
			case 1 : return frac(_x) < 0.5? 1 : -1;
			case 2 : return frac(_x + 0.5) * 2 - 1;
		}
		
		return 0;
	}
	
	static __fnEval = function(_x = 0) {
		var _p0 = floor(pattern);
		var _p1 = floor(pattern) + 1;
		var _fr = frac(pattern);
		
		var _v0  = getPattern(_p0, _x * frequency) * .5 + .5;
		var _v1  = getPattern(_p1, _x * frequency) * .5 + .5;
		var _lrp = lerp(_v0, _v1, _fr);
		
		return lerp(range_min, range_max, _lrp);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		pattern     = _data[inl + 0];
		var ran     = _data[inl + 1];
		range_min   = array_safe_get_fast(ran, 0);
		range_max   = array_safe_get_fast(ran, 1);
		
		frequency   = _data[inl + 2];
		
		var val = __fnEval(CURRENT_FRAME / TOTAL_FRAMES);
		text_display = val;
		
		return val;
	} #endregion
	
}
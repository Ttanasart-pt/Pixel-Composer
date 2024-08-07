function Node_Fn_Constant(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name = "Constant";
	
	inputs[| inl + 0] = nodeValue_Float("Value", self, 0 );
		
	array_append(input_display_list, [
		["Value",	false], inl + 0
	]);
	
	value = 0;
	
	static __fnEval = function(_x = 0) {
		return value;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		value = _data[inl + 0];
		
		var val = __fnEval(CURRENT_FRAME / TOTAL_FRAMES);
		text_display = val;
		
		return val;
	} #endregion
	
}
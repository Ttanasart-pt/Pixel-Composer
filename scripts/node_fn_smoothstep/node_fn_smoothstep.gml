function Node_Fn_SmoothStep(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name       = "SmoothStep";
	time_based = false;
	
	inputs[inl + 0] = nodeValue_Float("Value", self, 0 )
		.setVisible(true, true);
	
	newInput(inl + 1, nodeValue_Enum_Scroll("Type", self,  0 , [ "Cubic poly", "Quadratic rat", "Cubic rat", "Cosine" ] ));
	
	array_append(input_display_list, [
		["Value",	false], inl + 1, inl + 0, 
	]);
	
	type  = 0;
	value = 0;
	
	static __fnEval = function(_x = 0) {
		switch(type) {
			case 0 : return _x * _x * (3.0 - 2.0 * _x);
			case 1 : return _x * _x / (2.0 * _x * _x - 2.0 * _x + 1.0);
			case 2 : return _x * _x * _x / (3.0 * _x * _x - 3.0 * _x + 1.0);
			case 3 : return 0.5 - 0.5 * cos(pi * _x);
		}
		
		return _x;
	}
	
	static refreshDisplayX = function(i) { 
		var _fr = inputs[inl + 0].value_from;
		if(_fr != noone && is_instanceof(_fr.node, Node_Fn)) 
			return _fr.node.getDisplayX(i);
		return i / graph_res; 
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		value = _data[inl + 0];
		type  = _data[inl + 1];
		
		var val = __fnEval(value);
		
		text_display = val;
		return val;
	} #endregion
	
}
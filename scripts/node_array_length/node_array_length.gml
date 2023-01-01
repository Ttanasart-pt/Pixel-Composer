function Node_Array_Length(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name		= "Array Length";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Size", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	function process_data(_output, _data, index = 0) { 
		var _arr = _data[0];
		if(!is_array(_arr)) return 0;
		
		return array_length(_arr);
	}
}
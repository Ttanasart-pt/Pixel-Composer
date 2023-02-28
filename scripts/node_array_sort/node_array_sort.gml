function Node_Array_Sort(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Sort Array";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [])
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Ascending", "Descending" ])
		.rejectArray();
	
	outputs[| 0] = nodeValue("Sorted array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var arr = inputs[| 0].getValue();
		var asc = inputs[| 1].getValue();
		
		inputs[| 0].type = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
			
		if(!is_array(arr)) return;
		
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].type = inputs[| 0].value_from.type;
			outputs[| 0].type = inputs[| 0].value_from.type;
		}
		
		var _arr = array_clone(arr);
		array_sort(_arr, bool(!asc));
		
		outputs[| 0].setValue(_arr);
	}
}
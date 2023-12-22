function Node_Iterator_Sort_Inline_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sort Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	
	manual_ungroupable	 = false;
	
	inputs[| 0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Value 1", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	
	outputs[| 1] = nodeValue("Value 2", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	
	static onGetPreviousNodes = function(arr) {
		array_push(arr, loop);
	}
	
}
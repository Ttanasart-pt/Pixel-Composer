function Node_Iterator_Sort_Inline_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sort Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	clonable = false;
	inline_parent_object = "Node_Iterate_Sort_Inline";
	manual_ungroupable	 = false;
	
	inputs[0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[0] = nodeValue_Output("Value 1", self, VALUE_TYPE.any, 0 );
	
	outputs[1] = nodeValue_Output("Value 2", self, VALUE_TYPE.any, 0 );
	
	startSort = false;
	
	static onGetPreviousNodes = function(arr) {
		array_push(arr, loop);
	}
	
	static update = function() {
		if(startSort) {
			startSort = false;
			loop.sortArray();
		}
	}
}
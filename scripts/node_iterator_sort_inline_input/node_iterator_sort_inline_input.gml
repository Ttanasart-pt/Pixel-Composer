function Node_Iterator_Sort_Inline_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sort Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	clonable = false;
	inline_input         = false;
	inline_parent_object = "Node_Iterate_Sort_Inline";
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Array in", self, CONNECT_TYPE.input, VALUE_TYPE.any, [] ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Value 1", self, VALUE_TYPE.any, 0 ));
	
	newOutput(1, nodeValue_Output("Value 2", self, VALUE_TYPE.any, 0 ));
	
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
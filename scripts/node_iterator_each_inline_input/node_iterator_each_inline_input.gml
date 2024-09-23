function Node_Iterator_Each_Inline_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	clonable = false;
	inline_parent_object = "Node_Iterate_Each_Inline";
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Array in", self, CONNECT_TYPE.input, VALUE_TYPE.any, [] ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Value in", self, VALUE_TYPE.any, 0 ));
	
	static onGetPreviousNodes = function(arr) {
		array_push(arr, loop);
	}
	
	static update = function() {
		if(!is_instanceof(loop, Node_Iterate_Each_Inline)) return;
		
		var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
		
		var val = inputs[0].getValue();
		var itr = loop.iterated - 1;
		
		if(!is_array(val)) return;
		
		outputs[0].setValue(array_safe_get_fast(val, itr));
	}
}
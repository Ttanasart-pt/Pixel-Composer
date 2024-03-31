function Node_Iterator_Filter_Inline_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Filter Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	
	manual_ungroupable	 = false;
	
	inputs[| 0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Value in", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	
	static onGetPreviousNodes = function(arr) {
		array_push(arr, loop);
	}
	
	static update = function() { #region
		if(!is_instanceof(loop, Node_Iterate_Filter_Inline)) return;
		
		var _typ = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].setType(_typ);
		outputs[| 0].setType(_typ);
		
		var val = inputs[| 0].getValue();
		var itr = loop.iterated - 1;
		
		outputs[| 0].setValue(array_safe_get_fast(val, itr));
	} #endregion
}
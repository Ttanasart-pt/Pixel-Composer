function Node_Iterator_Sort_Inline_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sort result";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	clonable = false;
	inline_parent_object = "Node_Iterate_Sort_Inline";
	manual_ungroupable	 = false;
	
	inputs[| 0] = nodeValue("Swap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Array out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, [] );
}
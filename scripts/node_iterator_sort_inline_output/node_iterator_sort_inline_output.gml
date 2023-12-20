function Node_Iterator_Sort_Inline_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sort result";
	color = COLORS.node_blend_loop;
	loop  = noone;
	
	inputs[| 0] = nodeValue("Swap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Array out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, [] );
}
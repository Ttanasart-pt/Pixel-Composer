function Node_Iterator_Sort_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sort Input";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Value in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(false, false);
	
	outputs[| 0] = nodeValue("Value in", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	
	static update = function() {
		outputs[| 0].type = inputs[| 0].type;
		
		var val = getInputData(0);
		outputs[| 0].setValue(val);
	}
	
}
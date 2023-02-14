function Node_Iterator_Each_Input(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name  = "Input";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	outputs[| 0] = nodeValue("Value in", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 );
	outputs[| 0].getValueDefault = method(outputs[| 0], outputs[| 0].getValueRecursive); //Get value from outside loop
	outputs[| 0].getValueRecursive = function() {
		if(!variable_struct_exists(group, "iterated"))
			return outputs[| 0].getValueDefault();
			
		var ind = group.iterated;
		var val = group.inputs[| 0].getValue();
		
		return [ array_safe_get(val, ind), group.inputs[| 0] ];
	}
	
	static step = function() {
		if(!variable_struct_exists(group, "iterated")) return;
		
		outputs[| 0].type = group.inputs[| 0].type;
	}
	
}
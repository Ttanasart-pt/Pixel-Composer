function Node_Iterator_Input(_x, _y, _group = noone) : Node_Group_Input(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	is_group_io  = true;
	local_output = noone;
	
	manual_ungroupable	 = false;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	outputs[| 0].getValueDefault = method(outputs[| 0], outputs[| 0].getValueRecursive); //Get value from outside loop
	
	outputs[| 0].getValueRecursive = function() {
		if(!struct_has(group, "iterated"))
			return outputs[| 0].getValueDefault();
		
		var _to = outputs[| 1].getJunctionTo();
		
		// Not connect to any loop output
		if(array_empty(_to))
			return [ noone, inParent ];
		
		var _node_output = _to[0];
		
		// First iteration, get value from outside
		if(_node_output == noone || group.iterated == 0) {
			var _def = outputs[| 0].getValueDefault();
			return [ variable_clone(_def[0]), _def[1] ];
		}
		
		// Later iteration, get value from output
		return [ _node_output.node.cache_value, inParent ];
	}
	
	outputs[| 1] = nodeValue("Loop entrance", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, 0)
		.nonForward();
}
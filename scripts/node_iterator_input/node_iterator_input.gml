function Node_Iterator_Input(_x, _y, _group = noone) : Node_Group_Input(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	is_group_io  = true;
	local_output = noone;
	
	manual_ungroupable	 = false;
	setDimension(96, 48);
	
	outputs[0].getValueDefault = method(outputs[0], outputs[0].getValueRecursive); //Get value from outside loop
	
	outputs[0].getValueRecursive = function(arr) {
		if(!struct_has(group, "iterated"))
			return outputs[0].getValueDefault(arr);
		
		var _to = outputs[1].getJunctionTo();
		
		// Not connect to any loop output
		if(array_empty(_to)) {
			arr[@ 0] = noone;
			arr[@ 1] = inParent;
			return;
		}
		
		var _node_output = _to[0];
		
		// First iteration, get value from outside
		if(_node_output == noone || group.iterated == 0) {
			outputs[0].getValueDefault(arr);
			arr[@ 0] = variable_clone(arr[@ 0]);
			return;
		}
		
		// Later iteration, get value from output
		arr[@ 0] = _node_output.node.cache_value;
		arr[@ 1] = inParent;
	}
	
	newOutput(1, nodeValue_Output("Loop entrance", self, VALUE_TYPE.node, 0))
		.nonForward();
}
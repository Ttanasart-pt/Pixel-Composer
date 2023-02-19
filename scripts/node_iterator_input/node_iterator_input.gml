function Node_Iterator_Input(_x, _y, _group = -1) : Node_Group_Input(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	
	local_output = noone;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	cache_value = -1;
	
	outputs[| 0].getValueDefault = method(outputs[| 0], outputs[| 0].getValueRecursive); //Get value from outside loop
	outputs[| 0].getValueRecursive = function() {
		//show_debug_message("iteration " + string(group.iterated));
		if(!variable_struct_exists(group, "iterated"))
			return outputs[| 0].getValueDefault();
			
		var _node_output = noone;
		for( var i = 0; i < ds_list_size(outputs[| 1].value_to); i++ ) {
			var vt = outputs[| 1].value_to[| i];
			if(vt.value_from == outputs[| 1])
				_node_output = vt;
		}
		
		if(_node_output == noone || group.iterated == 0)
			return outputs[| 0].getValueDefault();
		
		return [ _node_output.node.cache_value, inParent ];
	}
	
	outputs[| 1] = nodeValue("Loop entrance", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, 0);	
}
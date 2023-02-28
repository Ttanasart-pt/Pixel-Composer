function Node_Feedback_Input(_x, _y, _group = noone) : Node_Group_Input(_x, _y, _group) constructor {
	name  = "Feedback Input";
	color = COLORS.node_blend_feedback;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	outputs[| 0].getValueDefault = method(outputs[| 0], outputs[| 0].getValueRecursive); //Get value from outside loop
	outputs[| 0].getValueRecursive = function(_time) {
		var _node_output = noone;
		for( var i = 0; i < ds_list_size(outputs[| 1].value_to); i++ ) {
			var vt = outputs[| 1].value_to[| i];
			if(vt.value_from == outputs[| 1])
				_node_output = vt;
		}
		
		if(ANIMATOR.current_frame > 0 && _node_output != noone && _node_output.node.cache_value != noone) //use cache from output 
			return [ _node_output.node.cache_value, inParent ];
		
		return outputs[| 0].getValueDefault();
	}
	
	outputs[| 1] = nodeValue("Feedback loop", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, 0);
}
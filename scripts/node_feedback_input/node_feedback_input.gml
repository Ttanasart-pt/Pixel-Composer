function Node_Feedback_Input(_x, _y, _group = -1) : Node_Group_Input(_x, _y, _group) constructor {
	name  = "Input";
	color = COLORS.node_blend_feedback;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	outputs[| 0].getValueRecursive = function(_time) {
		var _node_output = noone;
		for( var i = 0; i < ds_list_size(outputs[| 1].value_to); i++ ) {
			var vt = outputs[| 1].value_to[| i];
			if(vt.value_from == outputs[| 1])
				_node_output = vt;
		}
		
		if(ANIMATOR.current_frame > 1 && _node_output != noone)
			return [ _node_output.node.cache_value, inputs[| 2].getValue() ];
		
		if(inParent.value_from == noone)
			return [ -1, VALUE_TYPE.any ];
		return inParent.value_from.getValueRecursive(_time); 
	}
	
	outputs[| 1] = nodeValue(1, "Feedback loop", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, 0);
}
function Node_Feedback_Output(_x, _y, _group = -1) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Output";
	color = COLORS.node_blend_feedback;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	inputs[| 2] = nodeValue(2, "Feedback loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, -1)
		.setVisible(true, true);
	
	cache_value = -1;
	
	static update = function() {			
		var _val_get = inputs[| 0].getValue();
		
		switch(inputs[| 0].type) {
			case VALUE_TYPE.surface	: 
				if(is_surface(cache_value)) 
					surface_free(cache_value);
				if(is_surface(_val_get))
					cache_value = surface_clone(_val_get);
				break;
			default : 
				cache_value = _val_get;
		}
	}
}
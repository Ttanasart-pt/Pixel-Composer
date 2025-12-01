function Node_Feedback_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Feedback Output";
	color = COLORS.node_blend_feedback;
	is_group_io = true;
	loopable    = false;
	
	setDimension(96, 48);
	
	newInput(1, nodeValue("Feedback loop", self, CONNECT_TYPE.input, VALUE_TYPE.node, -1))
		.setVisible(true, true);
	
	cache_value = -1;
	
	static update = function(frame = CURRENT_FRAME) {
		if(inputs[0].value_from == noone) return;
		if(IS_LAST_FRAME) {
			cache_value = noone;
			return;
		}
		
		var _val_get = getInputData(0);
		var _arr     = inputs[0].value_from.isArray(inputs[0].value_from.getValue());
		var is_surf	 = inputs[0].type == VALUE_TYPE.surface;
		
		if(is_array(cache_value)) {
			for( var i = 0, n = array_length(cache_value); i < n; i++ ) {
				if(is_surface(cache_value[i])) 
					surface_free(cache_value[i]);
			}
		} else if(is_surface(cache_value)) 
			surface_free(cache_value);
		
		if(_arr) {
			var amo = is_array(_val_get)? array_length(_val_get) : 0;
			cache_value = array_create(amo);
			
			if(is_surf) {
				for( var i = 0; i < amo; i++ ) {
					if(is_surface(_val_get[i]))	
						cache_value[i] = surface_clone(_val_get[i]);
				}
			} else 
				cache_value = _val_get;
		} else {
			if(is_surf) {
				if(is_surface(_val_get))	
					cache_value = surface_clone(_val_get);
			} else
				cache_value = _val_get;
		}
	}
}
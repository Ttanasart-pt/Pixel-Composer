function Node_Fluid(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	static updateForward = function(frame = ANIMATOR.current_frame, _update = true) {
		if(_update) update(frame);
		print("Update " + string(frame) + ": " + name);
		
		var outJunc = outputs[| 0];
		for( var i = 0; i < ds_list_size(outJunc.value_to); i++ ) {
			var _to = outJunc.value_to[| i];
			if(_to.value_from != outJunc) continue;
			if(!struct_has(_to.node, "updateForward")) continue;
			
			_to.node.updateForward(frame);
		}
	}
}
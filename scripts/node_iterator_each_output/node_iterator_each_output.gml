function Node_Iterator_Each_Output(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name  = "Output";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Value out", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Preview", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 )
		.setVisible(false);
	
	static getNextNodes = function() {
		if(!struct_has(group, "iterationStatus")) return;
		var _ren = group.iterationStatus();
			
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			printIf(global.RENDER_LOG, "    > Loop restart: iteration " + string(group.iterated));
			__nodeLeafList(group.nodes, RENDER_QUEUE);
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			printIf(global.RENDER_LOG, "    > Loop completed");
			group.setRenderStatus(true);
			
			var _ot = group.outputs[| 0];
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				
				if(_to.node.active && _to.value_from != noone && _to.value_from.node == group) {
					_to.node.triggerRender();
					if(_to.node.isUpdateReady()) ds_queue_enqueue(RENDER_QUEUE, _to.node);
				}
			}
		} else 
			printIf(global.RENDER_LOG, "    > Loop not ready");
	}
	
	static step = function() {
		if(!variable_struct_exists(group, "iterated")) return;
		
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].type = type;
		group.outputs[| 0].type = type;
		outputs[| 0].type = type;
	}
	
	static cloneValue = function(_prev_val, _val) {
		if(inputs[| 0].value_from == noone) return _prev_val;
		
		var _arr     = inputs[| 0].value_from.isArray();
		var is_surf	 = inputs[| 0].value_from.type == VALUE_TYPE.surface;
		
		if(is_array(_prev_val)) {
			for( var i = 0; i < array_length(_prev_val); i++ ) {
				if(is_surf && is_surface(_prev_val[i])) 
					surface_free(_prev_val[i]);
			}
		} else if(is_surf && is_surface(_prev_val)) 
			surface_free(_prev_val);
		
		var _new_val = 0;
		if(_arr) {
			var amo  = array_length(_val);
			_new_val = array_create(amo);
			
			if(is_surf) {
				for( var i = 0; i < amo; i++ ) {
					if(is_surface(_val[i]))	
						_new_val[i] = surface_clone(_val[i]);
				}
			} else 
				_new_val = _val;
		} else {
			if(is_surf) {
				if(is_surface(_val))	
					_new_val = surface_clone(_val);
			} else
				_new_val = _val;
		}
		
		return _new_val;
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(inputs[| 0].value_from == noone) 
			return;
		
		if(!variable_struct_exists(group, "iterated"))
			return;
			
		var ind = group.iterated;
		var _val = group.outputs[| 0].getValue();
		if(!is_array(_val)) return;
		
		_val[ind] = cloneValue(array_safe_get(_val, ind), inputs[| 0].getValue());
		group.outputs[| 0].setValue(_val);
		outputs[| 0].setValue(_val);
	}
}
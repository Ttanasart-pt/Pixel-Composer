function Node_Iterator_Each_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Value out", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Preview", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 )
		.setVisible(false);
	
	static getNextNodesRaw = function() {
		var nodes = [];
		
		var _ot = group.outputs[| 0];
		for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
			var _to = _ot.value_to[| j];
			if(!_to.node.renderActive) continue;
				
			if(_to.node.active && _to.value_from != noone && _to.value_from.node == group) {
				if(_to.node.isRenderable()) 
					array_push(nodes, _to.node);
			}
		}
		
		return nodes;
	}
	
	static getNextNodes = function() {
		if(!struct_has(group, "iterationStatus")) return [];
		var _ren  = group.iterationStatus();
		var nodes = [];
		
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, "Call get next node from loop output.");
		
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			LOG_IF(global.FLAG.render, "Loop restart: iteration " + string(group.iterated));
		 	nodes = array_append(nodes, __nodeLeafList(group.getNodeList()));
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			LOG_IF(global.FLAG.render, "Loop completed");
			group.setRenderStatus(true);
			nodes = getNextNodesRaw();
		} else 
			LOG_IF(global.FLAG.render, "Loop not ready");
			
		LOG_BLOCK_END();
			
		return nodes;
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
		
		var is_surf	 = inputs[| 0].value_from.type == VALUE_TYPE.surface;
		var _new_val = [];
		
		surface_array_free(_prev_val);
		if(is_surf)	_new_val = surface_array_clone(_val);
		else		_new_val = array_clone(_val);
		
		return _new_val;
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(!variable_struct_exists(group, "iterated")) 
			return;
			
		if(inputs[| 0].value_from == noone) {
			group.iterationUpdate();
			return;
		}
			
		var ind = group.iterated;
		var _val = group.outputs[| 0].getValue();
		if(!is_array(_val)) {
			group.iterationUpdate();
			return;
		}
		
		_val[@ ind] = cloneValue(array_safe_get(_val, ind), inputs[| 0].getValue());
		
		outputs[| 0].setValue(_val);
		group.outputs[| 0].setValue(_val);
		group.iterationUpdate();
	}
}
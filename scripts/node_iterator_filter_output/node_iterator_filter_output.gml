function Node_Iterator_Filter_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Filter Output";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, false )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Result", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true);
		
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
		LOG_IF(global.RENDER_LOG, "Call get next node from loop output.");
		
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			LOG_IF(global.RENDER_LOG, "Loop restart: iteration " + string(group.iterated));
			nodes = array_append(nodes, __nodeLeafList(group.getNodeList()));
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			LOG_IF(global.RENDER_LOG, "Loop completed");
			group.setRenderStatus(true);
			nodes = getNextNodesRaw();
		} else 
			LOG_IF(global.RENDER_LOG, "Loop not ready");
		
		LOG_BLOCK_END();
		
		return nodes;
	}
	
	static step = function() {
		if(!variable_struct_exists(group, "iterated")) return;
		
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].type = type;
		group.outputs[| 0].type = type;
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(inputs[| 0].value_from == noone) 
			return;
		if(!variable_struct_exists(group, "iterated"))
			return;
			
		var val = inputs[| 0].getValue();
		var res = inputs[| 1].getValue();
			
		var _val = group.outputs[| 0].getValue();
		if(!is_array(_val)) return;
		
		if(res) {
			var is_surf	 = inputs[| 0].value_from.type == VALUE_TYPE.surface;
			var _new_val = val;
			if(is_surf)	_new_val = surface_array_clone(val);
			else		_new_val = array_clone(val);
			array_push(_val, _new_val);
		}
		
		LOG_IF(global.RENDER_LOG, "Value " + string(val) + " filter result " + string(res) + " to array " + string(_val));
		
		group.outputs[| 0].setValue(_val);
		group.iterationUpdate();
	}
}
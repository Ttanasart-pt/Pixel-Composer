function Node_Iterator_Filter_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Filter Output";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, false )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Result", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true);
		
	static getNextNodes = function() {
		if(!struct_has(group, "iterationStatus")) return;
		var _ren = group.iterationStatus();
			
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			printIf(global.RENDER_LOG, "    > Loop restart: iteration " + string(group.iterated));
			__nodeLeafList(group.getNodeList(), RENDER_QUEUE);
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			printIf(global.RENDER_LOG, "    > Loop completed");
			group.setRenderStatus(true);
			
			var _ot = group.outputs[| 0];
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				if(!_to.node.renderActive) continue;
				
				if(_to.node.active && _to.value_from != noone && _to.value_from.node == group) {
					_to.node.triggerRender();
					if(_to.node.isRenderable()) ds_queue_enqueue(RENDER_QUEUE, _to.node);
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
		
		group.outputs[| 0].setValue(_val);
	}
}
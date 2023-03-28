function Node_Iterator_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	inputs[| 0].setFrom_condition = function(_valueFrom) {
		if(instanceof(_valueFrom.node) != "Node_Iterator_Input") return true;
		if(inputs[| 2].value_from == noone) return true;
		if(inputs[| 2].value_from.node == _valueFrom.node) {
			noti_warning("setFrom: Immediate cycle disallowed",, self);
			return false;
		}
		return true;
	}
	
	inputs[| 2] = nodeValue("Loop exit", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, -1)
		.setVisible(true, true);
	
	inputs[| 2].setFrom_condition = function(_valueFrom) {
		if(instanceof(_valueFrom.node) != "Node_Iterator_Input") return true;
		if(inputs[| 0].value_from == noone) return true;
		if(inputs[| 0].value_from.node == _valueFrom.node) {
			noti_warning("setFrom: Immediate cycle disallowed",, self);
			return false;
		}
		return true;
	}
	
	cache_value = -1;
	
	static getNextNodes = function() {
		var nodes	 = [];
		var _node_it = group;
		if(!struct_has(_node_it, "iterationStatus")) return nodes;
		var _ren = _node_it.iterationStatus();
			
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			printIf(global.RENDER_LOG, "    > Loop restart: iteration " + string(group.iterated));
			nodes = array_append(nodes, __nodeLeafList(group.getNodeList()));
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			printIf(global.RENDER_LOG, "    > Loop completed");
			group.setRenderStatus(true);
			var _ot = outParent;
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				if(!_to.node.renderActive) continue;
				
				if(_to.node.active && _to.value_from != noone && _to.value_from.node == group) {
					if(_to.node.isRenderable()) 
						array_push(nodes, _to.node);
				}
			}
		} else 
			printIf(global.RENDER_LOG, "    > Loop not ready");
			
		return nodes;
	}
	
	static initLoop = function() {
		cache_value = noone;
	}
	
	static cloneValue = function(_prev_val, _val) {
		if(inputs[| 0].value_from == noone) return _prev_val;
		
		var is_surf	 = inputs[| 0].value_from.type == VALUE_TYPE.surface;
		var _new_val;
		
		surface_array_free(_prev_val);
		if(is_surf)
			_new_val = surface_array_clone(_val);
		else 
			_new_val = array_clone(_val);
		
		return _new_val;
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(inputs[| 0].value_from == noone) return;
		
		var _val = inputs[| 0].getValue();
		cache_value = cloneValue(cache_value, _val);
	}
}
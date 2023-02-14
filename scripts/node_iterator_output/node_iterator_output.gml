
function Node_Iterator_Output(_x, _y, _group = -1) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Output";
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
		var _node_it = group;
		if(!struct_has(_node_it, "iterationStatus")) return;
		var _ren = _node_it.iterationStatus();
			
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			printIf(global.RENDER_LOG, "    > Loop restart: iteration " + string(group.iterated));
			__nodeLeafList(group.nodes, RENDER_QUEUE);
			
			//var loopEnt = inputs[| 2].value_from.node;
			//ds_queue_enqueue(RENDER_QUEUE, loopEnt);
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			printIf(global.RENDER_LOG, "    > Loop completed");
			group.setRenderStatus(true);
			var _ot = outParent;
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
	
	static initLoop = function() {
		cache_value = noone;
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
		if(inputs[| 0].value_from == noone) return;
		
		var _val = inputs[| 0].getValue();
		cache_value = cloneValue(cache_value, _val);
	}
}
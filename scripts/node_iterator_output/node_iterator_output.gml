function Node_Iterator_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	inputs[| 0].setFrom_condition = function(_valueFrom) { #region
		if(instanceof(_valueFrom.node) != "Node_Iterator_Input") return true;
		if(inputs[| 1].isLeaf()) return true;
		if(inputs[| 1].value_from.node == _valueFrom.node) {
			noti_warning("setFrom: Immediate cycle disallowed",, self);
			return false;
		}
		return true;
	} #endregion
	
	inputs[| 1] = nodeValue("Loop exit", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, -1)
		.uncache()
		.setVisible(true, true);
	
	inputs[| 1].setFrom_condition = function(_valueFrom) { #region
		if(instanceof(_valueFrom.node) != "Node_Iterator_Input") return true;
		if(inputs[| 0].isLeaf()) return true;
		if(inputs[| 0].value_from.node == _valueFrom.node) {
			noti_warning("setFrom: Immediate cycle disallowed",, self);
			return false;
		}
		return true;
	} #endregion
	
	cache_value = -1;
	
	static getNextNodes = function() { #region
		if(!struct_has(group, "outputNextNode")) return [];
		return group.outputNextNode();
	} #endregion
	
	static initLoop = function() { #region
		cache_value = noone;
	} #endregion
	
	static cloneValue = function(_prev_val, _val) { #region
		if(inputs[| 0].isLeaf()) return _prev_val;
		
		var is_surf	 = inputs[| 0].value_from.type == VALUE_TYPE.surface;
		var _new_val;
		
		surface_array_free(_prev_val);
		_new_val = is_surf? surface_array_clone(_val) : array_clone(_val);
		
		return _new_val;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(inputs[| 0].isLeaf()) {
			group.iterationUpdate();
			return;
		}
		
		var _val = getInputData(0);
		cache_value = cloneValue(cache_value, _val);
		group.iterationUpdate();
	} #endregion
}
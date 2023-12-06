function Node_Iterator_Each_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Value out", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Preview", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0 )
		.setVisible(false, false);
	
	static getNextNodes = function() { #region
		if(!struct_has(group, "outputNextNode")) return [];
		return group.outputNextNode();
	} #endregion
	
	static step = function() { #region
		if(!variable_struct_exists(group, "iterated")) return;
		
		var type = inputs[| 0].isLeaf()? VALUE_TYPE.any : inputs[| 0].value_from.type;
		
		inputs[| 0].setType(type);
		group.outputs[| 0].setType(type);
		
		if(outputs[| 0].setType(type))
			will_setHeight = true;
	} #endregion
	
	static cloneValue = function(_prev_val, _val) { #region
		if(inputs[| 0].isLeaf()) return _prev_val;
		
		var is_surf	 = inputs[| 0].value_from.type == VALUE_TYPE.surface;
		var _new_val = [];
		
		if(!is_instanceof(inputs[| 0].value_from.node, Node_Iterator_Each_Input)) 
			surface_array_free(_prev_val);
			
		if(is_surf)	_new_val = surface_array_clone(_val);
		else		_new_val = array_clone(_val);
		
		return _new_val;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(inputs[| 0].isLeaf()) {
			group.iterationUpdate();
			return;
		}
			
		var ind  = group.iterated;
		var _val = group.outputs[| 0].getValue();
		if(!is_array(_val)) {
			group.iterationUpdate();
			return;
		}
		
		_val[@ ind] = cloneValue(array_safe_get(_val, ind), getInputData(0));
		
		outputs[| 0].setValue(_val);
		group.outputs[| 0].setValue(_val);
		group.iterationUpdate();
	} #endregion
	
	static onLoadGroup = function() { #region
		if(group == noone) nodeDelete(self);
	} #endregion
}
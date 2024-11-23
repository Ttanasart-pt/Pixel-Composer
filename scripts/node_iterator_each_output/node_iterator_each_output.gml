function Node_Iterator_Each_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	manual_deletable = false;
	
	newInput(0, nodeValue("Value out", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ))
		.setVisible(true, true);
		
	newOutput(0, nodeValue_Output("Preview", self, VALUE_TYPE.any, 0 ))
		.setVisible(false, false);
	
	static getNextNodes = function() {
		if(!struct_has(group, "outputNextNode")) return [];
		return group.outputNextNode();
	}
	
	static step = function() {
		if(!variable_struct_exists(group, "iterated")) return;
		
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		
		inputs[0].setType(type);
		group.outputs[0].setType(type);
	}
	
	static cloneValue = function(_prev_val, _val) {
		if(inputs[0].value_from == noone) return _prev_val;
		
		var is_surf	 = inputs[0].value_from.type == VALUE_TYPE.surface;
		var _new_val = [];
		
		if(!is_instanceof(inputs[0].value_from.node, Node_Iterator_Each_Input)) 
			surface_array_free(_prev_val);
			
		if(is_surf)	_new_val = surface_array_clone(_val);
		else		_new_val = array_clone(_val);
		
		return _new_val;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(inputs[0].value_from == noone) {
			group.iterationUpdate();
			return;
		}
			
		var ind  = group.iterated;
		var _val = group.outputs[0].getValue();
		if(!is_array(_val)) {
			group.iterationUpdate();
			return;
		}
		
		_val[@ ind] = cloneValue(array_safe_get_fast(_val, ind), getInputData(0));
		
		outputs[0].setValue(_val);
		group.outputs[0].setValue(_val);
		group.iterationUpdate();
	}
	
	static onLoadGroup = function() {
		if(group == noone) destroy();
	}
}
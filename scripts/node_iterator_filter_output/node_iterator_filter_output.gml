function Node_Iterator_Filter_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Filter Output";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, false )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Result", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true);
		
	static getNextNodes = function() {
		if(!struct_has(group, "outputNextNode")) return [];
		return group.outputNextNode();
	}
	
	static step = function() {
		if(!variable_struct_exists(group, "iterated")) return;
		
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].type = type;
		group.outputs[| 0].type = type;
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		if(!variable_struct_exists(group, "iterated")) 
			return;
			
		if(inputs[| 0].value_from == noone) {
			group.iterationUpdate();
			return;
		}
			
		var val = inputs[| 0].getValue();
		var res = inputs[| 1].getValue();
			
		var _val = group.outputs[| 0].getValue();
		if(!is_array(_val)) {
			group.iterationUpdate();
			return;
		}
		
		if(res) {
			var is_surf	 = inputs[| 0].value_from.type == VALUE_TYPE.surface;
			var _new_val = val;
			if(is_surf)	_new_val = surface_array_clone(val);
			else		_new_val = array_clone(val);
			array_push(_val, _new_val);
		}
		
		LOG_IF(global.FLAG.render, "Value " + string(val) + " filter result " + string(res) + " to array " + string(_val));
		
		group.outputs[| 0].setValue(_val);
		group.iterationUpdate();
	}
}
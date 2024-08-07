function nodeValue_Palette(_name, _node, _value, _tooltip = "") { return new NodeValue_Palette(_name, _node, _value, _tooltip); }

function NodeValue_Palette(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.color, _value, _tooltip) constructor {;
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		
		if(!is_array(val)) val = [ val ];
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(is_anim) return animator.getValue(_time);
		return ds_list_empty(animator.values)? 0 : animator.values[| 0].value;
	}
}
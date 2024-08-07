function nodeValue_D3Mesh(_name, _node, _value, _tooltip = "") { return new NodeValue_D3Mesh(_name, _node, _value, _tooltip); }

function NodeValue_D3Mesh(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, _value, _tooltip) constructor {
	
	animable = false;
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) { return value; }
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		return ds_list_empty(animator.values)? 0 : animator.values[| 0].value;
	}
}
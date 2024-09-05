function nodeValue_Trigger(_name, _node, _value, _tooltip = "") { return new NodeValue_Trigger(_name, _node, _value, _tooltip); }

function NodeValue_Trigger(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.trigger, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}
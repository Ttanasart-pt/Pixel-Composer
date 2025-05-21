function nodeValue_Trigger(_name, _tooltip = "") { return new __NodeValue_Trigger(_name, self, _tooltip); }

function __NodeValue_Trigger(_name, _node, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.trigger, false, _tooltip) constructor {
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) { return animator.getValue(_time); }
	
	static arrayLength = arrayLengthSimple;
}
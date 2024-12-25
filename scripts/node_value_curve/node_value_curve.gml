function nodeValue_Curve(_name, _node, _value) { return new __NodeValue_Curve(_name, _node, _value); }

function __NodeValue_Curve(_name, _node, _value) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.curve, _value, "") constructor {
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, Node)) return val;
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(is_anim) return animator.getValue(_time);
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
}
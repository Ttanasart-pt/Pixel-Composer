function nodeValue_Enum_Scroll(_name, _node, _value, _data) { return new NodeValue_Enum_Scroll(_name, _node, _value, _data); }

function NodeValue_Enum_Scroll(_name, _node, _value, _data) : NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.integer, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.enum_scroll, _data);
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(is_anim) return animator.getValue(_time);
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}
function nodeValue_Enum_Button(_name, _node, _value, _data) { return new __NodeValue_Enum_Button(_name, _node, _value, _data); }

function __NodeValue_Enum_Button(_name, _node, _value, _data) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.enum_button, _data);
	
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
	
	static arrayLength = arrayLengthSimple;
}

//Replacement regex 
// (nodeValue)(.*self,\s*)(CONNECT_TYPE\.input, VALUE_TYPE\.integer,)(.*(?=\)))(.*\n.*)(\.setDisplay\(VALUE_DISPLAY\.enum_button)
// nodeValue_Enum_Button$2$4
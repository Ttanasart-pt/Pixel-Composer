function nodeValue_Range(_name, _node, _value, _data = {}) { return new NodeValue_Range(_name, _node, _value, _data); }

function NodeValue_Range(_name, _node, _value, _data) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.range, _data);
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		
		if(!is_array(val)) val = [ val, val ];
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(!is_anim) {
			if(sep_axis) return array_create_ext(2, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(2, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
}
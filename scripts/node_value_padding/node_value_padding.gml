function nodeValue_Padding(_name, _node, _value, _tooltip = "") { return new NodeValue_Padding(_name, _node, _value, _tooltip); }

function NodeValue_Padding(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	setDisplay(VALUE_DISPLAY.padding);
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		
		if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
		if(validator != noone)          value = validator.validate(value);
		
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		
		val = array_verify(val, 4);
		return valueProcess(val, nod, applyUnit, arrIndex);
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(!is_anim) {
			if(sep_axis) return array_create_ext(4, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(4, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
}
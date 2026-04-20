function   nodeValue_Padding(_name, _value, _tooltip = "") { return new __NodeValue_Padding(_name, self, _value, _tooltip); }
function __NodeValue_Padding(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	setDisplay(VALUE_DISPLAY.padding);
	def_length = 4;
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
		if(validator != noone)          value = validator.validate(value);
		
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var _d  = array_get_depth(val);
		
		__nod       = nod;
		__applyUnit = applyUnit;
		__arrIndex  = arrIndex;
		
		if(_d == 0) return valueProcess([ val, val, val, val ], nod, applyUnit, arrIndex);
		if(_d == 1) return valueProcess(array_verify(val, 4),   nod, applyUnit, arrIndex);
		if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return valueProcess(array_verify(v, 4), __nod, __applyUnit, __arrIndex)});
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		if(sep_axis) getAnimators();
		
		if(!getAnim()) {
			if(sep_axis) return [
				animators[0].values[0].value, animators[1].values[0].value,
				animators[2].values[0].value, animators[3].values[0].value,
			];
			
			return array_empty(animator.values)? 0 : animator.values[0].value;
		}
		
		if(sep_axis) return [
			animators[0].getValue(_time), animators[1].getValue(_time),
			animators[2].getValue(_time), animators[3].getValue(_time),
		];
		
		return animator.getValue(_time);
	}
}

function   nodeValue_IPadding(_name, _value, _tooltip = "") { return new __NodeValue_IPadding(_name, self, _value, _tooltip); }
function __NodeValue_IPadding(_name, _node, _value, _tooltip = "") : __NodeValue_Padding(_name, _node, _value, _tooltip) constructor {
	setType(VALUE_TYPE.integer);
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
		if(validator != noone)          value = validator.validate(value);
		
		var res = applyUnit? unit.apply(value, arrIndex) : value;
		
		res[0] = round(res[0]);
		res[1] = round(res[1]);
		res[2] = round(res[2]);
		res[3] = round(res[3]);
		
		return res;
	}
	
}
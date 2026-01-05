function nodeValue_Int(_name, _value, _tooltip = "") { return new __NodeValue_Int(_name, self, _value, _tooltip); }
function __NodeValue_Int(_name, _node, _value, _tooltip = "") : __NodeValue_Number(_name, _node, VALUE_TYPE.integer, _value, _tooltip) constructor {
	
	////- GET
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		if(validator != noone) value = validator.validate(value);
		value = applyUnit? unit.apply(value, arrIndex) : value;
		return is_real(value)? round(value) : value;
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) {
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(typ == VALUE_TYPE.surface) return surface_get_dimension(val);
		if(typ == VALUE_TYPE.text) val = toNumber(val);
		
		if(is_struct(val) && struct_has(val, "to_real")) val = val.to_real();
		
		return valueProcess(val, nod, applyUnit);
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}

function nodeValue_ISlider(_name, _value, _data = {}) { 
	return new __NodeValue_Int(_name, self, _value, _data).setDisplay(VALUE_DISPLAY.slider, is_array(_data)? { range: _data } : _data);
}
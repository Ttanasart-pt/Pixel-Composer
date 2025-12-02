function __NodeValue_Number(_name, _node, _type, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, _type, _value, _tooltip) constructor {
	anim_presets = [
		[ "0, 1",  [[ 0, 0 ], [ 1, 1 ]], THEME.apreset_01 ], 
		[ "1, 0",  [[ 0, 1 ], [ 1, 0 ]], THEME.apreset_10 ], 
		[ "-1, 1", [[ 0,-1 ], [ 1, 1 ]], THEME.apreset_01 ], 
		[ "1, -1", [[ 0, 1 ], [ 1,-1 ]], THEME.apreset_10 ], 
	];
}

function nodeValue_Float(_name, _value, _tooltip = "") { return new __NodeValue_Float(_name, self, _value, _tooltip); }
function __NodeValue_Float(_name, _node, _value, _tooltip = "") : __NodeValue_Number(_name, _node, VALUE_TYPE.float, _value, _tooltip) constructor {
	
	////- GET
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		if(validator != noone) value = validator.validate(value);
		value = applyUnit? unit.apply(value, arrIndex) : value;
		return value;
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
		var _anims = animators;
		
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}

function nodeValue_Float_Simple(_name, _node, _value, _tooltip = "") { return new __NodeValue_Float_Simple(_name, _node, _value, _tooltip); }
function __NodeValue_Float_Simple(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	
	////- GET
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) {
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		return __curr_get_val[0];
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}
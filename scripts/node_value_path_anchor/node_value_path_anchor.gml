function nodeValue_Path_Anchor(_name, _value, _tooltip = "") { return new __NodeValue_Path_Anchor(_name, self, _value, _tooltip); }
function __NodeValue_Path_Anchor(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	setDisplay(VALUE_DISPLAY.path_anchor);
	type_array = 1;
	def_length = _ANCHOR.amount;
	
	////- GET
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) {
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var typ = nod.type;
		
		var _d = array_get_depth(val);
		__nod       = nod;
		__applyUnit = applyUnit;
		__arrIndex  = arrIndex;
		
		switch(_d) {
			case 0: return valueProcess(array_create(def_length, val), nod, applyUnit, arrIndex);
			case 1: return valueProcess(_array_verify(val, def_length), nod, applyUnit, arrIndex);
			case 2: return array_map(val, function(v, i) /*=>*/ {return valueProcess(_array_verify(v, def_length), __nod, __applyUnit, __arrIndex)}); 
		}
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		if(sep_axis) getAnimators()
				
		if(!getAnim()) {
			if(sep_axis) return array_create_ext(def_length, function(i) /*=>*/ {return animators[i].values[0].value});
			return array_empty(animator.values)? 0 : animator.values[0].value;
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(def_length, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		return [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
			
			lerp(__f[2], __t[2], __i),
			lerp(__f[3], __t[3], __i),
			
			lerp(__f[4], __t[4], __i),
			lerp(__f[5], __t[5], __i),
			
			lerp(__f[6], __t[6], __i),
		];
	}
	
}

function nodeValue_Path_Anchor_3D(_name, _value, _tooltip = "") { return new __NodeValue_Path_Anchor_3D(_name, self, _value, _tooltip); }
function __NodeValue_Path_Anchor_3D(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, _ANCHOR3.amount) constructor {
	setDisplay(VALUE_DISPLAY.path_anchor);
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		return [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
			lerp(__f[2], __t[2], __i),
			
			lerp(__f[3], __t[3], __i),
			lerp(__f[4], __t[4], __i),
			lerp(__f[5], __t[5], __i),
			
			lerp(__f[6], __t[6], __i),
			lerp(__f[7], __t[7], __i),
			lerp(__f[8], __t[8], __i),
			
			lerp(__f[9], __t[9], __i),
		];
	}
	
}
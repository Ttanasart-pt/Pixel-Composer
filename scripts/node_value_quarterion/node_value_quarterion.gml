function nodeValue_Quaternion(_name, _value = [0,0,0,1], _tooltip = "") { return new __NodeValue_Quaternion(_name, self, _value, _tooltip); }

function __NodeValue_Quaternion(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, 4) constructor {
	setDisplay(VALUE_DISPLAY.d3quarternion);
	attributes.angle_display = QUARTERNION_DISPLAY.euler;
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(!is_array(val)) return array_create(4, val);
		
		var _convert = applyUnit && attributes.angle_display == QUARTERNION_DISPLAY.euler;
		if(!_convert) return array_verify(val, 4);
		
		var _d = array_get_depth(val);
		
		if(_d == 1) return quarternionFromEuler(val[0], val[1], val[2]);
		if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return quarternionFromEuler(v[0], v[1], v[2])});
		
		return val;
	}
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		var _af = array_safe_length(__f, -1);
		var _at = array_safe_length(__t, -1);
		
		if(_af ==  0 || _at ==  0) return 0;
		if(_af == -1 || _at == -1) return lerp(__f, __t, __i);
		
		if(attributes.angle_display == QUARTERNION_DISPLAY.quarterion)
			return quarternionArraySlerp(__f, __t, __i);
		return array_create_ext(min(_af, _at), function(i) /*=>*/ {return lerp(__f[i], __t[i], __i)});
	}
	
}
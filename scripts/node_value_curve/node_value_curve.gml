function nodeValue_Curve(_name, _value) { return new __NodeValue_Curve(_name, self, _value); }
function __NodeValue_Curve(_name, _node, _value) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.curve, _value, "") constructor {
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
}
function nodeValue_Palette(_name, _value = array_clone(DEF_PALETTE), _tooltip = "") { return new __NodeValue_Palette(_name, self, _value, _tooltip); }
function __NodeValue_Palette(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.color, _value, _tooltip) constructor {
	
	setDisplay(VALUE_DISPLAY.palette);
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(!is_array(val)) val = [ val ];
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
}
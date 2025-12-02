function nodeValue_Atlas(_name = "Atlas", _value = [], _tooltip = "") { return new __NodeValue_Atlas(_name, self, _value, _tooltip); }
function __NodeValue_Atlas(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.atlas, _value, _tooltip) constructor {
	
	animable = false;
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) { 
		var _anim  = animator;
		var _anims = animators;
		
		return array_empty(_anim.values)? noone : _anim.processValue(_anim.values[0].value); 
	}
	
	static arrayLength = arrayLengthSimple;
}
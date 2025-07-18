function nodeValue_Object(_name, _value, _tooltip = "") { return new __NodeValue_Object(_name, self, _value, _tooltip); }
function __NodeValue_Object_Generic(_name, _node, _type, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, _type, _value, _tooltip) constructor {
	
	animable = false;
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) { 
		var _anim  = animator;
		var _anims = animators;
		
		return array_empty(_anim.values)? noone : _anim.values[0].value; 
	} 
	
	static arrayLength = arrayLengthSimple;
}

function __NodeValue_Object(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.object, _value, _tooltip) constructor {
	
}
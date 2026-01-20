#macro nodeValue_EString nodeValue_Enum_String
function nodeValue_Enum_String(_name, _value, _data = noone) { return new __NodeValue_Enum_String(_name, self, _value, _data); }

function __NodeValue_Enum_String(_name, _node, _value, _data) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.text, _value, "") constructor {
	if(_data != noone) setDisplay(VALUE_DISPLAY.enum_string, _data);
	
	/////============== SET =============
	
	static setChoices = function(_ch) { setDisplay(VALUE_DISPLAY.enum_string, _ch); return self; }
	
	/////============== CONNECT =============
	
	static isConnectableStrict = function() /*=>*/ {return false};
	
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
	
	static arrayLength = arrayLengthSimple;
	
	/////============ Serialize ===========
	
	options_histories = [];
	
	static setHistory  = function(h) /*=>*/ { options_histories = h;  return self;  }
	
	static postApplyDeserialize = function() { // convert Enum_Scroll
		if(CLONING)                        return;
		if(array_empty(options_histories)) return;
		if(array_empty(animator.values))   return;
		
		var _load = noone;
		
		for( var i = 1, n = array_length(options_histories); i < n; i++ ) {
			var _oph = options_histories[i];
			if(_oph.cond()) { _load = _oph; break; }
		}
		
		if(_load == noone) return;
		
		var _v = animator.values[0].value;
		if(is_numeric(_v)) {
			var _o = array_safe_get(_load.list, _v, noone);
			if(_o != noone) animator.values[0].value = _o;
		}
	}
	
}
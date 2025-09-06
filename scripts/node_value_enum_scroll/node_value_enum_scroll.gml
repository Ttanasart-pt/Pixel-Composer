#macro nodeValue_EScroll nodeValue_Enum_Scroll
function nodeValue_Enum_Scroll(_name, _value, _data = noone) { return new __NodeValue_Enum_Scroll(_name, self, _value, _data); }

function __NodeValue_Enum_Scroll(_name, _node, _value, _data) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, "") constructor {
	if(_data != noone) setDisplay(VALUE_DISPLAY.enum_scroll, _data);
	
	clamp_range   = true;
	choicesAmount = undefined;
	
	/////============== SET =============
	
	static setChoices = function(_ch) { setDisplay(VALUE_DISPLAY.enum_scroll, _ch); return self; }
	
	static scrollValue = function(_d=1) /*=>*/ { 
		choicesAmount = array_length(editWidget.data);
		if(choicesAmount == undefined) return self;
		
		setValue((getValue() + _d + choicesAmount) % choicesAmount); 
		return self;  
	}
		
	static setUnclamp  = function( ) /*=>*/ { clamp_range = false;    return self;  }
	static setHistory  = function(h) /*=>*/ { options_histories = h;  return self;  }
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(!clamp_range) return val;
		
		choicesAmount = array_length(editWidget.data);
		if(choicesAmount == undefined) return val;
		
		if(is_real(val)) val = clamp(val, 0, choicesAmount - 1);
		
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
	
	/////============ Serialize ===========
	
	options_histories = [];
	
	static postApplyDeserialize = function() {
		if(getAnim()) return;
		if(CLONING) return;
		if(array_empty(options_histories)) return;
		if(array_empty(animator.values))   return;
		
		var _load = noone;
		
		for( var i = 1, n = array_length(options_histories); i < n; i++ ) {
			var _oph = options_histories[i];
			if(_oph.cond()) { _load = _oph; break; }
		}
		
		if(_load == noone) return;
		
		var _v = animator.values[0].value;
		var _o = array_safe_get(_load.list, _v, noone);
		if(_o != noone) {
			var _n = array_find(options_histories[0], _o);
			if(_n == -1) _n = 0;
			animator.values[0].value = _n;
		}
	}
	
}
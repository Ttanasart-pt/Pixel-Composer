#macro nodeValue_EButton nodeValue_Enum_Button
function nodeValue_Enum_Button(_name, _value = 0, _data = noone) { return new __NodeValue_Enum_Button(_name, self, _value, _data); }

function __NodeValue_Enum_Button(_name, _node, _value, _data) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, "") constructor {
	if(_data != noone) setDisplay(VALUE_DISPLAY.enum_button, _data);
	
	/////============== Display =============
	
	static setChoices = function(_ch) { setDisplay(VALUE_DISPLAY.enum_button, _ch); return self; }
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		var choicesAmount = array_length(editWidget.data);
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
}

function __enum_array_gen(arr, spr, col = COLORS._main_icon) { 
	__spr = spr;
	__c   = col;
	
	return array_map(arr, function(v,i) /*=>*/ {return new scrollItem(v, __spr, i).setBlend(__c)}); 
}
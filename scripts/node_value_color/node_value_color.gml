function nodeValue_Color(_name, _value, _tooltip = "") { return new __NodeValue_Color(_name, self, _value, _tooltip); }

function __NodeValue_Color(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.color, _value, _tooltip) constructor {
	preview_hotkey_spr    = THEME.tool_color;
	
	////- GET
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0]; 
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	// NOTE: remove 32 bit alpha check, this may cause some value to show up as transparent color (alpha = 0)
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		return merge_color(__f, __t, __i);
	}
	
	static arrayLength = arrayLengthSimple;
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _typ = 0, _sca = [ 1, 1 ], _rot = 0) {
		if(active && preview_hotkey && preview_hotkey.isPressing()) {
			var clr    = getValue();
			var dialog = colorSelectorCall(clr, function(c) /*=>*/ {return setValueInspector(c)});
		}
	}
}
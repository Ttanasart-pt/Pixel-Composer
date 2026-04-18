function nodeValue_Palette(_name, _value = array_clone(PROJ_PALETTE), _tooltip = "") { return new __NodeValue_Palette(_name, self, _value, _tooltip); }
function __NodeValue_Palette(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.color, _value, _tooltip) constructor {
	preview_hotkey_spr    = THEME.tool_color;
	setDisplay(VALUE_DISPLAY.palette);
	
	////- GET
	
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
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		var _af = array_safe_length(__f, -1);
		var _at = array_safe_length(__t, -1);
		
		var _len = ceil(lerp(array_length(__f), array_length(__t), __i));
		var res  = array_create(_len);
		
		for( var i = 0; i < _len; i++ ) {
			var _rat = i / (_len - 1);
	
			var rf = _rat * (array_length(__f) - 1);
			var rt = _rat * (array_length(__t) - 1);
			
			var cf = array_get_decimal(__f, rf, true);
			var ct = array_get_decimal(__t, rt, true);
			
			res[i] = merge_color(cf, ct, __i);
		}
		
		return res;
	}
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _typ = 0, _sca = [ 1, 1 ], _rot = 0) {
		if(active && preview_hotkey && preview_hotkey.isPressing()) {
			var clr    = getValue();
			var dialog = dialogCall(o_dialog_palette, WIN_W / 2, WIN_H / 2);
			dialog.setDefault(clr);
			dialog.onModify = function(c) /*=>*/ {return setValueInspector(c)};
		}
	}
}
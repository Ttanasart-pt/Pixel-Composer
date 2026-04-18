function nodeValue_Gradient(_name, _value, _tooltip = "") { return new __NodeValue_Gradient(_name, self, _value, _tooltip); }
function __NodeValue_Gradient(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.gradient, _value, _tooltip) constructor {
	updateOnSet = true;
	preview_hotkey_spr    = THEME.tool_color;
	
	////- GET
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(is_instanceof(val, gradientObject)) return val;
		if(nod.type != VALUE_TYPE.color)	   return val;
		
		if(is_array(val)) {
			var amo  = array_length(val);
			var grad = array_create(amo);
			
			for( var i = 0; i < amo; i++ )
				grad[i] = new gradientKey(i / amo, val[i]);
				
			var g = new gradientObject();
			g.keys = grad;
			return g;
		} 
		
		return is_numeric(val)? new gradientObject(val) : new gradientObject(ca_black);
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
		return has(__f, "lerpTo")? __f.lerpTo(__t, __i) : __f;
	}
	
	static arrayLength = arrayLengthSimple;
	
	static setValueRaw = function(_dat) { 
		if(is(_dat, gradientObject)) {
			setValue(_dat); 
			return;
		}
		
		if(is_struct(_dat)) { // cast random struct to gradient [???]
			static_set(_dat, static_get(gradientObject));
			setValue(_dat);
			return;
		}
	}
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _typ = 0, _sca = [ 1, 1 ], _rot = 0) {
		if(active && preview_hotkey && preview_hotkey.isPressing()) {
			var clr    = getValue();
			var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
			dialog.setDefault(clr.clone());
			dialog.onModify = function(c) /*=>*/ {return setValueInspector(c)};
		}
	}
}
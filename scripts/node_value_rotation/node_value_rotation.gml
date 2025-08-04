function nodeValue_Rotation(_name, _value, _tooltip = "") { return new __NodeValue_Rotation(_name, self, _value, _tooltip); }

function __NodeValue_Rotation(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	setDisplay(VALUE_DISPLAY.rotation);
	preview_hotkey_spr = THEME.tools_2d_rotate;
	
	////- GET
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var typ = nod.type;
		
		if(typ == VALUE_TYPE.text) val = toNumber(val);
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
	
	////- DRAW
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad = 64) { 
		if(expUse) return -1;
		__preview_bbox = node.__preview_bbox;
		
		var _hovering = preview_hotkey_active;
		
		if(preview_hotkey_active) {
			var _d0 = point_direction(_x, _y, preview_hotkey_mx, preview_hotkey_my);
			var _d1 = point_direction(_x, _y, _mx, _my);
			
			preview_hotkey_mx = _mx;
			preview_hotkey_my = _my;
			
			var _vx = getValue() + angle_difference(_d1, _d0);
			if(KEYBOARD_NUMBER != undefined) _vx = preview_hotkey_s + KEYBOARD_NUMBER;
			
			if(setValue(_vx)) UNDO_HOLDING = true;
			
			draw_set_color(COLORS._main_icon);
			draw_circle_prec(_x, _y, _rad, true);
			
			if(mouse_lpress(active) || key_press(vk_enter) || preview_hotkey.isPressing()) {
				preview_hotkey_active = false;
				UNDO_HOLDING = false;
			}
			
		}
		
		if(active && preview_hotkey && preview_hotkey.isPressing()) {
			var _val = getValue();
			preview_hotkey_active = true;
			
			preview_hotkey_s  = _val;
			preview_hotkey_mx = _mx;
			preview_hotkey_my = _my;
			
			KEYBOARD_STRING = "";
		}
		
		_hovering = _hovering || preview_overlay_rotation(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad);
		return _hovering;
		
	}
	
}
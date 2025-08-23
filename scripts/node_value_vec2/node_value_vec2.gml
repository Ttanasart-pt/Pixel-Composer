function nodeValue_Vec2( _name, _value, _data = {}) { return new __NodeValue_Vec2( _name, self, _value, _data); }
function nodeValue_IVec2(_name, _value, _data = {}) { return new __NodeValue_IVec2(_name, self, _value, _data); }

function __NodeValue_Vec2(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	preview_hotkey_spr = THEME.tools_2d_move;
	def_length = 2;
	
	////- GET
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		
		if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
		if(validator != noone)          value = validator.validate(value);
		
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) {
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var typ = nod.type;
		
		if(typ == VALUE_TYPE.surface) return surface_get_dimension(val);
		if(array_empty(val)) return val;
		
		var _d = array_get_depth(val);
		
		__nod       = nod;
		__applyUnit = applyUnit;
		__arrIndex  = arrIndex;
		
		switch(_d) {
			case 0: return valueProcess([ val, val ], nod, applyUnit, arrIndex);
			case 1: return valueProcess(val, nod, applyUnit, arrIndex);
			case 2: return array_map(val, function(v, i) /*=>*/ {return valueProcess(array_verify_new(v, 2), __nod, __applyUnit, __arrIndex)}); 
		}
		
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		
		if(!getAnim()) {
			if(sep_axis) return array_create_ext(2, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(2, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}

	////- DRAW
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _typ = 0, _sca = [ 1, 1 ]) {
		if(expUse || value_from != noone) return false;
		
		if(!is_array(_sca)) _sca = [ _sca, _sca ];
		var _hovering = preview_hotkey_active;
		
		if(preview_hotkey_active) {
			var _mmx = value_snap(_mx, _snx);
			var _mmy = value_snap(_my, _sny);
			
			var _dx = KEYBOARD_NUMBER == undefined? (_mmx - preview_hotkey_mx) / _s / _sca[0] : KEYBOARD_NUMBER;
			var _dy = KEYBOARD_NUMBER == undefined? (_mmy - preview_hotkey_my) / _s / _sca[1] : KEYBOARD_NUMBER;
			
			if(key_mod_press(SHIFT)) {
				_dx = min(_dx, _dy);
				_dy = _dx;
			}
			
			var _vx = preview_hotkey_s[0];
			var _vy = preview_hotkey_s[1];
			
			if(preview_hotkey_axis == -1 || preview_hotkey_axis == 0) _vx = preview_hotkey_s[0] + _dx;
			if(preview_hotkey_axis == -1 || preview_hotkey_axis == 1) _vy = preview_hotkey_s[1] + _dy;
			
			if(setValue([_vx, _vy])) UNDO_HOLDING = true;
			
			if(key_press(ord("X"))) { preview_hotkey_axis = preview_hotkey_axis == 0? -1 : 0; KEYBOARD_STRING = ""; }
			if(key_press(ord("Y"))) { preview_hotkey_axis = preview_hotkey_axis == 1? -1 : 1; KEYBOARD_STRING = ""; }
			
			var _vdx = _x + _vx * _s * _sca[0];
			var _vdy = _y + _vy * _s * _sca[1];
			draw_set_color(COLORS._main_icon);
			if(preview_hotkey_axis == 0) draw_line_dashed(0, _vdy, 9999, _vdy);
			if(preview_hotkey_axis == 1) draw_line_dashed(_vdx, 0, _vdx, 9999);
			
			draw_anchor(0, _vdx, _vdy, ui(10), 2);
			
			if(mouse_lpress() || key_press(vk_enter) || preview_hotkey.isPressing()) {
				preview_hotkey_active = false;
				UNDO_HOLDING = false;
			}
			
		}
		
		if(active && preview_hotkey && preview_hotkey.isPressing()) {
			var _val = getValue();
			preview_hotkey_active = true;
			preview_hotkey_axis   = -1;
			
			preview_hotkey_s  = array_clone(_val);
			preview_hotkey_mx = _mx;
			preview_hotkey_my = _my;
			
			KEYBOARD_STRING = "";
		}
		
		if(getAnim()) {
			var ox, oy, nx, ny;
			draw_set_color(COLORS._main_accent);
			
			if(sep_axis) {
				// TODO	
				
			} else {
				for( var i = 0, n = array_length(animator.values); i < n; i++ ) {
					var _v = animator.values[i].value;
					    _v = unit.apply(_v, node.preview_index);
					
					nx = _x + _v[0] * _s;
					ny = _y + _v[1] * _s;
					
					draw_circle_prec(nx, ny, 4, false);
					if(i) {
						draw_set_alpha(.5);
						draw_line_dashed(ox, oy, nx, ny);
						draw_set_alpha(1);
					}
					
					ox = nx;
					oy = ny;
				}
			}
		}
		
		if(drag_type == 1) {
			if(key_press(ord("X"))) { preview_hotkey_axis = preview_hotkey_axis == 0? -1 : 0; KEYBOARD_STRING = ""; }
			if(key_press(ord("Y"))) { preview_hotkey_axis = preview_hotkey_axis == 1? -1 : 1; KEYBOARD_STRING = ""; }
			
			var _vdx = drag_sx;
			var _vdy = drag_sy;
			draw_set_color(COLORS._main_icon);
			if(preview_hotkey_axis == 0) draw_line_dashed(0, _vdy, 9999, _vdy);
			if(preview_hotkey_axis == 1) draw_line_dashed(_vdx, 0, _vdx, 9999);
			
		}
		
		_hovering = _hovering || preview_overlay_vector(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _typ, _sca);
		return _hovering;
	}
	
}

function __NodeValue_IVec2(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	def_length = 2;
}
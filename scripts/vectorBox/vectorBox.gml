enum DIMENSION {
	width,
	height
}

function vectorBox(_size, _onModify, _unit = noone) : widget() constructor {
	size     = _size;
	onModify = _onModify;
	unit	 = _unit;
	
	linkable      = true;
	per_line      = false;
	current_value = [];
	linked        = false;
	side_button   = noone;
	
	link_inactive_color = noone;
	
	scaleDrag = false;
	scaleDrag_mx = 0;
	scaleDrag_my = 0;
	scaleDrag_ss = 0;
	
	array_display_max = 16;
	array_editing     = false;
	array_focusing    = undefined;
	array_hovering    = undefined;
	array_adding      = false;
	
	tooltip	= new tooltipSelector("Axis", [ __txt("Independent"), __txt("Linked") ]);
	
	onModifyIndex = function(val, index) { 
		if(!is_callable(onModify)) return false;
		var v = val;
		
		if(array_editing) {
			current_value[array_focusing][index] = val;
			return onModify(current_value, setValueForceUpdate);
		}
		
		if(linked) {
			var modi = false;
			for( var i = 0; i < size; i++ ) {
				tb[i]._input_text = v;
				modi = onModify(v, i) || modi;
			}
			return modi;
			
		}
		
		return onModify(v, index);
	}
	
	axis = [ "x", "y", "z", "w" ];
	onModifySingle[0] = function(v) /*=>*/ {return onModifyIndex(v, 0)};
	onModifySingle[1] = function(v) /*=>*/ {return onModifyIndex(v, 1)};
	onModifySingle[2] = function(v) /*=>*/ {return onModifyIndex(v, 2)};
	onModifySingle[3] = function(v) /*=>*/ {return onModifyIndex(v, 3)};
	
	for(var i = 0; i < 4; i++) tb[i] = textBox_Number(onModifySingle[i]).setSlide(true);
	
	////- Setters
	
	static setLink     = function(  ) /*=>*/ { linked = true;                                    return self; }
	static setSuffix   = function(_v) /*=>*/ { for(var i = 0; i < 4; i++) tb[i].setSuffix(_v);   return self; }
	static setLinkable = function(_l) /*=>*/ { linkable = _l;                                    return self; }
	static setBoxColor = function(_v) /*=>*/ { for(var i = 0; i < 4; i++) tb[i].setBoxColor(_v); return self; }
	static setFont     = function(_f) /*=>*/ { for(var i = 0; i < 4; i++) tb[i].setFont(_f);     return self; }
	static setLinkInactiveColor = function(_c) /*=>*/ { link_inactive_color = _c;                return self; }
	
	////- Draw
	
	static apply = function() {
		for( var i = 0; i < size; i++ ) {
			tb[i].apply();
			current_value[i] = toNumber(tb[i]._input_text);
		}
	}
	
	static setInteract = function(_interactable) {
		interactable = _interactable;
		
		if(side_button) 
			side_button.interactable = _interactable;
			
		for( var i = 0; i < size; i++ ) 
			tb[i].interactable = _interactable;
	}
	
	static register = function(parent = noone) {
		for( var i = 0; i < size; i++ ) 
			tb[i].register(parent);
		
		if(side_button != noone) 
			side_button.register(parent);
		
		if(unit != noone && unit.reference != noone)
			unit.triggerButton.register(parent);
	}
	
	static isHovering = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static onSetParam = function(params) {
		for(var i = 0; i < 4; i++) 
			tb[i].setParam(params);
	}
	
	static fetchHeight = function(params) { 
		var d = array_get_depth(params.data);
		return d == 2? (params.h + ui(2)) * (min(array_display_max, array_length(params.data)) + 1) - ui(2) : params.h;
	}
	
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = per_line? (_h + ui(4)) * size - ui(4) : _h;
		
		if(has(_display_data, "linked"))      linked      = _display_data.linked;
		if(has(_display_data, "side_button")) side_button = _display_data.side_button;
		tooltip.index = linked;
		current_value = _data;
		array_editing = false;
		
		var d = array_get_depth(_data);
		
		if(d == 2) {
			array_editing = true;
			var _len = min(array_display_max, array_length(_data));
			h = (_len + 1) * (_h + ui(2)) - ui(2);
			
			var toDel = undefined;
			var bs = min(_h, ui(24));
			var bc = [COLORS._main_icon, COLORS._main_value_negative];
			
			array_hovering = noone;
			if(mouse_lpress(active)) 
				array_focusing = undefined;
			
			for( var i = 0; i < _len; i++ ) {
				var _vect = _data[i];
				var _sz   = min(size, array_length(_vect));
				
				var _yy = _y + i * (_h + ui(2));
				var  ww = (_w - bs - ui(4)) / _sz;
				
				if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _x, _yy, _w, _h, boxColor, 1);
				
				var hv = hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _h);
				if(hv) {
					array_hovering = i;
					if(mouse_lpress(active)) 
						array_focusing = i;
				}
				
				for(var j = 0; j < _sz; j++) {
					var bx = _x + ww * j;
					var by = _yy;
					
					if(array_focusing == i) {
						tb[j].setFocusHover(active, hover);
						tb[j].labelColor = sep_axis? COLORS.axis[i] : COLORS._main_text_sub;
						tb[j].hide       = !per_line;
						tb[j].setLabel(axis[j]);
						
						tb[j].draw(bx, by, ww - 1, _h, _vect[j], _m);
						
					} else {
						draw_set_text(font, fa_center, fa_center, COLORS._main_text);
						draw_text_add(bx + ww / 2, by + _h / 2, _vect[j]);
					}
				}
				
				if(hide == 0 && (array_focusing != i || hv)) 
					draw_sprite_stretched_ext(THEME.textbox, 0, _x, _yy, _w, _h, boxColor, .5 + .5 * interactable);
				
				var bx = _x + _w - bs;
				var by = _yy;
				if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, hover, active, "Delete", THEME.minus, 0, bc, 1, .5) == 2)
					toDel = i;
			}
			
			if(toDel != undefined) {
				array_delete(_data, toDel, 1);
				if(array_length(_data) == 1) 
					_data = _data[0];
				onModify(_data, setValueForceUpdate);
			}
			
			// array_adding
			var _yy = _y + _len * (_h + ui(2));
			var hv = hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _h);
			
			if(hv) draw_sprite_stretched_ext(THEME.textbox, 0, _x, _yy, _w, _h, boxColor, .5 + .5 * interactable);
			
			draw_sprite_ui_uniform(THEME.add_16, 0, _x + _w - bs / 2, _yy + _h / 2, 1, COLORS._main_value_positive);
			draw_set_text(font, fa_right, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w - bs - ui(4), _yy + _h / 2, __txt("Add Vector"));
			
			if(hv && mouse_lpress(active)) {
				array_push(_data, array_clone(array_last(_data)));
				onModify(_data, setValueForceUpdate);
			}
			
			return h;
			
		} else if(d < 1 || d > 2) {
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, boxColor,  1);
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, boxColor, .5);	
			
			var _scis = gpu_get_scissor();
			gpu_set_scissor(_x, _y, _w, _h);
			draw_set_text(font, fa_center, fa_center, COLORS._main_text, .5);
			draw_text(_x + _w / 2, _y + _h / 2, _data);
			draw_set_alpha(1);
			gpu_set_scissor(_scis);
			return _h;
		}
		
		var bs = min(_h, ui(32));
		var bx = _x + _w - bs;
		var by = _y + _h / 2 - bs / 2;
		var _sz = min(size, array_length(_data));
		
		if(!per_line && hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, w, h, boxColor, 1);
		
		if((_w - bs) / _sz > ui(48)) {
			if(side_button) {
				if(!per_line && hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, _h, CDEF.main_mdwhite, 1);
				
				if(is(side_button, buttonAnchor)) 
					side_button.index = round(array_safe_get(_data, 0) * 2 + array_safe_get(_data, 1) * 6);
				
				side_button.setFocusHover(active, hover);
				side_button.draw(bx, by, bs, bs, _m, THEME.button_hide_fill);
				bx -= bs;
				_w -= bs;
			}
			
			if(unit != noone && unit.reference != noone) {
				if(!per_line && hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, _h, CDEF.main_mdwhite, 1);
				
				unit.triggerButton.setFocusHover(iactive, ihover);
				unit.draw(bx, by, bs, bs, _m);
				bx -= bs;
				_w -= bs;
			}
			
			if(front_button && front_button.visible) {
				if(!per_line && hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, bs, _h, CDEF.main_mdwhite, 1);
				front_button.setFocusHover(iactive, ihover);
				front_button.draw(_x, by, bs, bs, _m, THEME.button_hide_fill);
				
				_x += bs;
				_w -= bs;
			}
			
		}
		
		if((_w - bs) / _sz > ui(48)) {
			if(linkable) {
				var _icon_blend = linked? COLORS._main_accent : (link_inactive_color == noone? COLORS._main_icon : link_inactive_color);
				var bx = _x;
				
				if(!per_line && hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, _h, CDEF.main_mdwhite, 1);
				var b  = buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, hover, active, tooltip, THEME.value_link, linked, _icon_blend);
				
				var tg = false;
				if(b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0) tg = true;
				if(b == 2) tg = true;
					
				if(tg) {
					linked = !linked;
					if(is_struct(_display_data))
						_display_data.linked = linked;
				
					if(linked) 
					for( var i = 0; i < _sz; i++ )
						onModify(_data[0], i);
				}
				
				_x += bs;
				_w -= bs;
			}
		}
		
		var ww = per_line? _w : _w / _sz;
		
		if(!per_line && hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, h, boxColor, .5 + .5 * interactable);
		
		var bxHover = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var tbHover = bxHover;
		
		if(!per_line && _sz == 2) {
			var ps = _h / 2;
			var px = _x + ww;
			var py = _y + _h / 2;
			
			if(bxHover && w > ui(80)) {
				var pHover = hover && point_in_rectangle(_m[0], _m[1], px-ps, py-ps, px+ps, py+ps);
				if(pHover) tbHover = false;
			}
		}
		
		for(var i = 0; i < _sz; i++) {
			var bx = per_line? _x : _x + ww * i;
			var by = per_line? _y + (_h + ui(4)) * i : _y;
			
			tb[i].setFocusHover(active, tbHover);
			tb[i].labelColor = sep_axis? COLORS.axis[i] : COLORS._main_text_sub;
			tb[i].hide       = !per_line;
			tb[i].setLabel(axis[i]);
			
			tb[i].draw(bx, by, ww - 1, _h, _data[i], _m);
		}
		
		if(!per_line && _sz == 2) {
			if(scaleDrag) {
				hover = false;
				
				var _dt = (_m[0] - scaleDrag_mx) / w;
				var _sc = power(2, _dt);
				
				var _vx = scaleDrag_ss[0] * _sc;
				var _vy = scaleDrag_ss[1] * _sc;
				
				if(key_mod_press(CTRL)) {
					_vx = round(_vx);
					_vy = round(_vy);
				}
				
				var u0 = onModify(_vx, 0); 
				var u1 = onModify(_vy, 1); 
				if(u0 || u1) UNDO_HOLDING = true;
				
				if(mouse_lrelease()) {
					UNDO_HOLDING = false;
					scaleDrag    = false;
				}
			}
			
			if(scaleDrag) {
				draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, COLORS._main_accent, 1);
				
			} else if(bxHover && w > ui(80)) {
				draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, pHover? COLORS._main_icon_light : COLORS._main_icon, 1);
				if(pHover && mouse_lpress(active)) {
					scaleDrag = true;
					scaleDrag_mx = _m[0];
					scaleDrag_my = _m[1];
					scaleDrag_ss = [_data[0], _data[1]];
				}
			}
		}
		
		resetFocus();
		return h;
	}
	
	////- Actions
	
	static clone = function() {
		var cln = new vectorBox(size, onModify, unit);
		
		cln.linkable = linkable;
		cln.per_line = per_line;
		
		return cln;
	}

	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}
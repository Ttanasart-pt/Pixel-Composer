enum ROTATOR_RANDOM_TYPE {
	range,
	span,
	double_range,
	double_span, 
	length
}

function rotatorRandom(_onModify) : widget() constructor {
	#region data
		onModify = _onModify;
		
		dragging_index = -1;
		dragging       = false;
		drag_sv        = 0;
		drag_dat       = ROTRAN_DEF_0;
		
		knob_hovering  = noone;
		
		rangeDrag      = false;
		rangeDrag_mx   = 0;
		rangeDrag_my   = 0;
		rangeDrag_ss   = 0;
		
		mode     = 0;
		tb_min_0 = textBox_Number(function(v) /*=>*/ {return onModify(v, 1)}).setHide(true);
		tb_max_0 = textBox_Number(function(v) /*=>*/ {return onModify(v, 2)}).setHide(true);
		tb_min_1 = textBox_Number(function(v) /*=>*/ {return onModify(v, 3)}).setHide(true);
		tb_max_1 = textBox_Number(function(v) /*=>*/ {return onModify(v, 4)}).setHide(true);
		
		tooltip  = new tooltipSelector("Mode", [
			__txt("widget_rotator_random_range",        "Range"), 
			__txt("widget_rotator_random_span",         "Span"), 
			__txt("widget_rotator_random_double_range", "Double Range"), 
			__txt("widget_rotator_random_double_span",  "Double Span")
		]);
		
		mode_tooltip  = new tooltipSelector("Double Select", [
			__txt("Random"), 
			__txt("Index"), 
		]);
	#endregion
	
	////- Set
	
	static setInteract = function(i = noone) {
		interactable = i;
		tb_min_0.interactable = i;
		tb_max_0.interactable = i;
		
		if(mode == 2 || mode == 3)	tb_min_1.interactable = i;
		if(mode == 2)				tb_max_1.interactable = i;
	}
	
	static register = function(parent = noone) {
		tb_min_0.register(parent);
		tb_max_0.register(parent);
		
		if(mode == 2 || mode == 3)	tb_min_1.register(parent);
		if(mode == 2)				tb_max_1.register(parent);
	}
	
	static isHovering = function() { return dragging || tb_min_0.hovering || tb_max_0.hovering || tb_min_1.hovering || tb_max_1.hovering; }
	
	static setMode = function(_data, _mode) {
		onModify(_mode, 0);
					
		if(_mode == 0) {
			onModify(  0, 1);
			onModify(180, 2);
			
		} else if(_mode == 1) {
			onModify((_data[1] + _data[2]) / 2,    1);
			onModify(abs(_data[1] - _data[2]) / 2, 2);
			
		} else if(_mode == 2) {
			onModify(0,   1);
			onModify(90,  2);
			onModify(180, 3);
			onModify(270, 4);
			
		} else if(_mode == 3) {
			onModify(45,  1);
			onModify(225, 2);
			onModify(45,  3);
		}
		
		return _mode;
	}
	
	static fetchHeight = function(params) { return params.data[0]? params.h * 2 : params.h; }
	
	////- Draw
	
	static drawParam   = function(params) {
		setParam(params);
		tb_min_0.setParam(params);
		tb_max_0.setParam(params);
		tb_min_1.setParam(params);
		tb_max_1.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		if(!is_array(_data)) return;
		
		x = _x;
		y = _y;
		w = _w;
		h = _data[0] > 1? _h * 2 : _h;
		
		// if(array_any(_data, (a,i) => !is_real(a))) return;
		
		_data    = array_verify(_data, ROTRAN_LENGTH);
		_data[0] = clamp(_data[0], 0, ROTATOR_RANDOM_TYPE.length - 1);
		mode     = _data[0];
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, w, h, boxColor, 1);
		
		var _bs = min(_h, ui(32));
		if(side_button) {
			var bx = _x + _w - _bs;
			
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, _bs, _h, CDEF.main_mdwhite, 1);
			side_button.setFocusHover(active, hover);
			side_button.draw(bx, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			_w -= _bs;
		}
		
		var _khv = dragging_index;
		var _r   = _h;
		var _drawRot = _w - _r > ui(64);
		
		var _tx = _drawRot? _x + _r : _x;
		var _tw = _drawRot? _w - _r : _w;
		var _ty = _y;
		
		if(_drawRot) {
			if((_w - _r) / 2 > ui(48)) {
				tooltip.index = mode;
				var _bx = _x + _w - _bs;
				var _by = _y + _h / 2 - _bs / 2;
				
				if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _bx, _y, _bs, h, CDEF.main_mdwhite, 1);
				var b = buttonInstant_Pad(noone, _bx, _by, _bs, _bs, _m, hover, active, tooltip, THEME.rotator_random_mode, mode, [ COLORS._main_icon, c_white ]);
				if(b == 1) {
					if(key_mod_press(SHIFT) && MOUSE_WHEEL > 0) mode = setMode(_data, (mode - 1 + 4) % 4);
					if(key_mod_press(SHIFT) && MOUSE_WHEEL < 0) mode = setMode(_data, (mode + 1)     % 4);
				}
				if(b == 2) mode = setMode(_data, (mode + 1) % 4);
				
				_tw -= _bs;
			}
			
			var _kx = _x + _r / 2;
			var _ky = _y + _r / 2;
			var _kr = (_r - ui(12)) / 2;
			var _kc = COLORS._main_icon;
		}
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, _r, h, CDEF.main_mdwhite, 1);
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, x, y,  w, h, boxColor, 0.5 + 0.5 * interactable);	
		
		_tw /= 2;
		
		var bxHover = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var tbHover = bxHover;
		
		var ps = _h / 2;
		var px = _tx + _tw;
				
		switch(mode) {
			case ROTATOR_RANDOM_TYPE.range : 
				var py = _ty + _h / 2;
				
				if(rangeDrag) {
					hover = false;
					
					var _dt = (_m[0] - rangeDrag_mx) / w * 180;
					var _vx = value_snap(rangeDrag_ss[1] + _dt, key_mod_press(CTRL)? 15 : 1);
					var _vy = value_snap(rangeDrag_ss[2] + _dt, key_mod_press(CTRL)? 15 : 1);
					
					var u0 = onModify(_vx, 1); 
					var u1 = onModify(_vy, 2); 
					if(u0 || u1) UNDO_HOLDING = true;
					
					if(mouse_lrelease()) {
						UNDO_HOLDING = false;
						rangeDrag    = false;
					}
				}
				
				if(bxHover && w > ui(80)) {
					var pHover = hover && point_in_rectangle(_m[0], _m[1], px-ps, py-ps, px+ps, py+ps);
					if(pHover) tbHover = false;
				}
				
				tb_min_0.setFocusHover(active, tbHover);
				tb_max_0.setFocusHover(active, tbHover);
		
				tb_min_0.draw(_tx,        _ty, _tw, _h, array_safe_get_fast(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty, _tw, _h, array_safe_get_fast(_data, 2), _m);
				
				if(rangeDrag) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, COLORS._main_accent, 1);
					
				} else if(bxHover && w > ui(80)) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, pHover? COLORS._main_icon_light : COLORS._main_icon, 1);
					if(pHover && mouse_lpress(active)) {
						rangeDrag = true;
						rangeDrag_mx = _m[0];
						rangeDrag_my = _m[1];
						rangeDrag_ss = array_clone(_data);
					}
				}
				
				if(_drawRot) {
					if(dragging_index > -1) {
						_kc = COLORS._main_icon_light;
			
						var val;
						var curr_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
						var modi     = false;
						
						curr_val[1] = round(dragging.delta_acc + drag_sv[1]);
						curr_val[2] = round(dragging.delta_acc + drag_sv[2]);
						
						val   = key_mod_press(SHIFT)? value_snap(curr_val[1], 15) : curr_val[1];
						modi = onModify(val, 1) || modi;
						
						val   = key_mod_press(SHIFT)? value_snap(curr_val[2], 15) : curr_val[2];
						modi = onModify(val, 2) || modi;
				
						if(modi) UNDO_HOLDING = true;
					
						MOUSE_BLOCK = true;
					
						if(mouse_rpress(true, true)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
							
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_lrelease()) {
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;
						}
					
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _r, _y + _r)) {
						_kc = COLORS._main_icon_light;
						
						if(DOUBLE_CLICK) {
							var _cr = (_data[1] + _data[2]) / 2;
							onModify(_cr, 1);
							onModify(_cr, 2);
							
						} else if(mouse_lpress(active)) {
							dragging_index = 2;
						
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky);
						}
					}
					
					draw_set_color(CDEF.main_dkgrey);
					draw_circle_angle(_kx, _ky, _kr, _data[1], _data[2], 32);
				
					shader_set(sh_widget_rotator_range);
						shader_set_f("side",     _r);
						shader_set_color("color",   _kc);
						shader_set_f("angle",     degtorad(_data[1]), degtorad(_data[2]));
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
					shader_reset();
				}
				
				break;
			
			case ROTATOR_RANDOM_TYPE.span : 
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				
				tb_min_0.draw(_tx,        _ty, _tw, _h, array_safe_get_fast(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty, _tw, _h, array_safe_get_fast(_data, 2), _m);
				
				if(_drawRot) {
					var _a0 = _data[1] - _data[2];
					var _a1 = _data[1] + _data[2];
				
					if(dragging_index > -1) {
						_kc = COLORS._main_icon_light;
			
						var val = point_direction(_kx, _ky, _m[0], _m[1]);
						if(key_mod_press(SHIFT)) val = value_snap(val, 15);
					
						var val;
						var real_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
					
						real_val[1] = round(dragging.delta_acc + drag_sv[1]);
						val = key_mod_press(SHIFT)? value_snap(real_val[1], 15) : real_val[1];
						
						if(onModify(val, 1)) UNDO_HOLDING = true;
					
						MOUSE_BLOCK = true;
					
						if(mouse_rpress(true, true)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
						
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_lrelease()) {
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;
						}
					
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _r, _y + _r)) {
						_kc = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							onModify(0, 2);
							
						} else if(mouse_lpress(active)) {
							dragging_index = 2;
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky);
						}
					}
				
					draw_set_color(CDEF.main_dkgrey);
					draw_circle_angle(_kx, _ky, _kr, _a0, _a1, 32);
				
					shader_set(sh_widget_rotator);
						shader_set_f("side",     _r);
						shader_set_color("color", _kc);
						shader_set_f("angle",     degtorad(_data[1]));
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
					shader_reset();
				}
				
				break;
			
			case ROTATOR_RANDOM_TYPE.double_range : 
				var _ky0 = _y + _r / 2;
				var _ky1 = _y + _h + _r / 2;
				
				var _kc0 = _kc;
				var _kc1 = _kc;
				
				if(rangeDrag) {
					hover = false;
					
					var _dt = (_m[0] - rangeDrag_mx) / w * 180;
					var _vx = value_snap(rangeDrag_ss[(rangeDrag - 1) * 2 + 1] + _dt, key_mod_press(CTRL)? 15 : 1);
					var _vy = value_snap(rangeDrag_ss[(rangeDrag - 1) * 2 + 2] + _dt, key_mod_press(CTRL)? 15 : 1);
					
					var u0 = onModify(_vx, (rangeDrag - 1) * 2 + 1); 
					var u1 = onModify(_vy, (rangeDrag - 1) * 2 + 2); 
					if(u0 || u1) UNDO_HOLDING = true;
					
					if(mouse_lrelease()) {
						UNDO_HOLDING = false;
						rangeDrag    = false;
					}
				}
				
				var py = _ty + _h / 2;
				if(bxHover && w > ui(80)) {
					var pHover = hover && point_in_rectangle(_m[0], _m[1], px-ps, py-ps, px+ps, py+ps);
					if(pHover) tbHover = false;
				}
				
				tb_min_0.setFocusHover(active, tbHover);
				tb_max_0.setFocusHover(active, tbHover);
				tb_min_0.draw(_tx,        _ty,      _tw, _h, array_safe_get_fast(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty,      _tw, _h, array_safe_get_fast(_data, 2), _m);
				
				if(rangeDrag == 1) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, COLORS._main_accent, 1);
					
				} else if(bxHover && w > ui(80)) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, pHover? COLORS._main_icon_light : COLORS._main_icon, 1);
					if(pHover && mouse_lpress(active)) {
						rangeDrag = 1;
						rangeDrag_mx = _m[0];
						rangeDrag_my = _m[1];
						rangeDrag_ss = array_clone(_data);
					}
				}
				
				var py = _ty + _h + _h / 2;
				if(bxHover && w > ui(80)) {
					var pHover = hover && point_in_rectangle(_m[0], _m[1], px-ps, py-ps, px+ps, py+ps);
					if(pHover) tbHover = false;
				}
				
				tb_min_1.setFocusHover(active, tbHover);
				tb_max_1.setFocusHover(active, tbHover);
				tb_min_1.draw(_tx,        _ty + _h, _tw, _h, array_safe_get_fast(_data, 3), _m);
				tb_max_1.draw(_tx + _tw,  _ty + _h, _tw, _h, array_safe_get_fast(_data, 4), _m);
				
				if(rangeDrag == 2) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, COLORS._main_accent, 1);
					
				} else if(bxHover && w > ui(80)) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, pHover? COLORS._main_icon_light : COLORS._main_icon, 1);
					if(pHover && mouse_lpress(active)) {
						rangeDrag = 2;
						rangeDrag_mx = _m[0];
						rangeDrag_my = _m[1];
						rangeDrag_ss = array_clone(_data);
					}
				}
				
				if(_drawRot) {
					if(dragging_index > -1) {
						if(dragging_index == 1) _kc0 = COLORS._main_icon_light;
						else					_kc1 = COLORS._main_icon_light;
					
						var val = point_direction(_kx, dragging_index == 1? _ky0 : _ky1, _m[0], _m[1]);
						if(key_mod_press(SHIFT)) val = value_snap(val, 15);
					
						var val;
						var real_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
						var modi = false;
					
						for( var i = 1; i <= 2; i++ ) {
							var ind = (dragging_index - 1) * 2 + i;
						
							real_val[ind] = round(drag_sv[ind] + dragging.delta_acc);
							val = key_mod_press(SHIFT)? value_snap(real_val[ind], 15) : real_val[ind];
						
							if(onModify(val, ind)) modi = true;
						}
					
						if(modi) {
							UNDO_HOLDING = true;
							MOUSE_BLOCK  = true;
						}
					
						if(mouse_rpress(true, true)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
						
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_lrelease()) {
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;
						}
					
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _r, _y + _r)) {
						_kc0 = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							var _cr = (_data[1] + _data[2]) / 2;
							onModify(_cr, 1);
							onModify(_cr, 2);
							
						} else if(mouse_lpress(active)) {
							dragging_index = 1;
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky0);
						}
						
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y + _h, _x + _r, _y + _h + _r)) {
						_kc1 = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							var _cr = (_data[3] + _data[4]) / 2;
							onModify(_cr, 3);
							onModify(_cr, 4);
							
						} else if(mouse_lpress(active)) {
							dragging_index = 2;
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky1);
						}
					}
				
					draw_set_color(CDEF.main_dkgrey);
					draw_circle_angle(_kx, _ky0, _kr, _data[1], _data[2], 32);
					draw_circle_angle(_kx, _ky1, _kr, _data[3], _data[4], 32);
				
					shader_set(sh_widget_rotator_range);
						shader_set_f("side",     _r);
						shader_set_color("color",   _kc0);
						shader_set_f("angle",     degtorad(_data[1]), degtorad(_data[2]));
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
					
						shader_set_color("color",   _kc1);
						shader_set_f("angle",     degtorad(_data[3]), degtorad(_data[4]));
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y + _h, _r, _r);
					shader_reset();
				}
				
				var _bx = _x + _w - _bs;
				var _by = _y + _h + _h / 2 - _bs / 2;
				var _dmode = array_safe_get_fast(_data, 5);
				mode_tooltip.index = _dmode;
				var b = buttonInstant_Pad(noone, _bx, _by, _bs, _bs, _m, hover, active, mode_tooltip, THEME.rotator_random_double_mode, _dmode, [ COLORS._main_icon, c_white ]);
				if(b == 2) onModify(!_dmode, 5);
				break;
				
			case ROTATOR_RANDOM_TYPE.double_span : 
				var _ky0 = _y + _r / 2;
				var _ky1 = _y + _h + _r / 2;
				
				var _kc0 = _kc;
				var _kc1 = _kc;
				
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				tb_min_1.setFocusHover(active, hover);
				
				tb_min_0.draw(_tx,        _ty,      _tw, _h, array_safe_get_fast(_data, 1), _m);
				tb_max_0.draw(_tx,        _ty + _h, _tw, _h, array_safe_get_fast(_data, 2), _m);
				tb_min_1.draw(_tx + _tw,  _ty,	    _tw,  h, array_safe_get_fast(_data, 3), _m);
				
				if(_drawRot) {
					var _a0 = _data[1] - _data[3];
					var _a1 = _data[1] + _data[3];
					var _a2 = _data[2] - _data[3];
					var _a3 = _data[2] + _data[3];
				
					if(dragging_index > -1) {
						var val = point_direction(_kx, _ky, _m[0], _m[1]);
						if(key_mod_press(SHIFT)) val = value_snap(val, 15);
					
						var real_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
						var val;
						var ind = dragging_index;
					
						real_val[ind] = round(drag_sv[ind] + dragging.delta_acc);
						val = key_mod_press(SHIFT)? value_snap(real_val[ind], 15) : real_val[ind];
						
						if(onModify(val, ind)) UNDO_HOLDING = true;
					
						MOUSE_BLOCK = true;
					
						if(mouse_rpress(true, true)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
						
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_lrelease()) {
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;
						}
					
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _r, _y + _r)) {
						_kc0 = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							onModify(0, 3);
							
						} else if(mouse_lpress(active)) {
							dragging_index = 1;
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky0);
						}
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y + _h, _x + _r, _y + _h + _r)) {
						_kc1 = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							onModify(0, 3);
							
						} else if(mouse_lpress(active)) {
							dragging_index = 2;
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky1);
						}
					}
				
					draw_set_color(CDEF.main_dkgrey);
					draw_circle_angle(_kx, _ky0, _kr, _a0, _a1, 32);
					draw_circle_angle(_kx, _ky1, _kr, _a2, _a3, 32);
				
					shader_set(sh_widget_rotator);
						shader_set_f("side",     _r);
						shader_set_color("color", _kc0);
						shader_set_f("angle",     degtorad(_data[1]));
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
				
						shader_set_color("color", _kc1);
						shader_set_f("angle",     degtorad(_data[2]));
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y + _h, _r, _r);
					shader_reset();
				}
				
				var _bx = _x + _w - _bs;
				var _by = _y + _h + _h / 2 - _bs / 2;
				var _dmode = array_safe_get_fast(_data, 5);
				mode_tooltip.index = _dmode;
				var b = buttonInstant_Pad(noone, _bx, _by, _bs, _bs, _m, hover, active, mode_tooltip, THEME.rotator_random_double_mode, _dmode, [ COLORS._main_icon, c_white ]);
				if(b == 2) onModify(!_dmode, 5);
				break;
		}
		
		knob_hovering = _khv;
		resetFocus();
		
		return h;
	}
		
	////- Action
	
	static clone = function() {
		return new rotatorRandom(onModify);
	}

	static free = function() {
		tb_min_0.free();
		tb_max_0.free();
		tb_min_1.free();
		tb_max_1.free();
	}
}
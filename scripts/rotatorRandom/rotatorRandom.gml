enum ROTATOR_RANDOM_TYPE {
	range,
	span,
	double_range,
	double_span, 
	length
}

function rotatorRandom(_onModify) : widget() constructor {
	onModify = _onModify;
	
	dragging_index = -1;
	dragging = false;
	drag_sv  = 0;
	drag_dat = [ 0, 0, 0, 0, 0 ];
	
	knob_hovering = noone;
	
	mode = 0;
	tb_min_0 = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ {return onModify(v, 1)}).setSlideStep(15); tb_min_0.hide = true;
	tb_max_0 = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ {return onModify(v, 2)}).setSlideStep(15); tb_max_0.hide = true;
	tb_min_1 = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ {return onModify(v, 3)}).setSlideStep(15); tb_min_1.hide = true;
	tb_max_1 = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ {return onModify(v, 4)}).setSlideStep(15); tb_max_1.hide = true;
	
	tooltip  = new tooltipSelector("Mode", [
		__txtx("widget_rotator_random_range",        "Range"), 
		__txtx("widget_rotator_random_span",         "Span"), 
		__txtx("widget_rotator_random_double_range", "Double Range"), 
		__txtx("widget_rotator_random_double_span",  "Double Span")
	]);
	
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
	
	static drawParam = function(params) {
		setParam(params);
		tb_min_0.setParam(params);
		tb_max_0.setParam(params);
		tb_min_1.setParam(params);
		tb_max_1.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
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
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		_data = array_verify(_data, 5);
		_data[0] = clamp(_data[0], 0, ROTATOR_RANDOM_TYPE.length - 1);
		
		mode  = _data[0];
		
		var _hh = mode > 1? _h * 2 + ui(4) : _h;
		h = h == 0? _hh : lerp_float(h, _hh, 5);
		
		var _khv = dragging_index;
		var _r   = _h;
		var _drawRot = _w - _r > ui(64);
		
		var _bs = min(_h, ui(32));
		var _tx = _drawRot? _x + _r + ui(4) : _x;
		var _tw = _drawRot? _w - _r - ui(4) : _w;
		var _ty = _y;
		
		switch(mode) {
			case ROTATOR_RANDOM_TYPE.double_range :
				draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y + _h + ui(4), _tw, _h, boxColor, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y + _h + ui(4), _tw, _h, boxColor, 0.5 + 0.5 * interactable);	
				
			case ROTATOR_RANDOM_TYPE.range :
			case ROTATOR_RANDOM_TYPE.span :
				draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y, _tw, _h, boxColor, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y, _tw, _h, boxColor, 0.5 + 0.5 * interactable);	
				break;
				
			case ROTATOR_RANDOM_TYPE.double_span :
				draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y, _tw, h, boxColor, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y, _tw, h, boxColor, 0.5 + 0.5 * interactable);	
		}
		
		if(_drawRot) {
			if((_w - _r) / 2 > ui(48)) {
				tooltip.index = mode;
				var _bx = _x + _w - _bs;
				var _by = _y + _h / 2 - _bs / 2;
				
				var b = buttonInstant(noone, _bx, _by, _bs, _bs, _m, hover, active, tooltip, THEME.rotator_random_mode, mode, [ COLORS._main_icon, c_white ]);
				if(b == 1) {
					if(key_mod_press(SHIFT) && MOUSE_WHEEL > 0) mode = setMode(_data, (mode - 1 + 4) % 4);
					if(key_mod_press(SHIFT) && MOUSE_WHEEL < 0) mode = setMode(_data, (mode + 1)     % 4);
				}
				if(b == 2) mode = setMode(_data, (mode + 1) % 4);
		
				_tw -= _bs + ui(4);
			}
			
			var _kx = _x + _r / 2;
			var _ky = _y + _r / 2;
			var _kr = (_r - ui(12)) / 2;
			var _kc = COLORS._main_icon;
		}
		
		_tw /= 2;
		
		switch(mode) {
			case ROTATOR_RANDOM_TYPE.range : 
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
		
				tb_min_0.draw(_tx,        _ty, _tw, _h, array_safe_get_fast(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty, _tw, _h, array_safe_get_fast(_data, 2), _m);
				
				if(_drawRot) {
					if(dragging_index > -1) {
						_kc = COLORS._main_icon_light;
			
						var val;
						var curr_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
						var modi     = false;
						
						curr_val[1] = round(dragging.delta_acc + drag_sv[1]);
						curr_val[2] = round(dragging.delta_acc + drag_sv[2]);
						
						val   = key_mod_press(CTRL)? round(curr_val[1] / 15) * 15 : curr_val[1];
						modi = onModify(val, 1) || modi;
						
						val   = key_mod_press(CTRL)? round(curr_val[2] / 15) * 15 : curr_val[2];
						modi = onModify(val, 2) || modi;
				
						if(modi) UNDO_HOLDING = true;
					
						MOUSE_BLOCK = true;
					
						if(mouse_check_button_pressed(mb_right)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
							
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_release(mb_left)) {
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
							
						} else if(mouse_press(mb_left, active)) {
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
						if(key_mod_press(CTRL)) val = round(val / 15) * 15;
					
						var val;
						var real_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
					
						real_val[1] = round(dragging.delta_acc + drag_sv[1]);
						val = key_mod_press(CTRL)? round(real_val[1] / 15) * 15 : real_val[1];
						
						if(onModify(val, 1)) UNDO_HOLDING = true;
					
						MOUSE_BLOCK = true;
					
						if(mouse_check_button_pressed(mb_right)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
						
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_release(mb_left)) {
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;
						}
					
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _r, _y + _r)) {
						_kc = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							onModify(0, 2);
							
						} else if(mouse_press(mb_left, active)) {
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
				var _ky1 = _y + _h + ui(4) + _r / 2;
				
				var _kc0 = _kc;
				var _kc1 = _kc;
				
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				tb_min_1.setFocusHover(active, hover);
				tb_max_1.setFocusHover(active, hover);
				
				tb_min_0.draw(_tx,        _ty,              _tw, _h, array_safe_get_fast(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty,              _tw, _h, array_safe_get_fast(_data, 2), _m);
				tb_min_1.draw(_tx,        _ty + _h + ui(4), _tw, _h, array_safe_get_fast(_data, 3), _m);
				tb_max_1.draw(_tx + _tw,  _ty + _h + ui(4), _tw, _h, array_safe_get_fast(_data, 4), _m);
				
				if(_drawRot) {
					if(dragging_index > -1) {
						if(dragging_index == 1) _kc0 = COLORS._main_icon_light;
						else					_kc1 = COLORS._main_icon_light;
					
						var val = point_direction(_kx, dragging_index == 1? _ky0 : _ky1, _m[0], _m[1]);
						if(key_mod_press(CTRL)) val = round(val / 15) * 15;
					
						var val;
						var real_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
						var modi = false;
					
						for( var i = 1; i <= 2; i++ ) {
							var ind = (dragging_index - 1) * 2 + i;
						
							real_val[ind] = round(drag_sv[ind] + dragging.delta_acc);
							val = key_mod_press(CTRL)? round(real_val[ind] / 15) * 15 : real_val[ind];
						
							if(onModify(val, ind)) modi = true;
						}
					
						if(modi) {
							UNDO_HOLDING = true;
							MOUSE_BLOCK  = true;
						}
					
						if(mouse_check_button_pressed(mb_right)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
						
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_release(mb_left)) {
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
							
						} else if(mouse_press(mb_left, active)) {
							dragging_index = 1;
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky0);
						}
						
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y + _h + ui(4), _x + _r, _y + _h + ui(4) + _r)) {
						_kc1 = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							var _cr = (_data[3] + _data[4]) / 2;
							onModify(_cr, 3);
							onModify(_cr, 4);
							
						} else if(mouse_press(mb_left, active)) {
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
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y + _h + ui(4), _r, _r);
					shader_reset();
				}
				
				break;
				
			case ROTATOR_RANDOM_TYPE.double_span : 
				var _ky0 = _y + _r / 2;
				var _ky1 = _y + _h + ui(4) + _r / 2;
				
				var _kc0 = _kc;
				var _kc1 = _kc;
				
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				tb_min_1.setFocusHover(active, hover);
				
				tb_min_0.draw(_tx,        _ty,              _tw, _h, array_safe_get_fast(_data, 1), _m);
				tb_max_0.draw(_tx,        _ty + _h + ui(4), _tw, _h, array_safe_get_fast(_data, 2), _m);
				tb_min_1.draw(_tx + _tw,  _ty,	            _tw,  h, array_safe_get_fast(_data, 3), _m);
				
				if(_drawRot) {
					var _a0 = _data[1] - _data[3];
					var _a1 = _data[1] + _data[3];
					var _a2 = _data[2] - _data[3];
					var _a3 = _data[2] + _data[3];
				
					if(dragging_index > -1) {
						var val = point_direction(_kx, _ky, _m[0], _m[1]);
						if(key_mod_press(CTRL)) val = round(val / 15) * 15;
					
						var real_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
						var val;
						var ind = dragging_index;
					
						real_val[ind] = round(drag_sv[ind] + dragging.delta_acc);
						val = key_mod_press(CTRL)? round(real_val[ind] / 15) * 15 : real_val[ind];
						
						if(onModify(val, ind)) UNDO_HOLDING = true;
					
						MOUSE_BLOCK = true;
					
						if(mouse_check_button_pressed(mb_right)) {
							for( var i = 0; i < 5; i++ ) onModify(drag_dat[i], i);
						
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;	
						
						} else if(mouse_release(mb_left)) {
							instance_destroy(rotator_Rotator);
							dragging       = noone;
							dragging_index = -1;
							UNDO_HOLDING   = false;
						}
					
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _r, _y + _r)) {
						_kc0 = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							onModify(0, 3);
							
						} else if(mouse_press(mb_left, active)) {
							dragging_index = 1;
							drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
							dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky0);
						}
					} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y + _h + ui(4), _x + _r, _y + _h + ui(4) + _r)) {
						_kc1 = COLORS._main_icon_light;
							
						if(DOUBLE_CLICK) {
							onModify(0, 3);
							
						} else if(mouse_press(mb_left, active)) {
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
			
						draw_sprite_stretched(s_fx_pixel, 0, _x, _y + _h + ui(4), _r, _r);
					shader_reset();
				}
				
				break;
		}
		
		knob_hovering = _khv;
		resetFocus();
		
		return h;
	}
		
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
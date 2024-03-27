function rotatorRandom(_onModify) : widget() constructor {
	onModify = _onModify;
	
	dragging_index = -1;
	dragging = false;
	drag_sv  = 0;
	drag_dat = [ 0, 0, 0, 0, 0 ];
	
	knob_hovering = noone;
	
	mode = 0;
	tb_min_0 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(1, val); } ).setSlidable([ 0.1, 15 ], true); tb_min_0.hide = true;
	tb_max_0 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(2, val); } ).setSlidable([ 0.1, 15 ], true); tb_max_0.hide = true;
	tb_min_1 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(3, val); } ).setSlidable([ 0.1, 15 ], true); tb_min_1.hide = true;
	tb_max_1 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(4, val); } ).setSlidable([ 0.1, 15 ], true); tb_max_1.hide = true;
	
	tooltip    = new tooltipSelector("Mode", [
		__txtx("widget_rotator_random_range",        "Range"), 
		__txtx("widget_rotator_random_span",         "Span"), 
		__txtx("widget_rotator_random_double_range", "Double Range"), 
		__txtx("widget_rotator_random_double_span",  "Double Span")
	]);
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
		tb_min_0.interactable = interactable;
		tb_max_0.interactable = interactable;
		
		if(mode == 2 || mode == 3)	tb_min_1.interactable = interactable;
		if(mode == 2)				tb_max_1.interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
		tb_min_0.register(parent);
		tb_max_0.register(parent);
		
		if(mode == 2 || mode == 3)	tb_min_1.register(parent);
		if(mode == 2)				tb_max_1.register(parent);
	} #endregion
	
	static drawParam = function(params) { #region
		setParam(params);
		tb_min_0.setParam(params);
		tb_max_0.setParam(params);
		tb_min_1.setParam(params);
		tb_max_1.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _data, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		
		mode = _data[0];
		var _hh = mode > 1? _h * 2 + ui(4) : _h;
		h = h == 0? _hh : lerp_float(h, _hh, 5);
		
		var _kHover = dragging_index;
		var _r  = _h;
		var _bs = min(_h, ui(32));
		var _tx = _x + _r + ui(4);
		var _tw = _w - _r - ui(8) - _bs;
		
		switch(mode) {
			case 2 :
				draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y + _h + ui(4), _tw, _h, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y + _h + ui(4), _tw, _h, c_white, 0.5 + 0.5 * interactable);	
			case 0 :
			case 1 :
				draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y, _tw, _h, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y, _tw, _h, c_white, 0.5 + 0.5 * interactable);	
				break;
				
			case 3 :
				draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y, _tw, h, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y, _tw, h, c_white, 0.5 + 0.5 * interactable);	
		}
		
		tooltip.index = mode;
		if(buttonInstant(noone, _x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, active, hover, tooltip, THEME.rotator_random_mode, mode, [ COLORS._main_icon, c_white ]) == 2) { #region
			mode = (mode + 1) % 4;
			onModify(0, mode);
			
			if(mode == 0) {
				onModify(1,   0);
				onModify(2, 180);
			} else if(mode == 1) {
				onModify(1,    (_data[1] + _data[2]) / 2);
				onModify(2, abs(_data[1] - _data[2]) / 2);
			} else if(mode == 2) {
				onModify(1,   0);
				onModify(2,  90);
				onModify(3, 180);
				onModify(4, 270);
			} else if(mode == 3) {
				onModify(1,  45);
				onModify(2, 225);
				onModify(3,  45);
			}
			
		} #endregion
		
		_w -= _bs + ui(4);
		
		var _kx = _x + _r / 2;
		var _ky = _y + _r / 2;
		var _kr = (_r - ui(12)) / 2;
		var _kc = COLORS._main_icon;
		
		var _tw = (_w - _r - ui(4)) / 2;
		var _tx = _x + _r + ui(4);
		var _ty = _y;
		
		switch(mode) {
			case 0 : #region
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
		
				tb_min_0.draw(_tx,        _ty, _tw, _h, array_safe_get(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty, _tw, _h, array_safe_get(_data, 2), _m);
				
				if(dragging_index > -1) {
					_kc = COLORS._main_icon_light;
			
					var val;
					var curr_val = [ drag_sv[0], drag_sv[1], drag_sv[2], drag_sv[3], drag_sv[4] ];
					var modi     = false;
						
					curr_val[1] = round(dragging.delta_acc + drag_sv[1]);
					curr_val[2] = round(dragging.delta_acc + drag_sv[2]);
						
					val   = key_mod_press(CTRL)? round(curr_val[1] / 15) * 15 : curr_val[1];
					modi |= onModify(1, val);
						
					val   = key_mod_press(CTRL)? round(curr_val[2] / 15) * 15 : curr_val[2];
					modi |= onModify(2, val);
				
					if(modi) UNDO_HOLDING = true;
					
					MOUSE_BLOCK = true;
					
					if(mouse_check_button_pressed(mb_right)) {
						for( var i = 0; i < 5; i++ ) onModify(i, drag_dat[i]);
						
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
			
					if(mouse_press(mb_left, active)) {
						dragging_index = 2;
						
						drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky);
					}
					
				}
				
				draw_set_color(CDEF.main_dkgrey);
				draw_circle_angle(_kx, _ky, _kr, _data[1], _data[2], 32);
				
				shader_set(sh_widget_rotator_range);
					shader_set_color("color",   _kc);
					shader_set_f("angle",     degtorad(_data[1]), degtorad(_data[2]));
			
					draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
				shader_reset();
		
				break;
			#endregion
			
			case 1 : #region
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				
				tb_min_0.draw(_tx,        _ty, _tw, _h, array_safe_get(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty, _tw, _h, array_safe_get(_data, 2), _m);
				
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
						
					if(onModify(1, val)) UNDO_HOLDING = true;
					
					MOUSE_BLOCK = true;
					
					if(mouse_check_button_pressed(mb_right)) {
						for( var i = 0; i < 5; i++ ) onModify(i, drag_dat[i]);
						
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
							
					if(mouse_press(mb_left, active)) {
						dragging_index = 2;
						drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky);
					}
				}
				
				draw_set_color(CDEF.main_dkgrey);
				draw_circle_angle(_kx, _ky, _kr, _a0, _a1, 32);
				
				shader_set(sh_widget_rotator);
					shader_set_color("color", _kc);
					shader_set_f("angle",     degtorad(_data[1]));
			
					draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
				shader_reset();
		
				break;
			#endregion
			
			case 2 : #region
				var _ky0 = _y + _r / 2;
				var _ky1 = _y + _h + ui(4) + _r / 2;
				
				var _kc0 = _kc;
				var _kc1 = _kc;
				
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				tb_min_1.setFocusHover(active, hover);
				tb_max_1.setFocusHover(active, hover);
				
				tb_min_0.draw(_tx,        _ty,              _tw, _h, array_safe_get(_data, 1), _m);
				tb_max_0.draw(_tx + _tw,  _ty,              _tw, _h, array_safe_get(_data, 2), _m);
				tb_min_1.draw(_tx,        _ty + _h + ui(4), _tw, _h, array_safe_get(_data, 3), _m);
				tb_max_1.draw(_tx + _tw,  _ty + _h + ui(4), _tw, _h, array_safe_get(_data, 4), _m);
				
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
						
						if(onModify(ind, val)) modi = true;
					}
					
					if(modi) {
						UNDO_HOLDING = true;
						MOUSE_BLOCK  = true;
					}
					
					if(mouse_check_button_pressed(mb_right)) {
						for( var i = 0; i < 5; i++ ) onModify(i, drag_dat[i]);
						
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
							
					if(mouse_press(mb_left, active)) {
						dragging_index = 1;
						drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky0);
					}
				} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y + _h + ui(4), _x + _r, _y + _h + ui(4) + _r)) {
					_kc1 = COLORS._main_icon_light;
							
					if(mouse_press(mb_left, active)) {
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
					shader_set_color("color",   _kc0);
					shader_set_f("angle",     degtorad(_data[1]), degtorad(_data[2]));
			
					draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
					
					shader_set_color("color",   _kc1);
					shader_set_f("angle",     degtorad(_data[3]), degtorad(_data[4]));
			
					draw_sprite_stretched(s_fx_pixel, 0, _x, _y + _h + ui(4), _r, _r);
				shader_reset();
				
				break;
			#endregion
				
			case 3 : #region
				var _ky0 = _y + _r / 2;
				var _ky1 = _y + _h + ui(4) + _r / 2;
				
				var _kc0 = _kc;
				var _kc1 = _kc;
				
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				tb_min_1.setFocusHover(active, hover);
				
				tb_min_0.draw(_tx,        _ty,              _tw, _h, array_safe_get(_data, 1), _m);
				tb_max_0.draw(_tx,        _ty + _h + ui(4), _tw, _h, array_safe_get(_data, 2), _m);
				tb_min_1.draw(_tx + _tw,  _ty,	            _tw,  h, array_safe_get(_data, 3), _m);
				
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
						
					if(onModify(ind, val)) UNDO_HOLDING = true;
					
					MOUSE_BLOCK = true;
					
					if(mouse_check_button_pressed(mb_right)) {
						for( var i = 0; i < 5; i++ ) onModify(i, drag_dat[i]);
						
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
							
					if(mouse_press(mb_left, active)) {
						dragging_index = 1;
						drag_sv  = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						drag_dat = [ _data[0], _data[1], _data[2], _data[3], _data[4] ];
						dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky0);
					}
				} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y + _h + ui(4), _x + _r, _y + _h + ui(4) + _r)) {
					_kc1 = COLORS._main_icon_light;
							
					if(mouse_press(mb_left, active)) {
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
					shader_set_color("color", _kc0);
					shader_set_f("angle",     degtorad(_data[1]));
			
					draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
				
					shader_set_color("color", _kc1);
					shader_set_f("angle",     degtorad(_data[2]));
			
					draw_sprite_stretched(s_fx_pixel, 0, _x, _y + _h + ui(4), _r, _r);
				shader_reset();
		
				break;
			#endregion
		}
		
		knob_hovering = _kHover;
		resetFocus();
		
		return h;
	} #endregion
}
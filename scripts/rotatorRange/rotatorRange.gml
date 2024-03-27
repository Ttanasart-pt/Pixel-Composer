function rotatorRange(_onModify) : widget() constructor {
	onModify = _onModify;
	
	dragging_index = -1;
	dragging = noone;
	drag_sv  = 0;
	drag_dat = [ 0, 0 ];
	
	knob_hovering = noone;
	
	tb_min = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(0, val); } ).setSlidable([ 0.1, 15 ], true); tb_min.hide = true;
	tb_max = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(1, val); } ).setSlidable([ 0.1, 15 ], true); tb_max.hide = true;
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
		tb_min.interactable = interactable;
		tb_max.interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
		tb_min.register(parent);
		tb_max.register(parent);
	} #endregion
	
	static drawParam = function(params) { #region
		setParam(params);
		tb_min.setParam(params);
		tb_max.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _data, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(!is_real(_data[0])) return;
		if(!is_real(_data[1])) return;
		
		var _r  = _h;
		var _tx = _x + _r + ui(4);
		var _tw = _w - _r - ui(4);
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y, _tw, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y, _tw, _h, c_white, 0.5 + 0.5 * interactable);	
		
		var _tw = (_w - _r - ui(4)) / 2;
		
		tb_min.setFocusHover(active, hover);
		tb_min.draw(_x + _r + ui(4), _y, _tw, _h, _data[0], _m);
		
		tb_max.setFocusHover(active, hover);
		tb_max.draw(_x + _r + ui(4) + _tw, _y, _tw, _h, _data[1], _m);
		
		var _kx = _x + _r / 2;
		var _ky = _y + _r / 2;
		var _kr = (_r - ui(12)) / 2;
		var _kc = COLORS._main_icon;
		
		if(dragging_index) {
			_kc = COLORS._main_icon_light;
			
			var val = point_direction(_kx, _ky, _m[0], _m[1]);
			if(key_mod_press(CTRL)) val = round(val / 15) * 15;
			
			var val, real_val;
			var modi = false;
				
			real_val[0]   = round(dragging.delta_acc + drag_sv[0]);
			real_val[1]   = round(dragging.delta_acc + drag_sv[1]);
				
			val   = key_mod_press(CTRL)? round(real_val[0] / 15) * 15 : real_val[0];
			modi |= onModify(0, val);
				
			val   = key_mod_press(CTRL)? round(real_val[1] / 15) * 15 : real_val[1];
			modi |= onModify(1, val);
				
			if(modi) UNDO_HOLDING = true;
			MOUSE_BLOCK = true;
			
			if(mouse_check_button_pressed(mb_right)) {
				for( var i = 0; i < 2; i++ ) onModify(i, drag_dat[i]);
						
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
				dragging_index = 1;
				drag_sv  = [ _data[0], _data[1] ];
				drag_dat = [ _data[0], _data[1] ];
				dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky);
			}
		}
		
		draw_set_color(CDEF.main_dkgrey);
		draw_circle_angle(_kx, _ky, _kr, _data[0], _data[1], 32);
		
		shader_set(sh_widget_rotator_range);
			shader_set_color("color",   _kc);
			shader_set_f("angle",     degtorad(_data[0]), degtorad(_data[1]));
			
			draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
		shader_reset();
		
		resetFocus();
		
		return h;
	} #endregion
}
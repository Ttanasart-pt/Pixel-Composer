function rotatorRange(_onModify) : widget() constructor {
	#region data
		onModify = _onModify;
		
		dragging_index = -1;
		dragging = noone;
		drag_sv  = 0;
		drag_dat = [ 0, 0 ];
		
		knob_hovering = noone;
		
		rangeDrag = false;
		rangeDrag_mx = 0;
		rangeDrag_my = 0;
		rangeDrag_ss = 0;
		
		tb_min = textBox_Number(function(v) /*=>*/ {return onModify(v, 0)}).setHide(true);
		tb_max = textBox_Number(function(v) /*=>*/ {return onModify(v, 1)}).setHide(true);
	#endregion
	
	////- Set
	
	static setInteract = function(i = noone) {
		interactable = i;
		tb_min.interactable = i;
		tb_max.interactable = i;
	}
	
	static register = function(parent = noone) {
		tb_min.register(parent);
		tb_max.register(parent);
	}
	
	static isHovering = function() { return dragging || tb_min.hovering || tb_max.hovering; }
	
	////- Draw
	
	static drawParam = function(params) {
		setParam(params);
		tb_min.setParam(params);
		tb_max.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(!is_array(_data) || array_length(_data) < 2) return;
		if(array_any(_data, function(a) /*=>*/ {return !is_real(a)}))        return;
		
		var _r  = _h;
		var _drawRot = _w - _r > ui(64);
		var _tx = _drawRot? _x + _r : _x;
		var _tw = _drawRot? _w - _r : _w;
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, w,  _h, boxColor, 1);
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, _r, _h, CDEF.main_mdwhite, 1);
		
		if(_drawRot) {
			var _kx = _x + _r / 2;
			var _ky = _y + _r / 2;
			var _kr = (_r - ui(12)) / 2;
			var _kc = COLORS._main_icon;
		
			if(dragging_index) {
				_kc = COLORS._main_icon_light;
			
				var val = point_direction(_kx, _ky, _m[0], _m[1]);
				if(key_mod_press(SHIFT)) val = value_snap(val, 15);
			
				var val, real_val;
				var modi = false;
				
				real_val[0]   = round(dragging.delta_acc + drag_sv[0]);
				real_val[1]   = round(dragging.delta_acc + drag_sv[1]);
				
				val   = key_mod_press(SHIFT)? value_snap(real_val[0], 15) : real_val[0];
				modi = onModify(val, 0) || modi;
				
				val   = key_mod_press(SHIFT)? value_snap(real_val[1], 15) : real_val[1];
				modi = onModify(val, 1) || modi;
				
				if(modi) UNDO_HOLDING = true;
				MOUSE_BLOCK = true;
			
				if(mouse_rpress(true, true)) {
					for( var i = 0; i < 2; i++ ) onModify(drag_dat[i], i);
					
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
				
				if(mouse_lpress(active)) {
					dragging_index = 1;
					drag_sv  = [ _data[0], _data[1] ];
					drag_dat = [ _data[0], _data[1] ];
					dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky);
				}
			}
		
			draw_set_color(CDEF.main_dkgrey);
			draw_circle_angle(_kx, _ky, _kr, _data[0], _data[1], 32);
		
			shader_set(sh_widget_rotator_range);
				shader_set_f("side",     _r);
				shader_set_color("color",   _kc);
				shader_set_f("angle",     degtorad(_data[0]), degtorad(_data[1]));
			
				draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
			shader_reset();
		}
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, _h, boxColor, 0.5 + 0.5 * interactable);	
		
		_tw /= 2;
		
		var ps = h / 2;
		var px = _tx + _tw;
		var py = _y + _h / 2;
		
		if(rangeDrag) {
			hover = false;
			
			var _dt = (_m[0] - rangeDrag_mx) / w * 180;
			var _vx = value_snap(rangeDrag_ss[0] + _dt, key_mod_press(CTRL)? 15 : 1);
			var _vy = value_snap(rangeDrag_ss[1] + _dt, key_mod_press(CTRL)? 15 : 1);
			
			var u0 = onModify(_vx, 0); 
			var u1 = onModify(_vy, 1); 
			if(u0 || u1) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				UNDO_HOLDING = false;
				rangeDrag    = false;
			}
		}
		
		var bxHover = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var tbHover = bxHover;
		
		if(bxHover && w > ui(80)) {
			var pHover = hover && point_in_rectangle(_m[0], _m[1], px-ps, py-ps, px+ps, py+ps);
			if(pHover) tbHover = false;
		}
		
		tb_min.setFocusHover(active, tbHover);
		tb_min.draw(_tx, _y, _tw - 1, _h, _data[0], _m);
		
		tb_max.setFocusHover(active, tbHover);
		tb_max.draw(_tx + _tw, _y, _tw, _h, _data[1], _m);
		
		if(rangeDrag) {
			draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, COLORS._main_accent, 1);
			
		} else if(bxHover && w > ui(80)) {
			draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, pHover? COLORS._main_icon_light : COLORS._main_icon, 1);
			if(pHover && mouse_lpress(active)) {
				rangeDrag = true;
				rangeDrag_mx = _m[0];
				rangeDrag_my = _m[1];
				rangeDrag_ss = [_data[0], _data[1]];
			}
		}
		
		resetFocus();
		return h;
	}
		
	////- Action
	
	static clone = function() {
		var cln = new rotatorRange(onModify);
		return cln;
	}

	static free = function() {
		tb_min.free();
		tb_max.free();
	}
}
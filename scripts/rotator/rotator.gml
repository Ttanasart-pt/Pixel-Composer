function rotator(_onModify, _step = -1) : widget() constructor {
	onModify = _onModify;
	step	 = _step;
	
	scale    = 1;
	dragging = noone;
	drag_sv  = 0;
	real_val = 0;
	slide_speed = 1 / 10;
	side_button = noone;
	
	spr_bg   = THEME.rotator_bg;
	spr_knob = THEME.rotator_knob;
	
	tb_value = new textBox(TEXTBOX_INPUT.number, onModify).setSlidable();
	
	halign = fa_center;
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
		tb_value.interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
		tb_value.register(parent);
	} #endregion
	
	static drawParam = function(params) { #region
		halign = params.halign;
		return draw(params.x, params.y, params.w, params.data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _data, _m, draw_tb = true) { #region
		x = _x;
		y = _y;
		w = _w;
		h = ui(64);
		
		var _r = ui(28);
		
		if(side_button) {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - ui(32), _y + h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		switch(halign) {
			case fa_left :   _x += _r; break;
			case fa_center : _x += _w / 2; break;
		}
		
		if(!is_real(_data)) return;
		var knob_y = _y + h / 2;
		
		if(draw_tb) {
			tb_value.setFocusHover(active, hover);
			tb_value.draw(_x + ui(64), knob_y - ui(17), ui(64), TEXTBOX_HEIGHT, _data, _m);
		}
		
		draw_sprite(spr_bg, 0, round(_x), round(knob_y));
		
		draw_set_color(COLORS.widget_rotator_guide);
		draw_line(_x, knob_y, _x + lengthdir_x(ui(20), _data) - 1, knob_y + lengthdir_y(ui(20), _data) - 1);
		
		var px = _x     + lengthdir_x(_r, _data);
		var py = knob_y + lengthdir_y(_r, _data);
		
		if(dragging) {
			var real_val = round(dragging.delta_acc + drag_sv);
			var val      = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
			
			if(step != -1) val = round(real_val / step) * step;
			
			draw_sprite(spr_knob, 1, px, py);
			
			if(onModify(val))
				UNDO_HOLDING = true;
			
			MOUSE_BLOCK = true;
			
			if(mouse_check_button_pressed(mb_right)) {
				onModify(drag_sv);
				instance_destroy(dragging);
				dragging     = noone;
				UNDO_HOLDING = false;	
			} else if(mouse_release(mb_left)) {
				instance_destroy(dragging);
				dragging     = noone;
				UNDO_HOLDING = false;
			}
			
		} else if(hover && point_in_circle(_m[0], _m[1], _x, knob_y, _r + ui(16))) {
			draw_sprite(spr_knob, 1, px, py);
				
			if(mouse_press(mb_left, active)) {
				dragging = instance_create(0, 0, rotator_Rotator).init(_m, _x, knob_y);
				drag_sv  = _data;
			}
			
			var amo = 1;
			if(key_mod_press(CTRL)) amo *= 10;
			if(key_mod_press(ALT))  amo /= 10;
			
			if(key_mod_press(SHIFT)) {
				if(mouse_wheel_down())	onModify(_data + amo * SCROLL_SPEED);
				if(mouse_wheel_up())	onModify(_data - amo * SCROLL_SPEED);
			}
		} else {
			draw_sprite(spr_knob, 0, px, py);
		}
		
		resetFocus();
		
		return h;
	} #endregion
}
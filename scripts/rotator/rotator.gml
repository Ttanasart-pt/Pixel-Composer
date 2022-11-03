function rotator(_onModify) constructor {
	active = false;
	hover  = false;
	
	onModify = _onModify;
	
	dragging = false;
	drag_sv  = 0;
	drag_sa  = 0;
	
	real_val = 0;
	
	tb_value = new textBox(TEXTBOX_INPUT.number, onModify);
	
	static draw = function(_x, _y, _data, _m) {
		var knob_y = _y + ui(48);
		
		tb_value.hover  = hover;
		tb_value.active = active;
		tb_value.draw(_x + ui(64), knob_y - ui(17), ui(64), TEXTBOX_HEIGHT, _data, _m);
		
		draw_set_color(c_ui_blue_mdblack);
		draw_rectangle(_x - ui(44), knob_y - ui(44), _x + ui(44), knob_y + ui(44), 0);
		
		draw_sprite_ui_uniform(s_rotator_bg, 0, _x, knob_y);
		
		var px = _x     + lengthdir_x(ui(36), _data);
		var py = knob_y + lengthdir_y(ui(36), _data);
		
		if(dragging) {
			var delta = angle_difference(point_direction(_x, knob_y, _m[0], _m[1]), drag_sa);
			var val;
			var real_val   = round(delta + drag_sv);
			
			if(keyboard_check(vk_control)) 
				val = round(real_val / 15) * 15;
			else 
				val = real_val;
			
			draw_sprite_ui_uniform(s_rotator_knob, 1, px, py);
			
			if(val != drag_sv) {
				onModify(val);
				UNDO_HOLDING = true;
			}
			
			drag_sa = point_direction(_x, knob_y, _m[0], _m[1]);
			drag_sv = real_val;
			
			if(mouse_check_button_released(mb_left)) {
				dragging = false;
				UNDO_HOLDING = false;	
			}
			
		} else if(hover && point_in_circle(_m[0], _m[1], _x, knob_y, ui(48))) {
			draw_sprite_ui_uniform(s_rotator_knob, 1, px, py);
				
			if(active && mouse_check_button_pressed(mb_left)) {
				dragging = true;
				drag_sv  = _data;
				drag_sa  = point_direction(_x, knob_y, _m[0], _m[1]);
			}
		} else {
			draw_sprite_ui_uniform(s_rotator_knob, 0, px, py);
		}
		
		draw_set_text(f_p0, fa_center, fa_center, c_white);
		draw_text(_x, knob_y, string(_data));
		
		active = false;
		hover  = false;
	}
}
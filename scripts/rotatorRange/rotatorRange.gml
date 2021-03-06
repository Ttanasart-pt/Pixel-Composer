function rotatorRange(_onModify) constructor {
	active = false;
	hover  = false;
	
	onModify = _onModify;
	
	dragging = -1;
	drag_sv  = 0;
	drag_sa  = 0;
	
	static draw = function(_x, _y, _data, _m) {
		var knob_y = _y + 48;
		
		draw_set_color(c_ui_blue_mdblack);
		draw_rectangle(_x - 44, knob_y - 44, _x + 44, knob_y + 44, 0);
		
		draw_sprite(s_rotator_bg, 0, _x, knob_y);
		
		#region draw arc
			var hover_arc = false;
			var diss = point_distance(_m[0], _m[1], _x, knob_y);
			if(diss >= 32 && diss <= 40 || dragging == 2) {
				draw_set_color(c_ui_blue_ltgrey);
				hover_arc = true;
			} else
				draw_set_color(c_ui_blue_grey);
			var diff = _data[1] >= _data[0]? _data[1] - _data[0] : _data[1] + 360 - _data[0];
		
			for(var i = 0; i < abs(diff); i += 4) {
				var as = _data[0] + i * sign(diff);
				var ae = _data[0] + (i + 4) * sign(diff);
			
				var sx = _x     + lengthdir_x(36, as);
				var sy = knob_y + lengthdir_y(36, as);
				var ex = _x     + lengthdir_x(36, ae);
				var ey = knob_y + lengthdir_y(36, ae);
				
				draw_line_width(sx, sy, ex, ey, 8);
				draw_circle(ex, ey, 4, 0);
			}
		#endregion
		
		var px, py;
		
		for(var i = 0; i < 2; i++) {
			px[i] = _x + lengthdir_x(36, _data[i]);
			py[i] = knob_y + lengthdir_y(36, _data[i]);
			
			draw_sprite(s_rotator_knob, 0, px[i], py[i]);
		}
			
		if(dragging > -1) {
			var val = point_direction(_x, knob_y, _m[0], _m[1]);
			if(keyboard_check(vk_control)) val = round(val / 15) * 15;
			
			var delta = angle_difference(point_direction(_x, knob_y, _m[0], _m[1]), drag_sa);
			var val, real_val;
			
			if(dragging == 2) {
				real_val[0]   = round(delta + drag_sv[0]);
				val = keyboard_check(vk_control)? round(real_val[0] / 15) * 15 : real_val[0];
				onModify(0, val);
				
				real_val[1]   = round(delta + drag_sv[1]);
				val = keyboard_check(vk_control)? round(real_val[1] / 15) * 15 : real_val[1];
				onModify(1, val);
				
				UNDO_HOLDING = true;
			} else {
				real_val   = round(delta + drag_sv);
				val = keyboard_check(vk_control)? round(real_val / 15) * 15 : real_val;
				
				draw_sprite(s_rotator_knob, 1, px[dragging], py[dragging]);
				
				if(_data[dragging] != val) {
					onModify(dragging, val);
					UNDO_HOLDING = true;
				}
				
				drag_sv = real_val;
			}
			
			drag_sa = point_direction(_x, knob_y, _m[0], _m[1]);
			drag_sv = real_val;
			
			if(mouse_check_button_released(mb_left)) {
				dragging = -1;
				UNDO_HOLDING = false;
			}
		} else if(hover) {
			for(var i = 0; i < 2; i++) {
				if(point_in_circle(_m[0], _m[1], px[i], py[i], 10)) {
					draw_sprite(s_rotator_knob, 1, px[i], py[i]);
						
					if(active && mouse_check_button_pressed(mb_left)) {
						dragging = i;
						drag_sv  = _data[i];
						drag_sa  = point_direction(_x, knob_y, _m[0], _m[1]);
					}
				}
			}
			if(dragging == -1 && hover_arc && active && mouse_check_button_pressed(mb_left)) {
				dragging = 2;
				drag_sv  = _data;
				drag_sa  = point_direction(_x, knob_y, _m[0], _m[1]);
			}
		}
		
		draw_set_text(f_p0, fa_center, fa_center, c_white);
		draw_text(_x, knob_y - 12, string(_data[0]));
		draw_text(_x, knob_y + 12, string(_data[1]));
		
		active = false;
		hover  = false;
	}
}
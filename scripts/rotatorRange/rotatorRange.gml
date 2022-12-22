function rotatorRange(_onModify) constructor {
	active = false;
	hover  = false;
	
	onModify = _onModify;
	
	dragging = -1;
	drag_sv  = 0;
	drag_sa  = 0;
	drag_sc  = 0;
	
	static draw = function(_x, _y, _data, _m) {
		var knob_y = _y + ui(48);
		
		draw_sprite_ui_uniform(THEME.rotator_bg, 0, _x, knob_y);
		
		#region draw arc
			var hover_arc = false;
			var diss = point_distance(_m[0], _m[1], _x, knob_y);
			if(diss >= ui(32) && diss <= ui(40) || dragging == 2)
				hover_arc = true;
			
			var ans = _data[0] % 360;
			var ane = _data[1] % 360;
			
			var diff = ane >= ans? ane - ans : ane + 360 - ans;
			
			draw_set_color(COLORS.widget_rotator_range);
			for(var i = 0; i < abs(diff); i += 4) {
				var as = ans + i * sign(diff);
				var ae = ans + (i + 4) * sign(diff);
				
				var sx = _x     + lengthdir_x(ui(36), as);
				var sy = knob_y + lengthdir_y(ui(36), as);
				var ex = _x     + lengthdir_x(ui(36), ae);
				var ey = knob_y + lengthdir_y(ui(36), ae);
				
				draw_set_alpha(0.5 + 0.5 * hover_arc);
				draw_line_width(sx, sy, ex, ey, ui(8));
				draw_set_alpha(1);
				
				draw_circle(ex, ey, ui(4), 0);
			}
		#endregion
		
		var px, py;
		
		for(var i = 0; i < 2; i++) {
			px[i] = _x + lengthdir_x(ui(36), _data[i]);
			py[i] = knob_y + lengthdir_y(ui(36), _data[i]);
			
			draw_sprite_ui_uniform(THEME.rotator_knob, 0, px[i], py[i]);
		}
			
		if(dragging > -1) {
			var val = point_direction(_x, knob_y, _m[0], _m[1]);
			if(key_mod_press(CTRL)) val = round(val / 15) * 15;
			
			var delta = angle_difference(point_direction(_x, knob_y, _m[0], _m[1]), drag_sa);
			var val, real_val;
			
			if(dragging == 2) {
				real_val[0]   = round(delta + drag_sv[0]);
				val = key_mod_press(CTRL)? round(real_val[0] / 15) * 15 : real_val[0];
				onModify(0, val);
				
				real_val[1]   = round(delta + drag_sv[1]);
				val = key_mod_press(CTRL)? round(real_val[1] / 15) * 15 : real_val[1];
				onModify(1, val);
				
				UNDO_HOLDING = true;
			} else {
				var _o = _data[dragging];
				real_val   = round(delta + drag_sv);
				val = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
				
				draw_sprite_ui_uniform(THEME.rotator_knob, 1, px[dragging], py[dragging]);
				
				if(_data[dragging] != val) {
					onModify(dragging, val);
					
					if(keyboard_check(vk_alt)) {
						var dt = val - _o;
						onModify(!dragging, _data[!dragging] - dt);
					}
				
					UNDO_HOLDING = true;
				}
				
				drag_sv = real_val;
			}
			
			drag_sa = point_direction(_x, knob_y, _m[0], _m[1]);
			drag_sv = real_val;
			
			if(mouse_release(mb_left)) {
				dragging = -1;
				UNDO_HOLDING = false;
			}
		} else if(hover) {
			for(var i = 0; i < 2; i++) {
				if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(10))) {
					draw_sprite_ui_uniform(THEME.rotator_knob, 1, px[i], py[i]);
						
					if(mouse_press(mb_left, active)) {
						dragging = i;
						drag_sv  = _data[i];
						drag_sa  = point_direction(_x, knob_y, _m[0], _m[1]);
						drag_sc  = lerp_angle(_data[0], _data[1], 0.5);
					}
				}
			}
			if(dragging == -1 && hover_arc && mouse_press(mb_left, active)) {
				dragging = 2;
				drag_sv  = _data;
				drag_sa  = point_direction(_x, knob_y, _m[0], _m[1]);
			}
		}
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		draw_text(_x, knob_y - ui(12), string(_data[0]));
		draw_text(_x, knob_y + ui(12), string(_data[1]));
		
		active = false;
		hover  = false;
	}
}
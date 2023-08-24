function rotatorRange(_onModify) : widget() constructor {
	onModify = _onModify;
	
	dragging = -1;
	drag_sv  = 0;
	drag_sa  = 0;
	drag_sc  = 0;
	
	tb_min = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(0, val); } );
	tb_min.slidable = true;
	tb_min.slide_speed = 1;
	
	tb_max = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(1, val); } );
	tb_max.slidable = true;
	tb_max.slide_speed = 1;
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		tb_min.interactable = interactable;
		tb_max.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		tb_min.register(parent);
		tb_max.register(parent);
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = ui(64);
		
		_x += _w / 2;
		
		if(!is_real(_data[0])) return;
		if(!is_real(_data[1])) return;
		
		var knob_y = _y + h / 2;
		var _r = ui(28);
		
		tb_min.setFocusHover(active, hover);
		tb_max.setFocusHover(active, hover);
		
		tb_min.draw(_x - ui(40 + 16 + 80), knob_y - TEXTBOX_HEIGHT / 2, ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 0), _m);
		tb_max.draw(_x + ui(40 + 16),      knob_y - TEXTBOX_HEIGHT / 2, ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
		
		var px, py;
		for(var i = 0; i < 2; i++) {
			px[i] = _x + lengthdir_x(_r, _data[i]);
			py[i] = knob_y + lengthdir_y(_r, _data[i]);
		}
		
		draw_sprite(THEME.rotator_bg, 0, _x, knob_y);
		
		draw_set_color(COLORS.widget_rotator_guide);
		draw_line(_x, knob_y, _x + lengthdir_x(ui(20), _data[0]) - 1, knob_y + lengthdir_y(ui(20), _data[0]) - 1);
		draw_line(_x, knob_y, _x + lengthdir_x(ui(20), _data[1]) - 1, knob_y + lengthdir_y(ui(20), _data[1]) - 1);
		
		#region draw arc
			var hover_arc = false;
			var diss = point_distance(_m[0], _m[1], _x, knob_y);
			if(abs(diss - _r) < 6 || dragging == 2)
				hover_arc = true;
			for(var i = 0; i < 2; i++) {
				if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) 
					hover_arc = false;
			}
					
			draw_set_color(hover_arc? COLORS.widget_rotator_range_hover : COLORS.widget_rotator_range);
			draw_arc_th(_x, knob_y, _r, 3, _data[0], _data[1]);
		#endregion
		
		for(var i = 0; i < 2; i++)
			draw_sprite(THEME.rotator_knob, 0, px[i], py[i]);
			
		if(dragging > -1) {
			var val = point_direction(_x, knob_y, _m[0], _m[1]);
			if(key_mod_press(CTRL)) val = round(val / 15) * 15;
			
			var delta = angle_difference(point_direction(_x, knob_y, _m[0], _m[1]), drag_sa);
			var val, real_val;
			
			if(dragging == 2) {
				var modi = false;
				real_val[0]   = round(delta + drag_sv[0]);
				val = key_mod_press(CTRL)? round(real_val[0] / 15) * 15 : real_val[0];
				modi |= onModify(0, val);
				
				real_val[1]   = round(delta + drag_sv[1]);
				val = key_mod_press(CTRL)? round(real_val[1] / 15) * 15 : real_val[1];
				modi |= onModify(1, val);
				
				if(modi)
					UNDO_HOLDING = true;
			} else {
				var _o = _data[dragging];
				real_val   = round(delta + drag_sv);
				val = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
				
				draw_sprite(THEME.rotator_knob, 1, px[dragging], py[dragging]);
				
				if(_data[dragging] != val) {
					var modi = false;
					modi |= onModify(dragging, val);
					
					if(key_mod_press(ALT)) {
						var dt = val - _o;
						modi |= onModify(!dragging, _data[!dragging] - dt);
					}
				
					if(modi)
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
				if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) {
					draw_sprite(THEME.rotator_knob, 1, px[i], py[i]);
						
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
		
		//draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
		//draw_text(_x, knob_y - ui(8), string(_data[0]));
		//draw_text(_x, knob_y + ui(8), string(_data[1]));
		
		resetFocus();
		
		return h;
	}
}
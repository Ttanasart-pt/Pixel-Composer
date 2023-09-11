function rotatorRandom(_onModify) : widget() constructor {
	onModify = _onModify;
	
	dragging = -1;
	drag_sv  = 0;
	drag_sa  = 0;
	
	mode = 0;
	tb_min_0 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(1, val); } ).setSlidable(true, 1);
	tb_max_0 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(2, val); } ).setSlidable(true, 1);
	tb_min_1 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(3, val); } ).setSlidable(true, 1);
	tb_max_1 = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(4, val); } ).setSlidable(true, 1);
	
	tooltip    = new tooltipSelector("Mode", ["Range", "Span", "Double Range", "Double Span"]);
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		tb_min_0.interactable = interactable;
		tb_max_0.interactable = interactable;
		
		if(mode == 2 || mode == 3)	tb_min_1.interactable = interactable;
		if(mode == 2)				tb_max_1.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		tb_min_0.register(parent);
		tb_max_0.register(parent);
		
		if(mode == 2 || mode == 3)	tb_min_1.register(parent);
		if(mode == 2)				tb_max_1.register(parent);
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = ui(80);
		
		_x += _w / 2;
		
		mode = _data[0];
		
		var knx = _x;
		var kny = _y + h / 2;
		var px, py, _r = ui(28);
		
		draw_sprite(THEME.rotator_bg, 0, _x, kny);
		
		tooltip.index = mode;
		if(buttonInstant(THEME.button_hide_circle_28, knx - ui(28 / 2), kny - ui(28 / 2), ui(28), ui(28), _m, active, hover, tooltip, THEME.rotator_random_mode, mode) == 2) { #region
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
		
		switch(mode) {
			case 0 :
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
		
				tb_min_0.draw(knx - ui(40 + 16 + 80), kny - TEXTBOX_HEIGHT / 2, ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
				tb_max_0.draw(knx + ui(40 + 16),      kny - TEXTBOX_HEIGHT / 2, ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
				
				var _a0 = _data[1];
				var _a1 = _data[2];
				
				px[0] = knx + lengthdir_x(_r, _a0);
				px[1] = knx + lengthdir_x(_r, _a1);
				
				py[0] = kny + lengthdir_y(_r, _a0);
				py[1] = kny + lengthdir_y(_r, _a1);
				
				#region draw arc
					var hover_arc = false;
					var diss = point_distance(_m[0], _m[1], knx, kny);
					if(abs(diss - _r) < 6 || dragging == 2)
						hover_arc = true;
						
					for(var i = 0; i < 2; i++) {
						if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) 
							hover_arc = false;
					}
					
					draw_set_color(hover_arc? COLORS.widget_rotator_range_hover : COLORS.widget_rotator_range);
					draw_arc_width(knx, kny, _r, 3, _a0, _a1);
					
					for(var i = 0; i < 2; i++)
						draw_sprite(THEME.rotator_knob, 0, px[i], py[i]);
				#endregion
				
				if(dragging > -1) { #region
					var val = point_direction(knx, kny, _m[0], _m[1]);
					if(key_mod_press(CTRL)) val = round(val / 15) * 15;
					
					var delta = angle_difference(point_direction(knx, kny, _m[0], _m[1]), drag_sa);
					var val, real_val = drag_sv;
					
					if(dragging == 2) {
						var modi = false;
						real_val[1]   = round(delta + drag_sv[1]);
						val = key_mod_press(CTRL)? round(real_val[1] / 15) * 15 : real_val[1];
						modi |= onModify(1, val);
				
						real_val[2]   = round(delta + drag_sv[2]);
						val = key_mod_press(CTRL)? round(real_val[2] / 15) * 15 : real_val[2];
						modi |= onModify(2, val);
				
						if(modi) UNDO_HOLDING = true;
					} else {
						var _o = _data[dragging];
						real_val = round(delta + drag_sv);
						val = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
				
						draw_sprite(THEME.rotator_knob, 1, px[dragging], py[dragging]);
				
						if(_data[dragging] != val) {
							var modi = false;
							modi |= onModify(1 + dragging, val);
					
							if(key_mod_press(ALT)) {
								var dt = val - _o;
								modi |= onModify(1 + !dragging, _data[!dragging] - dt);
							}
				
							if(modi) UNDO_HOLDING = true;
						}
					}
			
					drag_sa = point_direction(knx, kny, _m[0], _m[1]);
					drag_sv = real_val;
			
					if(mouse_release(mb_left)) {
						dragging = -1;
						UNDO_HOLDING = false;
					}
					#endregion
				} else if(hover) { #region
					for(var i = 0; i < 2; i++) {
						if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) {
							draw_sprite(THEME.rotator_knob, 1, px[i], py[i]);
						
							if(mouse_press(mb_left, active)) {
								dragging = i;
								drag_sv  = _data[1 + i];
								drag_sa  = point_direction(knx, kny, _m[0], _m[1]);
							}
						}
					}
					if(dragging == -1 && hover_arc && mouse_press(mb_left, active)) {
						dragging = 2;
						drag_sv  = _data;
						drag_sa  = point_direction(knx, kny, _m[0], _m[1]);
					}
					#endregion
				}
				break;
			case 1 :
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
		
				tb_min_0.draw(knx - ui(40 + 16 + 80), kny - TEXTBOX_HEIGHT / 2, ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
				tb_max_0.draw(knx + ui(40 + 16),      kny - TEXTBOX_HEIGHT / 2, ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
				
				var _a0 = _data[1] - _data[2];
				var _a1 = _data[1] + _data[2];
				
				px[0] = knx + lengthdir_x(_r, _a0);
				py[0] = kny + lengthdir_y(_r, _a0);
				
				px[1] = knx + lengthdir_x(_r, _a1);
				py[1] = kny + lengthdir_y(_r, _a1);
				
				px[2] = knx + lengthdir_x(_r, (_a0 + _a1) / 2);
				py[2] = kny + lengthdir_y(_r, (_a0 + _a1) / 2);
				
				#region draw arc
					draw_set_color(COLORS.widget_rotator_range);
					draw_arc_width(knx, kny, _r, 3, _a0, _a1);
					
					for( var i = 0; i < 3; i++ ) 
						draw_sprite(THEME.rotator_knob, 0, px[i], py[i]);
				#endregion
				
				if(dragging > -1) { #region
					var val = point_direction(knx, kny, _m[0], _m[1]);
					if(key_mod_press(CTRL)) val = round(val / 15) * 15;
					
					var delta = angle_difference(point_direction(knx, kny, _m[0], _m[1]), drag_sa);
					var val, real_val = drag_sv;
					
					if(dragging == 2) {
						real_val[1] = round(delta + drag_sv[1]);
						val = key_mod_press(CTRL)? round(real_val[1] / 15) * 15 : real_val[1];
						
						draw_sprite(THEME.rotator_knob, 1, px[2], py[2]);
						
						if(onModify(1, val)) UNDO_HOLDING = true;
					} else {
						real_val[2] = round(drag_sv[2] + (delta * (dragging? 1 : -1)));
						val = key_mod_press(CTRL)? round(real_val[2] / 15) * 15 : real_val[2];
						
						draw_sprite(THEME.rotator_knob, 1, px[dragging], py[dragging]);
						
						if(onModify(2, val)) UNDO_HOLDING = true;
					}
					
					drag_sa = point_direction(knx, kny, _m[0], _m[1]);
					drag_sv = real_val;
			
					if(mouse_release(mb_left)) {
						dragging = -1;
						UNDO_HOLDING = false;
					}
					#endregion
				} else if(hover) { #region
					for(var i = 0; i < 3; i++) {
						if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) {
							draw_sprite(THEME.rotator_knob, 1, px[i], py[i]);
						
							if(mouse_press(mb_left, active)) {
								dragging = i;
								drag_sv  = _data;
								drag_sa  = point_direction(knx, kny, _m[0], _m[1]);
							}
						}
					}
					#endregion
				}
				break;
			case 2 :
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				tb_min_1.setFocusHover(active, hover);
				tb_max_1.setFocusHover(active, hover);
				
				tb_min_0.draw(knx - ui(40 + 16 + 80), kny - TEXTBOX_HEIGHT / 2 - ui(20), ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
				tb_max_0.draw(knx + ui(40 + 16),      kny - TEXTBOX_HEIGHT / 2 - ui(20), ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
				tb_min_1.draw(knx - ui(40 + 16 + 80), kny - TEXTBOX_HEIGHT / 2 + ui(20), ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 3), _m);
				tb_max_1.draw(knx + ui(40 + 16),      kny - TEXTBOX_HEIGHT / 2 + ui(20), ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 4), _m);
				
				var _a0 = _data[1];
				var _a1 = _data[2];
				var _a2 = _data[3];
				var _a3 = _data[4];
				
				px[0] = knx + lengthdir_x(_r, _a0);
				py[0] = kny + lengthdir_y(_r, _a0);
				
				px[1] = knx + lengthdir_x(_r, _a1);
				py[1] = kny + lengthdir_y(_r, _a1);
				
				px[2] = knx + lengthdir_x(_r, _a2);
				py[2] = kny + lengthdir_y(_r, _a2);
				
				px[3] = knx + lengthdir_x(_r, _a3);
				py[3] = kny + lengthdir_y(_r, _a3);
				
				#region draw arc
					draw_set_color(COLORS.widget_rotator_range);
					draw_arc_width(knx, kny, _r, 3, _a0, _a1);
					draw_arc_width(knx, kny, _r, 3, _a2, _a3);
					
					for( var i = 0; i < 4; i++ ) 
						draw_sprite(THEME.rotator_knob, 0, px[i], py[i]);
				#endregion
				
				if(dragging > -1) { #region
					var val = point_direction(knx, kny, _m[0], _m[1]);
					if(key_mod_press(CTRL)) val = round(val / 15) * 15;
					
					var delta = angle_difference(point_direction(knx, kny, _m[0], _m[1]), drag_sa);
					var val, real_val = drag_sv;
					var ind = dragging + 1;
					
					real_val[ind] = round(drag_sv[ind] + (delta * (ind? 1 : -1)));
					val = key_mod_press(CTRL)? round(real_val[ind] / 15) * 15 : real_val[ind];
						
					draw_sprite(THEME.rotator_knob, 1, px[dragging], py[dragging]);
						
					if(onModify(ind, val)) UNDO_HOLDING = true;
					
					drag_sa = point_direction(knx, kny, _m[0], _m[1]);
					drag_sv = real_val;
			
					if(mouse_release(mb_left)) {
						dragging = -1;
						UNDO_HOLDING = false;
					}
					#endregion
				} else if(hover) { #region
					for(var i = 0; i < 4; i++) {
						if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) {
							draw_sprite(THEME.rotator_knob, 1, px[i], py[i]);
						
							if(mouse_press(mb_left, active)) {
								dragging = i;
								drag_sv  = _data;
								drag_sa  = point_direction(knx, kny, _m[0], _m[1]);
							}
						}
					}
					#endregion
				}
				break;
			case 3 :
				tb_min_0.setFocusHover(active, hover);
				tb_max_0.setFocusHover(active, hover);
				tb_min_1.setFocusHover(active, hover);
				
				tb_min_0.draw(knx - ui(40 + 16 + 80), kny - TEXTBOX_HEIGHT / 2 - ui(20), ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
				tb_max_0.draw(knx - ui(40 + 16 + 80), kny - TEXTBOX_HEIGHT / 2 + ui(20), ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
				tb_min_1.draw(knx + ui(40 + 16),      kny - TEXTBOX_HEIGHT / 2, ui(80), TEXTBOX_HEIGHT, array_safe_get(_data, 3), _m);
				
				var _a0 = _data[1];
				var _a1 = _data[2];
				
				var _a2 = _data[1] - _data[3];
				var _a3 = _data[1] + _data[3];
				var _a4 = _data[2] - _data[3];
				var _a5 = _data[2] + _data[3];
				
				px[0] = knx + lengthdir_x(_r, _a0);
				py[0] = kny + lengthdir_y(_r, _a0);
				
				px[1] = knx + lengthdir_x(_r, _a1);
				py[1] = kny + lengthdir_y(_r, _a1);
				
				px[2] = knx + lengthdir_x(_r, _a2);
				py[2] = kny + lengthdir_y(_r, _a2);
				
				px[3] = knx + lengthdir_x(_r, _a3);
				py[3] = kny + lengthdir_y(_r, _a3);
				
				px[4] = knx + lengthdir_x(_r, _a4);
				py[4] = kny + lengthdir_y(_r, _a4);
				
				px[5] = knx + lengthdir_x(_r, _a5);
				py[5] = kny + lengthdir_y(_r, _a5);
				
				#region draw arc
					draw_set_color(COLORS.widget_rotator_range);
					draw_arc_width(knx, kny, _r, 3, _a2, _a3);
					draw_arc_width(knx, kny, _r, 3, _a4, _a5);
					
					draw_sprite(THEME.rotator_knob, 0, px[0], py[0]);
					draw_sprite(THEME.rotator_knob, 0, px[1], py[1]);
				#endregion
				
				if(dragging > -1) { #region
					var val = point_direction(knx, kny, _m[0], _m[1]);
					if(key_mod_press(CTRL)) val = round(val / 15) * 15;
					
					var delta = angle_difference(point_direction(knx, kny, _m[0], _m[1]), drag_sa);
					var val, real_val = drag_sv;
					var ind = dragging + 1;
					
					real_val[ind] = round(drag_sv[ind] + (delta * (ind? 1 : -1)));
					val = key_mod_press(CTRL)? round(real_val[ind] / 15) * 15 : real_val[ind];
						
					draw_sprite(THEME.rotator_knob, 1, px[dragging], py[dragging]);
						
					if(onModify(ind, val)) UNDO_HOLDING = true;
					
					drag_sa = point_direction(knx, kny, _m[0], _m[1]);
					drag_sv = real_val;
			
					if(mouse_release(mb_left)) {
						dragging = -1;
						UNDO_HOLDING = false;
					}
					#endregion
				} else if(hover) { #region
					for(var i = 0; i < 2; i++) {
						if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) {
							draw_sprite(THEME.rotator_knob, 1, px[i], py[i]);
							
							if(mouse_press(mb_left, active)) {
								dragging = i;
								drag_sv  = _data;
								drag_sa  = point_direction(knx, kny, _m[0], _m[1]);
							}
						}
					}
					#endregion
				}
				break;
		}
		
		resetFocus();
		
		return h;
	}
}
function rotatorRange(_onModify) : widget() constructor {
	onModify = _onModify;
	
	dragging_index = -1;
	dragging = noone;
	drag_sv  = 0;
	drag_dat = [ 0, 0 ];
	
	knob_hovering = noone;
	
	tb_min = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(0, val); } ).setSlidable();
	
	tb_max = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(1, val); } ).setSlidable();
	
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
		return draw(params.x, params.y, params.w, params.data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _data, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		h = ui(64);
		
		knob_hovering = dragging_index;
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
		
		draw_sprite(THEME.rotator_bg, 0, round(_x), round(knob_y));
		
		draw_set_color(COLORS.widget_rotator_guide);
		draw_line(_x, knob_y, _x + lengthdir_x(ui(20), _data[0]) - 1, knob_y + lengthdir_y(ui(20), _data[0]) - 1);
		draw_line(_x, knob_y, _x + lengthdir_x(ui(20), _data[1]) - 1, knob_y + lengthdir_y(ui(20), _data[1]) - 1);
		
		#region draw arc
			var hover_arc = false;
			var diss = point_distance(_m[0], _m[1], _x, knob_y);
			
			if(abs(diss - _r) < 6 || dragging_index == 2)
				hover_arc = true;
				
			for(var i = 0; i < 2; i++) {
				if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) 
					hover_arc = false;
			}
			
			draw_set_color(hover_arc? COLORS.widget_rotator_range_hover : COLORS.widget_rotator_range);
			draw_arc_forward(_x, knob_y, _r, 3, _data[0], _data[1]);
		#endregion
			
		if(dragging_index > -1) { #region
			var val = point_direction(_x, knob_y, _m[0], _m[1]);
			if(key_mod_press(CTRL)) val = round(val / 15) * 15;
			
			var val, real_val;
			
			if(dragging_index == 2) {
				var modi = false;
				
				real_val[0]   = round(dragging.delta_acc + drag_sv[0]);
				real_val[1]   = round(dragging.delta_acc + drag_sv[1]);
				
				val   = key_mod_press(CTRL)? round(real_val[0] / 15) * 15 : real_val[0];
				modi |= onModify(0, val);
				
				val   = key_mod_press(CTRL)? round(real_val[1] / 15) * 15 : real_val[1];
				modi |= onModify(1, val);
				
				if(modi) UNDO_HOLDING = true;
			} else {
				var _o   = _data[dragging_index];
				real_val = round(dragging.delta_acc + drag_sv);
				val = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
				
				if(_data[dragging_index] != val) {
					var modi = false;
					modi    |= onModify(dragging_index, val);
					
					if(key_mod_press(ALT)) {
						var dt = val - _o;
						modi  |= onModify(!dragging_index, _data[!dragging_index] - dt);
					}
				
					if(modi) UNDO_HOLDING = true;
				}
			}
			
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
		#endregion
		
		} else if(hover) { #region
			for(var i = 0; i < 2; i++) {
				if(point_in_circle(_m[0], _m[1], px[i], py[i], ui(20))) {
					knob_hovering = i;
						
					if(mouse_press(mb_left, active)) {
						dragging_index = i;
						drag_sv  = _data[i];
						drag_dat = [ _data[0], _data[1] ];
						dragging = instance_create(0, 0, rotator_Rotator).init(_m, _x, knob_y);
					}
				}
			}
			if(dragging_index == -1 && hover_arc && mouse_press(mb_left, active)) {
				dragging_index = 2;
				drag_sv  = [ _data[0], _data[1] ];
				drag_dat = [ _data[0], _data[1] ];
				dragging = instance_create(0, 0, rotator_Rotator).init(_m, _x, knob_y);
			}
		} #endregion
		
		for(var i = 0; i < 2; i++)
			draw_sprite(THEME.rotator_knob, knob_hovering == i, px[i], py[i]);
			
		resetFocus();
		
		return h;
	} #endregion
}
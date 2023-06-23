function rotator(_onModify, _step = -1) : widget() constructor {
	onModify = _onModify;
	step	 = _step;
	
	scale    = 1;
	dragging = false;
	drag_sv  = 0;
	drag_sa  = 0;
	real_val = 0;
	
	spr_bg   = THEME.rotator_bg;
	spr_knob = THEME.rotator_knob;
	
	tb_value = new textBox(TEXTBOX_INPUT.number, onModify);
	tb_value.slidable = true;
	tb_value.slide_speed = 1;
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		tb_value.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		tb_value.register(parent);
	}
	
	static draw = function(_x, _y, _data, _m, draw_tb = true) {
		x = _x;
		y = _y;
		w = 0;
		h = ui(64);
		
		if(!is_real(_data)) return;
		var knob_y = _y + h / 2;
		var _r = ui(28);
		
		if(draw_tb) {
			tb_value.setFocusHover(active, hover);
			tb_value.draw(_x + ui(64), knob_y - ui(17), ui(64), TEXTBOX_HEIGHT, _data, _m);
		}
		
		draw_sprite(spr_bg, 0, _x, knob_y);
		
		draw_set_color(COLORS.widget_rotator_guide);
		draw_line(_x, knob_y, _x + lengthdir_x(ui(20), _data) - 1, knob_y + lengthdir_y(ui(20), _data) - 1);
		
		var px = _x     + lengthdir_x(_r, _data);
		var py = knob_y + lengthdir_y(_r, _data);
		
		if(dragging) {
			var delta = angle_difference(point_direction(_x, knob_y, _m[0], _m[1]), drag_sa);
			var val;
			var real_val   = round(delta + drag_sv);
			
			if(key_mod_press(CTRL)) 
				val = round(real_val / 15) * 15;
			else 
				val = real_val;
			
			if(step != -1)
				val = round(real_val / step) * step;
			
			draw_sprite(spr_knob, 1, px, py);
			
			if(val != drag_sv) {
				if(onModify(val))
					UNDO_HOLDING = true;
			}
			
			drag_sa = point_direction(_x, knob_y, _m[0], _m[1]);
			drag_sv = real_val;
			
			if(mouse_release(mb_left)) {
				dragging = false;
				UNDO_HOLDING = false;
			}
			
		} else if(hover && point_in_circle(_m[0], _m[1], _x, knob_y, _r + ui(16))) {
			draw_sprite(spr_knob, 1, px, py);
				
			if(mouse_press(mb_left, active)) {
				dragging = true;
				drag_sv  = _data;
				drag_sa  = point_direction(_x, knob_y, _m[0], _m[1]);
			}
		} else {
			draw_sprite(spr_knob, 0, px, py);
		}
		
		//draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		//draw_text(_x, knob_y, string(_data));
		
		resetFocus();
	}
}
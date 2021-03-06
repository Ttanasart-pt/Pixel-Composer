function buttonColor(_onApply) {
	return new buttonColorClass(_onApply);
}

function buttonColorClass(_onApply) constructor {
	active = false;
	hover  = false;
	
	onApply = _onApply;
	onColorPick = function() {
		var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
		dialog.dropper_active = true;
		dialog.onApply = onApply;
	}
	
	is_picking = false;
	
	b_picker = button(onColorPick);
	b_picker.icon = s_color_picker_dropper;
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		b_picker.hover  = hover;
		b_picker.active = active;
		b_picker.draw(_x + _w - 32, _y + _h / 2 - 16, 32, 32, _m, s_button_hide);
		
		if(keyboard_check_pressed(vk_alt)) {
			onColorPick();
			is_picking = true;
		}
		if(is_picking) {
			if(keyboard_check_released(vk_alt)) {
				instance_destroy(o_dialog_color_selector);
				is_picking = false;
			}
		}
		
		var _cw = _w - 40;
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _cw, _y + _h)) {
			draw_sprite_stretched(s_button, 1, _x, _y, _cw, _h);	
			if(active && mouse_check_button_pressed(mb_left)) {
				var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
				dialog.current_color = _color;
				dialog.resetHSV();
				dialog.onApply = onApply;
				click = true;
			}
			if(mouse_check_button(mb_left))
				draw_sprite_stretched(s_button, 2, _x, _y, _cw, _h);	
		} else {
			draw_sprite_stretched(s_button, 0, _x, _y, _cw, _h);		
		}
		draw_sprite_stretched_ext(s_color_picker_sample, 0, _x + 4, _y + 4, _cw - 8, _h - 8, _color, 1);
		
		hover  = false;
		active = false;
		
		return click;
	}
}
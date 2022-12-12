function buttonColor(_onApply) {
	return new buttonColorClass(_onApply);
}

function buttonColorClass(_onApply) constructor {
	active = false;
	hover  = false;
	
	onApply = _onApply;
	onColorPick = function() {
		var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
		dialog.selector.dropper_active = true;
		dialog.selector.onApply = onApply;
		dialog.onApply = onApply;
	}
	
	is_picking = false;
	
	b_picker = button(onColorPick);
	b_picker.icon = THEME.color_picker_dropper;
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		b_picker.hover  = hover;
		b_picker.active = active;
		b_picker.draw(_x + _w - ui(32), _y + _h / 2 - ui(16), ui(32), ui(32), _m, THEME.button_hide);
		
		//if(keyboard_check_pressed(vk_alt)) {
		//	onColorPick();
		//	is_picking = true;
		//}
		//if(is_picking) {
		//	if(keyboard_check_released(vk_alt)) {
		//		instance_destroy(o_dialog_color_selector);
		//		is_picking = false;
		//	}
		//}
		
		var _cw = _w - ui(40);
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _cw, _y + _h)) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _cw, _h);	
			if(mouse_press(mb_left, active)) {
				var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
				dialog.selector.setColor(_color);
				dialog.selector.onApply = onApply;
				dialog.onApply = onApply;
				click = true;
			}
			if(mouse_click(mb_left, active))
				draw_sprite_stretched(THEME.button, 2, _x, _y, _cw, _h);	
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _cw, _h);		
		}
		draw_sprite_stretched_ext(THEME.color_picker_sample, 0, _x + ui(4), _y + ui(4), _cw - ui(8), _h - ui(8), _color, 1);
		
		hover  = false;
		active = false;
		
		return click;
	}
}
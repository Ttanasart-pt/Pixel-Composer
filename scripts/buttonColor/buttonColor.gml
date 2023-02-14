function buttonColor(_onApply) {
	return new buttonColorClass(_onApply);
}

function buttonColorClass(_onApply) : widget() constructor {
	onApply = _onApply;
	onColorPick = function() {
		var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
		dialog.selector.dropper_active = true;
		dialog.selector.onApply = onApply;
		dialog.onApply = onApply;
	}
	
	is_picking = false;
	
	current_color = c_black;
	b_picker = button(onColorPick);
	b_picker.icon = THEME.color_picker_dropper;
	
	static trigger = function() { 
		var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_color);
		dialog.selector.onApply = onApply;
		dialog.onApply = onApply;
	}
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		current_color = _color;
		
		b_picker.hover  = hover;
		b_picker.active = active;
		b_picker.draw(_x + _w - ui(32), _y + _h / 2 - ui(16), ui(32), ui(32), _m, THEME.button_hide);
		
		var _cw = _w - ui(40);
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _cw, _y + _h)) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _cw, _h);	
			if(mouse_press(mb_left, active)) {
				trigger();
				click = true;
			}
			if(mouse_click(mb_left, active))
				draw_sprite_stretched(THEME.button, 2, _x, _y, _cw, _h);	
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _cw, _h);		
			if(mouse_press(mb_left)) deactivate();
		}
		
		draw_sprite_stretched_ext(THEME.color_picker_sample, 0, _x + ui(4), _y + ui(4), _cw - ui(8), _h - ui(8), _color, 1);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6));	
		
		resetFocus();
		
		return click;
	}
}
function buttonGradient(_onApply) {
	return new buttonGradientClass(_onApply);
}

function buttonGradientClass(_onApply) : widget() constructor {
	onApply = _onApply;
	
	current_gradient = noone;
	current_data = noone;
	
	static trigger = function() {
		var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
		dialog.setGradient(current_gradient, current_data);
		dialog.onApply = onApply;
	}
	
	static draw = function(_x, _y, _w, _h, _gradient, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		current_gradient = _gradient;
		current_data = _data;
		
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _w, _h);	
			if(mouse_press(mb_left, active)) {
				trigger();
				click = true;
			}
			if(mouse_click(mb_left, active))
				draw_sprite_stretched(THEME.button, 2, _x, _y, _w, _h);	
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _w, _h);		
			if(mouse_press(mb_left)) deactivate();
		}
		
		draw_gradient(_x + ui(6), _y + ui(6), _w - ui(12), _h - ui(12), _gradient, _data[| 0]);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6));	
		
		resetFocus();
		
		return click;
	}
}
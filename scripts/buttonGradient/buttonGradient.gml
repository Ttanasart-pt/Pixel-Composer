function buttonGradient(_onApply, dialog = noone) : widget() constructor {
	onApply = _onApply;
	parentDialog = dialog;
	
	current_gradient = noone;
	
	function apply(value) {
		if(!interactable) return;
		onApply(value);
	}
	
	static trigger = function() {
		var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_gradient);
		dialog.onApply = apply;
		dialog.interactable = interactable;
		
		if(parentDialog)
			parentDialog.addChildren(dialog);
	}
	
	static draw = function(_x, _y, _w, _h, _gradient, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		if(!is_instanceof(_gradient, gradientObject)) return;
		
		current_gradient = _gradient;
		
		var click = false;
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		if(ihover && hoverRect) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _w, _h);	
			if(mouse_press(mb_left, iactive)) {
				trigger();
				click = true;
			}
			if(mouse_click(mb_left, iactive)) {
				draw_sprite_stretched(THEME.button, 2, _x, _y, _w, _h);	
				draw_sprite_stretched_ext(THEME.button, 3, _x, _y, _w, _h, COLORS._main_accent, 1);	
			}
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _w, _h);		
			if(mouse_press(mb_left)) deactivate();
		}
		
		_gradient.draw(_x + ui(6), _y + ui(6), _w - ui(12), _h - ui(12));
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);
		
		if(DRAGGING && DRAGGING.type == "Gradient" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _w, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		return click;
	}
}
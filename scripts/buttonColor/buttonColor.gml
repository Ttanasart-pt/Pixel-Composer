function buttonColor(_onApply, dialog = noone) : widget() constructor {
	onApply = _onApply;
	parentDialog = dialog;
	current_value = 0;
	triggered = false;
	
	onColorPick = function() {
		var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
		dialog.selector.dropper_active = true;
		dialog.selector.dropper_close  = true;
		dialog.drop_target = self;
		
		dialog.selector.onApply = onApply;
		dialog.onApply = onApply;
	}
	
	is_picking = false;
	
	current_color = c_black;
	b_picker = button(onColorPick);
	b_picker.icon = THEME.color_picker_dropper;
	
	function apply(value) {
		if(!interactable) return;
		current_value = value;
		triggered = true;
		onApply(value);
	}
	
	static isTriggered = function() {
		var t = triggered;
		triggered = false;
		return t;
	}
	
	static trigger = function() { 
		var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_color);
		dialog.selector.onApply = apply;
		dialog.onApply = apply;
		dialog.interactable = interactable;
		dialog.drop_target = self;
		
		if(parentDialog)
			parentDialog.addChildren(dialog);
	}
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		current_color = toNumber(_color);
		
		if(interactable) {
			b_picker.setActiveFocus(hover, active);
			b_picker.draw(_x + _w - ui(32), _y + _h / 2 - ui(16), ui(32), ui(32), _m, THEME.button_hide);
			b_picker.icon_blend = c_white;
			b_picker.icon_index = 0;
			if(instance_exists(o_dialog_color_selector) && o_dialog_color_selector.selector.dropper_active && o_dialog_color_selector.drop_target != noone) {
				if(o_dialog_color_selector.drop_target == self) {
					b_picker.icon_blend = COLORS._main_accent;
					b_picker.icon_index = 1;
				} else
					b_picker.icon_blend = COLORS._main_icon;
			}
		}
		
		var _cw = _w - ui(40);
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _cw, _y + _h);
		
		var click = false;
		if(ihover && hoverRect) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _cw, _h);	
			if(mouse_press(mb_left, iactive)) {
				trigger();
				click = true;
			}
			if(mouse_click(mb_left, iactive)) {
				draw_sprite_stretched(THEME.button, 2, _x, _y, _cw, _h);	
				draw_sprite_stretched_ext(THEME.button, 3, _x, _y, _w, _h, COLORS._main_accent, 1);	
			}
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _cw, _h);		
			if(mouse_press(mb_left)) deactivate();
		}
		
		draw_sprite_stretched_ext(THEME.button_color_overlay, 0, _x + ui(4), _y + ui(4), _cw - ui(8), _h - ui(8), current_color, 1);
		//draw_set_color(c_white);
		//draw_rectangle( _x + ui(4), _y + ui(4),  _x + _cw - ui(4), _y + _h - ui(4), 1);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);
		
		if(DRAGGING && DRAGGING.type == "Color" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _cw, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		return click;
	}
}
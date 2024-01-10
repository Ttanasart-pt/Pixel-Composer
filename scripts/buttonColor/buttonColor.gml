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
	
	b_quick_pick = button(function() {
		var pick = instance_create(mouse_mx, mouse_my, o_dialog_color_quick_pick);
		pick.onApply = onApply;
	});
	b_quick_pick.activate_on_press = true;
	b_quick_pick.icon = THEME.color_wheel;
	
	function apply(value) {
		if(!interactable) return;
		current_value = value;
		triggered     = true;
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
		
		if(parentDialog) {
			if(is_instanceof(parentDialog, PanelContent)) {
				if(parentDialog.panel)
					parentDialog.panel.addChildren(dialog);
			} else
				parentDialog.addChildren(dialog);
		}
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		current_color = _color;
		
		var _cw = _w;
		
		if(interactable) {
			var bx = _x + _cw - ui(32);
			_cw -= ui(32);
			
			b_picker.setFocusHover(active && !instance_exists(o_dialog_color_quick_pick), hover);
			b_picker.draw(bx, _y + _h / 2 - ui(16), ui(32), ui(32), _m, THEME.button_hide);
			b_picker.icon_blend = c_white;
			b_picker.icon_index = 0;
			if(instance_exists(o_dialog_color_selector) && o_dialog_color_selector.selector.dropper_active && o_dialog_color_selector.drop_target != noone) {
				if(o_dialog_color_selector.drop_target == self) {
					b_picker.icon_blend = COLORS._main_accent;
					b_picker.icon_index = 1;
				} else
					b_picker.icon_blend = COLORS._main_icon;
			}
			
			if(_cw > ui(64)) {
				bx  -= ui(32 + 4)
				_cw -= ui(32 + 4);
			
				b_quick_pick.setFocusHover(active, hover);
				b_quick_pick.draw(bx, _y + _h / 2 - ui(16), ui(32), ui(32), _m, THEME.button_hide);
			}
			
			_cw -= ui(8);
		}
		
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
		
		var _bx = _x  + ui(4);
		var _by = _y  + ui(4);
		var _bw = _cw - ui(8);
		var _bh = _h  - ui(8);
			
		if(is_array(current_color))
			drawPalette(current_color, _bx, _by, _bw, _bh);
		else if(is_real(current_color)) 
			draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by, _bw, _bh, current_color, 1);
		else if(is_int64(current_color)) {
			var _a = _color_get_alpha(current_color);
			
			if(_a == 1) {
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by, _bw, _bh, current_color, 1);
			} else {
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by, _bw, _bh - ui(8), current_color, 1);
			
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by + _bh - ui(6), _bw,      ui(6), c_black, 1);
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by + _bh - ui(6), _bw * _a, ui(6), c_white, 1);
			}
		}	
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);
		
		if(DRAGGING && DRAGGING.type == "Color" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _cw, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		return h;
	}
}

function drawColor(color, _x, _y, _w, _h) {
	if(is_real(color)) 
		draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y, _w, _h, color, 1);
	else if(is_int64(color)) {
		var _a = _color_get_alpha(color);
			
		if(_a == 1) {
			draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y, _w, _h, color, 1);
		} else {
			draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y, _w, _h - ui(8), color, 1);
			
			draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y + _h - ui(6), _w,      ui(6), c_black, 1);
			draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y + _h - ui(6), _w * _a, ui(6), c_white, 1);
		}
	}	
}
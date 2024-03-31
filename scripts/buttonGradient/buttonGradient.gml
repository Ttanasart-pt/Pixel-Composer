function buttonGradient(_onApply, dialog = noone) : widget() constructor {
	onApply      = _onApply;
	parentDialog = dialog;
	
	current_gradient = noone;
	side_button      = noone;
	
	function apply(value) { #region
		if(!interactable) return;
		onApply(value);
	} #endregion
	
	static trigger = function() { #region
		var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_gradient.clone());
		dialog.onApply = apply;
		dialog.interactable = interactable;
		
		if(parentDialog)
			parentDialog.addChildren(dialog);
	} #endregion
	
	static drawParam = function(params) { return draw(params.x, params.y, params.w, params.h, params.data, params.m); }
	
	static draw = function(_x, _y, _w, _h, _gradient, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		
		var _bs = min(_h, ui(32));
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		if(_w - _bs > ui(100) && side_button && instanceof(side_button) == "buttonClass") {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
			_w -= _bs + ui(8);
		}
		
		var _gw = _w - ui(8);
		var _gh = _h - ui(8);
		
		current_gradient = _gradient;
		
		if(is_array(_gradient)) {
			if(array_length(_gradient) == 0) return 0;
			
			h = ui(12) + array_length(_gradient) * _gh;
			current_gradient = _gradient[0];
		} else {
			h = _h;
		}
		
		if(!is_instanceof(current_gradient, gradientObject)) 
			return 0;
		
		var click = false;
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + h);
		if(ihover && hoverRect) {
			draw_sprite_stretched(THEME.button_def, 1, _x, _y, _w, h);	
			if(mouse_press(mb_left, iactive)) {
				trigger();
				click = true;
			}
			if(mouse_click(mb_left, iactive)) {
				draw_sprite_stretched(THEME.button_def, 2, _x, _y, _w, h);	
				draw_sprite_stretched_ext(THEME.button_def, 3, _x, _y, _w, h, COLORS._main_accent, 1);	
			}
		} else {
			draw_sprite_stretched(THEME.button_def, 0, _x, _y, _w, h);		
			if(mouse_press(mb_left)) deactivate();
		}
		
		if(!is_array(_gradient)) _gradient = [ _gradient ];
		
		for( var i = 0, n = array_length(_gradient); i < n; i++ ) {
			var _grad = _gradient[i];
			var _gx   = _x + ui(4);
			var _gy   = _y + ui(4) + i * _gh;
			
			if(is_instanceof(_grad, gradientObject))
				_grad.draw(_gx, _gy, _gw, _gh);
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), h + ui(6), COLORS._main_accent, 1);
		
		if(DRAGGING && DRAGGING.type == "Gradient" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _w, h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		return h;
	} #endregion
	
	static clone = function() { #region
		var cln = new buttonGradient(onApply, parentDialog);
		return cln;
	} #endregion
}
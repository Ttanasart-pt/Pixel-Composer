function buttonGradient(_onApply, dialog = noone) : widget() constructor {
	onApply      = _onApply;
	parentDialog = dialog;
	
	current_gradient = noone;
	side_button      = noone;
	
	expanded         = false;
	drag_color_index = -1;
	edit_color_index = -1;
	edit_color_mx    = 0;
	edit_color_sx    = 0;
	
	hover_index = 0;
	
	function apply(value) { #region
		if(!interactable) return;
		onApply(value);
	} #endregion
	
	static trigger = function() { #region
		var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_gradient.clone());
		dialog.onApply      = apply;
		dialog.interactable = interactable;
		dialog.drop_target  = self;
		
		if(parentDialog)
			parentDialog.addChildren(dialog);
	} #endregion
	
	static triggerSingle = function(_index) { #region
		edit_color_index = _index;
		
		var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(edit_color_index.value);
		dialog.selector.onApply = editColor;
		dialog.onApply = editColor;
		dialog.interactable = interactable;
	} #endregion
	
	function editColor(col) { #region
		if(edit_color_index == -1) return;
		
		edit_color_index.value = col;
		apply(current_gradient);
	} #endregion
	
	static drawParam = function(params) { return draw(params.x, params.y, params.w, params.h, params.data, params.m); }
	
	static draw = function(_x, _y, _w, _h, _gradient, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		
		right_click_block = true;
		
		var _bs = min(_h, ui(32));
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		if(_w - _bs > ui(100) && side_button && instanceof(side_button) == "buttonClass") {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
			_w -= _bs + ui(8);
		}
		
		var _gw = _w - ui(4);
		var _gh = _h - ui(4);
		
		current_gradient = _gradient;
		
		if(is_array(_gradient)) {
			if(array_length(_gradient) == 0) return 0;
			
			h = ui(4) + array_length(_gradient) * _gh;
			current_gradient = _gradient[0];
		} else {
			h = _h;
		}
		
		if(!is_instanceof(current_gradient, gradientObject)) 
			return 0;
		
		var _drawSingle = !is_array(_gradient) && is_instanceof(_gradient, gradientObject);
		var _ggw = _drawSingle? _gw - ui(24) : _w;
		var _ggx = _drawSingle? _x + ui(2) + ui(24) : _x;
		
		var hoverRect = ihover && point_in_rectangle(_m[0], _m[1], _ggx, _y, _ggx + _ggw, _y + h);
		
		if(_drawSingle && expanded)
			h = _h + ui(22);
		
		if(hoverRect) {
			draw_sprite_stretched(THEME.button_def, 1, _x, _y, _w, h);	
			if(mouse_press(mb_left, iactive)) 
				trigger();
			
			if(mouse_click(mb_left, iactive)) {
				draw_sprite_stretched(THEME.button_def, 2, _x, _y, _w, h);	
				draw_sprite_stretched_ext(THEME.button_def, 3, _x, _y, _w, h, COLORS._main_accent, 1);	
			}
		} else {
			draw_sprite_stretched(THEME.button_def, 0, _x, _y, _w, h);		
			if(mouse_press(mb_left)) deactivate();
		}
		
		if(_drawSingle) { 
			var _ggh = _gh;
			var _ggy = _y + ui(2);
		
			var _bbx = _x + ui(12);
			var _bby = _y + _ggh / 2 + ui(2);
			
			var _bba = 0.5;
			var _bbc = COLORS._main_icon;
			
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ui(24), _y + _ggh)) {
				_bba = 1;
				if(mouse_press(mb_left))
					expanded = !expanded;
				
				if(mouse_click(mb_left))
					_bbc = COLORS._main_icon_light;
			}
			
			draw_sprite_ext(THEME.arrow, expanded? 3 : 0, _bbx, _bby + ui(expanded), 1, 1, 0, _bbc, _bba);
			
			_gradient.draw(_ggx, _ggy, _ggw, _ggh);
			
			if(expanded) {
				var _cx = _x + ui(2);
				var _cy = _y + _ggh + ui(4);
				var _cw = _w - ui(4);
				var _ch = h - _ggh - ui(4 + 2);
				var _ks = ui(16);
				var _hv = noone;
				var _hi = noone;
				var _hover_index = hover_index;
				
				draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _ggx, _cy, _ggw, _ch, CDEF.main_mdblack, 1);	
				
				for (var i = 0, n = array_length(_gradient.keys); i < n; i++) {
					var _k  = _gradient.keys[i];
					var _kx = _ggx + _k.time * _ggw;
					var _ky = _ggy + _ggh + _ks - ui(4);
					
					if(drag_color_index == _k || edit_color_index == _k) {
						draw_set_color(COLORS._main_accent);
					} else {
						draw_set_color(c_white);
						draw_set_alpha(0.5);
					}
						
					draw_line_round(_kx, _ggy + _ggh - ui(8), _kx, _ky, 1);
					draw_set_alpha(1);
					
					_kx = clamp(_kx, _ggx + _ks / 2, _ggx + _ggw - _ks / 2);
					
					draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _kx - _ks / 2, _ky - _ks / 2, _ks, _ks, _k.value, 1);
					var _ka = 0.3;
					
					if(hover && point_in_rectangle(_m[0], _m[1], _kx - _ks / 2, _ky - _ks / 2, _kx + _ks / 2, _ky + _ks / 2)) {
						_ka = 1;
						_hv = _k;
						_hi = i;
						
						if(mouse_press(mb_left, active)) {
							drag_color_index = _k;
							edit_color_mx    = _m[0];
							edit_color_sx    = _k.time;
						}
						
						if(DOUBLE_CLICK) 
							triggerSingle(_k);
					}
					
					if(_hover_index == i && DRAGGING && DRAGGING.type == "Color") {
						draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _kx - _ks / 2, _ky - _ks / 2, _ks, _ks, COLORS._main_value_positive, 1);
						if(mouse_release(mb_left)) {
							_k.value = DRAGGING.data;
							apply(current_gradient);
						}
						
					} else {
						if(drag_color_index == _k || edit_color_index == _k)
							draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _kx - _ks / 2, _ky - _ks / 2, _ks, _ks, COLORS._main_accent, 1);
						else
							draw_sprite_stretched_add(THEME.menu_button_mask, 1, _kx - _ks / 2, _ky - _ks / 2, _ks, _ks, c_white, _ka);
					}
				}
				
				if(_hv != noone) {
					right_click_block = false;
					if(array_length(_gradient.keys) > 1 && mouse_press(mb_right, active)) {
						array_remove(_gradient.keys, _hv);
						_gradient.refresh();
						apply(_gradient);
					}
					
				} else if(point_in_rectangle(_m[0], _m[1], _ggx, _cy, _ggx + _ggw, _cy + _ch)) {
					if(mouse_press(mb_left, active)) {
						var _ti = clamp((_m[0] - _ggx) / _ggw, 0, 1);
						var _va = _gradient.eval(_ti);
						var _nk = new gradientKey(_ti, _va);
						
						_gradient.add(_nk);
						
						drag_color_index = _nk;
						edit_color_mx    = _m[0];
						edit_color_sx    = _ti;
					}
				}
				
				hover_index = _hi;
			}
			
			if(drag_color_index != -1) {
				var _val = edit_color_sx + (_m[0] - edit_color_mx) / _ggw;
				    _val = clamp(_val, 0, 1);
				
				if(drag_color_index.time != _val) {
					drag_color_index.time = _val;
					_gradient.refresh();
				}
				
				if(mouse_release(mb_left)) {
					drag_color_index = -1;
					_gradient.refresh();
					apply(_gradient);
				}
			}
			
		} else {
			for( var i = 0, n = array_length(_gradient); i < n; i++ ) {
				var _grad = _gradient[i];
				var _gx   = _x + ui(2);
				var _gy   = _y + ui(2) + i * _gh;
				
				if(is_instanceof(_grad, gradientObject))
					_grad.draw(_gx, _gy, _gw, _gh);
			}
		}
		
		if(WIDGET_CURRENT == self || (instance_exists(o_dialog_gradient) && o_dialog_gradient.drop_target == self))
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x, _y, _w, h, COLORS._main_accent, 1);
		
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
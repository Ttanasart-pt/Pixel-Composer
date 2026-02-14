function buttonGradient(_onApply, dialog = noone) : widget() constructor {
	onApply      = _onApply;
	parentDialog = dialog;
	
	current_gradient = undefined;
	edit_gradient    = undefined;
	
	expanded         = false;
	drag_color_index = -1;
	edit_color_index = -1;
	edit_color_mx    =  0;
	edit_color_sx    =  0;
	
	hover_index = 0;
	
	static trigger = function() {
		var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2)
						.setDefault(current_gradient.clone());
						
		dialog.onApply      = onApply;
		dialog.interactable = interactable;
		dialog.drop_target  = self;
		
		if(parentDialog) parentDialog.addChildren(dialog);
	}
	
	static triggerSingle = function(_index) {
		edit_gradient    = current_gradient.clone();
		edit_color_index = _index;
		
		var dialog = dialogCall(o_dialog_color_selector)
						.setDefault(edit_gradient.keys[edit_color_index].value)
						.setApply(editColor)
		
		dialog.interactable = interactable;
	}
	
	static editColor = function(col) {
		if(edit_color_index == -1) return;
		
		edit_gradient.keys[edit_color_index].value = col;
		onApply(edit_gradient);
		
	} editColor = method(self, editColor);
	
	////- Widget
	
	static fetchHeight = function(params) { return params.h + expanded * ui(22); }
	static drawParam   = function(params) { return draw(params.x, params.y, params.w, params.h, params.data, params.m); }
	
	static draw = function(_x, _y, _w, _h, _gradient, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		right_click_block = true;
		
		var bs = min(_h, ui(32));
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		draw_sprite_stretched_ext(THEME.button_def, 0, x, y, w, h, boxColor);
		
		if(_w - bs > ui(100) && side_button && instanceof(side_button) == "buttonClass") {
			var bx = _x + _w - bs;
			
			draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, _h, CDEF.main_mdwhite, 1);
			side_button.setFocusHover(active, hover);
			side_button.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
			_w -= bs;
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
		
		if(!is(current_gradient, gradientObject)) return 0;
		
		var _drawSingle = !is_array(_gradient) && is(_gradient, gradientObject);
		var _bbw = _h;
		var _ggw = _drawSingle? _gw - _bbw : _w;
		var _ggx = _drawSingle? _x + ui(2) + _bbw : _x;
		
		var hoverRect = ihover && point_in_rectangle(_m[0], _m[1], _ggx, _y, _ggx + _ggw, _y + h);
		
		if(_drawSingle && expanded)
			h = _h + ui(22);
		
		if(hoverRect) {
			if(mouse_lpress(iactive)) 
				trigger();
			
			if(mouse_lclick(iactive)) {
				draw_sprite_stretched_ext(THEME.button_def, 2, _x, _y, _w, h, boxColor);	
				draw_sprite_stretched_ext(THEME.button_def, 3, _x, _y, _w, h, COLORS._main_accent, 1);	
			}
			
		} else if(mouse_lpress()) deactivate();
		
		if(_drawSingle) { 
			var _ggh = _gh;
			var _ggy = _y + ui(2);
			
			var _bbx = _x + _bbw / 2;
			var _bby = _y + _ggh / 2 + ui(2);
			
			var _bba = .4 + .4 * interactable;
			var _bbc = COLORS._main_icon;
			
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _bbw, _y + _ggh)) {
				_bbc = COLORS._main_icon_light;
				
				if(mouse_lpress())
					expanded = !expanded;
			}
			
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _bbw, h, CDEF.main_mdwhite, 1);
			draw_sprite_ui(THEME.arrow, expanded? 3 : 0, _bbx, _bby + ui(expanded), 1, 1, 0, _bbc, _bba);
			
			var _display_gradient = current_gradient;
			_display_gradient.draw(_ggx, _ggy, _ggw, _ggh);
			
			if(expanded) {
				var _cx = _x + ui(2);
				var _cy = _y + _ggh + ui(4);
				var _cw = _w - ui(4);
				var _ch = h - _ggh - ui(4 + 2);
				var _ks = ui(16);
				var _hv = noone;
				var _hi = noone;
				var _hover_index = hover_index;
				
				draw_sprite_stretched_ext(THEME.box_r2, 0, _ggx, _cy, _ggw, _ch, CDEF.main_mdblack, 1);	
				
				for (var i = 0, n = array_length(_display_gradient.keys); i < n; i++) {
					var _k  = _display_gradient.keys[i];
					var _kx = _ggx + _k.time * _ggw;
					var _ky = _ggy + _ggh + _ks - ui(4);
					
					if(drag_color_index == _k || edit_color_index == i)
						draw_set_color(COLORS._main_accent);
					else
						draw_set_color_alpha(c_white, .5);
					
					draw_line_round(_kx, _ggy + _ggh - ui(8), _kx, _ky, 1);
					draw_set_alpha(1);
					
					_kx = clamp(_kx, _ggx + _ks / 2, _ggx + _ggw - _ks / 2);
					
					draw_sprite_stretched_ext(THEME.box_r2, 0, _kx - _ks / 2, _ky - _ks / 2, _ks, _ks, _k.value, 1);
					var _ka = 0.3;
					
					if(hover && point_in_rectangle(_m[0], _m[1], _kx - _ks / 2, _ky - _ks / 2, _kx + _ks / 2, _ky + _ks / 2)) {
						_ka = 1;
						_hv = _k;
						_hi = i;
						
						if(mouse_lpress(active)) {
							edit_gradient    = current_gradient.clone();
							
							drag_color_index = edit_gradient.keys[i];
							edit_color_mx    = _m[0];
							edit_color_sx    = _k.time;
						}
						
						if(DOUBLE_CLICK) triggerSingle(i);
					}
					
					if(_hover_index == i && DRAGGING && DRAGGING.type == "Color") { // drag color to grad key
						draw_sprite_stretched_ext(THEME.box_r2, 1, _kx - _ks / 2, _ky - _ks / 2, _ks, _ks, COLORS._main_value_positive, 1);
						if(mouse_lrelease()) {
							var apply_gradient = current_gradient.clone();
							apply_gradient.keys[i].value = DRAGGING.data;
							
							onApply(apply_gradient);
						}
						
					} else {
						var cc = drag_color_index == _k || edit_color_index == i? COLORS._main_accent : c_white;
						var aa = drag_color_index == _k || edit_color_index == i? 1 : _ka;
						draw_sprite_stretched_ext(THEME.box_r2, 1, _kx - _ks / 2, _ky - _ks / 2, _ks, _ks, cc, aa);
					}
				}
				
				if(_hi != noone) {
					right_click_block = false;
					
					var apply_gradient = current_gradient.clone();
					if(array_length(apply_gradient.keys) > 1 && mouse_press(mb_right, active)) {
						array_delete(apply_gradient.keys, _hi, 1);
						apply_gradient.refresh();
						onApply(apply_gradient);
					}
					
				} else if(point_in_rectangle(_m[0], _m[1], _ggx, _cy, _ggx + _ggw, _cy + _ch)) {
					if(mouse_lpress(active)) {
						edit_gradient = current_gradient.clone();
						
						var _ti = clamp((_m[0] - _ggx) / _ggw, 0, 1);
						var _va = _gradient.eval(_ti);
						var _nk = new gradientKey(_ti, _va);
						
						edit_gradient.add(_nk);
						drag_color_index = _nk;
						edit_color_mx    = _m[0];
						edit_color_sx    = _ti;
						
						onApply(edit_gradient);
					}
				}
				
				hover_index = _hi;
			}
			
			if(drag_color_index != -1) {
				var _val = edit_color_sx + (_m[0] - edit_color_mx) / _ggw;
				    _val = clamp(_val, 0, 1);
				
				if(drag_color_index.time != _val) {
					drag_color_index.time = _val;
					edit_gradient.refresh();
					onApply(edit_gradient);
				}
				
				if(mouse_lrelease())
					drag_color_index = -1;
			}
			
		} else {
			for( var i = 0, n = array_length(_gradient); i < n; i++ ) {
				var _grad = _gradient[i];
				var _gx   = _x + ui(2);
				var _gy   = _y + ui(2) + i * _gh;
				
				if(is(_grad, gradientObject))
					_grad.draw(_gx, _gy, _gw, _gh);
			}
		}
		
		if(hide == 0) {
			if(hoverRect) draw_sprite_stretched_ext(THEME.button_def, 3, x, y, w, h, CDEF.main_grey);	
			else draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, h, boxColor, .5 + .5 * interactable);
		}
		
		if(WIDGET_CURRENT == self || (instance_exists(o_dialog_gradient) && o_dialog_gradient.drop_target == self))
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x, _y, _w, h, COLORS._main_accent, 1);
		
		if(DRAGGING && DRAGGING.type == "Gradient" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _w, h, COLORS._main_value_positive, 1);	
			if(mouse_lrelease())
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		return h;
	}
	
	static clone = function() { return new buttonGradient(onApply, parentDialog); }
}
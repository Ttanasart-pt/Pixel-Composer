function buttonColor(_onApply, dialog = noone) : widget() constructor {
	onApply       = _onApply;
	parentDialog  = dialog;
	current_value = 0;
	triggered     = false;
	show_alpha    = true;
	simple        = false;
	
	hover_hex     = 0;
	hover_wid     = ui(24);
	
	onColorPick   = function() /*=>*/ {
		with(dialogCall(o_dialog_color_selector)) {
			setApply(other.onApply);
			selector.dropper_active = true;
			selector.dropper_close  = true;
			drop_target = other;
		}
	}
	
	is_picking    = false;
	current_color = c_black;
	b_picker      = button(onColorPick).setIcon(THEME.color_picker_dropper, 0, COLORS._main_icon);
	b_quick_pick  = button(function() /*=>*/ {
		var pick = instance_create(mouse_mx, mouse_my, o_dialog_color_quick_pick);
		array_insert(pick.palette, 0, current_color);
		pick.onApply = onApply;
	}).setIcon(THEME.color_wheel);
	
	b_quick_pick.activate_on_press = true;
	
	function apply(value) {
		if(!interactable) return;
		current_value = value;
		triggered     = true;
		onApply(value);
	}
	
	static isSimple  = function() /*=>*/ { simple = true; show_alpha = false; return self; };
	static hideAlpha = function() /*=>*/ { show_alpha = false; return self; };
	
	static isTriggered = function() {
		var t = triggered;
		triggered = false;
		return t;
	}
	
	static trigger = function() { 
		var dialog = dialogCall(o_dialog_color_selector)
						.setDefault(is_array(current_color)? array_safe_get(current_color, 0, 0) : current_color)
						.setApply(apply);
		
		dialog.interactable     = interactable;
		dialog.drop_target      = self;
		
		if(parentDialog == noone) return;
		
		if(is(parentDialog, PanelContent)) {
			if(parentDialog.panel) parentDialog.panel.addChildren(dialog);
			
		} else
			parentDialog.addChildren(dialog);
	}
	
	static drawParam = function(params) { return draw(params.x, params.y, params.w, params.h, params.data, params.m); }
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		current_color = _color;
		hovering      = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		var _cw = _w;
		var _bs = min(_h, ui(32));
		
		if(_w - _bs > ui(128) && interactable) {
			var bx = _x + _cw - _bs;
			_cw -= _bs;
			
			b_picker.setFocusHover(active && !instance_exists(o_dialog_color_quick_pick), hover);
			
			b_picker.draw(bx, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			b_picker.icon_blend = COLORS._main_icon;
			b_picker.icon_index = 0;
			b_picker.icon_size  = min(1, _bs / ui(32));
			
			if(instance_exists(o_dialog_color_selector) && o_dialog_color_selector.selector.dropper_active && o_dialog_color_selector.drop_target != noone) {
				if(o_dialog_color_selector.drop_target == self) {
					b_picker.icon_blend = COLORS._main_accent;
					b_picker.icon_index = 1;
				}
			}
			
			if(_cw > ui(128)) {
				bx  -= _bs + ui(4)
				_cw -= _bs + ui(4);
				
				b_quick_pick.icon_size = min(1, _bs / ui(32));
				b_quick_pick.setFocusHover(active, hover);
				b_quick_pick.draw(bx, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			}
			
			_cw -= ui(4);
		}
		
		var _bx  = _x  + ui(2);
		var _by  = _y  + ui(2);
		var _bw  = _cw - ui(4);
		var _bh  = _h  - ui(4);
		var _bww = _bw - hover_hex * hover_wid;
		
		var hoverRect = ihover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _bww, _y + _h);
		
		if(hoverRect) {
			draw_sprite_stretched_ext(THEME.button_def, 1, _x, _y, _cw, _h, boxColor);	
			
			if(mouse_press(mb_left, iactive)) 
				trigger();
			
			if(mouse_click(mb_left, iactive)) {
				draw_sprite_stretched_ext(THEME.button_def, 2, _x, _y, _cw, _h, boxColor);
				draw_sprite_stretched_ext(THEME.button_def, 3, _x, _y, _cw, _h, COLORS._main_accent);
			}
		} else {
			draw_sprite_stretched_ext(THEME.button_def, 0, _x, _y, _cw, _h, boxColor);
			if(mouse_press(mb_left)) deactivate();
		}
		
		if(is_array(current_color))
			drawPalette(current_color, _bx, _by, _bw, _bh);
			
		else if(is_numeric(current_color)) {
			var _hvb  = ihover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _cw, _y + _h);
			hover_hex = isSimple? 0 : lerp_float(hover_hex, _hvb, 4);
			
			var _bs  = min(_bh, ui(24));
			var _bcx = _bx + _bw - _bs - ui(4);
			var _bcy = _by + _bh / 2;
			
			var _baa = 0.5;
			var _htg = ui(12);
			var _bcc = COLORS._main_icon;
			
			if(hover_hex > 0) {
				if(ihover && point_in_rectangle(_m[0], _m[1], _bx + _bw - ui(24), _y, _bx + _bw, _y + _h)) {
					_htg = _bw - _bh;
					_baa = 1.;
				
					if(mouse_press(mb_left, iactive)) {
						if(interactable && key_mod_press(SHIFT)) {
							var _hx = clipboard_get_text();
							var _cc = color_from_rgb(_hx);
							if(_cc >= 0) onApply(_cc);
						} else
							clipboard_set_text(color_get_hex(current_color));
					}
					
					if(mouse_click(mb_left, iactive))
						_bcc = COLORS._main_icon_light;
				}
				
				var _scis = gpu_get_scissor();
				draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text_sub);
				gpu_set_scissor(_bx, _by, _bw, _bh);
				draw_text_add(_bcx - ui(4), _y + _h / 2 + ui(1), color_get_hex(current_color));
				gpu_set_scissor(_scis);
				
				var _spr = interactable && key_mod_press(SHIFT)? THEME.paste_20 : THEME.copy_20;
				draw_sprite_stretched_ext(_spr, 0, _bcx, _bcy - _bs / 2, _bs, _bs, _bcc, _baa);
			}
			
			hover_wid = lerp_float(hover_wid, _htg, 5);
			
			var _a = _color_get_alpha(current_color);
			if(_a == 1 || !show_alpha) {
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by, _bww, _bh, current_color, 1);
			} else {
				draw_sprite_stretched_ext(THEME.button_backdroup, 4, _bx, _by, _bww, _bh, boxColor, 1);
				draw_sprite_stretched_ext(THEME.palette_mask,     1, _bx, _by, _bww, _bh - ui(8), current_color, 1);
			
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by + _bh - ui(6), _bww,      ui(6), c_black, 1);
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by + _bh - ui(6), _bww * _a, ui(6), c_white, 1);
			}
		}	
		
		if(WIDGET_CURRENT == self || (instance_exists(o_dialog_color_selector) && o_dialog_color_selector.drop_target == self))
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x, _y, _cw, _h, COLORS._main_accent, 1);
		
		if(DRAGGING && DRAGGING.type == "Color" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _cw, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		return h;
	}
	
	static clone = function() {
		var cln = new buttonColor(onApply, parentDialog);
		return cln;
	}
}

function drawColorBBOX(_color, _bbox, _alp = true, _ind = 1) { drawColor(_color, _bbox.x0, _bbox.y0, _bbox.w, _bbox.h, _alp, _ind); }
	
function drawColor(color, _x, _y, _w, _h, _alp = true, _ind = 1) {
	
	if(is_real(color) || !_alp) {
		draw_sprite_stretched_ext(THEME.palette_mask, _ind, _x, _y, _w, _h, color, 1);
		return;
	}
		
	var _a = _color_get_alpha(color);
		
	if(_a == 1) {
		draw_sprite_stretched_ext(THEME.palette_mask, _ind, _x, _y, _w, _h, color, 1);
		return;
	}
		
	draw_sprite_stretched_ext(THEME.palette_mask, _ind, _x, _y, _w, _h - ui(8), color, 1);
	
	draw_sprite_stretched_ext(THEME.palette_mask,         1, _x, _y + _h - ui(6), _w, ui(6), c_black, 1.);
	draw_sprite_stretched_ext(THEME.palette_mask_outline, 1, _x, _y + _h - ui(6), _w, ui(6), c_white, 1.);
	
	draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y + _h - ui(6), _w * _a, ui(6), c_white, 1);
	
		
}
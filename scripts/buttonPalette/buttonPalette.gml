function buttonPalette(_onApply, dialog = noone) : widget() constructor {
	onApply      = _onApply;
	parentDialog = dialog;
	
	current_palette = [];
	side_button     = noone;
	
	function apply(value) { #region
		if(!interactable) return;
		onApply(value);
	} #endregion
	
	static trigger = function() { #region
		var dialog = dialogCall(o_dialog_palette, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_palette);
		dialog.onApply = apply;
		dialog.interactable = interactable;
		
		if(parentDialog)
			parentDialog.addChildren(dialog);
	} #endregion
	
	static drawParam = function(params) { return draw(params.x, params.y, params.w, params.h, params.data, params.m); }
	
	static draw = function(_x, _y, _w, _h, _color, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		var _bs = min(_h, ui(32));
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		if(_w - _bs > ui(100) && side_button && instanceof(side_button) == "buttonClass") {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w -_bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
			_w -= _bs + ui(8);
		}
		
		var _pw = _w - ui(8);
		var _ph = _h - ui(8);
		
		current_palette = _color;
		
		if(array_length(_color) > 0 && is_array(_color[0])) {
			if(array_length(_color[0]) == 0) return 0;
			
			h = ui(8) + array_length(_color) * _ph;
			current_palette = _color[0];
		} else {
			h = _h;
		}
		
		if(!is_array(current_palette) || array_empty(current_palette) || is_array(current_palette[0]))
			return 0;
		
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + h);
		if(ihover && hoverRect) {
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
		
		if(!is_array(_color[0])) _color = [ _color ];
		
		for( var i = 0, n = array_length(_color); i < n; i++ ) {
			var _pal = _color[i];
			var _px  = _x + ui(4);
			var _py  = _y + ui(4) + i * _ph;
			
			if(is_array(_pal)) drawPalette(_pal, _px, _py, _pw, _ph);
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), h + ui(6), COLORS._main_accent, 1);	
		
		if(DRAGGING && DRAGGING.type == "Palette" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _w, h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		
		return h;
	} #endregion
	
	static clone = function() { #region
		var cln = new buttonPalette(onApply, parentDialog);
		return cln;
	} #endregion
}

function drawPalette(_pal, _x, _y, _w, _h, _a = 1) { #region
	var aa = array_length(_pal);
	
	if(aa == 1) {
		draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y, _w, _h, _pal[0], _a);
		return;
	}
	
	var ww  = _w / aa;
	var _x0 = _x;
	var _in;
	
	for(var i = 0; i < aa; i++) {
		if(!is_numeric(_pal[i])) continue;
		
		     if(i == 0)      _in = 2;
		else if(i == aa - 1) _in = 3;
		else                 _in = 0;
		
		var _ca = _color_get_alpha(_pal[i]);
		
		if(_ca == 1) {
			draw_sprite_stretched_ext(THEME.palette_mask, _in, floor(_x0), _y, ceil(ww), _h, _pal[i], _a);
		} else {
			draw_sprite_stretched_ext(THEME.palette_mask, _in, floor(_x0), _y, ceil(ww), _h - ui(8), _pal[i], _a);
			
			draw_sprite_stretched_ext(THEME.palette_mask, 1, floor(_x0), _y + _h - ui(6), ceil(ww), ui(6), c_black, _a);
			draw_sprite_stretched_ext(THEME.palette_mask, 1, floor(_x0), _y + _h - ui(6), ceil(ww) * _ca, ui(6), c_white, _a);
		}
		
		_x0 += ww;
	}
} #endregion


function drawPaletteGrid(_pal, _x, _y, _w, _gs = 24, c_color = -1) { #region
	var amo = array_length(_pal);
	var col = floor(_w / _gs);
	var row = ceil(amo / col);
	var cx = -1, cy = -1;
	var _pd = ui(5);
	
	for(var i = 0; i < array_length(_pal); i++) {
		draw_set_color(_pal[i]);
		var _x0 = _x + safe_mod(i, col) * _gs;
		var _y0 = _y + floor(i / col) * _gs;
		
		draw_rectangle(_x0, _y0 + 1, _x0 + _gs, _y0 + _gs, false);
		
		if(c_color == _pal[i]) {
			cx = _x0;
			cy = _y0;
		}
	}
	
	if(cx == -1) return;
	
	draw_sprite_stretched_ext(THEME.palette_selecting, 0, cx - _pd, cy + 1 - _pd, _gs + _pd * 2, _gs + _pd * 2);
} #endregion
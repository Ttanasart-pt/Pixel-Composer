function buttonPalette(_onApply, dialog = noone) : widget() constructor {
	onApply      = _onApply;
	parentDialog = dialog;
	
	current_palette = [];
	side_button     = noone;
	
	expanded         = false;
	edit_color_index = -1;
	
	static trigger = function() {
		var dialog = dialogCall(o_dialog_palette, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_palette);
		dialog.onApply      = onApply;
		dialog.interactable = interactable;
		dialog.drop_target  = self;
		
		if(parentDialog)
			parentDialog.addChildren(dialog);
	}
	
	static triggerSingle = function(_index) {
		edit_color_index = _index;
		current_palette  = array_clone(current_palette);
		
		var dialog = dialogCall(o_dialog_color_selector)
							.setDefault(current_palette[edit_color_index])
							.setApply(method(self, editColor));
		
		dialog.interactable = interactable;
	}
	
	static editColor = function(col) {
		if(edit_color_index == -1) return;
		current_palette[edit_color_index] = col;
		onApply(current_palette);
	}
	
	static fetchHeight = function(params) { return params.h + expanded * (array_length(params.data) * ui(16) + ui(2));  }
	static drawParam   = function(params) { return draw(params.x, params.y, params.w, params.h, params.data, params.m); }
	static draw = function(_x, _y, _w, _h, _color, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		draw_sprite_stretched_ext(THEME.button_def, 0, x, y, w, h, boxColor);
		
		var bs = min(_h, ui(32));
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		if(_w - bs > ui(100) && side_button && instanceof(side_button) == "buttonClass") {
			var bx = _x + _w - bs;
			
			draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, _h, CDEF.main_mdwhite, 1);
			side_button.setFocusHover(active, hover);
			side_button.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
			_w -= bs;
		}
		
		var _pw = _w - ui(4);
		var _ph = _h - ui(4);
		
		current_palette = _color;
		
		if(array_length(_color) > 0 && is_array(_color[0])) {
			if(array_length(_color[0]) == 0) return 0;
			
			h = ui(4) + array_length(_color) * _ph;
			current_palette = _color[0];
			
		} else
			h = _h;
		
		if(!is_array(current_palette) || array_empty(current_palette) || is_array(current_palette[0]))
			return 0;
		
		var _colr_h = ui(16);
		var _drawSingle = !is_array(_color[0]);
		var _bbw = _h;
		var _ppw = _drawSingle? _pw - _bbw : _w;
		var _ppx = _drawSingle? _x + ui(2) + _bbw : _x;
		
		var hoverRect = ihover && point_in_rectangle(_m[0], _m[1], _ppx, _y, _ppx + _ppw, _y + h);
		
		if(_drawSingle && expanded)
			h = _h + array_length(_color) * _colr_h + ui(2);
		
		if(hoverRect) {
			if(mouse_press(mb_left, iactive))
				trigger();
			
			if(mouse_click(mb_left, iactive)) {
				draw_sprite_stretched_ext(THEME.button_def, 2, _x, _y, _w, h, boxColor);	
				draw_sprite_stretched_ext(THEME.button_def, 3, _x, _y, _w, h, COLORS._main_accent, 1);	
			}
		} else if(mouse_press(mb_left)) deactivate();
		
		if(_drawSingle) {
			var _pph = _ph;
			var _ppy = _y + ui(2);
		
			var _bbx = _x + _bbw / 2;
			var _bby = _y + _pph / 2 + ui(2);
			
			var _bba = .4 + .4 * interactable;
			var _bbc = COLORS._main_icon;
			
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _bbw, _y + _pph)) {
				_bbc = COLORS._main_icon_light;
				
				if(mouse_press(mb_left))
					expanded = !expanded;
			}
			
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _bbw, h, CDEF.main_mdwhite, 1);
			draw_sprite_ui(THEME.arrow, expanded? 3 : 0, _bbx, _bby + ui(expanded), 1, 1, 0, _bbc, _bba);
			
			if(expanded) {
				var _cx = _x + ui(2);
				var _cy = _y + _pph + ui(4);
				var _cw = _w - ui(4);
				var _ch = h - _pph - ui(4 + 2);
				var _pd  = ui(2);
				var _pd2 = _pd / 2;
				
				draw_sprite_stretched_ext(THEME.box_r2, 0, _cx, _cy, _cw, _ch, CDEF.main_mdblack, 1);	
				
				for (var i = 0, n = array_length(_color); i < n; i++) {
					var _c  = _color[i];
					var _ccx = _cx;
					var _ccy = _cy + i * _colr_h;
					var _ccw = _cw;
					var _cch = _colr_h;
					
					draw_sprite_stretched_ext(THEME.palette_mask, 1, _ccx + _pd2, _ccy + _pd2, _ccw - _pd, _cch - _pd, _c, 1);
					
					if(hover && point_in_rectangle(_m[0], _m[1], _ccx, _ccy, _ccx + _ccw, _ccy + _cch - 1)) {
						if(DRAGGING && DRAGGING.type == "Color") {
							draw_sprite_stretched_ext(THEME.box_r2, 1, _ccx + _pd2, _ccy + _pd2, _ccw - _pd, _cch - _pd, COLORS._main_value_positive, 1);
							if(mouse_release(mb_left)) {
								current_palette[i] = DRAGGING.data;
								onApply(current_palette);
							}
							
						} else {
							draw_sprite_stretched_add(THEME.box_r2, 1, _ccx + _pd2, _ccy + _pd2, _ccw - _pd, _cch - _pd, c_white, .3);
							
							if(mouse_press(mb_left, active))
								triggerSingle(i);
						}
					}
				}
			}
			
			drawPalette(_color, _ppx, _ppy, _ppw, _pph);
			
		} else {
			expanded = false;
			
			for( var i = 0, n = array_length(_color); i < n; i++ ) {
				var _pal = _color[i];
				var _px  = _x + ui(2);
				var _py  = _y + ui(2) + i * _ph;
				
				if(is_array(_pal)) drawPalette(_pal, _px, _py, _pw, _ph);
			}
		}
		
		if(hide == 0) {
			if(hoverRect) draw_sprite_stretched_ext(THEME.button_def, 3, x, y, w, h, CDEF.main_grey);	
			else draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, h, boxColor, .5 + .5 * interactable);
		}
		
		if(WIDGET_CURRENT == self || (instance_exists(o_dialog_palette) && o_dialog_palette.drop_target == self))
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x, _y, _w, h, COLORS._main_accent, 1);	
		
		if(DRAGGING && DRAGGING.type == "Palette" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _w, h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new buttonPalette(onApply, parentDialog);
		return cln;
	}
}

function drawPaletteBBOX(_pal, _bbox, _a = 1) { drawPalette(_pal, _bbox.x0, _bbox.y0, _bbox.w, _bbox.h, _a); }

function drawPalette(_pal, _x, _y, _w, _h, _a = 1) {
	var am = array_length(_pal);
	
	if(am == 1) {
		draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y, _w, _h, _pal[0], _a);
		return;
	}
	
	var aa = min(am, 64);
	var st = am / aa;
	
	var ww  = _w / aa;
	var _x0 = _x;
	var _in;
	
	for(var i = 0; i < am; i += st) {
		var _p = _pal[floor(i)];
		if(!is_numeric(_p)) continue;
		
		     if(i == 0)      _in = 2;
		else if(i == aa - 1) _in = 3;
		else                 _in = 0;
		
		var _ca = _color_get_alpha(_p);
		
		if(_ca == 1) {
			draw_sprite_stretched_ext(THEME.palette_mask, _in, floor(_x0), _y, ceil(ww), _h, _p, _a);
		} else {
			draw_sprite_stretched_ext(THEME.palette_mask, _in, floor(_x0), _y, ceil(ww), _h - ui(8), _p, _a);
			
			draw_sprite_stretched_ext(THEME.palette_mask, 1, floor(_x0), _y + _h - ui(6), ceil(ww), ui(6), c_black, _a);
			draw_sprite_stretched_ext(THEME.palette_mask, 1, floor(_x0), _y + _h - ui(6), ceil(ww) * _ca, ui(6), c_white, _a);
		}
		
		_x0 += ww;
	}
}

function drawPaletteGrid(_pal, _x, _y, _w, _gs = 24, params = {}) {
	var c_color  = struct_try_get(params, "color",   -1);
	var _stretch = struct_try_get(params, "stretch", true);
	var _mx      = struct_try_get(params, "mx",      -1);
	var _my      = struct_try_get(params, "my",      -1);
	
	var amo = array_length(_pal);
	var col = floor(_w / _gs);
	var row = ceil(amo / col);
	var cx  = -1, cy = -1;
	var _h  = row * _gs;
	
	var _gw  = _stretch? _w / (min(col, amo)) : _gs;
	var _hov = noone;
	var _hcc = noone;
	
	var hvx = 0;
	var hvy = 0;
	var hvw = 0;
	var hvh = 0;
	
	for(var i = 0; i < amo; i++) {
		var _cc = safe_mod(i, col);
		var _rr = floor(i / col);
		var _x0 = _x + _cc * _gw;
		var _y0 = _y + _rr * _gs;
		var _i  = 0;
		
		var _clr = _pal[i];
		
		if(amo == 1) {
			_i = 1;
		} else {
			if(row == 1) {
				     if(i == 0)       _i = 2;
				else if(i == amo - 1) _i = 3;
			} else {
				     if(i == 0)                           _i = 6;
				else if(_cc == col - 1 && i + col >= amo) {
					if(_rr == 0) _i = 3;
					else         _i = 9;
				}
				else if(_rr == 0 && _cc == col - 1)       _i = 7;
				else if(_rr == row - 1 && _cc == 0)       _i = 8;
				else if(i == amo - 1)                     _i = 9;
				
			}
		}
		
		var _same = (c_color & 0x00FFFFFF) == (_clr & 0x00FFFFFF);
		
		draw_sprite_stretched_ext(THEME.palette_mask, _i, _x0, _y0, ceil(_gw), _gs, _clr, 1);
		if(point_in_rectangle(_mx, _my, _x0, _y0, _x0 + _gw, _y0 + _gs)) {
			
			_hov = i;
			_hcc = _clr;
			
			hvx = _x0;
			hvy = _y0;
			hvw = _gw;
			hvh = _gs;
		}
		
		if(c_color >= 0 && _same) {
			cx = _x0;
			cy = _y0;
		}
	}
	
	if(cx != -1) draw_sprite_stretched_ext(THEME.palette_selecting, 0, cx - 5, cy - 5, _gw + 5 * 2, _gs + 5 * 2);
	
	return {
		height     : _h,
		hoverIndex : _hov,
		hoverColor : _hcc,
		hoverBBOX  : [ hvx, hvy, hvw, hvh ],
		
		gridColumn : col, 
		gridRow    : row, 
		gridWidth  : _gw,
		gridHeight : _gs,
	};
}
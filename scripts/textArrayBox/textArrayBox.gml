function textArrayBox(arraySet, data, onModify = noone) : widget() constructor {
	self.getArray = arraySet;
	self.arraySet = noone;
	
	self.data     = data;
	self.onModify = onModify;
	
	hide = false;
	open = false;
	
	static drawParam = function(params) {
		setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _m, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		w = _w;
		if(getArray != noone)
			arraySet = getArray();
		
		var tx = _x + ui(4);
		var ty = _y + ui(4);
		var hh = line_get_height(font, ui(4));
		var th = hh + ui(8);
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		for( var i = 0, n = array_length(arraySet); i < n; i++ ) {
			var ww = string_width(arraySet[i]) + ui(16);
			if(tx + ww + ui(2) > _x + _w - ui(8)) {
				tx = _x + ui(4);
				ty += hh + ui(2);
				th += hh + ui(2);
			}
			tx += ww + ui(2);
		}
		
		h = th;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, th, boxColor);
		
		if(open) { 
			draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, _w, th, COLORS._main_accent, 1);
		} else {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + th)) {
				draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, th, boxColor, 0.5 + !hide * 0.5);	
				if(mouse_press(mb_left, active)) {
					with(dialogCall(o_dialog_arrayBox, _rx + _x, _ry + _y + th)) {
						arrayBox = other;	
						dialog_w = other.w;
						font     = other.font;
					}
				}
			} else if(!hide)
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, th, boxColor, 0.5 + 0.5 * interactable);
		}
		
		var tx = _x + ui(4);
		var ty = _y + ui(4);
		var hh = line_get_height(font, ui(4));
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		for( var i = 0, n = array_length(arraySet); i < n; i++ ) {
			var ww = string_width(arraySet[i]) + ui(16);
			if(tx + ww + ui(2) > _x + _w - ui(8)) {
				tx = _x + ui(4);
				ty += hh + ui(2);
			}
			
			draw_sprite_stretched_ext(THEME.s_box_r5_clr, 0, tx, ty, ww, hh, COLORS._main_icon, 1);
			draw_text_add(tx + ui(8), ty + hh / 2, arraySet[i]);
			
			tx += ww + ui(2);
		}
		
		resetFocus();
		return th;
	}
	
	static clone = function() {
		var cln = new textArrayBox(getArray, data, onModify);
		
		return cln;
	}
}
function textArrayBox(arraySet, data, onModify = noone) : widget() constructor {
	self.getArray = arraySet;
	self.arraySet = noone;
	
	self.data     = data;
	self.onModify = onModify;
	
	hide = false;
	open = false;
	mode = 0;
	
	pressed  = false;
	dragging = noone;
	
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
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, h, boxColor);
		
		if(open) { 
			draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, _w, h, COLORS._main_accent, 1);
		} else {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + h)) {
				draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, h, boxColor, 0.5 + !hide * 0.5);	
				if(mouse_press(mb_left, active)) pressed = true;
				
				if(pressed && mouse_release(mb_left, active)) {
					with(dialogCall(o_dialog_arrayBox, _rx + _x, _ry + _y + h)) {
						arrayBox = other;	
						dialog_w = other.w;
						font     = other.font;
						mode     = other.mode;
					}
				}
			} else if(!hide)
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, h, boxColor, 0.5 + 0.5 * interactable);
		}
		
		if(mouse_release(mb_left)) pressed = false;
		
		var ww, hh = line_get_height(font, ui(4));
		var tx = _x + ui(4);
		var ty = _y + ui(4);
		var th = hh + ui(8);
		var hovi = noone;
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		for( var i = 0, n = array_length(arraySet); i < n; i++ ) {
			var _txt = arraySet[i];
			
			switch(mode) {
				case 0 : 
					ww = string_width(_txt) + ui(16); 
					break;
				
				case 1 :
					var _type = string_char_at(_txt, 1);
					
					_txt = string_copy(_txt, 2, string_length(_txt) - 1);
					ww   = ui(24) + string_width(_txt) + ui(16); 
					break;
			}
			
			if(tx + ww + ui(2) > _x + _w - ui(8)) {
				tx  = _x + ui(4);
				ty += hh + ui(2);
				th += hh + ui(2);
			}
			
			var _hov = hover && point_in_rectangle(_m[0], _m[1], tx, ty, tx + ww, ty + hh);
			if(_hov) hovi = [i, tx, ty, tx + ww, ty + hh];
			
			draw_sprite_stretched_ext(THEME.box_r5_clr, _hov, tx, ty, ww, hh, COLORS._main_icon, 1);
			draw_set_color(dragging == i? COLORS._main_text_accent : COLORS._main_text);
			
			switch(mode) {
				case 0 : 
					draw_text_add(tx + ui(8), ty + hh / 2, _txt); 
					break;
					
				case 1 : 
					     if(_type == "+") draw_sprite_ui(THEME.arrow, 1, tx + ui(16), ty + hh / 2,         1, 1, 0, COLORS._main_value_positive, 1);
					else if(_type == "-") draw_sprite_ui(THEME.arrow, 3, tx + ui(16), ty + hh / 2 + ui(2), 1, 1, 0, COLORS._main_value_negative, 1);
					
					draw_text_add(tx + ui(32), ty + hh / 2, _txt); 
					break;
			}
			
			if(_hov && mouse_press(mb_left, active)) {
				pressed  = false;
				dragging = i;
			}
			
			tx += ww + ui(2);
		}
		
		if(dragging != noone) {
			if(hovi != noone && hovi[0] != dragging) {
				draw_set_color(COLORS._main_accent);
				var _tx = hovi[0] > dragging? hovi[3] : hovi[1];
				draw_line_width(_tx, hovi[2], _tx, hovi[4], 2);
			}
			
			if(mouse_release(mb_left)) {
				if(hovi != noone && hovi[0] != dragging) {
					var _val = arraySet[dragging];
					
					array_delete(arraySet, dragging, 1);
					array_insert(arraySet, hovi[0], _val);
					
					onModify();
				}
				
				dragging = noone;
			}
		}
		
		h = th;
		
		resetFocus();
		return th;
	}
	
	static clone = function() /*=>*/ {return new textArrayBox(getArray, data, onModify)};
}
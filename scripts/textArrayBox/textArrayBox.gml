function textArrayBox(array, data) : widget() constructor {
	self.getArray = array;
	self.data  = data;
	
	open = false;
	
	static draw = function(_x, _y, _w, _h, _m) {
		x = _x;
		y = _y;
		w = _w;
		var array = getArray();
		
		var tx = _x + ui(4);
		var ty = _y + ui(4);
		var array = getArray();
		var hh = line_height(f_p0, ui(4));
		var th = hh + ui(8);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		for( var i = 0; i < array_length(array); i++ ) {
			var ww = string_width(array[i]) + ui(16);
			if(tx + ww + ui(2) > _x + _w - ui(8)) {
				tx = _x + ui(4);
				ty += hh + ui(2);
				th += hh + ui(2);
			}
			tx += ww + ui(2);
		}
		
		h = th;
		
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, th);
		
		if(open) { 
			draw_sprite_stretched(THEME.textbox, 2, _x, _y, _w, th);
		} else {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + th)) {
				draw_sprite_stretched(THEME.textbox, 1, _x, _y, _w, th);	
				if(mouse_press(mb_left, active)) {
					with(dialogCall(o_dialog_arrayBox, _x, _y + th)) {
						arrayBox = other;	
						dialog_w = other.w;
					}
				}
			} else
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, th, c_white, 0.5 + 0.5 * interactable);
		}
		
		var tx = _x + ui(4);
		var ty = _y + ui(4);
		var hh = line_height(f_p0, ui(4));
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		for( var i = 0; i < array_length(array); i++ ) {
			var ww = string_width(array[i]) + ui(16);
			if(tx + ww + ui(2) > _x + _w - ui(8)) {
				tx = _x + ui(4);
				ty += hh + ui(2);
			}
			
			draw_sprite_stretched_ext(THEME.group_label, 0, tx, ty, ww, hh, COLORS._main_icon, 1);
			draw_text(tx + ui(8), ty + hh / 2, array[i]);
			
			tx += ww + ui(2);
		}
		
		resetFocus();
		return th;
	}
}
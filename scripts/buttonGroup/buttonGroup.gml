function buttonGroup(_data, _onClick) {
	return new buttonGroupClass(_data, _onClick);
}

function buttonGroupClass(_data, _onClick) constructor {
	data    = _data;
	onClick = _onClick;
	
	hover  = false;
	active = false;
	
	for(var i = 0; i < array_length(data); i++) {
		buttons[i] = button(-1);	
	}
	
	sb_small = new scrollBox(data, _onClick);
	
	static draw = function(_x, _y, _w, _h, _seleting, _m, _rx = 0, _ry = 0) {
		var amo = array_length(data);
		var ww  = _w / amo;
		
		var total_width = 0;
		draw_set_font(f_p0);
		for(var i = 0; i < amo; i++) {
			if(is_string(data[i]))
				total_width += string_width(data[i]) + ui(32);
		}
		
		if(total_width < _w) {
			for(var i = 0; i < amo; i++) {
				buttons[i].hover  = hover;
				buttons[i].active = active;
			
				var bx  = _x + ww * i;
				var spr = i == 0 ? THEME.button_left : (i == amo - 1? THEME.button_right : THEME.button_middle);
			
				if(_seleting == i) {
					draw_sprite_stretched(spr, 2, bx, _y, ww, _h);	
				} else if(buttons[i].draw(bx, _y, ww, _h, _m, spr)) {
					onClick(i);	
				}
			
				if(is_string(data[i])) {
					draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
					draw_text(bx + ww / 2, _y + _h / 2, data[i]);
				} else if(sprite_exists(data[i])) {
					draw_sprite_ui_uniform(data[i], i, bx + ww / 2, _y + _h / 2);
				}
			}
		} else {
			sb_small.hover = hover;
			sb_small.active = active;
			sb_small.draw(_x, _y, _w, _h, _seleting, _m, _rx, _ry);
		}
		
		hover  = false;
		active = false;
	}
}
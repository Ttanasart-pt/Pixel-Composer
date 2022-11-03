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
	
	static draw = function(_x, _y, _w, _h, _seleting, _m) {
		var amo = array_length(data);
		var ww  = _w / amo;
		
		for(var i = 0; i < amo; i++) {
			buttons[i].hover  = hover;
			buttons[i].active = active;
			
			var bx  = _x + ww * i;
			var spr = i == 0 ? s_button_left : (i == amo - 1? s_button_right : s_button_middle);
			
			if(_seleting == i) {
				draw_sprite_stretched(spr, 2, bx, _y, ww, _h);	
			} else if(buttons[i].draw(bx, _y, ww, _h, _m, spr)) {
				onClick(i);	
			}
			
			if(is_string(data[i])) {
				draw_set_text(f_p0, fa_center, fa_center, c_white);
				draw_text(bx + ww / 2, _y + _h / 2, data[i]);
			} else if(sprite_exists(data[i])) {
				draw_sprite_ui_uniform(data[i], i, bx + ww / 2, _y + _h / 2);
			}
		}
		hover  = false;
		active = false;
	}
}
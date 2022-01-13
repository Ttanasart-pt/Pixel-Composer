function slider(_min, _max, _step, _onModify) constructor {
	active = false;
	hover  = false;
	
	minn = _min;
	maxx = _max;
	step = _step;
	
	onModify = _onModify;
	
	dragging = false;
	drag_mx  = 0;
	drag_sx  = 0;
	
	tb_value = new textBox(TEXTBOX_INPUT.float, onModify);
	
	function draw(_x, _y, _w, _h, _data, _m) {
		var tb_w = 64;
		var sw = _w - (tb_w + 16);
		
		tb_value.hover  = hover;
		tb_value.active = active;
		tb_value.draw(_x + sw + 16, _y, tb_w, 34, _data, _m);
		
		draw_sprite_stretched(s_slider, 0, _x, _y + _h / 2 - 4, sw, 8);	
		
		var _kx = _x + clamp((_data - minn) / (maxx - minn), 0, 1) * sw;
		draw_sprite_stretched(s_slider, 1, _kx - 10, _y, 20, _h);
		
		if(dragging) {
			draw_sprite_stretched(s_slider, 3, _kx - 10, _y, 20, _h);
			
			var val = (_m[0] - _x) / sw * (maxx - minn) + minn;
			val = round(val / step) * step;
			val = clamp(val, minn, maxx);
			onModify(val);
			
			if(mouse_check_button_released(mb_left))
				dragging = false;
		} else {
			if(hover && (point_in_rectangle(_m[0], _m[1], _x, _y, _x + sw, _y + _h) || point_in_rectangle(_m[0], _m[1], _kx - 10, _y, _kx + 10, _y + _h))) {
				draw_sprite_stretched(s_slider, 2, _kx - 10, _y, 20, _h);
				
				if(active && mouse_check_button_pressed(mb_left)) {
					dragging = true;
					drag_mx  = _m[0];
					drag_sx  = _data;
				}
			}
		}
		
		hover  = false;
		active = false;
	}
}
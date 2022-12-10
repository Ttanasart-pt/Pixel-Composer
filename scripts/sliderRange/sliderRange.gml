function sliderRange(_min, _max, _step, _onModify) constructor {
	active = false;
	hover  = false;
	
	minn = _min;
	maxx = _max;
	step = _step;
	
	onModify = _onModify;
	
	dragging = -1;
	drag_mx  = 0;
	drag_sx  = 0;
	
	tb_value_min = new textBox(TEXTBOX_INPUT.float, function(val) { onModify(0, val); });
	tb_value_max = new textBox(TEXTBOX_INPUT.float, function(val) { onModify(1, val); });
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		var tb_w = ui(64);
		var sw = _w - (tb_w + ui(16)) * 2;
		
		tb_value_min.hover  = hover;
		tb_value_min.active = active;
		tb_value_min.draw(_x, _y, tb_w, TEXTBOX_HEIGHT, _data[0], _m);
		
		tb_value_max.hover  = hover;
		tb_value_max.active = active;
		tb_value_max.draw(_x + _w - tb_w, _y, tb_w, TEXTBOX_HEIGHT, _data[1], _m);
		
		var _x0 = _x + tb_w + ui(16);
		draw_sprite_stretched(THEME.slider, 0, _x0, _y + _h / 2 - ui(4), sw, ui(8));	
		
		var _slider_x0 = _x0 + clamp((_data[0] - minn) / (maxx - minn), 0, 1) * sw;
		var _slider_x1 = _x0 + clamp((_data[1] - minn) / (maxx - minn), 0, 1) * sw;
		
		draw_sprite_stretched(THEME.slider, 4, min(_slider_x0, _slider_x1), _y + _h / 2 - ui(4), abs(_slider_x1 - _slider_x0), ui(8));	
		draw_sprite_stretched(THEME.slider, 1, _slider_x0 - ui(10), _y, ui(20), _h);
		draw_sprite_stretched(THEME.slider, 1, _slider_x1 - ui(10), _y, ui(20), _h);
		
		if(dragging > -1) {
			if(dragging == 0)
				draw_sprite_stretched(THEME.slider, 3, _slider_x0 - ui(10), _y, ui(20), _h);
			else if(dragging == 1)
				draw_sprite_stretched(THEME.slider, 3, _slider_x1 - ui(10), _y, ui(20), _h);
			
			var val = (_m[0] - _x0) / sw * (maxx - minn) + minn;
			val = round(val / step) * step;
			val = clamp(val, minn, maxx);
			onModify(dragging, val);
			UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				UNDO_HOLDING = false;
				dragging = -1;
			}
		} else {
			if(hover) {
				var _hover = -1;
				
				if(point_in_rectangle(_m[0], _m[1], _slider_x0 - ui(10), _y, _slider_x0 + ui(10), _y + _h)) {
					draw_sprite_stretched(THEME.slider, 2, _slider_x0 - ui(10), _y, ui(20), _h);
					_hover = 0;
				}
				if(point_in_rectangle(_m[0], _m[1], _slider_x1 - ui(10), _y, _slider_x1 + ui(10), _y + _h)) {
					draw_sprite_stretched(THEME.slider, 2, _slider_x1 - ui(10), _y, ui(20), _h);
					_hover = 1;
				}
				
				if(_hover > -1 && mouse_press(mb_left, active)) {
					dragging = _hover;
					drag_mx  = _m[0];
					drag_sx  = _data[_hover];
				}
			}
		}
		
		hover  = false;
		active = false;
	}
}
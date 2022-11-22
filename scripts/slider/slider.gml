function slider(_min, _max, _step, _onModify = noone, _onRelease = noone) constructor {
	active = false;
	hover  = false;
	
	minn = _min;
	maxx = _max;
	step = _step;
	
	onModify = _onModify;
	onRelease = _onRelease;
	onApply = function(val) {
		if(onModify)  onModify(val);
		if(onRelease) onRelease();
	}
	
	dragging = false;
	drag_mx  = 0;
	drag_sx  = 0;
	
	tb_value = new textBox(TEXTBOX_INPUT.float, onApply);
	
	static draw = function(_x, _y, _w, _h, _data, _m, tb_w = 64, halign = fa_left, valign = fa_top) {
		switch(halign) {
			case fa_left:   _x = _x;			break;	
			case fa_center: _x = _x - _w / 2;	break;	
			case fa_right:  _x = _x - _w;		break;	
		}
		
		switch(valign) {
			case fa_top:    _y = _y;			break;	
			case fa_center: _y = _y - _h / 2;	break;	
			case fa_bottom: _y = _y - _h;		break;	
		}
		
		var sw = _w - (tb_w + ui(16));
		
		tb_value.hover  = hover;
		tb_value.active = active;
		tb_value.draw(_x + sw + ui(16), _y, tb_w, _h, _data, _m);
		
		draw_sprite_stretched(THEME.slider, 0, _x, _y + _h / 2 - ui(4), sw, ui(8));	
		
		var _kx = _x + clamp((_data - minn) / (maxx - minn), 0, 1) * sw;
		draw_sprite_stretched(THEME.slider, 1, _kx - ui(10), _y, ui(20), _h);
		
		if(dragging) {
			draw_sprite_stretched(THEME.slider, 3, _kx - ui(10), _y, ui(20), _h);
			
			var val = (_m[0] - _x) / sw * (maxx - minn) + minn;
			val = round(val / step) * step;
			val = clamp(val, minn, maxx);
			if(onModify != noone)
				onModify(val);
			UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				dragging = false;
				if(onRelease != noone)
					onRelease(val);
				UNDO_HOLDING = false;
			}
		} else {
			if(hover && (point_in_rectangle(_m[0], _m[1], _x, _y, _x + sw, _y + _h) || point_in_rectangle(_m[0], _m[1], _kx - ui(10), _y, _kx + ui(10), _y + _h))) {
				draw_sprite_stretched(THEME.slider, 2, _kx - ui(10), _y, ui(20), _h);
				
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
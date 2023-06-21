function slider(_min, _max, _step, _onModify = noone, _onRelease = noone) : widget() constructor {
	minn = _min; curr_minn = _min;
	maxx = _max; curr_maxx = _max;
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
	
	spr		= THEME.slider;
	blend   = c_white;
	
	handle_w = ui(20);
	
	tb_value = new textBox(TEXTBOX_INPUT.number, onApply);
	
	static setSlideSpeed = function(speed) {
		tb_value.slide_speed = speed;
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		tb_value.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		tb_value.register(parent);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m, tb_w = 64, halign = fa_left, valign = fa_top) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		if(!is_real(_data)) return;
		
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
		
		var _rang = abs(maxx - minn);
		if(!dragging) {
			curr_minn = (_data >= minn)? minn : minn - ceil(abs(_data - minn) / _rang) * _rang; 
			curr_maxx = (_data <= maxx)? maxx : maxx + ceil(abs(_data - maxx) / _rang) * _rang;
		}
		
		var sw = _w;
		
		if(tb_w > 0) {
			sw = _w - (tb_w + ui(16));
			
			tb_value.setFocusHover(active, hover);
			tb_value.draw(_x + sw + ui(16), _y, tb_w, _h, _data, _m);
		}
		
		if(THEME_VALUE.slider_type == "full_height")
			draw_sprite_stretched_ext(spr, 0, _x, _y, sw, _h, blend, 1);
		else if(THEME_VALUE.slider_type == "stem")
			draw_sprite_stretched_ext(spr, 0, _x, _y + _h / 2 - ui(4), sw, ui(8), blend, 1);	
		
		var _pg = clamp((_data - curr_minn) / (curr_maxx - curr_minn), 0, 1) * sw;
		var _kx = _x + _pg;
		if(THEME_VALUE.slider_type == "full_height")
			draw_sprite_stretched_ext(spr, 1, _x, _y, _pg, _h, blend, 1);
		else if(THEME_VALUE.slider_type == "stem")
			draw_sprite_stretched_ext(spr, 1, _kx - handle_w / 2, _y, handle_w, _h, blend, 1);
		
		if(dragging) {
			if(THEME_VALUE.slider_type == "stem")
				draw_sprite_stretched_ext(spr, 3, _kx - handle_w / 2, _y, handle_w, _h, COLORS._main_accent, 1);
			
			var val = (_m[0] - _x) / sw * (curr_maxx - curr_minn) + curr_minn;
			val = round(val / step) * step;
			val = clamp(val, curr_minn, curr_maxx);
			
			if(key_mod_press(CTRL))
				val = round(val);
			
			if(onModify != noone) {
				if(onModify(val))
					UNDO_HOLDING = true;
			}
			
			if(mouse_release(mb_left)) {
				dragging = false;
				if(onRelease != noone)
					onRelease(val);
				UNDO_HOLDING = false;
			}
		} else {
			if(hover && (point_in_rectangle(_m[0], _m[1], _x, _y, _x + sw, _y + _h) || point_in_rectangle(_m[0], _m[1], _kx - handle_w / 2, _y, _kx + handle_w / 2, _y + _h))) {
				if(THEME_VALUE.slider_type == "stem")
					draw_sprite_stretched_ext(spr, 2, _kx - handle_w / 2, _y, handle_w, _h, blend, 1);
				
				if(mouse_press(mb_left, active)) {
					dragging = true;
					drag_mx  = _m[0];
					drag_sx  = _data;
				}
			}
		}
		
		resetFocus();
	}
}
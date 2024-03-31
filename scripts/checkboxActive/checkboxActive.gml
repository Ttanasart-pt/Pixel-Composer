function checkBoxActive(_onClick) : widget() constructor {
	onClick = _onClick;
	spr = THEME.checkbox_active;
	
	static trigger = function() { 
		if(!is_callable(onClick))
			return noone;
		onClick();
	}
	
	static drawParam = function(params) { return draw(params.x, params.y, params.data, params.m, params.w, params.h); }
	
	static draw = function(_x, _y, _value, _m, _w, _h) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		var bw = ui(96);
		var bh = h;
		var bx = x + w / 2 - bw / 2;
		var by = y;
		
		draw_sprite_stretched_ext(spr, _value, bx - 8, by - 8, bw + 16, bh + 16, c_white, 1);
		
		if(hover && point_in_rectangle(_m[0], _m[1], bx, by, bx + bw, by + bh)) {
			BLEND_ADD
			draw_sprite_stretched_ext(THEME.slider_def, 3, bx, by, bw, bh, COLORS._main_icon_dark, 1);
			BLEND_NORMAL
			
			if(mouse_press(mb_left, active))
				trigger();
		} else {
			if(mouse_press(mb_left)) 
				deactivate();
		}
		
		draw_set_text(f_p1, fa_center, fa_center, _value? COLORS._main_value_positive : COLORS._main_value_negative);
		draw_text_add(bx + bw / 2, by + bh / 2, _value? "ACTIVE" : "INACTIVE");
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, bx - ui(3), by - ui(3), bw + ui(6), bh + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
}

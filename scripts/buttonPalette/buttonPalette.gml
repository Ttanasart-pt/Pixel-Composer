function buttonPalette(_onApply) {
	return new buttonPaletteClass(_onApply);
}

function buttonPaletteClass(_onApply) constructor {
	active = false;
	hover  = false;
	
	onApply = _onApply;
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _w, _h);	
			if(active && mouse_check_button_pressed(mb_left)) {
				var dialog = dialogCall(o_dialog_palette, WIN_W / 2, WIN_H / 2);
				dialog.setPalette(_color);
				dialog.onApply = onApply;
				click = true;
			}
			if(mouse_check_button(mb_left))
				draw_sprite_stretched(THEME.button, 2, _x, _y, _w, _h);	
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _w, _h);		
		}
		
		drawPalette(_color, _x + ui(6), _y + ui(6), _w - ui(12), _h - ui(12));
		
		hover  = false;
		active = false;
		
		return click;
	}
}

function drawPalette(_pal, _x, _y, _w, _h) {
	var ww = _w / array_length(_pal);
	for(var i = 0; i < array_length(_pal); i++) {
		draw_set_color(_pal[i]);
		var _x0 = _x + i * ww;
		var _x1 = _x0 + ww;
		draw_rectangle(_x0, _y, _x1, _y + _h, false);
	}
}


function drawPaletteGrid(_pal, _x, _y, _w, _gs = 24, c_color = -1) {
	var amo = array_length(_pal);
	var col = floor(_w / _gs);
	var row = ceil(amo / col);
	
	for(var i = 0; i < array_length(_pal); i++) {
		draw_set_color(_pal[i]);
		var _x0 = _x + (i % col) * _gs;
		var _y0 = _y + floor(i / col) * _gs;
		draw_rectangle(_x0, _y0 + 1, _x0 + _gs, _y0 + _gs, false);
	}
	
	if(c_color > -1) {
		for(var i = 0; i < array_length(_pal); i++) {
			if(c_color == _pal[i]) {
				var _x0 = _x + (i % col) * _gs;
				var _y0 = _y + floor(i / col) * _gs;
				
				draw_set_color(c_white);
				draw_rectangle_border(_x0, _y0 + 1, _x0 + _gs, _y0 + _gs, 2);
			}
		}
	}
}

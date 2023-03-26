function buttonPalette(_onApply, dialog = noone) : widget() constructor {
	onApply = _onApply;
	parentDialog = dialog;
	current_palette = noone;
	
	function apply(value) {
		if(!interactable) return;
		onApply(value);
	}
	
	static trigger = function() {
		var dialog = dialogCall(o_dialog_palette, WIN_W / 2, WIN_H / 2);
		dialog.setDefault(current_palette);
		dialog.onApply = apply;
		dialog.interactable = interactable;
		
		if(parentDialog)
			parentDialog.addChildren(dialog);
	}
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		current_palette = _color;
		
		var click	  = false;
		var hoverRect = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		if(ihover && hoverRect) {
			draw_sprite_stretched(THEME.button, 1, _x, _y, _w, _h);	
			if(mouse_press(mb_left, iactive)) {
				trigger();
				click = true;
			}
			if(mouse_click(mb_left, iactive))
				draw_sprite_stretched(THEME.button, 2, _x, _y, _w, _h);	
		} else {
			draw_sprite_stretched(THEME.button, 0, _x, _y, _w, _h);		
			if(mouse_press(mb_left)) deactivate();
		}
		
		drawPalette(_color, _x + ui(6), _y + ui(6), _w - ui(12), _h - ui(12));
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6));	
		
		if(DRAGGING && DRAGGING.type == "Palette" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _y, _w, _h, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left))
				onApply(DRAGGING.data);
		}
		
		resetFocus();
		return click;
	}
}

function drawPalette(_pal, _x, _y, _w, _h, _a = 1) { 
	var ww = _w / array_length(_pal);
	draw_set_alpha(_a);
	for(var i = 0; i < array_length(_pal); i++) {
		if(!is_real(_pal[i])) continue;
		draw_set_color(_pal[i]);
		var _x0 = _x + i * ww;
		var _x1 = _x0 + ww - 1;
		draw_rectangle(_x0, _y, _x1, _y + _h, false);
	}
	draw_set_alpha(1);
}


function drawPaletteGrid(_pal, _x, _y, _w, _gs = 24, c_color = -1) {
	var amo = array_length(_pal);
	var col = floor(_w / _gs);
	var row = ceil(amo / col);
	
	for(var i = 0; i < array_length(_pal); i++) {
		draw_set_color(_pal[i]);
		var _x0 = _x + safe_mod(i, col) * _gs;
		var _y0 = _y + floor(i / col) * _gs;
		draw_rectangle(_x0, _y0 + 1, _x0 + _gs, _y0 + _gs, false);
	}
	
	if(c_color > -1) {
		for(var i = 0; i < array_length(_pal); i++) {
			if(c_color == _pal[i]) {
				var _x0 = _x + safe_mod(i, col) * _gs;
				var _y0 = _y + floor(i / col) * _gs;
				
				draw_set_color(c_white);
				draw_rectangle_border(_x0, _y0 + 1, _x0 + _gs, _y0 + _gs, 2);
			}
		}
	}
}

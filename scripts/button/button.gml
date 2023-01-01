function button(_onClick, _icon = noone) {
	return new buttonClass(_onClick, _icon);
}

function buttonClass(_onClick, _icon = noone) constructor {
	active = false;
	hover  = false;
	
	icon	   = _icon;
	icon_blend = c_white;
	icon_index = 0;
	
	text = "";
	tooltip = "";
	
	onClick = _onClick;
	
	static setIcon = function(_icon, _index = 0, _blend = c_white) { 
		icon       = _icon; 
		icon_index = _index;
		icon_blend = _blend;
		return self; 
	}
	
	static setText = function(_text) { 
		text = _text; 
		return self; 
	}
	
	static setTooltip = function(_tip) { 
		tooltip = _tip; 
		return self; 
	}
	
	static draw = function(_x, _y, _w, _h, _m, spr = THEME.button, blend = c_white) {
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched_ext(spr, 1, _x, _y, _w, _h, blend, 1);	
			if(mouse_press(mb_left, active)) {
				if(onClick) onClick();
				click = true;
			}
			if(mouse_click(mb_left, active))
				draw_sprite_stretched_ext(spr, 2, _x, _y, _w, _h, blend, 1);	
			if(tooltip != "") TOOLTIP = tooltip;
		} else {
			draw_sprite_stretched_ext(spr, 0, _x, _y, _w, _h, blend, 1);	
		}
		if(icon) draw_sprite_ui_uniform(icon, icon_index, _x + _w / 2, _y + _h / 2,, icon_blend);
		if(text != "") {
			draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
			draw_text(_x + _w / 2, _y + _h / 2, text);
		}
		
		hover  = false;
		active = false;
		
		return click;
	}
}

function buttonInstant(spr, _x, _y, _w, _h, _m, _act, _hvr, _tip = "", _icon = noone, _icon_index = 0, _icon_blend = COLORS._main_icon, _icon_alpha = 1) {
	var res = 0;
	
	if(_hvr && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
		res = 1;
		draw_sprite_stretched(spr, 1, _x, _y, _w, _h);	
		if(_tip != "") 
			TOOLTIP = _tip;
		if(mouse_press(mb_left, _act))
			res = 2;
		if(mouse_click(mb_left, _act))
			draw_sprite_stretched(spr, 2, _x, _y, _w, _h);	
	} else {
		draw_sprite_stretched(spr, 0, _x, _y, _w, _h);		
	}
	
	if(_icon) {
		draw_sprite_ui_uniform(_icon, _icon_index, _x + _w / 2, _y + _h / 2, 1, _icon_blend, _icon_alpha);
	}
	
	return res;
}
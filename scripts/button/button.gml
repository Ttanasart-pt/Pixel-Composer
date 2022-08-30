function button(_onClick) {
	return new buttonClass(_onClick);
}

function buttonClass(_onClick) constructor {
	active = false;
	hover  = false;
	
	icon   = noone;
	icon_index = 0;
	
	text = "";
	tooltip = "";
	
	onClick = _onClick;
	
	static setIcon = function(_icon, _index = 0) { 
		icon = _icon; icon_index = _index 
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
	
	static draw = function(_x, _y, _w, _h, _m, spr = s_button, blend = c_white) {
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched_ext(spr, 1, _x, _y, _w, _h, blend, 1);	
			if(active && mouse_check_button_pressed(mb_left)) {
				if(onClick) onClick();
				click = true;
			}
			if(mouse_check_button(mb_left))
				draw_sprite_stretched_ext(spr, 2, _x, _y, _w, _h, blend, 1);	
			if(tooltip != "") TOOLTIP = tooltip;
		} else {
			draw_sprite_stretched_ext(spr, 0, _x, _y, _w, _h, blend, 1);	
		}
		if(icon) draw_sprite(icon, icon_index, _x + _w / 2, _y + _h / 2);
		if(text != "") {
			draw_set_text(f_p0, fa_center, fa_center, c_white);
			draw_text(_x + _w / 2, _y + _h / 2, text);
		}
		
		hover  = false;
		active = false;
		
		return click;
	}
}

function buttonInstant(spr, _x, _y, _w, _h, _m, _act, _hvr, _tip = "", _icon = noone, _icon_index = 0, _icon_blend = c_ui_blue_grey, _icon_alpha = 1) {
	var res = 0;
	
	if(_hvr && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
		res = 1;
		draw_sprite_stretched(spr, 1, _x, _y, _w, _h);	
		if(_tip != "") 
			TOOLTIP = _tip;
		if(_act && mouse_check_button_pressed(mb_left))
			res = 2;
		if(mouse_check_button(mb_left))
			draw_sprite_stretched(spr, 2, _x, _y, _w, _h);	
	} else {
		draw_sprite_stretched(spr, 0, _x, _y, _w, _h);		
	}
	
	if(_icon) {
		draw_sprite_ext(_icon, _icon_index, _x + _w / 2, _y + _h / 2, 1, 1, 0, _icon_blend, _icon_alpha);
	}
	
	return res;
}
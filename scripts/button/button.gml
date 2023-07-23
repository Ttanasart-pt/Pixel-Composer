function button(_onClick, _icon = noone) {
	return new buttonClass(_onClick, _icon);
}

function buttonClass(_onClick, _icon = noone) : widget() constructor {
	icon	   = _icon;
	icon_blend = c_white;
	icon_index = 0;
	
	text	= "";
	tooltip = "";
	blend   = c_white;
	
	onClick = _onClick;
	triggered = false;
	
	activate_on_press = false;
	clicked = false;
		
	static setLua = function(_lua_thread, _lua_key, _lua_func) { 
		lua_thread = _lua_thread;
		lua_thread_key = _lua_key;
		onClick = method(self, _lua_func);
	}
	
	static trigger = function() { 
		clicked = true;
		
		if(!is_callable(onClick))
			return noone;
		triggered = true;
		onClick();
	}
	
	static isTriggered = function() {
		var t = triggered;
		triggered = false;
		return t;
	}
	
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
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		clicked = false;
		
		var b = colorMultiply(self.blend, blend);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched_ext(spr, 1, _x, _y, _w, _h, b, 1);	
			if(!activate_on_press && mouse_release(mb_left, active))
				trigger();
			if(activate_on_press && mouse_press(mb_left, active))
				trigger();
				
			if(mouse_click(mb_left, active)) {
				draw_sprite_stretched_ext(spr, 2, _x, _y, _w, _h, b, 1);
				draw_sprite_stretched_ext(spr, 3, _x, _y, _w, _h, COLORS._main_accent, 1);
			}
			if(tooltip != "") TOOLTIP = tooltip;
		} else {
			draw_sprite_stretched_ext(spr, 0, _x, _y, _w, _h, b, 1);	
			if(mouse_press(mb_left)) deactivate();
		}
		
		var aa = interactable * 0.25 + 0.75;
		if(icon) draw_sprite_ui_uniform(icon, icon_index, _x + _w / 2, _y + _h / 2,, icon_blend, aa);
		if(text != "") {
			draw_set_alpha(aa);
			draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
			draw_text(_x + _w / 2, _y + _h / 2, text);
			draw_set_alpha(1);
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);
		
		resetFocus();
		
		return _h;
	}
}

function buttonInstant(spr, _x, _y, _w, _h, _m, _act, _hvr, _tip = "", _icon = noone, _icon_index = 0, _icon_blend = COLORS._main_icon, _icon_alpha = 1, _icon_scale = 1) {
	var res = 0;
	var cc  = is_array(_icon_blend)? _icon_blend[0] : _icon_blend;
	
	if(_hvr && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
		if(is_array(_icon_blend))
			cc = _icon_blend[1];
			
		res = 1;
		if(spr) draw_sprite_stretched(spr, 1, _x, _y, _w, _h);	
		if(_tip != "") TOOLTIP = _tip;
			
		if(mouse_press(mb_left, _act))
			res = 2;
		if(mouse_press(mb_right, _act))
			res = 3;
			
		if(mouse_release(mb_left, _act))
			res = -2;
		if(mouse_release(mb_right, _act))
			res = -3;
			
		if(spr && mouse_click(mb_left, _act)) {
			draw_sprite_stretched(spr, 2, _x, _y, _w, _h);	
			draw_sprite_stretched_ext(spr, 3, _x, _y, _w, _h, COLORS._main_accent, 1);	
		}
	} else if(spr)
		draw_sprite_stretched(spr, 0, _x, _y, _w, _h);		
	
	if(_icon)
		draw_sprite_ui_uniform(_icon, _icon_index, _x + _w / 2, _y + _h / 2, _icon_scale, cc, _icon_alpha);
	
	return res;
}
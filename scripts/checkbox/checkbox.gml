function checkBox(_onClick) : widget() constructor {
	onClick   = _onClick;
	triggered = false;
	spr       = THEME.checkbox_def;
	tooltip   = "";
	slot_x    = undefined;
	
	static setTooltip = function(_t) /*=>*/ { tooltip = _t; return self; }
	
	static setLua = function(_lua_thread, _lua_key, _lua_func) { 
		lua_thread = _lua_thread;
		lua_thread_key = _lua_key;
		onClick = method(self, _lua_func);
	}
	
	static trigger = function() { 
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
	
	static fetchHeight = function(params) { return params.h; }
	static drawParam   = function(params) { 
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _value, _m, halign = fa_left, valign = fa_top) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(PREFERENCES.theme_boolean == 1) {
			w = min(w,h);
			h = w;
			
			x = _x + _w / 2 - w / 2;
			y = _y + _h / 2 - h / 2;
		}
		
		var aa = interactable * .25 + .75;
		draw_sprite_stretched_ext(spr, 0, x, y, w, h, c_white, aa);
		
		if(is_array(_value)) {
			draw_set_text(f_p4, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(x + w/2, y + h/2, __txt("Array"));
			return h;
		}
			
		if(hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h)) {
			if(tooltip != "") TOOLTIP = tooltip;
			draw_sprite_stretched_ext(spr, 1, x, y, w, h, c_white, aa);	
			
			if(mouse_lpress(active))
				trigger();
		} else
			if(mouse_lpress()) deactivate();
		
		if(PREFERENCES.theme_boolean == 0) {
			var w2 = w > ui(128)? w * .5 : w * .65;
			var kx = x + _value * (w - w2);
			var cc = _value? COLORS._main_accent : CDEF.main_dark;
			slot_x = slot_x == undefined? kx : lerp_float(slot_x, kx, 3);
			
			draw_sprite_stretched_ext(spr, 2, slot_x, y, w2, h, cc, aa);
			
			if(w2 > ui(64)) { 
				draw_set_text(f_p4, fa_center, fa_center);
				
				if(_value) {
					draw_set_color(CDEF.main_mdblack);
					draw_text(round(x + w2 + w2/2), round(y + h/2), __txt("True"));
					
				} else {
					draw_set_color(COLORS._main_text_sub);
					draw_text_add(x + w2/2, y + h/2, __txt("False"));
				}
			}
			
		} else {
			if(_value) draw_sprite_stretched_ext(spr, 2, x, y, w, h, COLORS._main_accent);
		}
			
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, x - ui(3), y - ui(3), w + ui(6), h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() { return new checkBox(onClick); }
}

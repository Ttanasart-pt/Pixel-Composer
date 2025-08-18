function button(_onClick, _icon = noone) { INLINE return new buttonClass(_onClick, _icon); }

function buttonClass(_onClick, _icon = noone) : widget() constructor {
	icon	   = _icon;
	icon_blend = c_white;
	icon_index = 0;
	icon_size  = 1;
	icon_padd  = ui(4);
	icon_w     = 1;
	icon_h     = 1;
	
	text	= "";
	tooltip = "";
	tooltipIndexFn = undefined;
	blend   = c_white;
	
	onClick   = _onClick;
	triggered = false;
	params    = undefined;
	
	activate_on_press = false;
	clicked = false;
	pressed = false;
	
	toggled = false;
	context = noone;
	
	base_spr = THEME.button_def;
	
	onWUp   = undefined;
	onWDown = undefined;
	
	static setContext = function(_s)          /*=>*/ { onClick = method(_s, onClick); return self; }
	static setWheel   = function(_u, _d = _u) /*=>*/ { onWUp = _u; onWDown = _d;      return self; }
	
	static setBaseSprite = function(_b) /*=>*/ { base_spr = _b; return self; }
	static setText       = function(_t) /*=>*/ { text     = _t; return self; }
	static setParams     = function(_p) /*=>*/ { params   = _p; return self; }
	static setTooltip    = function(_t, _v = undefined) /*=>*/ { tooltip  = _t; tooltipIndexFn = _v; return self; }
	
	static setIcon = function(_icon, _index = 0, _blend = c_white, _size = 1) {
		icon       = _icon; 
		icon_index = _index;
		icon_blend = _blend;
		icon_size  = _size;
		
		return self; 
	}
	
	static iconPad = function(_padd = ui(4)) {
		icon_size = 0;
		icon_padd = _padd;
		if(icon == noone) return self;
		icon_w    = sprite_get_width(icon);
		icon_h    = sprite_get_height(icon);
		
		return self;
	}
	
	static setLua = function(_lua_thread, _lua_key, _lua_func) {
		lua_thread     = _lua_thread;
		lua_thread_key = _lua_key;
		onClick        = method(self, _lua_func);
		return self;
	}
	
	static trigger = function() {
		clicked = true;
		
		if(!is_callable(onClick))
			return noone;
			
		triggered = true;
		if(params == undefined) onClick();
		else onClick(params);
	}
	
	static isTriggered = function() {
		var t = triggered;
		triggered = false;
		return t;
	}
	
	static drawParam = function(_params) {
		setParam(_params);
		return draw(_params.x, _params.y, _params.w, _params.h, _params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _m, spr = base_spr, _blend = c_white) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		clicked  = false;
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		var b = colorMultiply(blend, _blend);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched_ext(spr, toggled? 2 : 1, _x, _y, _w, _h, b, 1);
			
			if(!activate_on_press && pressed && mouse_release(mb_left, active))
				trigger();
				
			if(mouse_press(mb_left, active)) {
				pressed = true;
				if(activate_on_press) trigger();
			}
				
			if(mouse_click(mb_left, active)) {
				draw_sprite_stretched_ext(spr, 2, _x, _y, _w, _h, b, 1);
				draw_sprite_stretched_ext(spr, 3, _x, _y, _w, _h, COLORS._main_accent, 1);
			}
			if(tooltip != "") {
				var _ind = is_method(tooltipIndexFn)? tooltipIndexFn(params) : 0;
				if(is(tooltip, tooltipSelector)) tooltip.index = _ind;
				TOOLTIP = tooltip;
			}
			
			if(onWUp   != undefined && key_mod_press(SHIFT) && MOUSE_WHEEL > 0) onWUp();
			if(onWDown != undefined && key_mod_press(SHIFT) && MOUSE_WHEEL < 0) onWDown();

		} else {
			draw_sprite_stretched_ext(spr, toggled? 2 : 0, _x, _y, _w, _h, b, 1);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var aa = interactable * .5 + .5;
		var bx = _x + _w / 2;
		
		if(text != "") {
			var tx = _x + _w / 2;
			if(icon) tx += ui(8);
			
			draw_set_text(font, fa_center, fa_center, COLORS._main_text, aa);
			draw_text_add(tx, _y + _h / 2, text);
			draw_set_alpha(1);
			
			bx = tx - string_width(text) / 2 - ui(12);
		}
		
		if(icon) {
			var ind = icon_index;
			
			     if(is_array(ind))    ind = ind[0](params);
			else if(is_method(ind)) ind = ind(params);
			
			gpu_set_tex_filter(true);
			if(icon_size == 0) {
				var ics = min(1, (_w - icon_padd) / icon_w, (_h - icon_padd) / icon_h);
				draw_sprite_ext(icon, ind, bx, _y + _h / 2, ics, ics, 0, icon_blend, aa);
			} else draw_sprite_ui_uniform(icon, ind, bx, _y + _h / 2, icon_size, icon_blend, aa);
			gpu_set_tex_filter(false);
		}
		
		if(WIDGET_CURRENT == self) draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);
		
		resetFocus();
		
		if(mouse_release(mb_left)) pressed = false;
		
		return _h;
	}
		
	static clone = function() {
		var cln = new buttonClass(onClick);
		
		cln.icon	   = icon;
		cln.icon_blend = icon_blend;
		cln.icon_index = icon_index;
		
		cln.text	= text;
		cln.tooltip = tooltip;
		cln.blend   = blend;
		
		return cln;
	}
}

function buttonInstant(spr, _x, _y, _w, _h, _m, _hvr, _act, _tip = "", 
	_icon = noone, _icon_index = 0, _icon_blend = COLORS._main_icon, _icon_alpha = 1, _icon_scale = 1, _button_blend = c_white) {
		
	var res = 0;
	var cc  = is_array(_icon_blend)? _icon_blend[0] : _icon_blend;
	
	if(_hvr && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
		if(is_array(_icon_blend))
			cc = _icon_blend[1];
			
		res = 1;
		if(spr) draw_sprite_stretched_ext(spr, 1, _x, _y, _w, _h, _button_blend);
		if(_tip != "") TOOLTIP = _tip;
			
		if(mouse_press(mb_left, _act))		res = 2;
		if(mouse_press(mb_right, _act))		res = 3;
			
		if(mouse_release(mb_left, _act))	res = -2;
		if(mouse_release(mb_right, _act))	res = -3;
			
		if(spr && mouse_click(mb_left, _act)) {
			draw_sprite_stretched_ext(spr, 2, _x, _y, _w, _h, _button_blend);	
			draw_sprite_stretched_ext(spr, 3, _x, _y, _w, _h, COLORS._main_accent, 1);	
		}
	} else if(spr)
		draw_sprite_stretched_ext(spr, 0, _x, _y, _w, _h, _button_blend);
	
	var icx = _x + _w / 2;
	var icy = _y + _h / 2;
	var ica = _icon_alpha == 1 || res == 0? _icon_alpha : 1;
	
	     if(is(_icon, sprite_drawer)) _icon.draw(icx, icy, _icon_scale, cc, ica);
	else if(sprite_exists(_icon))     draw_sprite_ui_uniform(_icon, _icon_index, icx, icy, _icon_scale, cc, ica);
	
	return res;
}

function buttonInstant_Pad(spr, _x, _y, _w, _h, _m, _hvr, _act, _tip = "", 
	_icon = noone, _icon_index = 0, _icon_blend = COLORS._main_icon, _icon_alpha = 1, _icon_padding = ui(4), _button_blend = c_white) {
		
	var res = 0;
	var cc  = is_array(_icon_blend)? _icon_blend[0] : _icon_blend;
	
	if(_hvr && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
		if(is_array(_icon_blend))
			cc = _icon_blend[1];
			
		res = 1;
		if(spr) draw_sprite_stretched_ext(spr, 1, _x, _y, _w, _h, _button_blend);
		if(_tip != "") TOOLTIP = _tip;
			
		if(mouse_press(mb_left, _act))		res = 2;
		if(mouse_press(mb_right, _act))		res = 3;
			
		if(mouse_release(mb_left, _act))	res = -2;
		if(mouse_release(mb_right, _act))	res = -3;
			
		if(spr && mouse_click(mb_left, _act)) {
			draw_sprite_stretched_ext(spr, 2, _x, _y, _w, _h, _button_blend);	
			draw_sprite_stretched_ext(spr, 3, _x, _y, _w, _h, COLORS._main_accent, 1);	
		}
	} else if(spr)
		draw_sprite_stretched_ext(spr, 0, _x, _y, _w, _h, _button_blend);
		
	if(_icon) {
		var icx = _x + _w / 2;
		var icy = _y + _h / 2;
		var ica = _icon_alpha == 1 || res == 0? _icon_alpha : 1;
		var ics = min(1, (_w - _icon_padding) / sprite_get_width(_icon), (_h - _icon_padding) / sprite_get_height(_icon));
		
		gpu_set_tex_filter(true);
		draw_sprite_ext(_icon, _icon_index, icx, icy, ics, ics, 0, cc, ica);
		gpu_set_tex_filter(false);
	}
	
	return res;
}

function buttonTextIconInstant(active, spr, _x, _y, _w, _h, _m, _act, _hvr, _tip = "", _icon = noone, _icon_label = "", _icon_blend = COLORS._main_icon_light, _icon_alpha = 1) {
	var _b = 0;
	
	if(active) _b = buttonInstant(spr, _x, _y, _w, _h, _m, _hvr, _act, _tip);
	
	draw_set_text(f_p1, fa_left, fa_center, active? COLORS._main_icon_light : COLORS._main_icon);
	var bxc = _x + _w / 2 - (string_width(_icon_label) + ui(64)) / 2;
	var byc = _y + _h / 2;
	
	if(_icon) draw_sprite_ui(_icon, 0, bxc + ui(24), byc, 1, 1, 0, _icon_blend, _icon_alpha * (0.5 + 0.5 * active));
	
	draw_text_add(bxc + ui(48), byc, _icon_label);
	
	return _b;
}

function buttonInstantGlass(hover, focus, mx, my, bx, by, bw, bh, txt = "", aa = .3) {
	var _hov = hover && point_in_rectangle(mx, my, bx, by, bx + bw, by + bh);
	var _res = _hov;
	
	draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, _hov? COLORS._main_value_positive : COLORS._main_icon, aa     + _hov * .1);
	draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, _hov? COLORS._main_value_positive : COLORS._main_icon, aa * 2 + _hov * .25);
	
	draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon);
	draw_text_add(bx + bw / 2, by + bh / 2, txt);
	
	if(mouse_press(mb_left, focus && _hov))
		_res = 2;
		
	return _res;
}
function tooltipHotkey(text, context = "", name = "") constructor {
	self.text   = text;
	self.hotkey = find_hotkey(context, name);
	
	keyStr = hotkey? key_get_name(hotkey.key, hotkey.modi) : "";
	
	static setKey = function(key) { keyStr = key; return self;  }
	
	static drawTooltip = function() {
		if(keyStr == "") { draw_tooltip_text(text); return; }
		
		draw_set_font(f_p1);
		var _w1 = string_width(text);
		
		draw_set_font(f_p1);
		var _w2 = string_width(keyStr);
		
		var tw  = min(__win_tw - ui(32), _w1 + ui(24) + _w2);
		var th  = string_height_ext(text, -1, tw);
		
		var mx = min(__mouse_tx + ui(16), __win_tw - (tw + ui(16)));
		var my = min(__mouse_ty + ui(16), __win_th - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
		draw_set_color(COLORS._main_text);
		draw_text_line(mx + ui(8), my + ui(8), text, -1, tw);
		
		var _hx = mx + tw + ui(6);
		var _hy = my + th / 2 + ui(10);
		hotkey_draw(keyStr, _hx, _hy);
	}
}

function tooltipHotkey_assign(text, hotkey = "") constructor {
	self.text   = text;
	self.hotkey = hotkey;
	
	static drawTooltip = function() {
		var _uns = text == noone;
		var _txt = _uns? [ __txt("Unassigned") ] : text;
		
		draw_set_font(f_p1);
		var _w1 = string_width(hotkey);
		
		draw_set_font(f_p1);
		var _w2 = 0;
		var  th = 0;
		
		for (var i = 0, n = array_length(_txt); i < n; i++) {
			var _t  = _txt[i];
			var _ts = is_string(_t)? _t : _t.name;
			
			_w2  = max(_w2, string_width(_ts));
			 th += string_height(_ts);
		}
		
		var tw = min(__win_tw - ui(32), _w1 + ui(24) + _w2);
		var mx = min(__mouse_tx + ui(16), __win_tw - (tw + ui(16)));
		var my = min(__mouse_ty + ui(16), __win_th - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		var txy = my + ui(8);
		
		draw_set_text(f_p1, fa_left, fa_top, _uns? COLORS._main_text_sub : COLORS._main_text);
		for (var i = 0, n = array_length(_txt); i < n; i++) {
			var _t  = _txt[i];
			var _ts = is_string(_t)? _t : _t.name;
			
			draw_text(mx + ui(8), txy, _ts);
			txy += string_height(_ts);
		}
		
		var _hx = mx + tw + ui(6);
		var _hy = my + line_get_height() / 2 + ui(10);
		hotkey_draw(hotkey, _hx, _hy);
	}
}
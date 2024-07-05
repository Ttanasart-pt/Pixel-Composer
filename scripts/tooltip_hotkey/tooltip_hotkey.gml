function tooltipHotkey(text, context = "", name = "") constructor {
	self.text   = text;
	self.hotkey = find_hotkey(context, name);
	
	keyStr = hotkey? key_get_name(hotkey.key, hotkey.modi) : "";
	
	static setKey = function(key) { keyStr = key; return self;  }
	
	static drawTooltip = function() {
		if(keyStr == "") { draw_tooltip_text(text); return; }
		
		draw_set_font(f_p0);
		var _w1 = string_width(text);
		
		draw_set_font(f_p1);
		var _w2 = string_width(keyStr);
		
		var tw  = min(WIN_W - ui(32), _w1 + ui(24) + _w2);
		var th  = string_height_ext(text, -1, tw);
		
		var mx = min(mouse_mx + ui(16), WIN_W - (tw + ui(16)));
		var my = min(mouse_my + ui(16), WIN_H - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_set_color(COLORS._main_text);
		draw_text_line(mx + ui(8), my + ui(8), text, -1, tw);
		
		var _hx = mx + tw + ui(6);
		var _hy = my + th / 2 + ui(10);
		hotkey_draw(keyStr, _hx, _hy);
	}
}
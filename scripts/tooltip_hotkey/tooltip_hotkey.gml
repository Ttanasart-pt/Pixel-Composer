function tooltipHotkey(_text, context = "", name = "") constructor {
	text   = _text;
	hotkey = context == undefined? noone : find_hotkey(context, name);
	
	static drawTooltip = function() {
		var keyStr = hotkey? hotkey.getKeyName() : "";
		if(keyStr == "") { draw_tooltip_text(text); return; }
		
		draw_set_font(f_p2);
		var _w1 = string_width(text);
		
		draw_set_font(f_p2);
		var _w2 = string_width(keyStr);
		
		var tw  = min(WIN_W - ui(32), _w1 + ui(24) + _w2);
		var th  = string_height_ext(text, -1, tw);
		
		var mx = min(mouse_mxs + ui(16), WIN_W - (tw + ui(16)));
		var my = min(mouse_mys + ui(16), WIN_H - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
		draw_set_color(COLORS._main_text);
		draw_text_line(mx + ui(8), my + ui(8), text, -1, tw);
		
		var _hx = mx + tw + ui(6);
		var _hy = my + th / 2 + ui(10);
		hotkey_draw(keyStr, _hx, _hy);
	}
}

function tooltipKey(_text, _keyStr) constructor {
	text   = _text;
	keyStr = _keyStr;
	
	static drawTooltip = function() {
		if(keyStr == "") { draw_tooltip_text(text); return; }
		
		draw_set_font(f_p2);
		var _w1 = string_width(text);
		
		draw_set_font(f_p2);
		var _w2 = string_width(keyStr);
		
		var tw  = min(WIN_W - ui(32), _w1 + ui(24) + _w2);
		var th  = string_height_ext(text, -1, tw);
		
		var mx = min(mouse_mxs + ui(16), WIN_W - (tw + ui(16)));
		var my = min(mouse_mys + ui(16), WIN_H - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
		draw_set_color(COLORS._main_text);
		draw_text_line(mx + ui(8), my + ui(8), text, -1, tw);
		
		var _hx = mx + tw + ui(6);
		var _hy = my + th / 2 + ui(10);
		hotkey_draw(keyStr, _hx, _hy);
	}
}

function tooltipHotkey_assign(_text, _hotkey = "") constructor {
	text   = _text;
	hotkey = _hotkey;
	
	static drawTooltip = function() {
		var _uns = text == noone;
		var _txt = _uns? [ __txt("Unassigned") ] : text;
		
		draw_set_font(f_p2);
		var _w1 = string_width(hotkey);
		
		draw_set_font(f_p2);
		var _w2 = 0;
		var  th = 0;
		
		for (var i = 0, n = array_length(_txt); i < n; i++) {
			var _t  = _txt[i];
			var _ts = is_string(_t)? _t : _t.name;
			
			_w2  = max(_w2, string_width(_ts));
			 th += string_height(_ts);
		}
		
		var tw = min(WIN_W - ui(32), _w1 + ui(24) + _w2);
		var mx = min(mouse_mxs + ui(16), WIN_W - (tw + ui(16)));
		var my = min(mouse_mys + ui(16), WIN_H - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		var txy = my + ui(8);
		
		draw_set_text(f_p2, fa_left, fa_top, _uns? COLORS._main_text_sub : COLORS._main_text);
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

function tooltipHotkey_multiple(_keys, _cmod) constructor {
	keys = _keys;
	cmod = _cmod;
	
	draw_set_font(f_p2);
	lh = line_get_height(f_p2, 2);
	
	list = struct_get_names(keys);
	array_sort(list, true);
	hh = ui(16);
	ww = 0;
	
	for( var i = 0, n = array_length(list); i < n; i++ ) {
		var _mod = list[i];
		var _hks = keys[$ _mod];
		
		for( var j = 0, m = array_length(_hks); j < m; j++ ) {
			var _hk = _hks[j];
			ww = max(ww, string_width(_hk.name) + ui(32) + string_width(_hk.getKeyName()));
			hh += lh;
		}
	}
	
	ww += ui(16);
	
	static drawTooltip = function() {
		var mx = min(mouse_mxs + ui(16), WIN_W - ww);
		var my = min(mouse_mys + ui(16), WIN_H - hh);
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, ww, hh);
		draw_sprite_stretched(THEME.textbox, 0, mx, my, ww, hh);
		
		var tx = mx + ui(8);
		var hx = mx + ww - ui(8);
		var ty = my + ui(8);
		
		for( var i = 0, n = array_length(list); i < n; i++ ) {
			var _mod = list[i];
			var _hks = keys[$ _mod];
			
			for( var j = 0, m = array_length(_hks); j < m; j++ ) {
				var _hk = _hks[j];
				var _press = cmod == _hk.key._M;
				
				draw_set_text(f_p2, fa_left, fa_top, _press? COLORS._main_text_accent : COLORS._main_text);
				draw_text_add(tx, ty, _hk.name);
				
				draw_set_text(f_p2, fa_right, fa_top, _press? COLORS._main_text : COLORS._main_text_sub);
				draw_text_add(hx, ty, _hk.getKeyName());
				
				ty += lh;
			}
		}
		
	}
}
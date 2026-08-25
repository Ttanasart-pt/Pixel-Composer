function tooltipHotkey(_text, context = undefined, name = undefined) constructor {
	text   = _text;
	hotkey = noone; static setHotkey = function(hk) /*=>*/ { hotkey = hk; return self; }
	
	if(context != undefined) {
		if(name != undefined) hotkey = find_hotkey(context, name);
		else                  hotkey = find_hotkey_ext(context);
	}
	
	static drawTooltip = function() {
		var keyStr = hotkey? hotkey.getKeyName() : "";
		if(keyStr == "") { draw_tooltip_text(text); return; }
		
		draw_set_font(f_p2);
		var _w1 = string_width(text);
		
		draw_set_font(f_p2);
		var _w2 = string_width(keyStr);
		
		var tw = min(WIN_W - ui(32), _w1 + ui(24) + _w2);
		var th = string_height_ext(text, -1, tw);
		var pd = ui(8);
		
		var tww = tw + pd * 2;
		var thh = th + pd * 2;
		
		TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
		surface_set_shader(TOOLTIP_SURFACE);
			draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
			draw_set_color(COLORS._main_text);
			BLEND_ADD
			draw_text_line(pd, pd, text, -1, tw);
			BLEND_NORMAL
			
			var _hx = tw + ui(6);
			var _hy = th / 2 + ui(10);
			hotkey_draw(keyStr, _hx, _hy);
		surface_reset_shader();
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
		
		var tw = min(WIN_W - ui(32), _w1 + ui(24) + _w2);
		var th = string_height_ext(text, -1, tw);
		var pd = ui(8);
		
		var tww = tw + pd * 2;
		var thh = th + pd * 2;
		
		TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
			surface_set_shader(TOOLTIP_SURFACE);
			draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
			draw_set_color(COLORS._main_text);
			BLEND_ADD
			draw_text_line(pd, pd, text, -1, tw);
			BLEND_NORMAL
			
			var _hx = tw + ui(6);
			var _hy = th / 2 + ui(10);
			hotkey_draw(keyStr, _hx, _hy);
		surface_reset_shader();
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
		var pd = ui(8);
		
		var tww = tw + pd * 2;
		var thh = th + pd * 2;
		
		TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
		surface_set_shader(TOOLTIP_SURFACE);
			draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
			
			var txy = pd;
			
			draw_set_text(f_p2, fa_left, fa_top, _uns? COLORS._main_text_sub : COLORS._main_text);
			for (var i = 0, n = array_length(_txt); i < n; i++) {
				var _t  = _txt[i];
				var _ts = is_string(_t)? _t : _t.name;
				
				draw_text_add(pd, txy, _ts);
				txy += string_height(_ts);
			}
			
			var _hx = tw + ui(6);
			var _hy = line_get_height() / 2 + ui(10);
			hotkey_draw(hotkey, _hx, _hy);
		surface_reset_shader();
	}
}

function tooltipHotkey_multiple(_keys, _cmod) constructor {
	keys = _keys;
	cmod = _cmod;
	
	draw_set_font(f_p2);
	lh = line_get_height(f_p2, 2);
	
	list = struct_get_names(keys);
	array_sort(list, true);
	
	ww = 0;
	hh = 0;
	
	for( var i = 0, n = array_length(list); i < n; i++ ) {
		var _mod = list[i];
		var _hks = keys[$ _mod];
		
		for( var j = 0, m = array_length(_hks); j < m; j++ ) {
			var _hk = _hks[j];
			
			var hkw = ui(32);
			draw_set_font(f_p2);     hkw += string_width(_hk.name);
			draw_set_font(f_hotkey); hkw += string_width(_hk.getKeyName());
			
			ww = max(ww, hkw);
			hh += lh;
		}
	}
	
	static drawTooltip = function() {
		var tw = ww;
		var th = hh;
		var pd = ui(8);
		
		var tww = tw + pd * 2;
		var thh = th + pd * 2;
		
		TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
		surface_set_shader(TOOLTIP_SURFACE);
			draw_sprite_stretched(THEME.textbox, 3, 0, 0, tw, th);
			draw_sprite_stretched(THEME.textbox, 0, 0, 0, tw, th);
				var tx = ui(8);
				var hx = tw - ui(8);
				var ty = ui(8);
				
				for( var i = 0, n = array_length(list); i < n; i++ ) {
					var _mod = list[i];
					var _hks = keys[$ _mod];
					
					for( var j = 0, m = array_length(_hks); j < m; j++ ) {
						var _hk = _hks[j];
						var _press = cmod == _hk.key._M;
						
						draw_set_text(f_p2, fa_left, fa_top, _press? COLORS._main_text_accent : COLORS._main_text);
						draw_text_add(tx, ty, _hk.name);
						
						draw_set_text(f_hotkey, fa_right, fa_top, _press? COLORS._main_text : COLORS._main_text_sub);
						draw_text_add(hx, ty, _hk.getKeyName());
						
						ty += lh;
					}
				}
		surface_reset_shader();
		
	}
}
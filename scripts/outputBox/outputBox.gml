function outputBox() : widget() constructor {
	expand  = false;
	shorted = false;
	
	static trigger = function() { }
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _value, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		draw_set_text(font, fa_left, fa_top, COLORS._main_text_sub);
		
		if(shorted || string_length(_value) > 512) {
			var _hh  = string_height("l") + ui(16);
			
	        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _hh, COLORS._main_icon_light);
	        draw_text_add(_x + ui(8), _y + ui(8), "Output...");
	        return _hh;
		}
		
		if(typeof(_value) == "ref" && string_starts_with(string(_value), "ref surface")) {
			var _hh = ui(64);
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _hh, COLORS._main_icon_light);
			
			var _sw = _w  - ui(8);
			var _sh = _hh - ui(8);
			
			var sfw = surface_get_width(_value);	
			var sfh = surface_get_height(_value);	
			var ss  = min(_sw / sfw, _sh / sfh);
			var _sx = _x + _w  / 2 - ss * sfw / 2;
			var _sy = _y + _hh / 2 - ss * sfh / 2;
			
			draw_surface_ext_safe(_value, _sx, _sy, ss, ss, 0, c_white, 1);
			
			return _hh;
		}
		
		var _txt = string(_value);
		var _bh  = string_height("l");
        var _sh  = string_height_ext(_txt, -1, w - ui(16));
        var _hh  = (expand? _sh : _bh) + ui(16);
        
        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _hh, COLORS._main_icon_light);
        
        if(expand || _sh <= _bh)
	        draw_text_ext_add(_x + ui(8), _y + ui(8), _txt, -1, _w - ui(16));
        else
        	draw_text_add(_x + ui(8), _y + ui(8), "Output...");
        
        if(_sh > _bh) {
        	var _bs = _bh;
        	var _bx = _x + _w - ui(8) - _bs;
        	var _by = _y + ui(8);
        	
        	if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, iactive, ihover, "", THEME.arrow, expand? 3 : 0) == 2)
        		expand = !expand;
        }
        
		return _hh;
	}
	
	static clone = function() { return new outputBox(); }
}

function outputStructBox() : widget() constructor {
	expand  = false;
	shorted = false;
	
	static trigger = function() { }
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _value, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		draw_set_text(font, fa_left, fa_top, COLORS._main_text_sub);
		
		if(shorted) {
			var _hh  = string_height("l") + ui(16);
	        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _hh, COLORS._main_icon_light);
	        draw_text_add(_x + ui(8), _y + ui(8), "Output...");
	        return _hh;
		}
		
		var _txt = json_stringify(_value, true);
		var _bh  = string_height("l");
        var _sh  = string_height_ext(_txt, -1, w - ui(16));
        var _hh  = (expand? _sh : _bh) + ui(16);
        
        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _hh, COLORS._main_icon_light);
        
        if(expand || _sh <= _bh)
	        draw_text_ext_add(_x + ui(8), _y + ui(8), _txt, -1, _w - ui(16));
        else
        	draw_text_add(_x + ui(8), _y + ui(8), $"[{instanceof(_value)}]");
        
        if(_sh > _bh) {
        	var _bs = _bh;
        	var _bx = _x + _w - ui(8) - _bs;
        	var _by = _y + ui(8);
        	
        	if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, iactive, ihover, "", THEME.arrow, expand? 3 : 0) == 2)
        		expand = !expand;
        }
        
		return _hh;
	}
	
	static clone = function() { return new outputBox(); }
}

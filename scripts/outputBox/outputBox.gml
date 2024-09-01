function outputBox() : widget() constructor {
	
	static trigger = function() { }
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data);
	}
	
	static draw = function(_x, _y, _w, _value) {
		x = _x;
		y = _y;
		w = _w;
		
		draw_set_text(font, fa_left, fa_top, COLORS._main_text_sub);
		
		var _txt = string(_value);
        var _sh  = string_height_ext(_txt, -1, w - ui(16)) + ui(16);
        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _sh, COLORS._main_icon_light);
        draw_text_ext_add(_x + ui(8), _y + ui(8), _txt, -1, _w - ui(16));
        
		return _sh;
	}
	
	static clone = function() { return new outputBox(); }
}

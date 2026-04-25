function tooltipSelector(_title, _data, _index = 0) constructor {
	title = _title;
	data  = _data;
	index = _index;
	
	subtitle = "";
	
	arrow_pos    = noone;
	arrow_pos_to = 0;
	
	static setSubtitle = function(_sub) { subtitle = _sub; return self; }
	
	static drawTooltip = function() {
		draw_set_font(f_p1b);
		var th = line_get_height();
		var tw = string_width(title);
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
		var lh = line_get_height();
		
		var _h = (th + ui(4)) + (lh + ui(2)) * array_length(data) - ui(2);
		var _w = tw;
		
		for( var i = 0, n = array_length(data); i < n; i++ ) 
			_w = max(_w, ui(24) + string_width(data[i]));
		
		if(subtitle != "") {
			draw_set_font(f_p4);
			_h += ui(16);
			_w  = max(_w, string_width(subtitle));
		}
		
		var mx = min( mouse_mxs + ui(16), WIN_W - (_w + ui(16)) );
		var my = min( mouse_mys + ui(16), WIN_H - (_h + ui(16)) );
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + ui(16), _h + ui(16));
		if(subtitle != "") 
			draw_sprite_stretched_ext(THEME.textbox, 3, mx, my + _h - ui(4), _w + ui(16), ui(20), COLORS._main_icon_light);
		draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + ui(16), _h + ui(16));
		
		var yy = my + ui(6);
		draw_set_font(f_p1b);
		draw_text(mx + ui(8), yy, title);
		yy += th + ui(4);
		
		draw_set_font(f_p2);
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			if(i == index) arrow_pos_to = (yy + lh / 2) - my;
			
			draw_set_color(i == index? COLORS._main_text_accent : COLORS._main_text_sub);
			draw_text(mx + ui(8 + 24), yy, data[i]);
			
			yy += lh + ui(2);
		}
		
		arrow_pos = arrow_pos == noone? arrow_pos_to : lerp_float(arrow_pos, arrow_pos_to, 3);
		draw_sprite_ui(THEME.arrow, 0, mx + ui(8 + 12), my + arrow_pos, ,,, COLORS._main_text_accent);
		
		if(subtitle != "") {
			draw_set_text(f_p4, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(mx + ui(4), my + _h + ui(16 - 4), subtitle);
		}
	}
}
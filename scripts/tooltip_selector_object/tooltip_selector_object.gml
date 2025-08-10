function tooltipSelector(_title, _data, _index = 0) constructor {
	title = _title;
	data  = _data;
	index = _index;
	
	arrow_pos    = noone;
	arrow_pos_to = 0;
	
	static drawTooltip = function() {
		draw_set_font(f_p0);
		var th = line_get_height();
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
		var lh = line_get_height();
		
		var _h = (th + ui(6)) + (lh + ui(4)) * array_length(data);
		var _w = ui(16) + string_width(title);
		
		for( var i = 0, n = array_length(data); i < n; i++ ) 
			_w = max(_w, ui(8 + 16) + string_width(data[i]));
		
		var mx = min(mouse_mxs + ui(16), WIN_W - (_w + ui(16) + ui(4)));
		var my = min(mouse_mys + ui(16), WIN_H - (_h + ui(16) + ui(4)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + ui(16), _h + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + ui(16), _h + ui(16));
		
		var yy = my + ui(8);
		draw_set_font(f_p0);
		draw_text(mx + ui(12), yy, title);
		yy += th + ui(6);
		
		draw_set_font(f_p1);
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			if(i == index) arrow_pos_to = (yy + lh / 2) - my;
			
			draw_set_color(i == index? COLORS._main_text_accent : COLORS._main_text_sub);
			draw_text(mx + ui(8 + 24), yy, data[i]);
			
			yy += lh + ui(4);
		}
		
		arrow_pos = arrow_pos == noone? arrow_pos_to : lerp_float(arrow_pos, arrow_pos_to, 3);
		draw_sprite_ui(THEME.arrow, 0, mx + ui(8 + 12), my + arrow_pos, ,,, COLORS._main_text_accent);
	}
}
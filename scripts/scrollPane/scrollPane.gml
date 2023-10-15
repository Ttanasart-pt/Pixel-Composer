function scrollPane(_w, _h, ondraw) : widget() constructor {
	scroll_y		= 0;
	scroll_y_raw	= 0;
	scroll_y_to		= 0;
	
	x			= 0;
	y			= 0;
	w			= _w;
	h			= _h;
	surface_w   = _w - ui(12);
	surface_h   = _h;
	surface     = surface_create_valid(surface_w, surface_h);
	
	drawFunc    = ondraw;
	
	content_h   = 0;
	is_scroll	= true;
	always_scroll = false;
	show_scroll = true;
	
	scroll_step = 64;
	scroll_lock = false;
	
	is_scrolling = false;
	scroll_ms   = 0;
	
	static resize = function(_w, _h) {
		w = _w;
		h = _h;
		surface_w   = _w - (always_scroll || is_scroll) * ui(12);
		surface_h   = _h;
	}
	
	static setScroll = function(_scroll_y) { #region
		gml_pragma("forceinline");
		
		scroll_y_to  = clamp(_scroll_y, -content_h, 0);
	} #endregion
	
	static draw = function(x, y, _mx = mouse_mx - x, _my = mouse_my - y) {
		self.x = x;
		self.y = y;
		
		var mx = _mx, my = _my;
		hover  &= point_in_rectangle(mx, my, 0, 0, surface_w, surface_h);
		surface = surface_verify(surface, surface_w, surface_h);
		
		surface_set_target(surface);
			draw_clear(COLORS.panel_bg_clear);
			var hh = drawFunc(scroll_y, [mx, my], [x, y]);
			content_h = max(0, hh - surface_h);
		surface_reset_target();
		
		var sc = is_scroll;
		is_scroll = hh > surface_h;
		if(sc != is_scroll)
			resize(w, h);
		
		scroll_y_to  = clamp(scroll_y_to, -content_h, 0);
		scroll_y_raw = lerp_float(scroll_y_raw, scroll_y_to, 4);
		scroll_y	 = round(scroll_y_raw);
		draw_surface_safe(surface, x, y);
		
		if(hover && !scroll_lock && !key_mod_press(SHIFT)) {
			if(mouse_wheel_down())	scroll_y_to -= scroll_step * SCROLL_SPEED;
			if(mouse_wheel_up())	scroll_y_to += scroll_step * SCROLL_SPEED;
		}
		
		scroll_lock = false;
		
		if(show_scroll && (abs(content_h) > 0 || always_scroll)) {
			var scr_w = sprite_get_width(THEME.ui_scrollbar);
			draw_scroll(x + w - scr_w, y + ui(6), true, surface_h - ui(12), -scroll_y / content_h, surface_h / (surface_h + content_h), 
				COLORS.scrollbar_bg, COLORS.scrollbar_idle, COLORS.scrollbar_hover, x + _mx, y + _my);
		}
	}
	
	static draw_scroll = function(scr_x, scr_y, is_vert, scr_s, scr_prog, scr_ratio, bg_col, bar_col, bar_hcol, mx, my) {
		var scr_scale_s = scr_s * scr_ratio;
		var scr_prog_s  = scr_prog * (scr_s - scr_scale_s);
		var scr_w, scr_h, bar_w, bar_h, bar_x, bar_y;
		
		if(is_vert) {
			scr_w	= ui(sprite_get_width(THEME.ui_scrollbar));
			scr_h	= scr_s;
			
			bar_w	= ui(sprite_get_width(THEME.ui_scrollbar));
			bar_h   = scr_scale_s;
			
			bar_x	= scr_x;
			bar_y	= scr_y + scr_prog_s;
		} else {
			scr_w	= scr_s;
			scr_h	= ui(sprite_get_width(THEME.ui_scrollbar));
			
			bar_w	= scr_scale_s;
			bar_h   = ui(sprite_get_width(THEME.ui_scrollbar));
			
			bar_x	= scr_x + scr_prog_s;
			bar_y	= scr_y;
		}
		
		if(is_scrolling) {
			var delta = (is_vert? my : mx) - scroll_ms;
			scroll_ms = is_vert? my : mx;
			
			scroll_y_to -= (delta / scr_scale_s) * scr_s;
			scroll_y_to = clamp(scroll_y_to, -content_h, 0);
			
			if(mouse_release(mb_left))
				is_scrolling = false;
		}
		
		var bx0 = clamp(bar_x,         scr_x, scr_x + scr_w);
		var bx1 = clamp(bar_x + bar_w, scr_x, scr_x + scr_w);
		var ww = bx1 - bx0;
		
		var by0 = clamp(bar_y,         scr_y, scr_y + scr_h);
		var by1 = clamp(bar_y + bar_h, scr_y, scr_y + scr_h);
		var hh = by1 - by0;
		
		draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, scr_x, scr_y, scr_w, scr_h,  bg_col, 1);
		draw_sprite_stretched_ext(THEME.ui_scrollbar, 0,   bx0,   by0,    ww,    hh, bar_col, 1);
		
		//draw_set_color(c_white);
		//draw_rectangle(scr_x - 2, scr_y - 2, scr_x + scr_w + 2, scr_y + scr_h + 2, 0);
		//draw_set_color(c_red);
		//draw_circle(mx, my, 2, false);
		
		if(active && point_in_rectangle(mx, my, scr_x - 2, scr_y - 2, scr_x + scr_w + 2, scr_y + scr_h + 2) || is_scrolling) {
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, bar_x, bar_y, bar_w, bar_h, bar_hcol, 1);
			if(mouse_press(mb_left, active)) {
				is_scrolling = true;
				scroll_ms = is_vert? my : mx;
			}
		}
	}
}
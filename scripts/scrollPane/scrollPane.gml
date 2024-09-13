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
	
	content_h     = 0;
	is_scroll	  = true;
	always_scroll = true;
	show_scroll   = true;
	scroll_resize = true;
	
	scroll_step = 64;
	scroll_lock = false;
	
	is_scrolling = false;
	scroll_ms   = 0;
	
	pen_scrolling = false;
	pen_scroll_my = 0;
	pen_scroll_sy = 0;
	pen_scroll_py = 0;
	hover_content = false;
	
	scroll_s = sprite_get_width(THEME.ui_scrollbar);
	scroll_w = scroll_s;
	
	static resize = function(_w, _h) {
		w = _w;
		h = _h;
		surface_w = _w - ui(12) * (is_scroll || scroll_resize);
		surface_h = _h;
	}
	
	static setScroll = function(_scroll_y) {
		INLINE
		scroll_y_to  = clamp(_scroll_y, -content_h, 0);
	}
	
	static draw = function(x, y, mx = mouse_mx - x, my = mouse_my - y) {
		self.x = x;
		self.y = y;
		
		hover  &= point_in_rectangle( mx, my, 0, 0, surface_w, surface_h);
		hover  &= pen_scrolling != 2;
		surface = surface_verify(surface, surface_w, surface_h);
		hover_content = false;
		
		//// Draw
		
		surface_set_target(surface);
			draw_clear(COLORS.panel_bg_clear);
			var hh = drawFunc(scroll_y, [ mx, my ], [ x, y ]);
			content_h = max(0, hh - surface_h);
		surface_reset_target();
		
		var sc = is_scroll;
		is_scroll = hh > surface_h;
		if(sc != is_scroll) resize(w, h);
		
		//// Scrolling
		
		scroll_y_to  = clamp(scroll_y_to, -content_h, 0);
		scroll_y_raw = lerp_float(scroll_y_raw, scroll_y_to, 4);
		scroll_y	 = round(scroll_y_raw);
		draw_surface_safe(surface, x, y);
		
		if(hover && !scroll_lock && !key_mod_press(SHIFT) && !key_mod_press(CTRL)) {
			if(mouse_wheel_down())	scroll_y_to -= scroll_step * SCROLL_SPEED;
			if(mouse_wheel_up())	scroll_y_to += scroll_step * SCROLL_SPEED;
		}
		
		//// Pen scroll
		
		if(pen_scrolling == 0 && mouse_press(mb_left, !hover_content && hover && PEN_USE)) {
			pen_scrolling = 1;
			pen_scroll_my = 0;
		}
		
		if(pen_scrolling == 1) {
			pen_scroll_my += PEN_Y_DELTA;
			if(abs(pen_scroll_my) > 0)
				pen_scrolling = 2;
			if(mouse_release(mb_left)) pen_scrolling = 0;
			
		} else if(pen_scrolling == 2) {
			
			scroll_y_to  = clamp(scroll_y_to + PEN_Y_DELTA * 2, -content_h, 0);
			scroll_y_raw = scroll_y_to;
			scroll_y	 = round(scroll_y_raw);
			
			pen_scroll_py = abs(PEN_Y_DELTA) > abs(pen_scroll_py)? PEN_Y_DELTA : lerp_float(pen_scroll_py, PEN_Y_DELTA, 10);
			if(mouse_release(mb_left))
				pen_scrolling = 0;
			
		} else {
			pen_scroll_py = lerp_float(pen_scroll_py, 0, 30, 1);
			scroll_y_to += pen_scroll_py;
		}
		
		if(show_scroll && (abs(content_h) > 0 || (always_scroll && scroll_resize))) {
			var _p   = PEN_USE && (is_scrolling || point_in_rectangle(x + mx, y + my, x + w - scroll_w - 2, y, x + w, y + surface_h));
			scroll_w = lerp_float(scroll_w, _p? 12 : scroll_s, 5);
			
			draw_scroll(x + w - scroll_w, y + ui(6), true, surface_h - ui(12), -scroll_y / content_h, surface_h / (surface_h + content_h), 
				COLORS.scrollbar_bg, COLORS.scrollbar_idle, COLORS.scrollbar_hover, x + mx, y + my, scroll_w);
		}
		
		scroll_lock     = false;
	}
	
	static draw_scroll = function(scr_x, scr_y, is_vert, scr_s, scr_prog, scr_ratio, bg_col, bar_col, bar_hcol, mx, my, bar_spr_w) {
		var scr_scale_s = scr_s * scr_ratio;
		var scr_prog_s  = scr_prog * (scr_s - scr_scale_s);
		var scr_w, scr_h, bar_w, bar_h, bar_x, bar_y;
		
		if(is_vert) {
			scr_w	= bar_spr_w;
			scr_h	= scr_s;
			
			bar_w	= bar_spr_w;
			bar_h   = scr_scale_s;
			
			bar_x	= scr_x;
			bar_y	= scr_y + scr_prog_s;
		} else {
			scr_w	= scr_s;
			scr_h	= bar_spr_w;
			
			bar_w	= scr_scale_s;
			bar_h   = bar_spr_w;
			
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
		
		if(active && point_in_rectangle(mx, my, scr_x - 2, scr_y - 2, scr_x + scr_w + 2, scr_y + scr_h + 2) || is_scrolling) {
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, bar_x, bar_y, bar_w, bar_h, bar_hcol, 1);
			if(mouse_press(mb_left, active)) {
				is_scrolling = true;
				scroll_ms = is_vert? my : mx;
			}
		}
	}
}
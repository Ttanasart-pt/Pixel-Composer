function Panel_Custom_Frame_Scroll(_data) : Panel_Custom_Frame(_data) constructor {
	type = "framescroll";
	name = "Scroll Frame";
	icon = THEME.panel_icon_element_frame_scroll;
	
	sc_content_panel = undefined;
	show_all   = false;
	scroll_pad = 6;
	
	content_h    = 0;
	scroll_y     = 0;
	scroll_y_to  = 0;
	scroll_y_max = 0;
	
	is_scrolling   = false;
	scroll_ms      = 0;
	
	scroll_color_bg         = COLORS.scrollbar_bg;
	scroll_color_bar        = COLORS.scrollbar_idle;
	scroll_color_bar_hover  = COLORS.scrollbar_hover;
	scroll_color_bar_active = COLORS.scrollbar_active;
	scroll_color_bar_alpha  = 1;
	
	array_append(editors, [
		[ "Contents", false ], 
		Simple_Editor("View Contents", new checkBox( function() /*=>*/ { show_all = !show_all; } ), function() /*=>*/ {return show_all}, function(v) /*=>*/ { show_all = v; }), 
		
		[ "Scroll", false ], 
		Simple_Editor("Scroll Width", textBox_Number( function(v) /*=>*/ { scroll_pad = v; } ), function() /*=>*/ {return scroll_pad}, function(v) /*=>*/ { scroll_pad = v; }), 
	]);
	
	////- BBOX
	
	content_bbox = [0, 0, 1, 1];
	
	static setSize = function(_pBbox, _rx, _ry) {
		rx = _rx;
		ry = _ry;
		
		bbox = pbBox.setBase(_pBbox).getBBOX(bbox);
		x  = bbox[0];
		y  = bbox[1];
		w  = bbox[2] - bbox[0];
		h  = bbox[3] - bbox[1];
		
		var pbox = [
			bbox[0],
			bbox[1] - scroll_y,
			bbox[2] - scroll_pad,
			bbox[3] - scroll_y,
		];
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].setSize(pbox, _rx, _ry);
			
		var con_x0 =  infinity;
		var con_y0 =  infinity;
		var con_x1 = -infinity;
		var con_y1 = -infinity;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var c = contents[i];
			con_x0 = min(con_x0, c.x);
			con_y0 = min(con_y0, c.y + scroll_y);
			con_x1 = max(con_x1, c.x + c.w);
			con_y1 = max(con_y1, c.y + c.h + scroll_y);
		}
		
		content_bbox[0] = con_x0;
		content_bbox[1] = con_y0;
		content_bbox[2] = con_x1;
		content_bbox[3] = con_y1;
	}
	
	static checkMouse = function(panel, _m) {
		elementHover = panel._hovering_element == self;
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) {
			if(mouseEvent) panel.hovering_element = self;
			
			if(is_container || key_mod_press(CTRL)) 
				panel.hovering_frame = self;
				
			panel.hovering_scroll = self;
		}
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			if(!show_all && !_hov) contents[i].hover = false;
			contents[i].checkMouse(panel, _m);
		}
		
		if(panel._hovering_scroll == self && MOUSE_WHEEL != 0)
			scroll_y_to = clamp(scroll_y_to - MOUSE_WHEEL * ui(32), 0, scroll_y_max);
	}
	
	////- Draw
	
	static doDraw = function(panel, _m) {
		switch(style) {
			case 0 : break;
			case 1 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, x, y, w, h); break;
			case 2 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, x, y, w, h); break;
			case 3 : draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x, y, w, h); break;
		}
		
		content_h    = content_bbox[3] - y;
		scroll_y     = lerp_float(scroll_y, scroll_y_to, 5);
		scroll_y_max = max(0, content_h - h);
		
		if(!show_all) {
			var scis = gpu_get_scissor();
			gpu_set_scissor(x, y, w - scroll_pad, h);
		}
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].doDraw(panel, _m);
			
		if(!show_all) gpu_set_scissor(scis);
		
		if(scroll_pad > 0 && content_h > h) {
			var scrx = x + w - scroll_pad;
			var scrw = scroll_pad;
			
			var barh = h * h / content_h;
			var bary = y + scroll_y / scroll_y_max * (h - barh);
			
			if(is_scrolling) {
				var delta   = _m[1] - scroll_ms;
				scroll_ms   = _m[1];
				scroll_y_to = clamp(scroll_y_to + (delta / barh) * h, 0, scroll_y_max);
				
				if(mouse_lrelease())
					is_scrolling = false;
			}
			
			if(scroll_color_bg != undefined) 
				draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, scrx, y, scrw, h, scroll_color_bg, 1);
			
			var cc = scroll_color_bar;
			if(elementHover && point_in_rectangle(_m[0], _m[1], scrx - 2, y - 2, scrx + scrw + 2, y + h + 2)) {
				cc = scroll_color_bar_hover;
				
				if(mouse_lpress(focus)) {
					is_scrolling = true;
					scroll_ms    = _m[1];
				}
			}
			
			var by0 = clamp(bary,        y, y + h);
			var by1 = clamp(bary + barh, y, y + h);
			var hh  = by1 - by0;
			
			if(is_scrolling) cc = scroll_color_bar_active;
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, scrx, by0, scrw, hh, cc, scroll_color_bar_alpha);
		}
	}
	
	static drawBox = function(panel) {
		var aa = .25 + .5 * (panel._hovering_element == self);
		draw_sprite_stretched_add(THEME.ui_panel, 1, x, y, w, h, COLORS._main_icon, aa);
		
		if(!show_all) {
			var scis = gpu_get_scissor();
			gpu_set_scissor(x, y, w - scroll_pad, h);
		}
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) 
			contents[i].drawBox(panel);
			
		if(!show_all) gpu_set_scissor(scis);
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {
		_m.show_all   = show_all;
		_m.scroll_pad = scroll_pad / UI_SCALE;
	}
	
	static frameDeserialize = function(_m) {
		show_all   =  _m[$ "show_all"]   ?? show_all;
		scroll_pad = (_m[$ "scroll_pad"] ?? scroll_pad) * UI_SCALE;
		return self;
	}
}
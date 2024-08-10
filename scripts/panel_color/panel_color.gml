enum COLOR_SELECTOR_MODE {
	hue,
	value
}

function Panel_Color() : PanelContent() constructor {
	title   = __txt("Color");
	padding = 8;
	
	w = ui(320);
	h = ui(320);
	
	mode = COLOR_SELECTOR_MODE.hue;
	
	hue   = 1;
	sat   = 1;
	val   = 1;
	alp   = 1;
	
	drag_con = false;
	drag_sel = false;
	
	colors = [];
	
	hex_tb       = new textBox(TEXTBOX_INPUT.text, function(_hx) { setColor(colorFromHex(_hx)); })
	alpha_slider = slider(0, 1, 0.01, function(_a) { alp = _a; setHSV(); })
	show_alpha   = true;
	show_palette = false;
	show_hex     = true;
	
	current_color  = c_white;
	discretize_pal = false;
	
	content_surface = surface_create(1, 1);
	side_surface    = surface_create(1, 1);
	
	static setColor = function(color) {
		CURRENT_COLOR = color;
	}
	
	static refreshHSV = function() {
		hue = _color_get_hue(CURRENT_COLOR);
		sat = _color_get_saturation(CURRENT_COLOR);
		val = _color_get_value(CURRENT_COLOR);
		alp = _color_get_alpha(CURRENT_COLOR);
		
		current_color = CURRENT_COLOR;
	}
	
	static setHSV = function(h = hue, s = sat, v = val, a = alp) {
		hue = h;
		sat = s;
		val = v;
		alp = a;
		
		var _c = make_color_hsva(h * 255, s * 255, v * 255, a * 255);
		
		CURRENT_COLOR = _c;
		current_color = CURRENT_COLOR;
		
	} setHSV();
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		var _y1 = h - ui(padding);
		
		if(show_palette) {
			var amo = min(array_length(colors) + 1, floor((w - ui(padding * 2)) / ui(24 + 4)));
			var cy  = _y1 - ui(24);
			
			for( var i = 0; i < amo; i++ ) {
				var cx = ui(padding) + ui(24 + 4) * i;
				
				if(i == 0) {
					draw_sprite_stretched_ext(THEME.s_box_r2, 0, cx + ui(4), cy + ui(4), ui(16), ui(16), CURRENT_COLOR, _color_get_alpha(CURRENT_COLOR));
					draw_sprite_stretched_add(THEME.s_box_r2, 1, cx + ui(4), cy + ui(4), ui(16), ui(16), c_white, 0.3);
					
					draw_sprite_stretched_ext(THEME.ui_panel, 1, cx, cy, ui(24), ui(24), c_white, 0.5);
					
					if(pHOVER && point_in_rectangle(mx, my, cx, cy, cx + ui(24), cy + ui(24))) {
						draw_sprite_stretched_ext(THEME.ui_panel, 1, cx, cy, ui(24), ui(24), c_white, 1);
						if(mouse_press(mb_left, pFOCUS)) {
							array_insert(colors, 0, CURRENT_COLOR);
							
							DRAGGING = {
								type: "Color",
								data: CURRENT_COLOR
							}
							MESSAGE = DRAGGING;
						}
					}
					continue;
				}
				
				var c  = colors[i - 1];
				var aa = 0.3;
				draw_sprite_stretched_ext(THEME.s_box_r2, 0, cx, cy, ui(24), ui(24), c, 1);
				
				if(point_in_rectangle(mx, my, cx, cy, cx + ui(24), cy + ui(24))) {
					aa = 0.5;
					if(mouse_press(mb_left, pFOCUS)) {
						DRAGGING = {
							type: "Color",
							data: c
						}
						MESSAGE = DRAGGING;
					}
				}
				
				draw_sprite_stretched_add(THEME.s_box_r2, 1, cx, cy, ui(24), ui(24), c_white, aa);
			}
			
			_y1 = cy - ui(8);
		}
		
		if(show_hex) {
			var alp_h = ui(20);
			var alp_w = w - ui(padding * 2) - alp_h - ui(padding);
			
			var alp_x = alp_h + ui(padding * 2);
			var alp_y = _y1 - alp_h;
			
			draw_sprite_stretched_ext(THEME.s_box_r2, 0, ui(padding), alp_y, alp_h, alp_h, CURRENT_COLOR, alp);
			
			aa = 0.3;
			if(point_in_rectangle(mx, my, ui(padding), alp_y, ui(padding) + alp_h, alp_y + alp_h)) {
				aa = 0.5;
				if(mouse_press(mb_left, pFOCUS)) {
					DRAGGING = {
						type: "Color",
						data: CURRENT_COLOR
					} 
					MESSAGE = DRAGGING;
				}
			}
			
			draw_sprite_stretched_add(THEME.s_box_r2, 1, ui(padding), alp_y, alp_h, alp_h, c_white, aa);
			
			hex_tb.setFocusHover(pFOCUS, pHOVER);
			hex_tb.setFont(f_p2);
			
			hex_tb.align = fa_center;
			hex_tb.draw(alp_x, alp_y, alp_w, alp_h, color_get_hex(CURRENT_COLOR, show_alpha), [ mx, my ]);
			
			_y1 = alp_y - ui(8);
		}
		
		if(show_alpha) {
			var alp_w = w - ui(padding * 2);
			var alp_h = ui(20);
			
			var alp_x = ui(padding);
			var alp_y = _y1 - alp_h;
			
			alpha_slider.setFocusHover(pFOCUS, pHOVER);
			alpha_slider.setFont(f_p1);
			alpha_slider.draw(alp_x, alp_y, alp_w, alp_h, alp, [ mx, my ]);
			
			_y1 = alp_y - ui(8);
		}
		
		var sel_w  = ui(16);
		var sel_pd = ui(12);
		
		var _selPad = ui(12);
		var cont_x = _selPad;
		var cont_y = _selPad;
		var cont_w = w - _selPad * 2 - sel_w - sel_pd;
		var cont_h = _y1 - ui(4) - cont_y;
		
		var sel_x = cont_x + cont_w + sel_pd;
		var sel_y = _selPad;
		var sel_h = cont_h;
		
		content_surface = surface_verify(content_surface, cont_w, cont_h);
		side_surface    = surface_verify(side_surface,    sel_w,  sel_h);
		
		surface_set_target(content_surface);
			DRAW_CLEAR
			
			draw_sprite_stretched(THEME.s_box_r2, 0, 0, 0, cont_w, cont_h);
			gpu_set_colorwriteenable(1, 1, 1, 0);
			shader_set(sh_color_select_content);
				shader_set_i("mode", mode);
				shader_set_f("hue",  hue);
				shader_set_f("sat",  sat);
				shader_set_f("val",  val);
				
				shader_set_i("discretize",	  discretize_pal);
				shader_set_palette(PROJECT.attributes.palette);
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, cont_w, cont_h);
			shader_reset();
			gpu_set_colorwriteenable(1, 1, 1, 1);
		
		surface_reset_target();
			
		surface_set_target(side_surface);
			DRAW_CLEAR
			
			draw_sprite_stretched(THEME.s_box_r2, 0, 0, 0, sel_w, sel_h);
			gpu_set_colorwriteenable(1, 1, 1, 0);
			shader_set(sh_color_select_side);
				shader_set_i("mode", mode);
				shader_set_f("hue",  hue);
				shader_set_f("sat",  sat);
				shader_set_f("val",  val);
				
				shader_set_i("discretize", discretize_pal);
				shader_set_palette(PROJECT.attributes.palette);
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, sel_w, sel_h);
			shader_reset();
			gpu_set_colorwriteenable(1, 1, 1, 1);
			
		surface_reset_target();
		
		draw_surface(content_surface, cont_x, cont_y);
		draw_surface(side_surface,    sel_x,  sel_y);
		
		BLEND_ADD
		draw_sprite_stretched_ext(THEME.s_box_r2, 1, cont_x, cont_y, cont_w, cont_h, c_white, 0.2);
		draw_sprite_stretched_ext(THEME.s_box_r2, 1, sel_x,  sel_y,  sel_w,  sel_h,  c_white, 0.2);
		BLEND_NORMAL
		
		if(drag_con) {
			var _mmx = clamp((mx - cont_x) / cont_w, 0, 1);
			var _mmy = 1 - clamp((my - cont_y) / cont_h, 0, 1);
			
			if(mode == 0) {
				sat = _mmx;
				val = _mmy;
				
			} else if(mode == 1) {
				hue = _mmx;
				sat = _mmy;
				
			} else if(mode == 2) {
				hue = _mmx;
				val = _mmy;
			}
				
			setHSV();
				
			if(mouse_release(mb_left)) drag_con = false;
		}
		
		if(drag_sel) {
			var _mmy = clamp((my - sel_y) / sel_h, 0, 1);
			
				 if(mode == 0) hue = _mmy;
			else if(mode == 1) val = 1 - _mmy;
			else if(mode == 2) sat = 1 - _mmy;
				
			setHSV();
					
			if(mouse_release(mb_left)) drag_sel = false;
		}
		
		if(mouse_press(mb_left, pFOCUS)) {
			if(point_in_rectangle(mx, my, cont_x, cont_y, cont_x + cont_w, cont_y + cont_h))
				drag_con = true;
			
			if(point_in_rectangle(mx, my, sel_x, sel_y, sel_x + sel_w, sel_y + sel_h))
				drag_sel = true;
		}
		
		var bs = ui(12);
		var sw = ui(16 + 6);
		
		var cx = 0;
		var cy = 0;
		var sx = sel_x - ui(3);
		var sy = 0;
		var sc = c_black;
		var cc = CURRENT_COLOR;
		
		if(mode == 0) {
			var hy = sel_y + hue * sel_h;
			cx = cont_x + sat * cont_w - bs / 2;
			cy = cont_y + (1 - val) * cont_h - bs / 2;
			
			sy = hy - bs / 2;
			sc = make_color_hsv(hue * 255, 255, 255);
			
		} else if(mode == 1) {
			var vy = sel_y + (1 - val) * sel_h;
			cx = cont_x + hue * cont_w - bs / 2;
			cy = cont_y + (1 - sat) * cont_h - bs / 2;
			
			sy = vy - bs / 2;
			sc = make_color_hsv(hue * 255, 255, val * 255);
		
		} else if(mode == 2) {
			var sy = sel_y + (1 - sat) * sel_h;
			cx = cont_x + hue * cont_w - bs / 2;
			cy = cont_y + (1 - val) * cont_h - bs / 2;
			
			sy = sy - bs / 2;
			sc = make_color_hsv(hue * 255, sat * 255, 255);
		}
		
		draw_sprite_stretched_ext(THEME.s_box_r2, 0, cx - 1, cy - 1, bs + 2, bs + 2, c_black, 0.5);
		draw_sprite_stretched_ext(THEME.s_box_r2, 0, sx - 1, sy - 1, sw + 2, bs + 2, c_black, 0.5);
		
		draw_sprite_stretched_ext(THEME.s_box_r2, 0, sx, sy, sw, bs, sc, 1);
		draw_sprite_stretched_ext(THEME.s_box_r2, 0, cx, cy, bs, bs, cc, 1);
		
		BLEND_ADD
		draw_sprite_stretched_ext(THEME.s_box_r2, 1, sx, sy, sw, bs, c_white, 0.75);
		draw_sprite_stretched_ext(THEME.s_box_r2, 1, cx, cy, bs, bs, c_white, 0.75);
		BLEND_NORMAL
		
		if(DRAGGING && DRAGGING.type == "Color" && pHOVER) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, 2, 2, w - 4, h - 4, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left)) 
				setColor(DRAGGING.data);
		}
		
		if(mouse_press(mb_right, pFOCUS)) {
			menuCall("color_window_menu",,, [
				menuItem(__txt("Hue"),  		function() { mode = 0; } ),
				menuItem(__txt("Value"),		function() { mode = 1; } ),
				menuItem(__txt("Saturation"),	function() { mode = 2; } ),
				-1,
				menuItem(__txt("Toggle Alpha"),   function() { show_alpha   = !show_alpha;   }, noone, noone, function() /*=>*/ {return show_alpha}   ),
				menuItem(__txt("Toggle Palette"), function() { show_palette = !show_palette; }, noone, noone, function() /*=>*/ {return show_palette} ),
				menuItem(__txt("Toggle Hex"),     function() { show_hex     = !show_hex;     }, noone, noone, function() /*=>*/ {return show_hex}     ),
				-1,
				menuItem(__txt("Discretize"),     function() { discretize_pal = !discretize_pal; }, noone, noone, function() /*=>*/ {return discretize_pal} ),
			]);
		}
		
		if(current_color != CURRENT_COLOR)
			refreshHSV();
	}
}
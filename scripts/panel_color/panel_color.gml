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
	
	hex_tb       = new textBox(TEXTBOX_INPUT.text, function(val) { setColor(colorFromHex(val)); })
	alpha_slider = slider(0, 1, 0.01, function(val) { alp = val; setHSV(); })
	show_alpha   = true;
	show_palette = false;
	show_hex     = true;
	
	static setColor = function(color) {
		CURRENT_COLOR = color;
	}
	
	static refreshHSV = function() {
		hue = _color_get_hue(CURRENT_COLOR);
		sat = _color_get_saturation(CURRENT_COLOR);
		val = _color_get_value(CURRENT_COLOR);
		alp = _color_get_alpha(CURRENT_COLOR);
	}
	
	static setHSV = function(h = hue, s = sat, v = val, a = alp) {
		hue = h;
		sat = s;
		val = v;
		alp = a;
		
		CURRENT_COLOR = make_color_hsva(h * 255, s * 255, v * 255, a * 255);
		
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
					draw_sprite_stretched_ext(s_ui_base_white, 0, cx + ui(4), cy + ui(4), ui(16), ui(16), CURRENT_COLOR, _color_get_alpha(CURRENT_COLOR));
					draw_sprite_stretched_ext(THEME.ui_panel_active, 0, cx, cy, ui(24), ui(24), c_white, 0.5);
					
					if(pHOVER && point_in_rectangle(mx, my, cx, cy, cx + ui(24), cy + ui(24))) {
						draw_sprite_stretched_ext(THEME.ui_panel_active, 0, cx, cy, ui(24), ui(24), c_white, 1);
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
				draw_sprite_stretched_ext(s_ui_base_white, 0, cx, cy, ui(24), ui(24), c, 1);
				
				if(mouse_press(mb_left, pFOCUS) && point_in_rectangle(mx, my, cx, cy, cx + ui(24), cy + ui(24))) {
					DRAGGING = {
						type: "Color",
						data: c
					}
					MESSAGE = DRAGGING;
				}
			}
			
			_y1 = cy - ui(8);
		}
		
		if(show_hex) {
			var alp_w = w - ui(padding * 2);
			var alp_h = ui(20);
			
			var alp_x = ui(padding);
			var alp_y = _y1 - alp_h;
			
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
		
		var cont_x = ui(padding);
		var cont_y = ui(padding);
		var cont_w = w - ui(padding + padding) - ui(16 + 8);
		var cont_h = _y1 - cont_y;
		
		shader_set(sh_color_select_content);
		shader_set_i("mode", mode);
		shader_set_f("hue",  hue);
		shader_set_f("val",  val);
		draw_sprite_stretched(s_fx_pixel, 0, cont_x, cont_y, cont_w, cont_h);
		
		var sel_x = cont_x + cont_w + ui(8);
		var sel_y = ui(padding);
		var sel_w = ui(16);
		var sel_h = cont_h;
		
		shader_set(sh_color_select_side);
		shader_set_i("mode", mode);
		shader_set_f("hue",  hue);
		draw_sprite_stretched(s_fx_pixel, 0, sel_x, sel_y, sel_w, sel_h);
		shader_reset();
		
		if(drag_con) {
			if(mode == 0) {
				sat = clamp((mx - cont_x) / cont_w, 0, 1);
				val = 1 - clamp((my - cont_y) / cont_h, 0, 1);
			} else if(mode == 1) {
				hue = clamp((mx - cont_x) / cont_w, 0, 1);
				sat = 1 - clamp((my - cont_y) / cont_h, 0, 1);
			}
				
			setHSV();
				
			if(mouse_release(mb_left))
				drag_con = false;
		}
		
		if(drag_sel) {
			if(mode == 0)
				hue = clamp((my - sel_y) / sel_h, 0, 1);
			else if(mode == 1)
				val = 1 - clamp((my - sel_y) / sel_h, 0, 1);
				
			setHSV();
				
			if(mouse_release(mb_left))
				drag_sel = false;
		}
		
		if(mouse_press(mb_left, pFOCUS)) {
			if(point_in_rectangle(mx, my, cont_x, cont_y, cont_x + cont_w, cont_y + cont_h))
				drag_con = true;
			
			if(point_in_rectangle(mx, my, sel_x, sel_y, sel_x + sel_w, sel_y + sel_h))
				drag_sel = true;
		}
		
		if(mode == 0) {
			var hy = sel_y + hue * sel_h;
			var cx = cont_x + sat * cont_w - ui(6);
			var cy = cont_y + (1 - val) * cont_h - ui(6);
			draw_sprite_stretched_ext(s_ui_base_white, 0, sel_x - ui(3), hy - ui(6), ui(16 + 6), ui(10), make_color_hsv(hue * 255, 255, 255), 1);
			draw_sprite_stretched_ext(s_ui_base_white, 0, cx, cy, ui(12), ui(12), CURRENT_COLOR, 1);
			
		} else if(mode == 1) {
			var vy = sel_y + (1 - val) * sel_h;
			var cx = cont_x + hue * cont_w - ui(6);
			var cy = cont_y + (1 - sat) * cont_h - ui(6);
			draw_sprite_stretched_ext(s_ui_base_white, 0, sel_x - ui(3), vy - ui(6), ui(16 + 6), ui(10), make_color_hsv(hue * 255, 255, val * 255), 1);
			draw_sprite_stretched_ext(s_ui_base_white, 0, cx, cy, ui(12), ui(12), CURRENT_COLOR, 1);
		}
		
		if(DRAGGING && DRAGGING.type == "Color" && pHOVER) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, 2, 2, w - 4, h - 4, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left)) 
				setColor(DRAGGING.data);
		}
		
		if(mouse_press(mb_right, pFOCUS)) {
			menuCall("color_window_menu",,, [
				menuItem(__txt("Toggle Alpha"),   function() { show_alpha   = !show_alpha;   }, noone, noone, function() /*=>*/ {return show_alpha}   ),
				menuItem(__txt("Toggle Palette"), function() { show_palette = !show_palette; }, noone, noone, function() /*=>*/ {return show_palette} ),
				menuItem(__txt("Toggle Hex"),     function() { show_hex     = !show_hex;     }, noone, noone, function() /*=>*/ {return show_hex}     ),
			]);
		}
		
		refreshHSV();
	}
}
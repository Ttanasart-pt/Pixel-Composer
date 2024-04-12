enum COLOR_SELECTOR_MODE {
	hue,
	value
}

function Panel_Color() : PanelContent() constructor {
	title = __txt("Color");
	padding = 8;
	
	w = ui(320);
	h = ui(320);
	
	mode = COLOR_SELECTOR_MODE.hue;
	
	hue = 1;
	sat = 1;
	val = 1;
	color = c_black;
	
	drag_con = false;
	drag_sel = false;
	
	colors = [];
	
	static setColor = function(color) {
		self.color = color;
		hue = color_get_hue(color) / 255;
		sat = color_get_saturation(color) / 255;
		val = color_get_value(color) / 255;
		
		if(COLORS_GLOBAL_SET != noone)
			COLORS_GLOBAL_SET(color);
	}
	
	static setHSV = function(h = hue, s = sat, v = val) {
		hue = h;
		sat = s;
		val = v;
		
		color = make_color_hsv(h * 255, s * 255, v * 255);
		
		if(COLORS_GLOBAL_SET != noone)
			COLORS_GLOBAL_SET(color);
	}
	setHSV();
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		if(COLORS_GLOBAL_GET != noone) {
			var c = COLORS_GLOBAL_GET();
			if(c != color) setColor(c);
		}
			
		var cont_x = ui(padding);
		var cont_y = ui(padding);
		var cont_w = w - ui(padding + padding + ui(16 + 8));
		var cont_h = h - ui(padding + padding + ui(24 + 8));
		
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
			draw_sprite_stretched_ext(s_ui_base_white, 0, cx, cy, ui(12), ui(12), color, 1);
			
		} else if(mode == 1) {
			var vy = sel_y + (1 - val) * sel_h;
			var cx = cont_x + hue * cont_w - ui(6);
			var cy = cont_y + (1 - sat) * cont_h - ui(6);
			draw_sprite_stretched_ext(s_ui_base_white, 0, sel_x - ui(3), vy - ui(6), ui(16 + 6), ui(10), make_color_hsv(hue * 255, 255, val * 255), 1);
			draw_sprite_stretched_ext(s_ui_base_white, 0, cx, cy, ui(12), ui(12), color, 1);
		}
		
		var amo = min(array_length(colors) + 1, floor((w - ui(padding * 2)) / ui(24 + 4)));
		
		for( var i = 0; i < amo; i++ ) {
			var cx = ui(padding) + ui(24 + 4) * i;
			var cy = cont_y + cont_h + ui(8);
			
			if(i == 0) {
				draw_sprite_stretched_ext(s_ui_base_white, 0, cx + ui(4), cy + ui(4), ui(16), ui(16), color, 1);
				draw_sprite_stretched_ext(THEME.ui_panel_active, 0, cx, cy, ui(24), ui(24), c_white, 0.5);
				
				if(pHOVER && point_in_rectangle(mx, my, cx, cy, cx + ui(24), cy + ui(24))) {
					draw_sprite_stretched_ext(THEME.ui_panel_active, 0, cx, cy, ui(24), ui(24), c_white, 1);
					if(mouse_press(mb_left, pFOCUS)) {
						array_insert(colors, 0, color);
						
						if(COLORS_GLOBAL_SET != noone) {
							COLORS_GLOBAL_SET(color);
							
						} else {
							DRAGGING = {
								type: "Color",
								data: color
							}
							MESSAGE = DRAGGING;
						}
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
		
		if(DRAGGING && DRAGGING.type == "Color" && pHOVER) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, 2, 2, w - 4, h - 4, COLORS._main_value_positive, 1);	
			if(mouse_release(mb_left)) 
				setColor(DRAGGING.data);
		}
	}
}
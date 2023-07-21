function colorSelector(onApply = noone) constructor {
	self.onApply = onApply;
	
	current_color = c_white;
	
	hue           = 1;
	sat           = 0;
	val           = 0;
	
	area_dragging = false;
	side_dragging = false;
	
	dropper_active = false;
	dropper_close  = true;
	dropper_color  = c_white;
	interactable = true;
	
	disp_mode = 0;
	
	palette_display = false;
	palette = [];
	
	color_surface = surface_create_valid(ui(256), ui(256));
	
	tb_hue = new slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		hue = clamp(_val, 0, 255);
		setHSV();
	})
	tb_sat = new slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		sat = clamp(_val, 0, 255);
		setHSV();
	})
	tb_val= new slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		val = clamp(_val, 0, 255);
		setHSV();
	})
	
	tb_hue.hdw = ui(16);
	tb_sat.hdw = ui(16);
	tb_val.hdw = ui(16);
	
	tb_red = new slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		var r = clamp(_val, 0, 255);
		var g = color_get_green(current_color);
		var b = color_get_blue(current_color);
		
		current_color = make_color_rgb(r, g, b);
		resetHSV();
	})
	tb_green = new slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		var r = color_get_red(current_color);
		var g = clamp(_val, 0, 255);
		var b = color_get_blue(current_color);
		
		current_color = make_color_rgb(r, g, b);
		resetHSV();
	})
	tb_blue = new slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		var r = color_get_red(current_color);
		var g = color_get_green(current_color);
		var b = clamp(_val, 0, 255);
		
		current_color = make_color_rgb(r, g, b);
		resetHSV();
	})
	
	tb_red.hdw = ui(16);
	tb_green.hdw = ui(16);
	tb_blue.hdw = ui(16);
	
	tb_hex = new textBox(TEXTBOX_INPUT.text, function(str) {
		if(!interactable) return;
		if(str == "") return;
		if(string_char_at(str, 1) == "#") str = string_replace(str, "#", "");
		
		var _r = string_hexadecimal(string_copy(str, 1, 2));
		var _g = string_hexadecimal(string_copy(str, 3, 2));
		var _b = string_hexadecimal(string_copy(str, 5, 2));
		
		current_color = make_color_rgb(_r, _g, _b);
		resetHSV();
	})
	
	scr_disp = buttonGroup(["Hue", "Value"], function(mode) { disp_mode = mode; } );
	
	function resetHSV() {
		hue = round(color_get_hue(current_color));
		sat = round(color_get_saturation(current_color));
		val = round(color_get_value(current_color));
		
		if(onApply != noone) onApply(current_color);
	}
	function setHSV() {
		if(!interactable) return;
		current_color = make_color_hsv(hue, sat, val);	
		if(onApply != noone) onApply(current_color);
	}
	
	function setColor(color) {
		current_color = color;
		resetHSV();
	}
	
	function colorPicker() {
		if(!dropper_active) return;
		dropper_color = draw_getpixel(mouse_mx, mouse_my);
	}
	
	static drawDropper = function(instance) {
		if(mouse_press(mb_left)) {
			setColor(dropper_color);
			if(dropper_close)
				instance_destroy(instance);
			dropper_active = false;
		}
		
		if(dropper_active == true && mouse_press(mb_right))
			instance_destroy(instance);
		if(keyboard_check_released(vk_alt))
			instance_destroy(instance);
		
		var dx = mouse_mx + ui(36);
		var dy = mouse_my + ui(36);
		draw_sprite_stretched(THEME.color_picker_sample, 0, dx - ui(20), dy - ui(20), ui(40), ui(40));
		draw_sprite_stretched_ext(THEME.color_picker_sample, 0, dx - ui(18), dy - ui(18), ui(36), ui(36), dropper_color, 1);
	}
	
	static draw = function(_x, _y, focus, hover) {
		var col_x = _x + ui(8);
		var col_y = _y + ui(8);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 0, col_x - ui(8), col_y - ui(8), ui(256 + 16), ui(256 + 16));
	
		color_surface = surface_verify(color_surface, 256, 256);
		surface_set_target(color_surface);			
			if(disp_mode == 0) {
				shader_set(sh_color_picker_hue);
				shader_set_f("hue", hue / 256);
				shader_set_i("usePalette", palette_display);
				shader_set_palette(palette);
			} else if(disp_mode == 1) {
				shader_set(sh_color_picker_value);
				shader_set_f("value", val / 256);
				shader_set_i("usePalette", palette_display);
				shader_set_palette(palette);
			}
			
			draw_sprite_uniform(s_fx_pixel, 0, 0, 0, 256);
			shader_reset();
		surface_reset_target();
		
		draw_surface_ext_safe(color_surface, col_x, col_y,,,,, interactable * 0.5 + 0.5);
		
		#region side control
			var hue_x = col_x + ui(280);
			var hue_y = col_y;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 0, hue_x - ui(8), hue_y - ui(8), ui(32), ui(256 + 16));
			
			if(disp_mode == 0) {
				shader_set(sh_color_picker_side_hue);
					shader_set_i("usePalette", palette_display);
					shader_set_palette(palette);
					shader_set_f("sat", sat / 256);
					shader_set_f("value", val / 256);
					
					draw_sprite_stretched_ext(s_fx_pixel, 0, hue_x, hue_y, ui(16), ui(256), c_white, interactable * 0.5 + 0.5);
				shader_reset();
			} else if(disp_mode == 1) {
				shader_set(sh_color_picker_side_value);
					shader_set_i("usePalette", palette_display);
					shader_set_palette(palette);
					shader_set_f("hue", hue / 256);
					shader_set_f("sat", sat / 256);
					
					draw_sprite_stretched_ext(s_fx_pixel, 0, hue_x, hue_y, ui(16), ui(256), c_white, interactable * 0.5 + 0.5)
				shader_reset();
			}
			
			var _sy = disp_mode == 0? hue_y + ui(hue) : hue_y + ui(256 - val);
			
			if(palette_display) {
				draw_sprite_stretched_ext(s_ui_base_white, 0, hue_x - ui(3), _sy - ui(6), ui(24), ui(10), current_color, 1);
				
				if(disp_mode == 0)
					draw_sprite_stretched_ext(s_ui_base_white, 0, col_x + ui(sat - 6), col_y + ui(256 - val - 6), ui(12), ui(12), current_color, 1);
				else if(disp_mode == 1)
					draw_sprite_stretched_ext(s_ui_base_white, 0, col_x + ui(hue - 6), col_y + ui(256 - sat - 6), ui(12), ui(12), current_color, 1);
			} else {
				if(disp_mode == 0) {
					draw_sprite_stretched_ext(s_ui_base_white, 0, hue_x - ui(3), _sy - ui(6), ui(24), ui(10), make_color_hsv(hue, 255, 255), 1);
					draw_sprite_stretched_ext(s_ui_base_white, 0, col_x + ui(sat - 6), col_y + ui(256 - val - 6), ui(12), ui(12), current_color, 1);
				} else if(disp_mode == 1) {
					draw_sprite_stretched_ext(s_ui_base_white, 0, hue_x - ui(3), _sy - ui(6), ui(24), ui(10), make_color_hsv(hue, 255, val), 1);
					draw_sprite_stretched_ext(s_ui_base_white, 0, col_x + ui(hue - 6), col_y + ui(256 - sat - 6), ui(12), ui(12), current_color, 1);
				}
			}
			
			if(mouse_press(mb_left, interactable && focus)) {
				if(point_in_rectangle(mouse_mx, mouse_my, hue_x, hue_y, hue_x + ui(16), hue_y + ui(256)))
					side_dragging = true;
				else if(point_in_rectangle(mouse_mx, mouse_my, col_x, col_y, col_x + ui(256), col_y + ui(256)))
					area_dragging = true;
			}
			
			if(side_dragging) {
				if(disp_mode == 0) {
					hue = clamp((mouse_my - hue_y) / UI_SCALE, 0, 256);
				} else if(disp_mode == 1) {
					val = 256 - clamp((mouse_my - hue_y) / UI_SCALE, 0, 256);
				}
				
				setHSV();
				
				if(palette_display) {
					current_color = disp_mode == 0? surface_getpixel(color_surface, sat, 256 - val) : 
													surface_getpixel(color_surface, hue, sat);
					if(onApply != noone) onApply(current_color);
				}
				
				if(mouse_release(mb_left))
					side_dragging  = false;
			}
		
			if(area_dragging) {
				if(disp_mode == 0) {
					sat = clamp((mouse_mx - col_x) / UI_SCALE, 0, 256);
					val = 256 - clamp((mouse_my - col_y) / UI_SCALE, 0, 256);
				} else if(disp_mode == 1) {
					hue = clamp((mouse_mx - col_x) / UI_SCALE, 0, 256);
					sat = 256 - clamp((mouse_my - col_y) / UI_SCALE, 0, 256);	
				}
		
				setHSV();
				
				if(palette_display) {
					current_color = disp_mode == 0? surface_getpixel(color_surface, sat, 256 - val) : 
													surface_getpixel(color_surface, hue, sat);
					if(onApply != noone) onApply(current_color);
				}
				
				if(mouse_release(mb_left))
					area_dragging  = false;
			}
		#endregion
		
		#region type
			var tx = hue_x + ui(36);
			var ty = _y + ui(4);
			
			scr_disp.setFocusHover(focus, hover);
			scr_disp.draw(tx, ty, ui(190), ui(32), disp_mode, mouse_ui);
		#endregion
		
		#region register
			scr_disp.register();
			
			tb_hue.register();
			tb_sat.register();
			tb_val.register();
			
			tb_red.register();
			tb_green.register();
			tb_blue.register();
			
			tb_hex.register();
		#endregion
		
		#region data
			var data_x = hue_x + ui(40);
			var data_y = col_y + ui(40);
	
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(data_x, data_y + ui(36 * 0 + 15), "H");
			draw_text(data_x, data_y + ui(36 * 1 + 15), "S")
			draw_text(data_x, data_y + ui(36 * 2 + 15), "V");
	
			tb_hue.setFocusHover(focus, hover);
			tb_sat.setFocusHover(focus, hover);
			tb_val.setFocusHover(focus, hover);
	
			tb_hue.draw(data_x + ui(28), data_y + ui(36 * 0), ui(160), ui(30), round(color_get_hue(current_color)),			mouse_ui);
			tb_sat.draw(data_x + ui(28), data_y + ui(36 * 1), ui(160), ui(30), round(color_get_saturation(current_color)),	mouse_ui);
			tb_val.draw(data_x + ui(28), data_y + ui(36 * 2), ui(160), ui(30), round(color_get_value(current_color)),		mouse_ui);
	
			data_y = data_y + ui(36 * 3 + 8);
	
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(data_x, data_y + ui(36 * 0 + 15), "R");
			draw_text(data_x, data_y + ui(36 * 1 + 15), "G");
			draw_text(data_x, data_y + ui(36 * 2 + 15), "B");
			
			tb_red.setFocusHover(focus, hover);
			tb_green.setFocusHover(focus, hover);
			tb_blue.setFocusHover(focus, hover);
			
			tb_red.draw  (data_x + ui(28), data_y + ui(36 * 0), ui(160), ui(30), color_get_red(current_color),   mouse_ui);
			tb_green.draw(data_x + ui(28), data_y + ui(36 * 1), ui(160), ui(30), color_get_green(current_color), mouse_ui);
			tb_blue.draw (data_x + ui(28), data_y + ui(36 * 2), ui(160), ui(30), color_get_blue(current_color),  mouse_ui);
			
			tb_hex.active  = focus;  tb_hex.hover  = hover;
			tb_hex.draw(hue_x - ui(128), col_y + ui(256 + 24), ui(108), TEXTBOX_HEIGHT, color_get_hex(current_color),  mouse_ui);
		#endregion
		
		var cx = col_x + ui(16);
		var cy = col_y + ui(296);
	
		draw_sprite_stretched_ext(THEME.color_picker_box, 0, cx - ui(20), cy - ui(20), ui(40), ui(40), COLORS._main_icon_dark, 1);
		draw_sprite_stretched_ext(THEME.color_picker_box, 1, cx - ui(18), cy - ui(18), ui(36), ui(36), current_color, 1);
		
		cx += ui(48);
		if(buttonInstant(THEME.button_hide, cx - ui(18), cy - ui(18), ui(36), ui(36), mouse_ui, focus, hover, "", THEME.color_picker_dropper, 0, c_white) == 2)
			dropper_active = true;
	}
}
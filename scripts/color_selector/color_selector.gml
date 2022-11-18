function colorSelector(onApply = noone) constructor {
	self.onApply = onApply;
	
	current_color = c_white;
	
	hue           = 1;
	hue_dragging  = false;
	
	sat           = 0;
	
	val           = 0;
	value_draggin = false;
	
	dropper_active = false;
	dropper_color  = c_white;
	
	color_surface = surface_create_valid(ui(256), ui(256));
	
	tb_hue = new textBox(TEXTBOX_INPUT.number, function(str) {
		if(str == "") return;
		hue = clamp(real(str), 0, 255);
		setHSV();
	})
	tb_sat = new textBox(TEXTBOX_INPUT.number, function(str) {
		if(str == "") return;
		sat = clamp(real(str), 0, 255);
		setHSV();
	})
	tb_val= new textBox(TEXTBOX_INPUT.number, function(str) {
		if(str == "") return;
		val = clamp(real(str), 0, 255);
		setHSV();
	})
	
	tb_red = new textBox(TEXTBOX_INPUT.number, function(str) {
		if(str == "") return;
		var r = clamp(real(str), 0, 255);
		var g = color_get_green(current_color);
		var b = color_get_blue(current_color);
		
		current_color = make_color_rgb(r, g, b);
		resetHSV();
	})
	tb_green = new textBox(TEXTBOX_INPUT.number, function(str) {
		if(str == "") return;
		var r = color_get_red(current_color);
		var g = clamp(real(str), 0, 255);
		var b = color_get_blue(current_color);
		
		current_color = make_color_rgb(r, g, b);
		resetHSV();
	})
	tb_blue = new textBox(TEXTBOX_INPUT.number, function(str) {
		if(str == "") return;
		var r = color_get_red(current_color);
		var g = color_get_green(current_color);
		var b = clamp(real(str), 0, 255);
		
		current_color = make_color_rgb(r, g, b);
		resetHSV();
	})
	
	tb_hex = new textBox(TEXTBOX_INPUT.text, function(str) {
		if(str == "") return;
		if(string_char_at(str, 1) == "#") str = string_replace(str, "#", "");
		
		var _r = string_hexadecimal(string_copy(str, 1, 2));
		var _g = string_hexadecimal(string_copy(str, 3, 2));
		var _b = string_hexadecimal(string_copy(str, 5, 2));
		
		current_color = make_color_rgb(_r, _g, _b);
		resetHSV();
	})

	function resetHSV() {
		hue = round(color_get_hue(current_color));
		sat = round(color_get_saturation(current_color));
		val = round(color_get_value(current_color));
	}
	function setHSV() {
		current_color     = make_color_hsv(hue, sat, val);	
		onApply(current_color);
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
		if(mouse_check_button_pressed(mb_left)) {
			setColor(dropper_color);
			if(dropper_active == true) {
				onApply(current_color);
				instance_destroy(instance);
			}
			dropper_active = false;	
			resetHSV();
		}
		
		if(mouse_check_button_pressed(mb_right))
			if(dropper_active == true) instance_destroy(instance);
		
		var dx = mouse_mx + ui(36);
		var dy = mouse_my + ui(36);
		draw_sprite_stretched(THEME.color_picker_sample, 0, dx - ui(20), dy - ui(20), ui(40), ui(40));
		draw_sprite_stretched_ext(THEME.color_picker_sample, 0, dx - ui(18), dy - ui(18), ui(36), ui(36), dropper_color, 1);
	}
	
	static draw = function(col_x, col_y, focus, hover) {
		draw_sprite_stretched(THEME.ui_panel_bg, 0, col_x - ui(8), col_y - ui(8), ui(256 + 16), ui(256 + 16));
	
		if(!is_surface(color_surface)) color_surface = surface_create_valid(ui(256), ui(256));
		surface_set_target(color_surface);			
		draw_sprite_uniform(s_fx_pixel, 0, 0, 0, ui(256));
		surface_reset_target();
	
		shader_set(sh_color_picker);
		var h = shader_get_uniform(sh_color_picker, "hue");
		shader_set_uniform_f(h, hue / 256);
			
		draw_surface_safe(color_surface, col_x, col_y);
		shader_reset();
		
		#region hue
			var hue_x = col_x + ui(280);
			var hue_y = col_y;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 0, hue_x - ui(8), hue_y - ui(8), ui(32), ui(256 + 16));
		
			for(var i = 0; i < 256; i++) {
				draw_set_color(make_color_hsv(i, 255, 255));
				draw_rectangle(hue_x, hue_y + ui(i), hue_x + ui(16), hue_y + ui(i + 1), false);
			}
		
			var hy = hue_y + ui(hue);
			draw_sprite_stretched_ext(s_ui_base_white, 0, hue_x - ui(3), hy - ui(6), ui(24), ui(10), make_color_hsv(hue, 255, 255), 1);
			draw_sprite_stretched_ext(s_ui_base_white, 0, col_x + ui(sat - 6), col_y + ui(256 - val - 6), ui(12), ui(12), current_color, 1);
	
			if(focus) {
				if(mouse_check_button_pressed(mb_left)) {
					if(point_in_rectangle(mouse_mx, mouse_my, hue_x, hue_y, hue_x + ui(16), hue_y + ui(256))) {
						hue_dragging = true;
					} else if(point_in_rectangle(mouse_mx, mouse_my, col_x, col_y, col_x + ui(256), col_y + ui(256))) {
						value_draggin = true;
					}
				}
			}
	
			if(hue_dragging) {
				hue = clamp((mouse_my - hue_y) / UI_SCALE, 0, 256);
				setHSV();
			
				if(mouse_check_button_released(mb_left))
					hue_dragging  = false;
			}
		
			if(value_draggin) {
				sat     = clamp((mouse_mx - col_x) / UI_SCALE, 0, 256);
				val     = 256 - clamp((mouse_my - col_y) / UI_SCALE, 0, 256);
				setHSV();
		
				if(mouse_check_button_released(mb_left))
					value_draggin  = false;
			}
		#endregion
		
		#region data
			var data_x = hue_x + ui(40);
			var data_y = col_y;
	
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(data_x, data_y + ui(40 * 0 + 17), "Hue");
			draw_text(data_x, data_y + ui(40 * 1 + 17), "Saturation")
			draw_text(data_x, data_y + ui(40 * 2 + 17), "Value");
	
			tb_hue.active = focus; tb_hue.hover = hover;
			tb_sat.active = focus; tb_sat.hover = hover;
			tb_val.active = focus; tb_val.hover = hover;
	
			tb_hue.draw(data_x + ui(80), data_y + ui(44 * 0), ui(100), TEXTBOX_HEIGHT, round(color_get_hue(current_color)),			mouse_ui);
			tb_sat.draw(data_x + ui(80), data_y + ui(44 * 1), ui(100), TEXTBOX_HEIGHT, round(color_get_saturation(current_color)),	mouse_ui);
			tb_val.draw(data_x + ui(80), data_y + ui(44 * 2), ui(100), TEXTBOX_HEIGHT, round(color_get_value(current_color)),		mouse_ui);
	
			data_y = data_y + ui(44 * 3 + 8);
	
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(data_x, data_y + ui(40 * 0 + 17), "Red");
			draw_text(data_x, data_y + ui(40 * 1 + 17), "Green");
			draw_text(data_x, data_y + ui(40 * 2 + 17), "Blue");
			
			tb_red.active   = focus; tb_red.hover   = hover;
			tb_green.active = focus; tb_green.hover = hover;
			tb_blue.active  = focus; tb_blue.hover  = hover;
			
			tb_red.draw  (data_x + ui(80), data_y + ui(44 * 0), ui(100), TEXTBOX_HEIGHT, color_get_red(current_color),   mouse_ui);
			tb_green.draw(data_x + ui(80), data_y + ui(44 * 1), ui(100), TEXTBOX_HEIGHT, color_get_green(current_color), mouse_ui);
			tb_blue.draw (data_x + ui(80), data_y + ui(44 * 2), ui(100), TEXTBOX_HEIGHT, color_get_blue(current_color),  mouse_ui);
			
			tb_hex.active  = focus;  tb_hex.hover  = hover;
			tb_hex.draw(hue_x - ui(128), data_y + ui(140), ui(108), TEXTBOX_HEIGHT, color_get_hex(current_color),  mouse_ui);
		#endregion
		
		var cx = col_x + ui(16);
		var cy = col_y + ui(296);
	
		draw_sprite_stretched(THEME.color_picker_sample, 0, cx - ui(20), cy - ui(20), ui(40), ui(40));
		draw_sprite_stretched_ext(THEME.color_picker_sample, 0, cx - ui(18), cy - ui(18), ui(36), ui(36), current_color, 1);
		
		cx += ui(48);
		if(buttonInstant(THEME.button_hide, cx - ui(18), cy - ui(18), ui(36), ui(36), mouse_ui, focus, hover, "", THEME.color_picker_dropper, 0, c_white) == 2) {
			dropper_active = true;
		}
	}
}
/// @description init
if !ready exit;

#region dropper
	if(dropper_active) {
		if(mouse_check_button_pressed(mb_left)) {
			current_color  = dropper_color;
			dropper_active = false;	
			resetHSV();
		}
		
		if(mouse_check_button_pressed(mb_right)) {
			if(dropper_active == 2) instance_destroy();
		}
		
		var dx = mouse_mx + 36;
		var dy = mouse_my + 36;
		draw_sprite_stretched(s_color_picker_sample, 0, dx - 20, dy - 20, 40, 40);
		draw_sprite_stretched_ext(s_color_picker_sample, 0, dx - 18, dy - 18, 36, 36, dropper_color, 1);
		
		exit;
	}
#endregion

#region base UI
	var presets_x  = dialog_x;
	var presets_w  = 240;
	
	var content_x = dialog_x + presets_w + 16;
	var content_w = dialog_w - presets_w - 16;
	
	draw_sprite_stretched(s_dialog_bg, 0, presets_x, dialog_y, presets_w, dialog_h);
	if(FOCUS == self) draw_sprite_stretched(s_dialog_active, 0, presets_x, dialog_y, presets_w, dialog_h);
	
	draw_sprite_stretched(s_dialog_bg, 0, content_x, dialog_y, content_w, dialog_h);
	if(FOCUS == self) draw_sprite_stretched(s_dialog_active, 0, content_x, dialog_y, content_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(presets_x + 24, dialog_y + 24, "Presets");
	draw_text(content_x + 24, dialog_y + 24, name);
#endregion

#region presets
	draw_sprite_stretched(s_ui_panel_bg, 0, presets_x + 16, dialog_y + 44, 240 - 32, dialog_h - 44 - 16);
	
	sp_presets.active = FOCUS == self;
	sp_presets.draw(presets_x + 16 + 8, dialog_y + 44);
	
	var bx = presets_x + presets_w - 16 - 28;
	var by = dialog_y + 12;
	
	var _b = buttonInstant(s_button_hide, bx, by, 28, 28, [mouse_mx, mouse_my], FOCUS == self, HOVER == self);
	if(_b) TOOLTIP = "Add to preset";
	
	if(_b == 2) {
		var dia = dialogCall(o_dialog_file_name, mouse_mx + 8, mouse_my + 8);
		dia.onModify = function (txt) {
			var file = file_text_open_write(txt + ".txt");
			for(var i = 0; i < ds_list_size(gradient); i++) {
				var gr = gradient[| i];
				var cc = gr.value;
				var tt = gr.time;
				
				file_text_write_string(file, cc);
				file_text_writeln(file);
				
				file_text_write_string(file, tt);
				file_text_writeln(file);
			}
			file_text_close(file);
			presetCollect();
		};
		dia.path = DIRECTORY + "Gradients/"
	}
	draw_sprite_ext(s_add_24, 0, bx + 14, by + 14, 1, 1, 0, c_ui_blue_grey, 1);
	bx -= 32;
	
	if(buttonInstant(s_button_hide, bx, by, 28, 28, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, "Refresh", s_refresh_24) == 2)
		presetCollect();
	bx -= 32;
	
	if(buttonInstant(s_button_hide, bx, by, 28, 28, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, "Open gradient folder", s_folder_24) == 2) {
		var _realpath = environment_get_variable("LOCALAPPDATA") + "\\Pixels_Composer\\Gradients";
		var _windir   = environment_get_variable("WINDIR") + "\\explorer.exe";
		execute_shell(_windir, _realpath);
	}
	bx -= 32;
#endregion

#region gradient
	var gr_x = content_x + 22;
	var gr_y = dialog_y + 54;
	var gr_w = content_w - 44;
	var gr_h = 20;
	
	#region tools
		var bx = content_x + content_w - 22 - 28;
		var by = dialog_y + 16;
		
		if(buttonInstant(s_button_hide, bx, by, 28, 28, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, "Key blending", s_grad_blend) == 2) {
			if(grad_data != noone)
				grad_data[| 0] = !grad_data[| 0];
		}
		bx -= 32;
	#endregion
	
	draw_sprite_stretched(s_textbox, 0, gr_x - 6, gr_y - 6, gr_w + 12, gr_h + 12);
	draw_gradient(gr_x, gr_y, gr_w, gr_h, gradient, grad_data[| 0]);
	
	var hover = noone;
	for(var i = 0; i < ds_list_size(gradient); i++) {
		var _k  = gradient[| i];
		var _kx = gr_x + _k.time * gr_w; 
		var _in = _k == key_selecting? 1 : 0;
		
		draw_sprite_ext(s_prop_gradient, _in, _kx, gr_y + gr_h / 2, 1, 1, 0, c_white, 1);
		
		if(HOVER == self && point_in_rectangle(mouse_mx, mouse_my, _kx - 6, gr_y, _kx + 6, gr_y + gr_h)) {
			draw_sprite_ext(s_prop_gradient, _in, _kx, gr_y + gr_h / 2, 1.2, 1.2, 0, c_white, 1);
			hover = _k;
		}
	}
	
	if(key_dragging) {
		var tt = clamp((mouse_mx - gr_x) / gr_w, 0, 1);
		key_dragging.time = tt;
		
		var _index = ds_list_find_index(gradient, key_dragging);
		ds_list_delete(gradient, _index);
		gradient_add(gradient, key_dragging, false);
		
		if(mouse_check_button_released(mb_left)) {
			var _index = ds_list_find_index(gradient, key_dragging);
			ds_list_delete(gradient, _index);
			gradient_add(gradient, key_dragging, true);
			
			key_dragging = noone;	
		}
	}
	
	if(FOCUS == self) {
		if(point_in_rectangle(mouse_mx, mouse_my, gr_x - 6, gr_y - 6, gr_x + gr_w + 12, gr_y + gr_h + 12)) {
			if(mouse_check_button_pressed(mb_left)) {
				if(hover) {
					key_selecting = hover;
					key_dragging  = hover;
					
					current_color = key_dragging.value;
					resetHSV();
				} else {
					key_selecting = noone;
				
					var tt = clamp((mouse_mx - gr_x) / gr_w, 0, 1);
					var cc = gradient_eval(gradient, tt);
					var _newkey = new valueKey(tt, cc);
					gradient_add(gradient, _newkey, true);
					
					key_selecting  = _newkey;
					key_dragging   = _newkey;
					
					current_color = key_dragging.value;
					resetHSV();
				}
			}
			
			if(mouse_check_button_pressed(mb_right)) {
				if(hover && ds_list_size(gradient) > 1) {
					var _index = ds_list_find_index(gradient, hover);
					ds_list_delete(gradient, _index);
				}	
			}
		}
	}
#endregion

#region color surface
	var col_x = content_x + 20;
	var col_y = dialog_y + 96;
	
	draw_sprite_stretched(s_ui_panel_bg, 0, col_x - 8, col_y - 8, 256 + 16, 256 + 16);
	
	if(!is_surface(color_surface)) color_surface = surface_create(256, 256);
	surface_set_target(color_surface);			
		draw_sprite_ext(s_fx_pixel, 0, 0, 0, 256, 256, 0, c_white, 1);
	surface_reset_target();
	
	shader_set(sh_color_picker);
		var h = shader_get_uniform(sh_color_picker, "hue");
		shader_set_uniform_f(h, hue / 256);
		
		draw_surface_safe(color_surface, col_x, col_y);
	shader_reset();
#endregion

#region selector
	var hue_x = content_x + 300;
	var hue_y = col_y;
	
	draw_sprite_stretched(s_ui_panel_bg, 0, hue_x - 8, hue_y - 8, 32, 256 + 16);
	
	for(var i = 0; i < 256; i++) {
		draw_set_color(make_color_hsv(i, 255, 255));
		draw_rectangle(hue_x, hue_y + i, hue_x + 16, hue_y + i + 1, false);
	}
		
	var hy = hue_y + hue;
	draw_sprite_stretched_ext(s_ui_base_white, 0, hue_x - 3, hy - 6, 24, 10, make_color_hsv(hue, 255, 255), 1);
	draw_sprite_stretched_ext(s_ui_base_white, 0, col_x + sat - 6, col_y + 256 - val - 6, 12, 12, current_color, 1);
	
	if(FOCUS == self) {
		if(mouse_check_button_pressed(mb_left)) {
			if(point_in_rectangle(mouse_mx, mouse_my, hue_x, hue_y, hue_x + 16, hue_y + 256)) {
				hue_dragging = true;
			} else if(point_in_rectangle(mouse_mx, mouse_my, col_x, col_y, col_x + 256, col_y + 256)) {
				value_draggin = true;
			}
		}
	}
	
	if(hue_dragging) {
		hue = clamp(mouse_my - hue_y, 0, 256);
		setHSV();
			
		if(mouse_check_button_released(mb_left))
			hue_dragging  = false;
	}
	
	if(value_draggin) {
		var smx = mouse_mx - col_x;
		var smy = mouse_my - col_y;
			
		sat     = clamp(smx, 0, 256);
		val     = 256 - clamp(smy, 0, 256);
		setHSV();
			
		if(mouse_check_button_released(mb_left))
			value_draggin  = false;
	}
#endregion

#region data
	var data_x = hue_x + 40;
	var data_y = col_y;
	
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(data_x, data_y + 40 * 0 + 17, "Hue");
	draw_text(data_x, data_y + 40 * 1 + 17, "Saturation")
	draw_text(data_x, data_y + 40 * 2 + 17, "Value");
	
	tb_hue.active = FOCUS == self; tb_hue.hover = HOVER == self;
	tb_sat.active = FOCUS == self; tb_sat.hover = HOVER == self;
	tb_val.active = FOCUS == self; tb_val.hover = HOVER == self;
	
	tb_hue.draw(data_x + 80, data_y + 44 * 0, 100, 34, round(color_get_hue(current_color)),			[mouse_mx, mouse_my]);
	tb_sat.draw(data_x + 80, data_y + 44 * 1, 100, 34, round(color_get_saturation(current_color)),	[mouse_mx, mouse_my]);
	tb_val.draw(data_x + 80, data_y + 44 * 2, 100, 34, round(color_get_value(current_color)),		[mouse_mx, mouse_my]);
	
	data_y = data_y + 44 * 3 + 8;
	
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(data_x, data_y + 40 * 0 + 17, "Red");
	draw_text(data_x, data_y + 40 * 1 + 17, "Green");
	draw_text(data_x, data_y + 40 * 2 + 17, "Blue");
	
	tb_red.active   = FOCUS == self; tb_red.hover   = HOVER == self;
	tb_green.active = FOCUS == self; tb_green.hover = HOVER == self;
	tb_blue.active  = FOCUS == self; tb_blue.hover  = HOVER == self;
	
	tb_red.draw  (data_x + 80, data_y + 44 * 0, 100, 34, color_get_red(current_color),   [mouse_mx, mouse_my]);
	tb_green.draw(data_x + 80, data_y + 44 * 1, 100, 34, color_get_green(current_color), [mouse_mx, mouse_my]);
	tb_blue.draw (data_x + 80, data_y + 44 * 2, 100, 34, color_get_blue(current_color),  [mouse_mx, mouse_my]);

	tb_hex.active  = FOCUS == self;  tb_hex.hover  = HOVER == self;
	
	tb_hex.draw(hue_x - 108 - 20, data_y + 44 * 3, 108, 34, color_get_hex(current_color),  [mouse_mx, mouse_my]);
#endregion

#region controls
	var cx = content_x + 36;
	var cy = dialog_y + dialog_h - 36;
	
	draw_sprite_stretched(s_color_picker_sample, 0, cx - 20, cy - 20, 40, 40);
	draw_sprite_stretched_ext(s_color_picker_sample, 0, cx - 18, cy - 18, 36, 36, current_color, 1);
	
	var bx = content_x + content_w - 36;
	var by = dialog_y + dialog_h - 36;
	if(buttonInstant(s_button_lime, bx - 18, by - 18, 36, 36, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, "", s_icon_accept_24, 0, c_ui_blue_black) == 2) {
		onApply();
		instance_destroy();
	}
		
	var bx = content_x + 80;
	var by = dialog_y + dialog_h - 36;
	if(buttonInstant(s_button_hide, bx - 18, by - 18, 36, 36, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, "", s_color_picker_dropper, 0, c_white) == 2) {
		dropper_active = true;
	}
#endregion
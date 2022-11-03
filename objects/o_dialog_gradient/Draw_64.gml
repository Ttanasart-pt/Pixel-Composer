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
		
		var dx = mouse_mx + ui(36);
		var dy = mouse_my + ui(36);
		draw_sprite_stretched(s_color_picker_sample, 0, dx - ui(20), dy - ui(20), ui(40), ui(40));
		draw_sprite_stretched_ext(s_color_picker_sample, 0, dx - ui(18), dy - ui(18), ui(36), ui(36), dropper_color, 1);
		
		exit;
	}
#endregion

#region base UI
	var presets_x  = dialog_x;
	var presets_w  = ui(240);
	
	var content_x = dialog_x + presets_w + ui(16);
	var content_w = dialog_w - presets_w - ui(16);
	
	draw_sprite_stretched(s_dialog_bg, 0, presets_x, dialog_y, presets_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched(s_dialog_active, 0, presets_x, dialog_y, presets_w, dialog_h);
	
	draw_sprite_stretched(s_dialog_bg, 0, content_x, dialog_y, content_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched(s_dialog_active, 0, content_x, dialog_y, content_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(presets_x + ui(24), dialog_y + ui(16), "Presets");
	draw_text(content_x + ui(24), dialog_y + ui(16), name);
#endregion

#region presets
	draw_sprite_stretched(s_ui_panel_bg, 0, presets_x + ui(16), dialog_y + ui(44), ui(240 - 32), dialog_h - ui(60));
	
	sp_presets.active = sFOCUS;
	sp_presets.draw(presets_x + ui(16 + 8), dialog_y + ui(44));
	
	var bx = presets_x + presets_w - ui(44);
	var by = dialog_y + ui(12);
	
	var _b = buttonInstant(s_button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER);
	if(_b) TOOLTIP = "Add to preset";
	
	if(_b == 2) {
		var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
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
	draw_sprite_ui_uniform(s_add_24, 0, bx + ui(14), by + ui(14), 1, c_ui_blue_grey);
	bx -= ui(32);
	
	if(buttonInstant(s_button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, "Refresh", s_refresh_24) == 2)
		presetCollect();
	bx -= ui(32);
	
	if(buttonInstant(s_button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, "Open gradient folder", s_folder_24) == 2) {
		var _realpath = environment_get_variable("LOCALAPPDATA") + "\\Pixels_Composer\\Gradients";
		var _windir   = environment_get_variable("WINDIR") + "\\explorer.exe";
		execute_shell(_windir, _realpath);
	}
	bx -= ui(32);
#endregion

#region gradient
	var gr_x = content_x + ui(22);
	var gr_y = dialog_y + ui(54);
	var gr_w = content_w - ui(44);
	var gr_h = ui(20);
	
	#region tools
		var bx = content_x + content_w - ui(50);
		var by = dialog_y + ui(16);
		
		if(buttonInstant(s_button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, "Key blending", s_grad_blend) == 2) {
			if(grad_data != noone)
				grad_data[| 0] = !grad_data[| 0];
		}
		bx -= ui(32);
	#endregion
	
	draw_sprite_stretched(s_textbox, 0, gr_x - ui(6), gr_y - ui(6), gr_w + ui(12), gr_h + ui(12));
	draw_gradient(gr_x, gr_y, gr_w, gr_h, gradient, grad_data[| 0]);
	
	var hover = noone;
	for(var i = 0; i < ds_list_size(gradient); i++) {
		var _k  = gradient[| i];
		var _kx = gr_x + _k.time * gr_w; 
		var _in = _k == key_selecting? 1 : 0;
		
		draw_sprite_ui_uniform(s_prop_gradient, _in, _kx, gr_y + gr_h / 2, 1);
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, _kx - ui(6), gr_y, _kx + ui(6), gr_y + gr_h)) {
			draw_sprite_ui_uniform(s_prop_gradient, _in, _kx, gr_y + gr_h / 2, 1.2);
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
	
	if(sFOCUS) {
		if(point_in_rectangle(mouse_mx, mouse_my, gr_x - ui(6), gr_y - ui(6), gr_x + gr_w + ui(12), gr_y + gr_h + ui(12))) {
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
	var col_x = content_x + ui(20);
	var col_y = dialog_y + ui(96);
	
	draw_sprite_stretched(s_ui_panel_bg, 0, col_x - ui(8), col_y - ui(8), ui(256 + 16), ui(256 + 16));
	
	if(!is_surface(color_surface)) color_surface = surface_create_valid(ui(256), ui(256));
	surface_set_target(color_surface);			
		draw_sprite_ext(s_fx_pixel, 0, 0, 0, ui(256), ui(256), 0, c_white, 1);
	surface_reset_target();
	
	shader_set(sh_color_picker);
		var h = shader_get_uniform(sh_color_picker, "hue");
		shader_set_uniform_f(h, hue / 256);
		
		draw_surface_safe(color_surface, col_x, col_y);
	shader_reset();
#endregion

#region selector
	var hue_x = content_x + ui(300);
	var hue_y = col_y;
	
	draw_sprite_stretched(s_ui_panel_bg, 0, hue_x - ui(8), hue_y - ui(8), ui(32), ui(256 + 16));
	
	for(var i = 0; i < 256; i++) {
		draw_set_color(make_color_hsv(i, 255, 255));
		draw_rectangle(hue_x, hue_y + ui(i), hue_x + ui(16), hue_y + ui(i + 1), false);
	}
		
	var hy = hue_y + ui(hue);
	draw_sprite_stretched_ext(s_ui_base_white, 0, hue_x - ui(3), hy - ui(6), ui(24), ui(10), make_color_hsv(hue, 255, 255), 1);
	draw_sprite_stretched_ext(s_ui_base_white, 0, col_x + ui(sat - 6), col_y + ui(256 - val - 6), ui(12), ui(12), current_color, 1);
	
	if(sFOCUS) {
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
	
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(data_x, data_y + ui(40 * 0 + 17), "Hue");
	draw_text(data_x, data_y + ui(40 * 1 + 17), "Saturation")
	draw_text(data_x, data_y + ui(40 * 2 + 17), "Value");
	
	tb_hue.active = sFOCUS; tb_hue.hover = sHOVER;
	tb_sat.active = sFOCUS; tb_sat.hover = sHOVER;
	tb_val.active = sFOCUS; tb_val.hover = sHOVER;
	
	tb_hue.draw(data_x + ui(80), data_y + ui(44 * 0), ui(100), TEXTBOX_HEIGHT, round(color_get_hue(current_color)),			mouse_ui);
	tb_sat.draw(data_x + ui(80), data_y + ui(44 * 1), ui(100), TEXTBOX_HEIGHT, round(color_get_saturation(current_color)),	mouse_ui);
	tb_val.draw(data_x + ui(80), data_y + ui(44 * 2), ui(100), TEXTBOX_HEIGHT, round(color_get_value(current_color)),		mouse_ui);
	
	data_y = data_y + ui(44 * 3 + 8);
	
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(data_x, data_y + ui(40 * 0 + 17), "Red");
	draw_text(data_x, data_y + ui(40 * 1 + 17), "Green");
	draw_text(data_x, data_y + ui(40 * 2 + 17), "Blue");
	
	tb_red.active   = sFOCUS; tb_red.hover   = sHOVER;
	tb_green.active = sFOCUS; tb_green.hover = sHOVER;
	tb_blue.active  = sFOCUS; tb_blue.hover  = sHOVER;
	
	tb_red.draw  (data_x + ui(80), data_y + ui(44 * 0), ui(100), TEXTBOX_HEIGHT, color_get_red(current_color),   mouse_ui);
	tb_green.draw(data_x + ui(80), data_y + ui(44 * 1), ui(100), TEXTBOX_HEIGHT, color_get_green(current_color), mouse_ui);
	tb_blue.draw (data_x + ui(80), data_y + ui(44 * 2), ui(100), TEXTBOX_HEIGHT, color_get_blue(current_color),  mouse_ui);

	tb_hex.active  = sFOCUS;  tb_hex.hover  = sHOVER;
	
	tb_hex.draw(hue_x - ui(128), data_y + ui(44 * 3), ui(108), TEXTBOX_HEIGHT, color_get_hex(current_color),  mouse_ui);
#endregion

#region controls
	var cx = content_x + ui(36);
	var cy = dialog_y + dialog_h - ui(36);
	
	draw_sprite_stretched(s_color_picker_sample, 0, cx - ui(20), cy - ui(20), ui(40), ui(40));
	draw_sprite_stretched_ext(s_color_picker_sample, 0, cx - ui(18), cy - ui(18), ui(36), ui(36), current_color, 1);
	
	var bx = content_x + content_w - ui(36);
	var by = dialog_y + dialog_h - ui(36);
	if(buttonInstant(s_button_lime, bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, sFOCUS, sHOVER, "", s_icon_accept_24, 0, c_ui_blue_black) == 2) {
		onApply();
		instance_destroy();
	}
		
	var bx = content_x + ui(80);
	var by = dialog_y + dialog_h - ui(36);
	if(buttonInstant(s_button_hide, bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, sFOCUS, sHOVER, "", s_color_picker_dropper, 0, c_white) == 2) {
		dropper_active = true;
	}
#endregion
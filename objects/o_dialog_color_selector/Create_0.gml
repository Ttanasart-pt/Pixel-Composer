/// @description init
event_inherited();

#region data
	dialog_w = 240 + 16 + 540;
	dialog_h = 380;
	destroy_on_click_out = true;
	
	name = "Color selector";
	
	current_color = c_white;
	
	hue           = 1;
	hue_dragging  = false;
	value_draggin = false;
	
	sat           = 0;
	val           = 0;
	color_surface = surface_create(256, 256);
	
	onApply = -1;
	
	function resetHSV() {
		hue = round(color_get_hue(current_color));
		sat = round(color_get_saturation(current_color));
		val = round(color_get_value(current_color));
	}
	function setHSV() {
		current_color     = make_color_hsv(hue, sat, val);	
	}
	resetHSV();
		
	dropper_active = false;
	dropper_color  = c_white;
#endregion

#region textbox
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
#endregion

#region presets
	presets		= ds_list_create();
	preset_name = ds_list_create();
	preset_selecting = -1;
	
	function presetCollect() {
		ds_list_clear(presets);
		ds_list_clear(preset_name);
		
		var path = DIRECTORY + "Palettes/"
		var file = file_find_first(path + "*", 0);
		while(file != "") {
			ds_list_add(presets,		loadPalette(path + file));
			ds_list_add(preset_name,	filename_name(file));
			file = file_find_next();
		}
		file_find_close();
	}
	presetCollect();
	
	sp_preset_w = 240 - 32 - 16;
	sp_preset_size = 24;
	click_block = false;
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - 44 - 18, function(_y, _m) {
		var ww  = sp_preset_w - 32 - 8;
		var hh  = 32;
		var _gs = sp_preset_size;
		var yy  = _y + 8;
		var _height, pre_amo;
		draw_clear_alpha(c_ui_blue_black, 0);
		
		for(var i = 0; i < ds_list_size(presets); i++) {
			pre_amo = array_length(presets[| i]);
			var col = floor(ww / _gs);
			var row = ceil(pre_amo / col);
			
			if(preset_selecting == i)
				_height = 28 + row * _gs + 12;
			else
				_height = 52;
			
			draw_sprite_stretched(s_ui_panel_bg, 1, 4, yy, sp_preset_w - 16, _height);
			
			draw_set_text(f_p2, fa_left, fa_top, c_ui_blue_ltgrey);
			draw_text(16, yy + 8, preset_name[| i]);
			if(preset_selecting == i)
				drawPaletteGrid(presets[| i], 16, yy + 28, ww, _gs, current_color);
			else
				drawPalette(presets[| i], 16, yy + 24, ww, 20);
			
			if(FOCUS == self) {
				if(!click_block && mouse_check_button(mb_left)) {
					if(preset_selecting == i) {
						if(point_in_rectangle(_m[0], _m[1], 16, yy + 28, 16 + ww, yy + 28 + _height)) {
							var m_ax = _m[0] - 16;
							var m_ay = _m[1] - (yy + 28);
					
							var m_gx = floor(m_ax / _gs);
							var m_gy = floor(m_ay / _gs);
					
							var _index = clamp(m_gy * col + m_gx, 0, pre_amo - 1);
							current_color = presets[| i][_index];
							resetHSV();
						} 
					} else if(point_in_rectangle(_m[0], _m[1], 4, yy, 4 + sp_preset_w - 16, yy + _height)) {
						preset_selecting = i;
						click_block = true;
					}
				}	
			}
			
			yy += _height + 4;
			hh += _height + 4;
		}
		
		if(mouse_check_button_released(mb_left))
			click_block = false;
		
		return hh;
	})
#endregion
/// @description init
event_inherited();

#region data
	dialog_w = 240 + 16 + 540;
	dialog_h = 428;
	
	name = "Gradient editor";
	gradient = noone;
	grad_data = noone;
	
	key_selecting = noone;
	key_dragging  = noone;
	key_drag_sx   = 0;
	key_drag_mx   = 0;
	
	current_color = 0;
	
	hue           = 1;
	hue_dragging  = false;
	value_draggin = false;
	
	sat           = 0;
	val           = 0;
	color_surface = surface_create(256, 256);
	
	onApply = -1;
	
	destroy_on_click_out = true;
	
	function resetHSV() {
		hue = color_get_hue(current_color);	
		sat = color_get_saturation(current_color);	
		val = color_get_value(current_color);	
		setColor();
	}
	function setHSV() {		
		current_color = make_color_hsv(hue, sat, val);
		setColor();
	}
	function setColor() {
		if(key_selecting == noone) return;
		show_debug_message("set")
		key_selecting.value = current_color;
	}
	function setGradient(grad, data) {
		gradient = grad;	
		grad_data = data;
		if(!ds_list_empty(grad))
			key_selecting = grad[| 0];
	}
	
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

#region preset
	function loadGradient(path) {
		var grad = ds_list_create();
		
		if(path != "" && file_exists(path)) {
			var _t = file_text_open_read(path);
			while(!file_text_eof(_t)) {
				var _col = toNumber(file_text_readln(_t));
				var _pos = toNumber(file_text_readln(_t));
				
				ds_list_add(grad, new valueKey(_pos, _col));
			}
			file_text_close(_t);
		}
		return grad;
	}
	
	presets		= ds_list_create();
	preset_name = ds_list_create();
	
	function presetCollect() {
		ds_list_clear(presets);
		ds_list_clear(preset_name);
		
		var path = DIRECTORY + "Gradients/"
		var file = file_find_first(path + "*", 0);
		while(file != "") {
			ds_list_add(presets,		loadGradient(path + file));
			ds_list_add(preset_name,	filename_name(file));
			file = file_find_next();
		}
		file_find_close();
	}
	presetCollect();
	
	sp_preset_w = 240 - 32 - 16;
	sp_presets = new scrollPane(sp_preset_w, dialog_h - 44 - 18, function(_y, _m) {
		var ww  = sp_preset_w - 32 - 8;
		var hh = 32;
		var yy = _y + 8;
		var hg = 52;
		draw_clear_alpha(c_ui_blue_black, 0);
		
		for(var i = 0; i < ds_list_size(presets); i++) {
			draw_sprite_stretched(s_ui_panel_bg, 1, 4, yy, sp_preset_w - 16, hg);
			
			draw_set_text(f_p2, fa_left, fa_top, c_ui_blue_ltgrey);
			draw_text(16, yy + 8, preset_name[| i]);
			draw_gradient(16, yy + 24, ww, 16, presets[| i]);
			
			if(FOCUS == self && point_in_rectangle(_m[0], _m[1], 4, yy, 4 + sp_preset_w - 16, yy + hg)) {
				if(mouse_check_button_pressed(mb_left)) 
				ds_list_copy(gradient, presets[| i]);
			}
			
			yy += hg + 4;
			hh += hg + 4;
		}
		
		return hh;
	})
#endregion
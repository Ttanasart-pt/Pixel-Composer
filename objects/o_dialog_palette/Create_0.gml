/// @description init
event_inherited();

#region data
	dialog_w = ui(796);
	dialog_h = ui(432);
	destroy_on_click_out = true;
	
	name = "Palette editor";
	palette = 0;
	
	index_selecting = 0;
	index_dragging = -1;
	
	current_color = 0;
	
	hue           = 1;
	hue_dragging  = false;
	value_draggin = false;
	
	sat           = 0;
	val           = 0;
	color_surface = surface_create_valid(ui(256), ui(256));
	
	onApply = -1;
	
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
		if(index_selecting == -1 || palette == 0) return;
		palette[index_selecting] = current_color;
	}
	function setPalette(pal) {
		palette = pal;	
		index_selecting = 0;
		if(array_length(palette) > 0)
			current_color   = palette[0];
		resetHSV();
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

#region presets
	presets		= ds_list_create();
	preset_name = ds_list_create();
	
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
	
	sp_preset_w = ui(240 - 32 - 16);
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(62), function(_y, _m) {
		var ww  = sp_preset_w - ui(40);
		var hh = ui(32);
		var yy = _y + ui(8);
		var hg = ui(52);
		draw_clear_alpha(c_ui_blue_black, 0);
		
		for(var i = 0; i < ds_list_size(presets); i++) {
			draw_sprite_stretched(s_ui_panel_bg, 1, ui(4), yy, sp_preset_w - ui(16), hg);
			
			draw_set_text(f_p2, fa_left, fa_top, c_ui_blue_ltgrey);
			draw_text(ui(16), yy + ui(8), preset_name[| i]);
			drawPalette(presets[| i], ui(16), yy + ui(28), ww, ui(16));
			
			if(sFOCUS && point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_preset_w - ui(16), yy + hg)) {
				if(mouse_check_button_pressed(mb_left)) {
					palette = array_create(array_length(presets[| i]));
					for( var j = 0; j < array_length(presets[| i]); j++ ) {
						palette[j] = presets[| i][j];
					}
				}
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	})
#endregion

#region tools
	function sortPalette() {
		array_sort(palette, function(c1, c2) {
			var h1 = color_get_hue(c1);
			var h2 = color_get_hue(c2);
			
			if(h1 != h2) return h1 - h2;
			
			var r1 = color_get_red(c1);
			var g1 = color_get_green(c1);
			var b1 = color_get_blue(c1);
			var l1 = 0.299 * r1 + 0.587 * g1 + 0.114 * b1;
			
			var r2 = color_get_red(c2);
			var g2 = color_get_green(c2);
			var b2 = color_get_blue(c2);
			var l2 = 0.299 * r2 + 0.587 * g2 + 0.224 * b2;
			
			return l2 - l1;
	    });
	}
#endregion

#region resize
	onResize = function() {
		sp_presets.resize(sp_preset_w, dialog_h - ui(62));
	}
#endregion
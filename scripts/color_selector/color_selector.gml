function colorSelector(onApply = noone) constructor {
	self.onApply = onApply;
	
	current_color  = c_white;
	current_colors = noone;
	
	hue = 1;
	sat = 0;
	val = 0;
	
	area_dragging = false;
	side_dragging = false;
	
	dropper_active = false;
	dropper_close  = true;
	dropper_color  = c_white;
	interactable = true;
	
	disp_mode = 0;
	
	palette = PROJECT.attributes.palette;
	discretize_pal = true;
	
	content_surface = surface_create_valid(1, 1);
	side_surface    = surface_create_valid(1, 1);
	
	tb_hue = slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		hue = clamp(_val, 0, 255);
		setHSV();
	}).setSlideType(1);
	
	tb_sat = slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		sat = clamp(_val, 0, 255);
		setHSV();
	}).setSlideType(1);
	
	tb_val = slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		val = clamp(_val, 0, 255);
		setHSV();
	}).setSlideType(1);
	
	tb_red = slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		var r = clamp(_val, 0, 255);
		var g = color_get_green(current_color);
		var b = color_get_blue(current_color);
		var a = color_get_alpha(current_color);
		
		current_color = make_color_rgba(r, g, b, a);
		resetHSV();
	}).setSlideType(1);
	
	tb_green = slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		var r = color_get_red(current_color);
		var g = clamp(_val, 0, 255);
		var b = color_get_blue(current_color);
		var a = color_get_alpha(current_color);
		
		current_color = make_color_rgba(r, g, b, a);
		resetHSV();
	}).setSlideType(1);
	
	tb_blue = slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		var r = color_get_red(current_color);
		var g = color_get_green(current_color);
		var b = clamp(_val, 0, 255);
		var a = color_get_alpha(current_color);
		
		current_color = make_color_rgba(r, g, b, a);
		resetHSV();
	}).setSlideType(1);
	
	tb_alpha = slider(0, 255, 1, function(_val) {
		if(!interactable) return;
		var alp = clamp(_val, 0, 255);
		
		current_color = _cola(current_color, alp);
		resetHSV();
	}).setSlideType(1);
	
	tb_hue.hdw   = ui(16);
	tb_sat.hdw   = ui(16);
	tb_val.hdw   = ui(16);
	tb_red.hdw   = ui(16);
	tb_green.hdw = ui(16);
	tb_blue.hdw  = ui(16);
	tb_alpha.hdw = ui(16);
	
	tb_hue.font   = f_p1;
	tb_sat.font   = f_p1;
	tb_val.font   = f_p1;
	tb_red.font   = f_p1;
	tb_green.font = f_p1;
	tb_blue.font  = f_p1;
	tb_alpha.font = f_p1;
	
	tb_hex = new textBox(TEXTBOX_INPUT.text, function(str) {
		if(!interactable) return;
		if(str == "") return;
		if(string_char_at(str, 1) == "#") str = string_replace(str, "#", "");
		
		var _r = string_hexadecimal(string_copy(str, 1, 2));
		var _g = string_hexadecimal(string_copy(str, 3, 2));
		var _b = string_hexadecimal(string_copy(str, 5, 2));
		var _a = string_length(str) > 6? string_hexadecimal(string_copy(str, 7, 2)) : 255;
		
		current_color = make_color_rgba(_r, _g, _b, _a);
		resetHSV();
	});
	
	scr_disp = new buttonGroup(["Hue", "Value"], function(mode) { disp_mode = mode; } );
	
	function resetHSV(_apply = true) {
		hue = round(color_get_hue(current_color));
		sat = round(color_get_saturation(current_color));
		val = round(color_get_value(current_color));
		
		if(_apply && onApply != noone) onApply(int64(current_color));
	}
	
	function setHSV(_apply = true) {
		if(!interactable) return;
		var alp = color_get_alpha(current_color);
		current_color = make_color_hsva(hue, sat, val, alp);
		
		if(_apply && onApply != noone) onApply(int64(current_color));
	}
	
	function setColor(color, _apply = true) {
		current_color = color;
		resetHSV(_apply);
	}
	
	function colorPicker() {
		if(!dropper_active) return;
		dropper_color = int64(cola(draw_getpixel(mouse_mx, mouse_my)));
		MOUSE_BLOCK   = true;
	}
	
	static drawDropper = function(instance) {
		if(mouse_check_button_pressed(mb_left)) {
			setColor(dropper_color);
			if(dropper_close)
				instance_destroy(instance);
			dropper_active = false;
			MOUSE_BLOCK    = true;
			
			return;
		}
		
		if(dropper_active && mouse_check_button_pressed(mb_right))
			instance_destroy(instance);
		if(keyboard_check_released(vk_alt))
			instance_destroy(instance);
		
		var dx = mouse_mx + ui(36);
		var dy = mouse_my + ui(36);
		draw_sprite_stretched(THEME.color_picker_sample, 0, dx - ui(20), dy - ui(20), ui(40), ui(40));
		draw_sprite_stretched_ext(THEME.color_picker_sample, 0, dx - ui(18), dy - ui(18), ui(36), ui(36), dropper_color, 1);
	}
	
	static draw = function(_x, _y, focus, hover) {
		var cont_x = _x + ui(8);
		var cont_y = _y + ui(8);
		var cont_w = ui(256);
		var cont_h = ui(256);
		
		var sel_x = cont_x + ui(280);
		var sel_y = cont_y;
		var sel_w = ui(16);
		var sel_h = cont_h;
		var discr = NODE_COLOR_SHOW_PALETTE && discretize_pal;
		
		content_surface = surface_verify(content_surface, cont_w, cont_h);
		side_surface    = surface_verify(side_surface,    sel_w,  sel_h);
		
		surface_set_target(content_surface);			
			DRAW_CLEAR
			
			draw_sprite_stretched(THEME.box_r2, 0, 0, 0, cont_w, cont_h);
			gpu_set_colorwriteenable(1, 1, 1, 0);
			shader_set(sh_color_select_content);
				shader_set_i("mode", disp_mode);
				shader_set_f("hue",  hue / 256);
				shader_set_f("sat",  sat / 256);
				shader_set_f("val",  val / 256);
				
				shader_set_i("discretize",	  discr);
				shader_set_palette(palette);
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, cont_w, cont_h);
			shader_reset();
			gpu_set_colorwriteenable(1, 1, 1, 1);
		surface_reset_target();
		
		surface_set_target(side_surface);
			DRAW_CLEAR
			
			draw_sprite_stretched(THEME.box_r2, 0, 0, 0, sel_w, sel_h);
			gpu_set_colorwriteenable(1, 1, 1, 0);
			shader_set(sh_color_select_side);
				shader_set_i("mode", disp_mode);
				shader_set_f("hue",  hue / 256);
				shader_set_f("sat",  sat / 256);
				shader_set_f("val",  val / 256);
				
				shader_set_i("discretize", discr);
				shader_set_palette(palette);
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, sel_w, sel_h);
			shader_reset();
			gpu_set_colorwriteenable(1, 1, 1, 1);
			
		surface_reset_target();
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, cont_x - ui(8), cont_y - ui(8), cont_w + ui(16), cont_h + ui(16));
		draw_sprite_stretched(THEME.ui_panel_bg, 1, sel_x - ui(8), sel_y - ui(8), sel_w + ui(16), sel_h + ui(16));
		
		draw_surface(content_surface, cont_x, cont_y);
		draw_surface(side_surface,    sel_x,  sel_y);
		
		BLEND_ADD
			draw_sprite_stretched_ext(THEME.box_r2, 1, cont_x, cont_y, cont_w, cont_h, c_white, 0.2);
			draw_sprite_stretched_ext(THEME.box_r2, 1, sel_x,  sel_y,  sel_w,  sel_h,  c_white, 0.2);
		BLEND_NORMAL
		
		#region control
			var _cs = ui(12);
			var _p2 = _cs / 2;
			var _p  = _p2 / 2;
			var _sc;
			
			var _cx = disp_mode == 0? cont_x + ui(sat) - _p2 : cont_x + ui(hue) - _p2;
			var _cy = disp_mode == 0? cont_y + ui(256 - val) - _p2 : cont_y + ui(256 - sat) - _p2;
			
			var _sw = _p2 + sel_w;
			var _sh = _cs;
			var _sx = sel_x - _p;
			var _sy = (disp_mode == 0? sel_y + ui(hue) : sel_y + ui(256 - val)) - _sh / 2;
			
			if(discr) _sc = current_color;
			else      _sc = disp_mode == 0? make_color_hsv(hue, 255, 255) : make_color_hsv(hue, 255, val);
			
			if(current_colors != noone) {
				var _csz = ui(8);
				var _ssx = sel_x + sel_w / 2 - _csz / 2;
				
				BLEND_ADD
				for (var i = 0, n = array_length(current_colors); i < n; i++) {
					var _cc  = current_colors[i];
					var _cch = round(color_get_hue(_cc));
					var _ccs = round(color_get_saturation(_cc));
					var _ccv = round(color_get_value(_cc));
					
					var _csy = disp_mode == 0? cont_y + ui(_cch) : cont_y + ui(256 - _ccv);
					
					draw_sprite_stretched_ext(THEME.box_r2, 1, _ssx, _csy - _csz / 2, _csz, _csz, c_white, 0.75);
					
					var _sel  = 1 - abs(disp_mode == 0? _cch - hue : _ccv - val) / 32;
					
					if(_sel <= 0) continue;
					var _ccx  = disp_mode == 0? cont_x + ui(_ccs)  : cont_x + ui(_cch);
					var _ccy  = disp_mode == 0? cont_y + ui(256 - _ccv) : cont_y + ui(256 - _ccs);
					var _cszz = _sel == 1? ui(16) : lerp(ui(6), ui(12), _sel);
					var _caa  = _sel == 1? 1 : lerp(0.25, 0.75, _sel);
					
					draw_sprite_stretched_ext(THEME.box_r2, 1, _ccx - _cszz / 2, _ccy - _cszz / 2, _cszz, _cszz, c_white, _caa);
				}
				BLEND_NORMAL
				
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx - 1, _sy - 1, _sw + 2, _sh + 2, c_black, 0.5);
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx, _sy, _sw, _sh, _sc, 1);
				
			} else {
				draw_sprite_stretched_ext(THEME.box_r2, 0, _cx - 1, _cy - 1, _cs + 2, _cs + 2, c_black, 0.5);
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx - 1, _sy - 1, _sw + 2, _sh + 2, c_black, 0.5);
				
				draw_sprite_stretched_ext(THEME.box_r2, 0, _sx, _sy, _sw, _sh, _sc, 1);
				draw_sprite_stretched_ext(THEME.box_r2, 0, _cx, _cy, _cs, _cs, current_color, 1);
				
				BLEND_ADD
					draw_sprite_stretched_ext(THEME.box_r2, 1, _sx, _sy, _sw, _sh, c_white, 0.75);
					draw_sprite_stretched_ext(THEME.box_r2, 1, _cx, _cy, _cs, _cs, c_white, 0.75);
				BLEND_NORMAL
			}
			
			if(mouse_press(mb_left, interactable && focus)) {
				if(point_in_rectangle(mouse_mx, mouse_my, sel_x, sel_y, sel_x + ui(16), sel_y + ui(256)))
					side_dragging = true;
				else if(point_in_rectangle(mouse_mx, mouse_my, cont_x, cont_y, cont_x + ui(256), cont_y + ui(256)))
					area_dragging = true;
			}
			
			if(side_dragging) {
				if(disp_mode == 0) {
					hue = clamp((mouse_my - sel_y) / UI_SCALE, 0, 256);
				} else if(disp_mode == 1) {
					val = 256 - clamp((mouse_my - sel_y) / UI_SCALE, 0, 256);
				}
				
				setHSV();
				
				if(discr) {
					current_color = disp_mode == 0? surface_getpixel(content_surface, sat, 256 - val) : 
													surface_getpixel(content_surface, hue, 256 - sat);
					current_color = cola(current_color, 1);
					if(onApply != noone) onApply(current_color);
				}
				
				if(mouse_release(mb_left))
					side_dragging  = false;
			}
		
			if(area_dragging) {
				if(disp_mode == 0) {
					sat = clamp((mouse_mx - cont_x) / UI_SCALE, 0, 256);
					val = 256 - clamp((mouse_my - cont_y) / UI_SCALE, 0, 256);
				} else if(disp_mode == 1) {
					hue = clamp((mouse_mx - cont_x) / UI_SCALE, 0, 256);
					sat = 256 - clamp((mouse_my - cont_y) / UI_SCALE, 0, 256);	
				}
				
				setHSV();
				
				if(discr) {
					current_color = disp_mode == 0? surface_getpixel(content_surface, sat, 256 - val) : 
													surface_getpixel(content_surface, hue, 256 - sat);
					current_color = cola(current_color, 1);
					if(onApply != noone) onApply(current_color);
				}
				
				if(mouse_release(mb_left))
					area_dragging  = false;
			}
		#endregion
		
		#region type
			var tx = sel_x + ui(36);
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
			var data_x = sel_x + ui(40);
			var data_y = cont_y + ui(40);
			var wdw = ui(160);
			var wdh = ui( 27);
			var txh = wdh + ui(4);
	
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(data_x, data_y + txh * 0 + ui(15), "H");
			draw_text(data_x, data_y + txh * 1 + ui(15), "S")
			draw_text(data_x, data_y + txh * 2 + ui(15), "V");
			
			tb_hue.setFocusHover(focus, hover);
			tb_sat.setFocusHover(focus, hover);
			tb_val.setFocusHover(focus, hover);
			
			tb_hue.draw(data_x + ui(28), data_y + txh * 0, wdw, wdh, round(color_get_hue(current_color)),			mouse_ui);
			tb_sat.draw(data_x + ui(28), data_y + txh * 1, wdw, wdh, round(color_get_saturation(current_color)),	mouse_ui);
			tb_val.draw(data_x + ui(28), data_y + txh * 2, wdw, wdh, round(color_get_value(current_color)),			mouse_ui);
			
			data_y = data_y + txh * 3 + ui(8);
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(data_x, data_y + txh * 0 + ui(15), "R");
			draw_text(data_x, data_y + txh * 1 + ui(15), "G");
			draw_text(data_x, data_y + txh * 2 + ui(15), "B");
			draw_text(data_x, data_y + txh * 3 + ui(15), "A");
			
			tb_red.setFocusHover  (focus, hover);
			tb_green.setFocusHover(focus, hover);
			tb_blue.setFocusHover (focus, hover);
			tb_alpha.setFocusHover(focus, hover);
			
			tb_red.draw  (data_x + ui(28), data_y + txh * 0, wdw, wdh, round(color_get_red(current_color)),   mouse_ui);
			tb_green.draw(data_x + ui(28), data_y + txh * 1, wdw, wdh, round(color_get_green(current_color)), mouse_ui);
			tb_blue.draw (data_x + ui(28), data_y + txh * 2, wdw, wdh, round(color_get_blue(current_color)),  mouse_ui);
			tb_alpha.draw(data_x + ui(28), data_y + txh * 3, wdw, wdh, round(color_get_alpha(current_color)), mouse_ui);
			
			//////////////////////////////////////////////////////////////////
			
			tb_hex.active  = focus;  tb_hex.hover  = hover;
			tb_hex.draw(sel_x - ui(128), cont_y + ui(256 + 24), ui(108), TEXTBOX_HEIGHT, color_get_hex(current_color),  mouse_ui);
		#endregion
		
		var cx = cont_x + ui(16);
		var cy = cont_y + ui(296);
		var aa = _color_get_alpha(current_color);
		
		draw_sprite_stretched_ext(THEME.color_picker_box, 0, cx - ui(20), cy - ui(20), ui(40), ui(40), COLORS._main_icon_dark, 1);
		draw_sprite_stretched_ext(THEME.color_picker_box, 1, cx - ui(18), cy - ui(18), ui(36), ui(36), current_color, aa);
		
		cx += ui(48);
		if(interactable)
		if(buttonInstant(THEME.button_hide_fill, cx - ui(18), cy - ui(18), ui(36), ui(36), mouse_ui, focus, hover, "", THEME.color_picker_dropper, 0, c_white) == 2)
			dropper_active = true;
	}
}
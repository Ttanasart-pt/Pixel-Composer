/// @description 
#region draw 
	var key = "";
	
	for( var i = 0; i < array_length(extra_keys); i++ ) {
		if(keyboard_check(extra_keys[i][0]))
			key += key == ""? extra_keys[i][1] : (" + " + extra_keys[i][1]);
	}
	
	if(keyboard_check(vk_anykey)) {
		var pres = keyboard_lastkey;
		
		if(pres >= 32 && pres <= 126) {
			pres = string_upper(ansi_char(pres));
			key += key == ""? pres : " + " + pres;
		}
	}
	
	var pressing = key != "";
	if(key != "") {
		disp_text = key;
		alpha = 2;
	} else
		alpha = lerp_linear(alpha, 0, 0.01);
	
	if(alpha > 0) {
		draw_set_text(f_h3, fa_right, fa_bottom, COLORS._main_icon_dark);
		var ww = string_width(disp_text) + ui(16);
		var hh = string_height(disp_text) + ui(16);
		
		var x1 = WIN_W - ui(8);
		var y1 = WIN_H - ui(8);
		var x0 = x1 - ww;
		var y0 = y1 - hh;
		
		draw_sprite_stretched_ext(THEME.key_display, 0, x0, y0, ww, hh, 
			pressing? COLORS._main_accent : COLORS._main_icon, alpha);
		draw_set_alpha(alpha);
		draw_text(x1 - ui(8), y1 - ui(8), disp_text);
		draw_set_alpha(1);
	}
#endregion
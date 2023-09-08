/// @description
#region data
	depth = -9999;
	
	active   = false;
	dialog_x = 0;
	dialog_y = 0;
	dialog_w = 300;
	dialog_h = 160;
	
	selecting = 0;
	textbox	  = noone;
	prompt	  = "";
	data	  = [];
	
	sc_content = new scrollPane(dialog_w, dialog_h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_get_height(f_p0, 8);
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		
		for(var i = 0; i < array_length(data); i++) {
			var _dat = data[i];
			
			//if(point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
			//	selecting = i;
				
			//	if(mouse_press(mb_left))
			//		applyAutoComplete(_dat[3]);
			//}
			
			if(selecting == i) {
				WIDGET_TAB_BLOCK = true;
				
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
				if(keyboard_check_pressed(vk_tab))
					applyAutoComplete(_dat[3]);
			}
			
			var icn = _dat[0][0];
			var ss  = 16 / sprite_get_width(icn);
			draw_sprite_ext(icn, _dat[0][1], ui(4 + 12), _ly + hght / 2, ss, ss, 0, c_white, 1);
			
			draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text_sub);
			draw_text_cut(_dw - ui(8), _ly + hght / 2 - ui(2), _dat[2], _dw);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text_cut(ui(4 + 24 + 4), _ly + hght / 2 - ui(2), _dat[1], _dw);
			
			_ly += hght;
			_h  += hght;
		}
		
		if(keyboard_check_pressed(vk_up)) {
			selecting--;
			if(selecting < 0) selecting = array_length(data) - 1;
			
			sc_content.scroll_y_to = -(selecting - 2) * hght;
		}
			
		if(keyboard_check_pressed(vk_down)) {
			selecting = safe_mod(selecting + 1, array_length(data));
			
			sc_content.scroll_y_to = -(selecting - 2) * hght;
		}
		
		return _h;
	});
	
	function applyAutoComplete(rep) {
		var line = array_safe_get(textbox._input_text_line, textbox.cursor_line, "");
		var _line_curs = textbox.cursor - textbox.char_run;
		var crop = string_copy(line, 1, _line_curs);
		var rest = string_copy(line, _line_curs + 1, string_length(line) - _line_curs);
		var slp  = string_splice(crop, [" ", "(", ","], true);
		slp[array_length(slp) - 1] = rep;
		
		var txt = "";
		for( var i = 0, n = array_length(textbox._input_text_line); i < n; i++ ) {
			if(i == textbox.cursor_line) {
				for( var j = 0; j < array_length(slp); j++ )
					txt += slp[j];
				txt += rest;
				continue;
			}
			
			txt += textbox._input_text_line[i];
		}
		
		txt = string_trim(txt, [ "\n" ]);
		var shf = string_length(rep) - string_length(prompt);
		
		textbox.cursor += shf;
		textbox._input_text = txt;
		textbox.cut_line();
		
		active = false;
	}	
#endregion


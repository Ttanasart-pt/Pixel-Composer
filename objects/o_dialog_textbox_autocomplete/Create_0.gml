/// @description
event_inherited();

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
	
	destroy_on_escape    = false;
	destroy_on_click_out = false;
	
	sc_content = new scrollPane(dialog_w, dialog_h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_get_height(f_p0, 8);
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		
		for(var i = 0; i < array_length(data); i++) {
			var _dat = data[i];
			
			if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
				selecting = i;
				
				if(mouse_press(mb_left))
					applyAutoComplete(_dat[3]);
			}
			
			if(selecting == i) {
				WIDGET_TAB_BLOCK = true;
				
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
				if(keyboard_check_pressed(vk_tab) || keyboard_check_pressed(vk_enter))
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
		var _totAmo = string_length(textbox._input_text);
		var _prmAmo = string_length(prompt);
		var _repAmo = string_length(rep);
		
		var _sPreC = string_copy(textbox._input_text, 1, textbox.cursor - _prmAmo);
		var _sPosC = string_copy(textbox._input_text, textbox.cursor + 1, _totAmo - textbox.cursor);
		
		textbox._input_text = $"{_sPreC}{rep}{_sPosC}";
		textbox.cursor += _repAmo - _prmAmo;
		textbox.cut_line();
		
		active = false;
	}	
#endregion


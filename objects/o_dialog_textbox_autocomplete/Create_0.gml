/// @description
event_inherited();

#region data
	depth = -9999;
	
	dialog_x = 0;
	dialog_y = 0;
	dialog_w = 300;
	dialog_h = 160;
	on_top   = true;
	
	selecting = 0;
	textbox	  = noone;
	prompt	  = "";
	data	  = [];
	font      = f_code;
	pre_mx    = 0;
	pre_my    = 0;
	
	show_items = 8;
	pad_item   = 6;
	
	destroy_on_escape    = false;
	destroy_on_click_out = false;
	
	function activate(_textbox) { 
		textbox   = _textbox;
		selecting = 0;
	}
	
	function deactivate(_textbox) {
		if(textbox != _textbox) return;
		textbox = noone;
	}
	
	sc_content = new scrollPane(dialog_w, dialog_h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hght = line_get_height(font, pad_item);
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		var _mmove = pre_mx != _m[0] || pre_my != _m[1];
		
		gpu_set_tex_filter(true);
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _dat = data[i];
			
			if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
				if(_mmove) selecting = i;
				if(mouse_press(mb_left)) { applyAutoComplete(_dat[3]); MOUSE_BLOCK = true; break; }
			}
			
			if(selecting == i) {
				WIDGET_TAB_BLOCK = true;
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				if(keyboard_check_pressed(vk_tab) || keyboard_check_pressed(vk_enter)) { applyAutoComplete(_dat[3]); break; }
			}
			
			var icn = _dat[0][0];
			if(sprite_exists(icn)) {
				var ss = (hght - ui(8)) / sprite_get_width(icn);
				draw_sprite_ext(icn, _dat[0][1], ui(4 + 12), _ly + hght / 2, ss, ss, 0, c_white, 1);
			}
			
			BLEND_ALPHA_MULP
			draw_set_text(font, fa_right, fa_center, COLORS._main_text_sub);
			draw_text(round(_dw - ui(8)), round(_ly + hght / 2), _dat[2]);
			
			draw_set_text(font, fa_left, fa_center, CDEF.main_white);
			draw_text(round(ui(4 + 24 + 4)), round(_ly + hght / 2), _dat[1]);
			BLEND_NORMAL
			
			_ly += hght;
			_h  += hght;
		}
		gpu_set_tex_filter(false);
		
		if(KEYBOARD_PRESSED == vk_up)   { 
			selecting = (selecting - 1 + n) % n; 
			sc_content.scroll_y_to = max(sc_content.scroll_y_to, -selecting * hght);
			if(selecting == n - 1) sc_content.scroll_y_to = -(selecting - show_items + 1) * hght;
		}
		
		if(KEYBOARD_PRESSED == vk_down) { 
			selecting = (selecting + 1) % n; 
			sc_content.scroll_y_to = min(sc_content.scroll_y_to, -(selecting - show_items + 1) * hght);
			if(selecting == 0) sc_content.scroll_y_to = -selecting * hght;
		}
		
		pre_mx = _m[0];
		pre_my = _m[1];
		
		return _h;
	});
	
	sc_content.scroll_inertia = 0;
	
	function applyAutoComplete(rep) {
		if(textbox.isCodeFormat()) {
			var _totAmo = string_length(textbox._input_text);
			var _prmAmo = string_length(prompt);
			var _repAmo = string_length(rep);
			
			var _sPreC = string_copy(textbox._input_text, 1, textbox.cursor - _prmAmo);
			var _sPosC = string_copy(textbox._input_text, textbox.cursor + 1, _totAmo - textbox.cursor);
			
			textbox._input_text = $"{_sPreC}{rep}{_sPosC}";
			textbox.cursor += _repAmo - _prmAmo;
			textbox.cut_line();
			textbox.autocomplete_delay = 0;
			
		} else {
			textbox._input_text   = rep;
			textbox._current_text = rep;
			textbox.deactivate();
		}
		
		textbox = noone;
		prompt  = "";
		data    = [];
	}	
#endregion


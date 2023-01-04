/// @description init
#region draw
	var yy = dialog_y;
	
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	for(var i = 0; i < array_length(menu); i++) {
		if(!is_array(menu[i])) {
			draw_sprite_stretched(THEME.menu_separator, 0, dialog_x + ui(8), yy, dialog_w - ui(16), ui(6));
			yy += ui(8);
			
			continue;
		}
		var _h = hght;
		var label = menu[i][0];
		var activated = string_char_at(label, 1) != "-";
		if(!activated) label = string_copy(label, 2, string_length(label) - 1);
		
		if(is_array(menu[i][1]))
			_h += hght;
			
		if(activated && sHOVER && point_in_rectangle(mouse_mx, mouse_my, dialog_x, yy + 1, dialog_x + dialog_w, yy + _h - 1)) {
			draw_sprite_stretched_ext(THEME.textbox, 3, dialog_x, yy, dialog_w, _h, COLORS.dialog_menubox_highlight, 1);
			
			if(!is_array(menu[i][1]) && sFOCUS && mouse_release(mb_left)) {
				var res = menu[i][1](dialog_x + dialog_w, yy, depth, menu[i][0]);
				if(array_safe_get(menu[i], 2, 0) == ">")
					ds_list_add(children, res);
				else
					instance_destroy(o_dialog_menubox);
			}
		}
		
		if(is_array(menu[i][1])) {
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
			draw_set_alpha(activated * 0.5 + 0.5);
			draw_text(dialog_x + dialog_w / 2, yy + hght / 2, label);
			draw_set_alpha(1);
			
			var amo = array_length(menu[i][1]);
			var _w  = (amo - 1) / 2 * (hght + ui(4));
			var _sx = dialog_x + dialog_w / 2 - _w;
			
			for(var j = 0; j < amo; j++) {
				var _bx = _sx + j * (hght + ui(4));
				var _by = yy + hght + hght / 2 - ui(4);
				var _spr = noone, _ind = 0;
				var _ss = menu[i][1][j][0];
				
				if(is_array(_ss)) {
					_spr = _ss[0];
					_ind = _ss[1];
				} else {
					_spr = _ss;
					_ind = 0;
				}
				
				if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, _bx - ui(14), _by - ui(14), _bx + ui(14), _by + ui(14))) {
					draw_sprite_stretched_ext(THEME.textbox, 3, _bx - ui(14), _by - ui(14), ui(28), ui(28), COLORS.dialog_menubox_highlight, 1);
					draw_sprite_stretched_ext(THEME.textbox, 1, _bx - ui(14), _by - ui(14), ui(28), ui(28), COLORS.dialog_menubox_highlight, 1);
					
					if(mouse_press(mb_left, sFOCUS)) {
						menu[i][1][j][1]();
						instance_destroy(o_dialog_menubox);
					}
				}
				
				draw_sprite_ui_uniform(_spr, _ind, _bx, _by);
			}
		} else {
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_set_alpha(activated * 0.5 + 0.5);
			draw_text(dialog_x + ui(16), yy + hght / 2, label);
			draw_set_alpha(1);
		}
		
		if(array_length(menu[i]) > 2) {
			if(menu[i][2] == ">") {
				draw_sprite_ui_uniform(THEME.arrow, 0, dialog_x + dialog_w - ui(20), yy + hght / 2, 1, COLORS._main_icon);	
			} else if(is_array(menu[i][2])) {
				var _key = find_hotkey(menu[i][2][0], menu[i][2][1]);
				if(_key) {
					draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text_sub);
					draw_text(dialog_x + dialog_w - ui(16), yy + hght / 2, key_get_name(_key.key, _key.modi));	
				}	
			}
		}
		
		yy += _h;
	}
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion
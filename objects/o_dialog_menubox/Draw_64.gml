/// @description init
#region draw
	var yy   = dialog_y;
	
	draw_sprite_stretched(s_textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	for(var i = 0; i < array_length(menu); i++) {
		if(!is_array(menu[i])) {
			draw_sprite_stretched(s_menu_separator, 0, dialog_x + 8, yy, dialog_w - 16, 6);
			yy += 8;
			
			continue;
		}
		var _h = hght;
		
		if(is_array(menu[i][1]))
			_h += hght;
			
		if(HOVER == self && point_in_rectangle(mouse_mx, mouse_my, dialog_x, yy + 1, dialog_x + dialog_w, yy + _h - 1)) {
			draw_sprite_stretched_ext(s_textbox, 3, dialog_x, yy, dialog_w, _h, c_ui_blue_white, 1);
			
			if(FOCUS == self && mouse_check_button_released(mb_left)) {
				if(!is_array(menu[i][1])) {
					menu[i][1]();
					instance_destroy();
				}
			}
		}
		
		if(is_array(menu[i][1])) {
			draw_set_text(f_p1, fa_center, fa_center, c_ui_blue_ltgrey);
			draw_text(dialog_x + dialog_w / 2, yy + hght / 2, menu[i][0]);
			
			var amo = array_length(menu[i][1]);
			var _w  = (amo - 1) / 2 * (hght + 4);
			var _sx = dialog_x + dialog_w / 2 - _w;
			
			for(var j = 0; j < amo; j++) {
				var _bx = _sx + j * (hght + 4);
				var _by = yy + hght + hght / 2 - 4;
				var _spr = noone, _ind = 0;
				var _ss = menu[i][1][j][0];
				
				if(is_array(_ss)) {
					_spr = _ss[0];
					_ind = _ss[1];
				} else {
					_spr = _ss;
					_ind = 0;
				}
				
				if(HOVER == self && point_in_rectangle(mouse_mx, mouse_my, _bx - 14, _by - 14, _bx + 14, _by + 14)) {
					draw_sprite_stretched(s_textbox, 1, _bx - 14, _by - 14, 28, 28);
					
					if(FOCUS == self && mouse_check_button_pressed(mb_left)) {
						menu[i][1][j][1]();
						instance_destroy();
					}
				}
				
				draw_sprite(_spr, _ind, _bx, _by);
			}
		} else {
			draw_set_text(f_p0, fa_left, fa_center, c_white);
			draw_text(dialog_x + 16, yy + hght / 2, menu[i][0]);	
		}
		
		if(array_length(menu[i]) > 2) {
			var _key = find_hotkey(menu[i][2][0], menu[i][2][1]);
			if(_key) {
				draw_set_text(f_p1, fa_right, fa_center, c_ui_blue_grey);
				draw_text(dialog_x + dialog_w - 16, yy + hght / 2, key_get_name(_key.key, _key.modi));	
			}
		}
		
		yy += _h;
	}
#endregion
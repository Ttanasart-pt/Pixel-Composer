/// @description init
#region draw
	var yy = dialog_y;
	
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	for(var i = 0; i < array_length(menu); i++) {
		var _menuItem = menu[i];
		
		if(!is_array(_menuItem)) {
			draw_sprite_stretched(THEME.menu_separator, 0, dialog_x + ui(8), yy, dialog_w - ui(16), ui(6));
			yy += ui(8);
			
			continue;
		}
		var _h = hght;
		var label = _menuItem[0];
		var activated = string_char_at(label, 1) != "-";
		if(!activated) label = string_copy(label, 2, string_length(label) - 1);
		
		if(is_array(_menuItem[1]))
			_h += hght;
		
		var hoverable = activated && sHOVER;
		if(hoverable && point_in_rectangle(mouse_mx, mouse_my, dialog_x, yy + 1, dialog_x + dialog_w, yy + _h - 1))
			selecting = i;
			
		if(selecting == i) {
			draw_sprite_stretched_ext(THEME.textbox, 3, dialog_x, yy, dialog_w, _h, COLORS.dialog_menubox_highlight, 1);
			
			if(!is_array(_menuItem[1]) && sFOCUS && (mouse_release(mb_left) || keyboard_check_released(vk_enter))) {
				var res = _menuItem[1](dialog_x + dialog_w, yy, depth, _menuItem[0]);
				if(array_safe_get(_menuItem, 2, 0) == ">")
					ds_list_add(children, res);
				else
					instance_destroy(o_dialog_menubox);
			}
		}
		
		if(is_array(_menuItem[1])) { //submenu
			var _submenus = _menuItem[1];
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
			draw_set_alpha(activated * 0.5 + 0.5);
			draw_text(dialog_x + dialog_w / 2, yy + hght / 2, label);
			draw_set_alpha(1);
			
			var amo = array_length(_submenus);
			var _w  = (amo - 1) / 2 * (hght + ui(4));
			var _sx = dialog_x + dialog_w / 2 - _w;
			
			for(var j = 0; j < amo; j++) {
				var _submenu = _submenus[j];
				var _bx = _sx + j * (hght + ui(4));
				var _by = yy + hght + hght / 2 - ui(4);
				var _spr = noone, _ind = 0;
				var _sprs = _submenu[0];
				var _tlp = array_safe_get(_submenu, 2, "");
				
				if(is_array(_sprs)) {
					_spr = _sprs[0];
					_ind = _sprs[1];
				} else {
					_spr = _sprs;
					_ind = 0;
				}
				
				if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, _bx - ui(14), _by - ui(14), _bx + ui(14), _by + ui(14))) {
					if(_tlp != "") TOOLTIP = _tlp;
					draw_sprite_stretched_ext(THEME.textbox, 3, _bx - ui(14), _by - ui(14), ui(28), ui(28), COLORS.dialog_menubox_highlight, 1);
					draw_sprite_stretched_ext(THEME.textbox, 1, _bx - ui(14), _by - ui(14), ui(28), ui(28), COLORS.dialog_menubox_highlight, 1);
					
					if(mouse_press(mb_left, sFOCUS)) {
						_submenu[1]();
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
		
		if(array_length(_menuItem) > 2) {
			if(_menuItem[2] == ">") {
				draw_sprite_ui_uniform(THEME.arrow, 0, dialog_x + dialog_w - ui(20), yy + hght / 2, 1, COLORS._main_icon);	
			} else if(is_array(_menuItem[2])) {
				var _key = find_hotkey(_menuItem[2][0], _menuItem[2][1]);
				if(_key) {
					draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text_sub);
					draw_text(dialog_x + dialog_w - ui(16), yy + hght / 2, key_get_name(_key.key, _key.modi));	
				}	
			}
		}
		
		yy += _h;
	}
	
	if(sFOCUS) {
		if(keyboard_check_pressed(vk_up)) {
			selecting--;
			if(selecting < 0) selecting = array_length(menu) - 1;
		}
			
		if(keyboard_check_pressed(vk_down))
			selecting = (selecting + 1) % array_length(menu);
			
		if(keyboard_check_pressed(vk_escape))
			instance_destroy();
	}
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion
/// @description init
if(!ready) exit;

#region draw
	var yy = dialog_y;
	
	draw_sprite_stretched(THEME.menu_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	for(var i = 0; i < array_length(menu); i++) {
		var _menuItem = menu[i];
		
		if(is_instanceof(_menuItem, MenuItem) && _menuItem.shiftMenu != noone && key_mod_press(SHIFT))
			_menuItem = _menuItem.shiftMenu;
			
		if(_menuItem == -1) { #region
			var bx = dialog_x + ui(8);
			var bw = dialog_w - ui(16);
			draw_set_color(CDEF.main_mdblack);
			draw_line_width(bx, yy + ui(3), bx + bw, yy + ui(3), 2);
			yy += ui(8);
			
			continue;
		} #endregion
		
		var label = _menuItem.name;
		var _h    = is_instanceof(_menuItem, MenuItemGroup)? hght * 2 : hght;
		var cc    = struct_try_get(_menuItem, "color", c_white);
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, dialog_x, yy + 1, dialog_x + dialog_w, yy + _h - 1)) {
			selecting = i;
			var tips  = array_safe_get_fast(tooltips, i, noone);
			if(tips != noone) TOOLTIP = tips;
		}
		
		if(selecting == i) {
			var _hc = cc == c_white? COLORS.dialog_menubox_highlight : cc;
			var _ha = cc == c_white? 0.75 : 0.8;
			
			draw_sprite_stretched_ext(THEME.textbox, 3, dialog_x, yy, dialog_w, _h, _hc, _ha);
			
			var _click = sFOCUS && (!mouse_inside && mouse_release(mb_left)) || keyboard_check_released(vk_enter);
			
			if(_hovering_ch && is_instanceof(_menuItem, MenuItem) && _menuItem.active && _click) {
					
				var _dat = {
					_x:      dialog_x,
					x:       dialog_x + dialog_w,
					y:       yy,
					depth:   depth,
					name:    _menuItem.name,
					index:   i,
					context: context,
					params:  _menuItem.params,
				};
				
				var _res = _menuItem.func(_dat);
				if(_menuItem.isShelf) array_push(children, _res.id);
				else                  instance_destroy(o_dialog_menubox);
				
			}
		} else if(cc != c_white)
			draw_sprite_stretched_ext(THEME.textbox, 3, dialog_x, yy, dialog_w, _h, cc, 0.5);
		
		if(is_instanceof(_menuItem, MenuItemGroup)) {
			var _submenus = _menuItem.group;
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
			draw_set_alpha(_menuItem.active * 0.75 + 0.25);
			draw_text(dialog_x + dialog_w / 2, yy + hght / 2, label);
			draw_set_alpha(1);
			
			var amo = array_length(_submenus);
			var _w  = (amo - 1) / 2 * (_menuItem.spacing + ui(4));
			var _sx = dialog_x + dialog_w / 2 - _w;
			
			for(var j = 0; j < amo; j++) {
				var _submenu = _submenus[j];
				var _bx	  = _sx + j * (_menuItem.spacing + ui(4));
				var _by	  = yy + hght + hght / 2 - ui(4);
				var _spr  = noone, _ind = 0;
				var _sprs = _submenu[0];
				var _tlp  = array_safe_get_fast(_submenu, 2, "");
				var _dat  = array_safe_get_fast(_submenu, 3, {});
				var _clr  = c_white;
				var _str  = "";
				
				var _sw = _menuItem.spacing;
				var _sh = _menuItem.spacing;
				
				if(is_string(_sprs)) {
					_str = _sprs;
					draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
					
					_sw = string_width(_str) + ui(12);
					_sh = string_height(_str) + ui(8);
				} else {
					if(is_array(_sprs)) {
						_spr = _sprs[0];
						_ind = _sprs[1];
						_clr = array_safe_get_fast(_sprs, 2, c_white);
					} else _spr = _sprs;
					
					_sw = sprite_get_width(_spr)  + ui(8);
					_sh = sprite_get_height(_spr) + ui(8);
				}
				
				if(_hovering_ch && point_in_rectangle(mouse_mx, mouse_my, _bx - _sw / 2, _by - _sh / 2, _bx + _sw / 2, _by + _sh / 2)) {
					if(_tlp != "") TOOLTIP = _tlp;
					draw_sprite_stretched_ext(THEME.textbox, 3, _bx - _sw / 2, _by - _sh / 2, _sw, _sh, COLORS.dialog_menubox_highlight, 1);
					draw_sprite_stretched_ext(THEME.textbox, 1, _bx - _sw / 2, _by - _sh / 2, _sw, _sh, COLORS.dialog_menubox_highlight, 1);
					
					if(mouse_press(mb_left, sFOCUS)) {
						_submenu[1](_dat);
						instance_destroy(o_dialog_menubox);
					}
				}
				
				if(_spr != noone)
					draw_sprite_ui_uniform(_spr, _ind, _bx, _by,, _clr);
				
				if(_str != "")
					draw_text(_bx, _by, _str);
			}
		} else {
			if(_menuItem.spr != noone) {
				var spr = is_array(_menuItem.spr)? _menuItem.spr[0] : _menuItem.spr;
				var ind = is_array(_menuItem.spr)? _menuItem.spr[1] : 0;
				draw_sprite_ui(spr, ind, dialog_x + ui(24), yy + hght / 2,,,, COLORS._main_icon, _menuItem.active * 0.5 + 0.25);
			}
			
			if(_menuItem.toggle != noone) {
				var tog = _menuItem.toggle(_menuItem);
				if(tog) draw_sprite_ui(THEME.icon_toggle, 0, dialog_x + ui(24), yy + hght / 2,,,, COLORS._main_icon);
			}
			
			var tx = dialog_x + show_icon * ui(32) + ui(16);
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_set_alpha(_menuItem.active * 0.75 + 0.25);
			draw_text(tx, yy + hght / 2, label);
			draw_set_alpha(1);
			
			if(_menuItem.isShelf) {
				draw_sprite_ui_uniform(THEME.arrow, 0, dialog_x + dialog_w - ui(20), yy + hght / 2, 1, COLORS._main_icon);	
			} else if(_menuItem.hotkey != noone) {
				var _key = find_hotkey(_menuItem.hotkey[0], _menuItem.hotkey[1]);
				
				if(_key) {
					var _hx = dialog_x + dialog_w - ui(16);
					var _hy = yy + hght / 2 + ui(2);
					hotkey_draw(key_get_name(_key.key, _key.modi), _hx, _hy);
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
			selecting = safe_mod(selecting + 1, array_length(menu));
			
		if(keyboard_check_pressed(vk_escape))
			instance_destroy();
	}
	
	draw_sprite_stretched(THEME.menu_bg, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	if(mouse_inside && (mouse_release(mb_left) || mouse_release(mb_right))) mouse_inside = false;
#endregion

#region debug
	if(global.FLAG[$ "context_menu_id"]) {
		draw_set_color(c_white);
		draw_rectangle_border(dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h, 2);
		
		draw_set_text(f_p0, fa_left, fa_bottom);
		draw_text(dialog_x, dialog_y - ui(2), menu_id);
	}
#endregion
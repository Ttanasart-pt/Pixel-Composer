/// @description init
if(!ready) exit;

DIALOG_PREDRAW
DIALOG_WINCLEAR1

#region draw
	var yy = dialog_y;
	var _lclick = sFOCUS && (!mouse_init_inside && mouse_release(mb_left)) || (KEYBOARD_ENTER && hk_editing == noone);
	var _rclick = sFOCUS && !mouse_init_inside && !mouse_init_r_pressed && mouse_release(mb_right);
	if(!mouse_init_inside && mouse_press(mb_right) && item_sel_submenu) {
		if(instance_exists(item_sel_submenu))
			instance_destroy(item_sel_submenu);
		item_sel_submenu = noone;
	}
	
	draw_sprite_stretched(THEME.box_r2_clr, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	var to_del = noone;
	
	for( var i = 0; i < array_length(menu); i++ ) {
		var _menuItem = menu[i];
		
		if(is_string(_menuItem)) {
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(dialog_x + ui(8), yy + ui(4), _menuItem);
			yy += string_height(_menuItem) + ui(8);
			continue;
		}
		
		if(is(_menuItem, MenuItem) && _menuItem.shiftMenu != noone && key_mod_press(SHIFT))
			_menuItem = _menuItem.shiftMenu;
			
		if(_menuItem == -1) {
			var bx = dialog_x + ui(16);
			var bw = dialog_w - ui(32);
			draw_set_color(CDEF.main_mdblack);
			draw_line_width(bx, yy + ui(3), bx + bw, yy + ui(3), 2);
			yy += ui(8);
			continue;
		}
		
		var label = _menuItem.name;
		var _h    = is(_menuItem, MenuItemGroup)? hght * 2 : hght;
		var cc    = _menuItem[$ "color"] ?? c_white;
		var _key  = _menuItem.hoykeyObject;
		
		if(_key == noone && _menuItem.hotkey != noone) {
			_key = find_hotkey(_menuItem.hotkey[0], _menuItem.hotkey[1]);
			_menuItem.hoykeyObject = _key;
		}
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, dialog_x, yy + 1, dialog_x + dialog_w, yy + _h - 1)) {
			selecting = i;
			var tips = array_safe_get_fast(tooltips, i, noone);
			if(tips != noone) TOOLTIP = tips;
		}
		
		if(selecting == i) {
			if(_menuItem.active && cc == c_white) cc = COLORS.dialog_menubox_highlight;
			
			if(_hovering_ch) {
				if(_lclick && is(_menuItem, MenuItem) && _menuItem.active) {
					
					if(_menuItem.isShelf) {
						FOCUS_CONTENT = context;
						
						if(instance_exists(submenu)) {
							instance_destroy(submenu);
							submenu = noone;
						}
						
						if(submenuIt == _menuItem) {
							submenuIt = noone;
							
						} else {
							var _dat = {
								_x:      dialog_x,
								x:       dialog_x + dialog_w,
								y:       yy,
								name:    _menuItem.name,
								index:   i,
								depth:   depth,
								context: context,
								params:  _menuItem.params,
							};
							
							var _res  = _menuItem.toggleFunction(_dat);
							submenu   = _res;
							submenuIt = _menuItem;
						}
						
					} else {
						FOCUS_CONTENT = context;
						
						_menuItem.toggleFunction();
						if(close_on_trigger) to_del = remove_parents? o_dialog_menubox : self;
					}
				}
				
				if(_rclick && (is(_menuItem, MenuItem) || is(_menuItem, MenuItemGroup))) {
					var _dat = {
						_x:      mouse_mx + ui(4),
						x:       mouse_mx + ui(4),
						y:       mouse_my + ui(4),
						depth:   depth,
						name:    _menuItem.name,
						index:   i,
						context: context,
						params:  _menuItem.params,
					};
					
					_dat.panel     = self;
					selecting_menu = _menuItem;
					
					with(o_dialog_menubox) { if(!remove_parents) instance_destroy(); }
					
					var context_menu_settings = [];
					
					if(_key) {
						array_push(context_menu_settings, 
							_key.getNameFull(),
							menuItem(__txt("Edit Hotkey"),  function() /*=>*/ { hk_editing = selecting_menu; keyboard_lastchar = hk_editing.hoykeyObject.key; }),
							menuItem(__txt("Reset Hotkey"), function() /*=>*/ {return selecting_menu.hoykeyObject.reset(true)}, THEME.refresh_20).setActive(_key.isModified())
						);
					}
					
					if(menu_id != "" && !array_empty(menuItems_get(menu_id))) {
						if(!array_empty(context_menu_settings)) array_push(context_menu_settings, -1);
						
						array_push(context_menu_settings, menuItem(__txt("Edit Items..."), function(_mid) /*=>*/ { 
							dialogPanelCall(new Panel_MenuItems_Editor(_mid));
							instance_destroy(o_dialog_menubox);
						}).setParam(menu_id));
					}
					
					if(!array_empty(context_menu_settings)) {
						item_sel_submenu = submenuCall(_dat, context_menu_settings);
						item_sel_submenu.remove_parents = false;
					}
				}
			}
		} 
		
		if(cc != c_white) draw_sprite_stretched_ext(THEME.textbox, 3, dialog_x, yy, dialog_w, _h, cc);
		
		var _hx = dialog_x + dialog_w - ui(16);
		var _hy = yy + hght / 2 + ui(2);
			
		if(is(_menuItem, MenuItemGroup)) {
			var _submenus = _menuItem.group;
			draw_set_text(font, fa_center, fa_center, COLORS._main_text_sub);
			draw_set_alpha(_menuItem.active * 0.75 + 0.25);
			draw_text_add(dialog_x + dialog_w / 2, yy + hght / 2, label);
			draw_set_alpha(1);
			
			var amo = array_length(_submenus);
			var _w  = (amo - 1) / 2 * (_menuItem.spacing + ui(4));
			var _sx = dialog_x + dialog_w / 2 - _w;
			
			for(var j = 0; j < amo; j++) {
				var _submenu = _submenus[j];
				var _bx	  = _sx + j * (_menuItem.spacing + ui(4));
				var _by	  = yy + hght + hght / 2 - ui(4);
				
				var _spr  = noone;
				var _sprs = _submenu[0];
				var _ind  = 0;
				
				var _tlp  = array_safe_get_fast(_submenu, 2, "");
				var _dat  = array_safe_get_fast(_submenu, 3, {});
				var _clr  = c_white;
				var _str  = "";
				
				var _sw = _menuItem.spacing;
				var _sh = _menuItem.spacing;
				
				if(is_string(_sprs)) {
					_str = _sprs;
					draw_set_text(font, fa_center, fa_center, COLORS._main_text);
					
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
						DIALOG_POSTDRAW
						
						_submenu[1](_dat);
						instance_destroy(o_dialog_menubox);
						exit;
					}
				}
				
				if(_spr != noone) draw_sprite_ui_uniform(_spr, _ind, _bx, _by, 1, _clr);
				if(_str != "")    draw_text_add(_bx, _by, _str);
			}
			
		} else {
			var _spr = _menuItem.getSpr();
			var _txt = label;
				
			var _nodeKey = string_pos(">", _txt)? string_copy(_txt, 1, string_pos(">", _txt) - 1) : _txt;
			var _node    = struct_try_get(ALL_NODES, _nodeKey, noone);
			if(_node != noone) _spr = [ _node.spr, 0, .5, c_white ];
				
			if(_spr != noone) {
				var spr = array_safe_get_fast(_spr, 0, _spr);
				var sca = (_h - ui(10)) / sprite_get_height(spr);
				var ind = array_safe_get_fast(_spr, 1, 0);
				var clr = array_safe_get_fast(_spr, 3, COLORS._main_icon);
				
				gpu_set_tex_filter(true);
				draw_sprite_ext(spr, ind, dialog_x + ui(24), yy + hght / 2, sca, sca, 0, clr, _menuItem.active * 0.5 + 0.25);
				gpu_set_tex_filter(false);
			}
			
			if(_menuItem.toggle != noone) {
				var tog = _menuItem.toggle(_menuItem);
				if(tog) draw_sprite_ui(THEME.icon_toggle, 0, dialog_x + ui(24), yy + hght / 2,,,, COLORS._main_icon);
			}
			
			var tx = dialog_x + show_icon * ui(32) + ui(16);
			var ty = yy + hght / 2;
			var ta = _menuItem.active * 0.75 + 0.25;
			
			if(string_pos(">", label)) {
				var _sp = string_split(label, ">");
				var _txt = _sp[0];
				if(struct_has(ALL_NODES, _txt)) _txt = ALL_NODES[$ _txt].name;
				
				draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub, ta);
    			draw_text_add(tx, ty, _txt);
    			tx += string_width(_txt) + ui(8);
    			
    			draw_set_text(font, fa_left, fa_center, COLORS._main_text, ta);
				draw_text_add(tx, ty, _sp[1]);
				
			} else {
    			draw_set_text(font, fa_left, fa_center, COLORS._main_text, ta);
				draw_text_add(tx, ty, _node == noone? _txt : _node.name);
			}
			
			draw_set_alpha(1);
    		
			if(_menuItem.isShelf) {
				draw_sprite_ui_uniform(THEME.arrow, 0, dialog_x + dialog_w - ui(20), yy + hght / 2, 1, COLORS._main_icon);	
				_hx -= ui(24);
			}
		}
		
		if(_key) {
			draw_set_font(font);
			
			var _ktxt = key_get_name(_key.key, _key.modi);
			var _tw = string_width(_ktxt);
			var _th = line_get_height();
			
			var _bx = _hx - _tw - ui(4);
			var _by = _hy - _th / 2 - ui(3);
			var _bw = _tw + ui(8);
			var _bh = _th + ui(6);
			
			draw_set_text(font, fa_right, fa_center, COLORS._main_accent);
			
			if(hk_editing == _menuItem) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, COLORS._main_text_accent);
				
				draw_set_color(COLORS._main_accent);
				if(_ktxt == "") _ktxt = "-";
				
			} else if(_ktxt != "") {
				draw_set_color(COLORS._main_text_sub);
			}
			
			draw_text_add(_hx, _hy - ui(2), _ktxt);
		}
		
		yy += _h;
	}
	
	if(hk_editing != noone) {
		if(KEYBOARD_ENTER)  hk_editing = noone;
		else hotkey_editing(hk_editing.hoykeyObject);
			
		if(keyboard_check_pressed(vk_escape)) hk_editing = noone;
			
	} else if(sFOCUS) {
		if(KEYBOARD_PRESSED == vk_up) {
			selecting--;
			if(selecting < 0) selecting = array_length(menu) - 1;
		}
			
		if(KEYBOARD_PRESSED == vk_down)
			selecting = safe_mod(selecting + 1, array_length(menu));
		
		if(keyboard_check_pressed(vk_escape)) {
			DIALOG_POSTDRAW
			instance_destroy();
			exit;
		}
	}
	
	draw_sprite_stretched(THEME.box_r2_clr, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	if(mouse_init_inside && (mouse_release(mb_left) || mouse_release(mb_right))) 
		mouse_init_inside = false;
		
	if(mouse_release(mb_right)) 
		mouse_init_r_pressed = false;
#endregion

#region debug
	if(global.FLAG[$ "context_menu_id"]) {
		draw_set_color(c_white);
		draw_rectangle_border(dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h, 2);
		
		draw_set_text(f_p0, fa_left, fa_bottom);
		draw_text_add(dialog_x, dialog_y - ui(2), menu_id);
	}
#endregion

DIALOG_POSTDRAW

if(to_del != noone) instance_destroy(to_del);
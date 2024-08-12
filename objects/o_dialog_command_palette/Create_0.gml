/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	draggable = false;
	selecting = 0;
	
	text_pad = ui(8);
	item_pad = ui(6);
	
	dialog_w  = ui(480);
	dialog_h  = ui(32) + line_get_height(f_p2, item_pad);
	
	setFocus(self.id);
	
	data = [];
	keys = variable_struct_get_names(FUNCTIONS);
	
	hk_editing = noone;
	edit_block = 0;
	
	search_string	= "";
	KEYBOARD_STRING	= "";
	
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) { 
		search_string = string(str); 
		searchMenu();
	});
	
	selecting_hotkey = noone;
	tb_search.hide   = 2;
	tb_search.font	 = f_p2;
	tb_search.align	 = fa_left;
	tb_search.auto_update = true;
	tb_search.activate("");
	
	_prex = mouse_mx;
	_prey = mouse_my;
	
	keyboard_trigger = false;
	
	function searchMenu() {
		data = [];
		var pr_list      = ds_priority_create();
		var search_lower = string_lower(search_string);
		
		for (var i = 0, n = array_length(keys); i < n; i++) {
			var k     = keys[i];
			var _menu = FUNCTIONS[$ k];
			
			var _cnxt = _menu.context;
			var _name = _menu.name;
			var _fname = $"{string_lower(_cnxt)} {string_lower(_name)}"
			
			var match = string_partial_match(_fname, search_lower);
			if(match == -9999) continue;
				
			ds_priority_add(pr_list, _menu, match);
		}
		
		repeat(ds_priority_size(pr_list))
			array_push(data, ds_priority_delete_max(pr_list));
		
		ds_priority_destroy(pr_list);
		
		var hght = line_get_height(f_p2, item_pad);
		var _hh  = min(ui(32) + max(1, array_length(data)) * hght , ui(400))
		
		dialog_h = _hh;
		sc_content.resize(dialog_w - ui(4), dialog_h - ui(32));
	} 
	
	sc_content = new scrollPane(dialog_w - ui(4), dialog_h - ui(32), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hght = line_get_height(f_p2, item_pad);
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		
		draw_set_color(CDEF.main_mdblack);
		draw_rectangle(0, 0, ui(32), dialog_h, false);

		var mouse_move = _prex != mouse_mx || _prey != mouse_my;
		if(mouse_move) keyboard_trigger = false;
		
		for(var i = 0; i < array_length(data); i++) {
			var _menu = data[i];
			
			var _menuItem = _menu.menu;
			var _key	  = _menu.hotkey;
			var _mhover   = mouse_move && point_in_rectangle(_m[0], _m[1], 0, _ly, _dw, _ly + hght - 1); 
			
			if(selecting == i) {
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, dialog_w, hght, COLORS.dialog_menubox_highlight, 1);
				
				if(sc_content.active) {
					if((!keyboard_trigger && mouse_press(mb_left)) || keyboard_check_pressed(vk_enter)) {
						_menu.action();
						instance_destroy();
					}
					
					if(mouse_press(mb_right)) {
						selecting_hotkey = _key;
						
						var _loadKey = _key.full_name();
						var context_menu_settings = [
							_loadKey,
							menuItem("Edit hotkey", function() /*=>*/ {
								hk_editing        = selecting_hotkey;
								keyboard_lastchar = selecting_hotkey.key;
								
								tb_search.deactivate();
							}),
						];
						
						item_selecting = menuCall("command_palette_item", context_menu_settings);
					}
				}
			}
			
			if(sc_content.hover && _mhover) {
				sc_content.hover_content = true;
				selecting = i;
			}
			
			var _cnxt = _menu.context;
			var _name = _menu.name;
			var _tx   = text_pad + ui(32);
			var _ty   = _ly + hght / 2;
			
			if(_cnxt != "") {
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
				draw_text_add(_tx, _ty, _cnxt);
				_tx += string_width(_cnxt);
				
				draw_sprite_ext(THEME.arrow, 0, _tx + ui(8), _ty, .75, .75, 0, COLORS._main_text_sub);
				_tx += ui(16);
			}
			
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_icon_light);
			draw_text_match_ext(_tx, _ty, _name, _dw, search_string);
			
			if(_menuItem != noone && _menuItem.spr != noone) {
				var spr = is_array(_menuItem.spr)? _menuItem.spr[0] : _menuItem.spr;
				var ind = is_array(_menuItem.spr)? _menuItem.spr[1] : 0;
				draw_sprite_ui(spr, ind, ui(16), _ty, .75, .75, 0, COLORS._main_icon, 0.75);
			}
			
			if(_key != noone) {
				var _hx = _dw - ui(6);
				var _hy = _ty + ui(1);
				
				draw_set_font(f_p2);
				
				var _ktxt = key_get_name(_key.key, _key.modi);
				var _tw = string_width(_ktxt);
				var _th = line_get_height();
				
				var _bx = _hx - _tw - ui(4);
				var _by = _hy - _th / 2 - ui(2);
				var _bw = _tw + ui(8);
				var _bh = _th + ui(2);
				
				if(hk_editing == _key) {
					draw_set_text(f_p2, fa_right, fa_center, COLORS._main_accent);
					draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, COLORS._main_text_accent);
					
				} else if(_ktxt != "") {
					draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text_sub);
					draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, CDEF.main_dkgrey);
				}
				
				draw_text_add(_hx, _hy, _ktxt);
			}
			
			_ly += hght;
			_h  += hght;
		}
		
		if(hk_editing != noone) {
			edit_block = 2;
			
			if(keyboard_check_pressed(vk_enter))
				hk_editing = noone;
			else 
				hotkey_editing(hk_editing);
				
			if(keyboard_check_pressed(vk_escape))
				hk_editing = noone;
				
		} else if(sc_content.active) {
			if(keyboard_check_pressed(vk_up)) {
				keyboard_trigger = true;
				selecting--;
				if(selecting < 0) selecting = array_length(data) - 1;
			}
			
			if(keyboard_check_pressed(vk_down)) {
				keyboard_trigger = true;
				selecting = safe_mod(selecting + 1, array_length(data));
			}
				
			if(keyboard_check_pressed(vk_escape))
				instance_destroy();
		}
		
		_prex = mouse_mx;
		_prey = mouse_my;
	
		return _h;
	});
	
	
	function resetPosition() {
		if(!active) return;
		
		dialog_x = xstart - dialog_w / 2;
		dialog_y = ystart - ui(480) / 2;
	}
	
#endregion
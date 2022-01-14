/// @description init
event_inherited();

#region data
	dialog_w = 640;
	dialog_h = 480;
	
	destroy_on_click_out = true;
	destroy_on_escape    = false;
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = 640;
	dialog_h_min = 400;
	dialog_w_max = 1200;
	dialog_h_max = 800;
	
	onResize = function() {
		sp_pref.resize(dialog_w - 160 - 32, dialog_h - 56 - 28);
		sp_hotkey.resize(dialog_w - 160 - 32, dialog_h - 56 - 28);
	}
#endregion

#region pages
	page_current = 0;
	page[0] = "Global data";
	page[1] = "Node data";
	page[2] = "Hotkeys";
	
	pref_global = ds_list_create();
	pref_node = ds_list_create();
	
	ds_list_add(pref_global, [
		"Show welcome screen",
		"show_splash",
		new checkBox(function() { 
			PREF_MAP[? "show_splash"] = !PREF_MAP[? "show_splash"];
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Reset preview on focus",
		"reset_display",
		new checkBox(function() { 
			PREF_MAP[? "reset_display"] = !PREF_MAP[? "reset_display"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Curve connection line",
		"curve_connection_line",
		new checkBox(function() { 
			PREF_MAP[? "curve_connection_line"] = !PREF_MAP[? "curve_connection_line"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Double click delay",
		"double_click_delay",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "double_click_delay"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Default surface size",
		"default_surface_side",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "default_surface_side"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Node snapping (set to 1 for no snap)",
		"node_snapping",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "node_snapping"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	//NODE
	
	ds_list_add(pref_node, [
		"[Particle] Max particles",
		"part_max_amount",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "part_max_amount"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, [
		"[Separate shape] Max shapes",
		"shape_separation_max",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "shape_separation_max"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	current_list = pref_global;
	
	sp_pref = new scrollPane(dialog_w - 160 - 32, dialog_h - 64 - 28, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		var hh		= 0;
		var th		= 34;
		var x1		= dialog_w - 160 - 32 - 8;
		var yy		= _y + 8;
		var padd	= 6;
		
		for(var i = 0; i < ds_list_size(current_list); i++) {
			var _pref = current_list[| i];
			var name = _pref[0];
			
			if(search_text == "" || string_pos(string_lower(search_text), string_lower(name)) > 0) {
				if(i % 2 == 0) {
					draw_sprite_stretched_ext(s_ui_panel_bg, 0, 0, yy - padd, dialog_w - 200, th + padd * 2, c_ui_blue_white, 1);
				}
				
				draw_set_text(f_p1, fa_left, fa_center, c_white);
				draw_text(8, yy + 17, _pref[0]);
				_pref[2].active = FOCUS == self; 
				_pref[2].hover  = HOVER == self;
				
				switch(instanceof(_pref[2])) {
					case "textBox" :
						_pref[2].draw(x1 - 100, yy, 96, 34, PREF_MAP[? _pref[1]], _m);
						break;
					case "checkBox" :
						_pref[2].draw(x1 - 36, yy + 2, PREF_MAP[? _pref[1]], _m);
						break;
				}
				
				yy += th + padd + 8;
				hh += th + padd + 8;
			}
		}
		
		return hh;
	});
#endregion

#region search
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) {
		search_text = str;
	});
	
	search_text = "";
#endregion

#region hotkey
	vk_list = [ vk_left, vk_right, vk_up, vk_down, vk_space, vk_backspace, vk_tab, vk_home, vk_end, vk_delete, vk_insert, 
		vk_pageup, vk_pagedown, vk_pause, vk_printscreen, 
		vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
		];
	hk_editing = noone;
	
	sp_hotkey = new scrollPane(dialog_w - 160 - 32, dialog_h - 64 - 28, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		var padd		= 8;
		var hh			= 0;
		var currGroup	= -1;
		var x1			= dialog_w - 160 - 32;
		
		for(var j = 0; j < ds_list_size(HOTKEY_CONTEXT); j++) {
			var ll = HOTKEYS[? HOTKEY_CONTEXT[| j]];
			
			for(var i = 0; i < ds_list_size(ll); i++) {
				var key = ll[| i];
				var group = key.context;
				var name  = key.name;
				var pkey  = key.key;
				//var modi  = key.modi;
				
				if(search_text != "" && string_pos(string_lower(search_text), string_lower(name)) == 0)
					continue;
				
				if(group != currGroup) {
					if(group != "") hh += 12;
					draw_set_text(f_p0b, fa_left, fa_top, c_ui_blue_grey);
					draw_text(32, _y + hh, group == ""? "Global" : group);
					
					hh += string_height("l") + 16;
					currGroup = group;
				}
				draw_set_text(f_p0, fa_left, fa_top, c_white);
				var th = string_height("l");
			
				if(i % 2 == 0) {
					draw_sprite_stretched_ext(s_ui_panel_bg, 0, 0, _y + hh - padd, 
						dialog_w - 160 - 32, th + padd * 2, c_ui_blue_white, 1);
				}
			
				draw_set_text(f_p0, fa_left, fa_top, c_white);
				draw_text(16, _y + hh, name);
			
				var dk = key_get_name(key.key, key.modi);
				var kw = string_width(dk);
			
				if(hk_editing == key) {
					var _mod_prs = 0;
					
					if(keyboard_check(vk_control))	_mod_prs |= MOD_KEY.ctrl;
					if(keyboard_check(vk_shift))	_mod_prs |= MOD_KEY.shift;
					if(keyboard_check(vk_alt))		_mod_prs |= MOD_KEY.alt;
	
					if(keyboard_check_pressed(vk_escape)) {
						key.key	 = "";
						key.modi = 0;
						
						PREF_SAVE();
					} else if(keyboard_check_pressed(vk_anykey)) {
						var press = false;
						for(var a = 32; a <= 126; a++) {
							if(keyboard_check_pressed(a)) {
								key.key	 = ord(string_upper(ansi_char(a)));
								press = true;
								break;
							}
						}
						if(!press) {
							for(var a = 0; a < array_length(vk_list); a++) {
								if(keyboard_check_pressed(vk_list[a])) {	
									key.key = vk_list[a];
									press = true; 
									break;
								}
							}
						}
						
						if(press) key.modi = _mod_prs;
						PREF_SAVE();
					}
					
					draw_sprite_stretched(s_button_hide, 2, x1 - 24 - kw - 16, _y + hh - 6, kw + 32, th + 12);
				} else {
					if(buttonInstant(s_button_hide, x1 - 24 - kw - 16, _y + hh - 6, kw + 32, th + 12, _m, FOCUS == self, HOVER == self) == 2) {
						hk_editing = key;
						keyboard_lastchar = pkey;
					}
				}
				draw_set_text(f_p0, fa_right, fa_top, hk_editing == key? c_ui_orange : c_white);
				draw_text(x1 - 24, _y + hh, dk);
				
				hh += th + padd * 2;
			}
		}
		
		return hh;
	})
#endregion
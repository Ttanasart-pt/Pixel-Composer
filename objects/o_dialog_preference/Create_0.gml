/// @description init
event_inherited();

#region data
	dialog_w = ui(640);
	dialog_h = ui(480);
	
	destroy_on_click_out = true;
	destroy_on_escape    = false;
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = ui(640);
	dialog_h_min = ui(480);
	
	onResize = function() {
		sp_pref.resize(dialog_w - ui(192), dialog_h - ui(88));
		sp_hotkey.resize(dialog_w - ui(192), dialog_h - ui(88));
		sp_colors.resize(dialog_w - ui(192), dialog_h - ui(128));
	}
#endregion

#region pages
	page_current = 0;
	page[0] = "General";
	page[1] = "Node settings";
	page[2] = "Appearances";
	page[3] = "Colors";
	page[4] = "Hotkeys";
	
	pref_global = ds_list_create();
	
	ds_list_add(pref_global, [
		"Show welcome screen",
		"show_splash",
		new checkBox(function() { 
			PREF_MAP[? "show_splash"] = !PREF_MAP[? "show_splash"];
			PREF_SAVE();
		})
	]);
	
	PREF_MAP[? "_display_scaling"] = PREF_MAP[? "display_scaling"];
	ds_list_add(pref_global, [
		"GUI scaling",
		"_display_scaling",
		new slider(0.5, 2, 0.01, function(val) { 
			PREF_MAP[? "_display_scaling"] = val;
			PREF_SAVE();
		}, function() { 
			PREF_MAP[? "_display_scaling"] = clamp(PREF_MAP[? "_display_scaling"], 0.5, 2);
			if(PREF_MAP[? "display_scaling"] == PREF_MAP[? "_display_scaling"])
				return;
				
			PREF_MAP[? "display_scaling"] = PREF_MAP[? "_display_scaling"];
			setPanel();
			loadFonts();
			
			time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, onResize));
		})
	]);
	
	ds_list_add(pref_global, [
		"Double click delay",
		"double_click_delay",
		new slider(0, 1, 0.01, function(val) { 
			PREF_MAP[? "double_click_delay"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Keyboard hold start",
		"keyboard_repeat_start",
		new slider(0, 1, 0.01, function(val) { 
			PREF_MAP[? "keyboard_repeat_start"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Keyboard repeat delay",
		"keyboard_repeat_speed",
		new slider(0, 1, 0.01, function(val) { 
			PREF_MAP[? "keyboard_repeat_speed"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"UI frame rate",
		"ui_framerate",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "ui_framerate"] = max(15, round(real(str)));
			game_set_speed(PREF_MAP[? "ui_framerate"], gamespeed_fps);
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
		"Show node render time",
		"node_show_time",
		new checkBox(function() { 
			PREF_MAP[? "node_show_time"] = !PREF_MAP[? "node_show_time"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Show node render status",
		"node_show_render_status",
		new checkBox(function() { 
			PREF_MAP[? "node_show_render_status"] = !PREF_MAP[? "node_show_render_status"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Collection preview speed",
		"collection_preview_speed",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "collection_preview_speed"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	
	ds_list_add(pref_global, [
		"Inspector line break width",
		"inspector_line_break_width",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "inspector_line_break_width"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Expand hovering panel",
		"expand_hover",
		new checkBox(function() { 
			PREF_MAP[? "expand_hover"] = !PREF_MAP[? "expand_hover"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Graph zoom smoothing",
		"graph_zoom_smoooth",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "graph_zoom_smoooth"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Warning notification time",
		"notification_time",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "notification_time"] = max(0, round(real(str)));
			PREF_SAVE();
		})
	]);

#endregion

#region //NODE
	pref_node = ds_list_create();
	
	ds_list_add(pref_node, "Particle");
	ds_list_add(pref_node, [
		"Max particles",
		"part_max_amount",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "part_max_amount"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Separate shape");
	ds_list_add(pref_node, [
		"Max shapes",
		"shape_separation_max",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "shape_separation_max"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Levels");
	ds_list_add(pref_node, [
		"Histogram resolution",
		"level_resolution",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "level_resolution"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, [
		"Maximum sampling",
		"level_max_sampling",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "level_max_sampling"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Physic");
	ds_list_add(pref_node, [
		"Verlet iteration",
		"verlet_iteration",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "verlet_iteration"] = real(str); 
			PREF_SAVE();
		})
	]);
#endregion

#region appearance
	pref_appr = ds_list_create();
	
	ds_list_add(pref_appr, "Graph");
	ds_list_add(pref_appr, [
		"Connection thickness",
		"connection_line_width",
		new textBox(TEXTBOX_INPUT.float, function(str) { 
			PREF_MAP[? "connection_line_width"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_appr, [
		"Connection curve smoothness",
		"connection_line_sample",
		new textBox(TEXTBOX_INPUT.float, function(str) { 
			PREF_MAP[? "connection_line_sample"] = real(str); 
			PREF_SAVE();
		})
	]);
#endregion

#region theme
	themes = [];
	var f = file_find_first(DIRECTORY + "themes/*", fa_directory);
	while(f != "") {
		if(directory_exists(DIRECTORY + "themes/" + f))
			array_push(themes, f);
		f = file_find_next();
	}
	file_find_close();
	
	sb_theme = new scrollBox(themes, function(index) { 
			var thm = themes[index]
			if(PREF_MAP[? "theme"] == thm) return;
			PREF_MAP[? "theme"] = thm;
			PREF_SAVE();
			
			loadFonts();
			loadGraphic(thm);
			loadColor(thm);
		});
	sb_theme.align = fa_left;
	
	sp_colors = new scrollPane(dialog_w - ui(192), dialog_h - ui(128), function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hh		= 0;
		var th		= ui(28);
		var x1		= sp_colors.surface_w;
		var yy		= _y + ui(8);
		var padd	= ui(6);
		var ind		= 0;
		
		var cw = ui(100);
		var ch = th - ui(4);
		var cx = x1 - cw;
		var category = "";
		
		for( var i = 0; i < array_length(COLOR_KEYS); i++ ) {
			var key = COLOR_KEYS[i];
			var val = variable_struct_get(COLORS, key);
			
			if(search_text != "" && string_pos(string_lower(search_text), string_lower(key)) == 0)
				continue;
				
			if(is_array(val)) continue;
			var spl = string_splice(key, "_");
			var cat = spl[0] == ""? spl[1] : spl[0];
			if(cat != category) {
				category = cat;
				draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_sub);
				draw_text(ui(16), yy, string_title(category));
				yy += string_height(category) + ui(8);
				hh += string_height(category) + ui(8);
				ind = 0;
			}
			
			if(ind % 2 == 0)
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy - padd, sp_colors.w, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
					
			var keyStr = string_replace_all(key, "_", " ");
			keyStr = string_replace(keyStr, cat + " ", "");
			keyStr = string_title(keyStr);
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(8), yy + th / 2, keyStr);
			
			var b = buttonInstant(THEME.button, cx, yy + ui(2), cw, ch, _m, sFOCUS, sHOVER && sp_colors.hover);
			draw_sprite_stretched_ext(THEME.color_picker_sample, 0, cx + ui(2), yy + ui(2 + 2), cw - ui(4), ch - ui(4), val, 1);
			
			if(b == 2) {
				var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
				dialog.selector.setColor(val);
				self.key = key;
				dialog.onApply = function(color) { 
					variable_struct_set(COLORS, self.key, color); 
					overrideColor();
				};
				dialog.selector.onApply = dialog.onApply;
			}
			
			yy += th + padd + ui(8);
			hh += th + padd + ui(8);
			ind++;
		}
		
		return hh;
	});
	
	function overrideColor() {
		var path = DIRECTORY + "themes/" + PREF_MAP[? "theme"] + "/override.json";
		var f = file_text_open_write(path);
		file_text_write_string(f, json_stringify(COLORS));
		file_text_close(f);
	}
#endregion

#region draw
	current_list = pref_global;
	
	sp_pref = new scrollPane(dialog_w - ui(192), dialog_h - ui(88), function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hh		= 0;
		var th		= TEXTBOX_HEIGHT;
		var x1		= sp_pref.surface_w;
		var yy		= _y + ui(8);
		var padd	= ui(6);
		var ind		= 0;
		
		for(var i = 0; i < ds_list_size(current_list); i++) {
			var _pref = current_list[| i];
			
			if(is_string(_pref)) {
				draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_sub);
				draw_text(ui(16), yy, _pref);
				yy += string_height(_pref) + ui(8);
				hh += string_height(_pref) + ui(8);
				ind = 0;
				continue;
			}
			
			var name = _pref[0];
			
			if(search_text != "" && string_pos(string_lower(search_text), string_lower(name)) == 0)
				continue;
			
			if(ind % 2 == 0)
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy - padd, sp_pref.w, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
				
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(8), yy + th / 2, _pref[0]);
			_pref[2].active = sFOCUS; 
			_pref[2].hover  = sHOVER && sp_pref.hover;
				
			switch(instanceof(_pref[2])) {
				case "textBox" :
					_pref[2].draw(x1 - ui(4), yy + th / 2, ui(88), th, PREF_MAP[? _pref[1]], _m,, fa_right, fa_center);
					break;
				case "checkBox" :
					_pref[2].draw(x1 - ui(48), yy + th / 2, PREF_MAP[? _pref[1]], _m,, fa_center, fa_center);
					break;
				case "slider" :
					_pref[2].draw(x1 - ui(4), yy + th / 2, ui(200), th, PREF_MAP[? _pref[1]], _m, ui(88), fa_right, fa_center);
					break;
				case "scrollBox" :
					var _w = ui(200);
					var _h = th;
						
					_pref[2].align = fa_left;
					_pref[2].draw(x1 - ui(4) - _w, yy + th / 2 - _h / 2, _w, _h, PREF_MAP[? _pref[1]], _m, _r[0], _r[1]);
					break;
			}
				
			yy += th + padd + ui(8);
			hh += th + padd + ui(8);
			ind++;
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
	vk_list = [ 
		vk_left, vk_right, vk_up, vk_down, vk_space, vk_backspace, vk_tab, vk_home, vk_end, vk_delete, vk_insert, 
		vk_pageup, vk_pagedown, vk_pause, vk_printscreen, 
		vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
	];
	hk_editing = noone;
	
	sp_hotkey = new scrollPane(dialog_w - ui(192), dialog_h - ui(88), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var padd		= ui(8);
		var hh			= 0;
		var currGroup	= -1;
		var x1			= sp_hotkey.surface_w;
		
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
					if(group != "") hh += ui(12);
					draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_sub);
					draw_text(ui(16), _y + hh, group == ""? "Global" : group);
					
					hh += string_height("l") + ui(16);
					currGroup = group;
				}
				draw_set_text(f_p0, fa_left, fa_top);
				var th = string_height("l");
			
				if(i % 2 == 0) {
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y + hh - padd, 
						sp_hotkey.w, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
				}
			
				draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
				draw_text(ui(16), _y + hh, name);
			
				var dk = key_get_name(key.key, key.modi);
				var kw = string_width(dk);
			
				if(hk_editing == key) {
					var _mod_prs = 0;
					
					if(key_mod_press(CTRL))	_mod_prs |= MOD_KEY.ctrl;
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
					
					draw_sprite_stretched(THEME.button_hide, 2, x1 - ui(40) - kw, _y + hh - ui(6), kw + ui(32), th + ui(12));
				} else {
					if(buttonInstant(THEME.button_hide, x1 - ui(40) - kw, _y + hh - ui(6), kw + ui(32), th + ui(12), 
						_m, sFOCUS, sHOVER && sp_hotkey.hover) == 2) {
							hk_editing = key;
							keyboard_lastchar = pkey;
					}
				}
				draw_set_text(f_p0, fa_right, fa_top, hk_editing == key? COLORS._main_text_accent : COLORS._main_text);
				draw_text(x1 - ui(24), _y + hh, dk);
				
				hh += th + padd * 2;
			}
		}
		
		return hh;
	})
#endregion


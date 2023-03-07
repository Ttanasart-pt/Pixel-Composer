/// @description init
event_inherited();

#region data
	dialog_w = ui(640);
	dialog_h = ui(480);
	
	page_width = 160;
	destroy_on_click_out = true;
	destroy_on_escape    = false;
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = ui(640);
	dialog_h_min = ui(480);
	
	onResize = function() {
		sp_pref.resize(dialog_w - ui(padding + padding + page_width), dialog_h - ui(title_height + padding));
		sp_hotkey.resize(dialog_w - ui(padding + padding + page_width), dialog_h - ui(title_height + padding));
		sp_colors.resize(dialog_w - ui(padding + padding + page_width), dialog_h - (title_height + ui(padding + 40)));
	}
#endregion

#region pages
	page_current = 0;
	page[0] = get_text("pref_pages_general",	"General");
	page[1] = get_text("pref_pages_nodes",		"Node settings");
	page[2] = get_text("pref_pages_appearance", "Appearances");
	page[3] = get_text("pref_pages_theme",		"Theme");
	page[4] = get_text("pref_pages_hotkeys",	"Hotkeys");
	
	pref_global = ds_list_create();
	
	ds_list_add(pref_global, [
		get_text("pref_show_welcome_screen", "Show welcome screen"),
		"show_splash",
		new checkBox(function() { 
			PREF_MAP[? "show_splash"] = !PREF_MAP[? "show_splash"];
			PREF_SAVE();
		})
	]);
	
	PREF_MAP[? "_display_scaling"] = PREF_MAP[? "display_scaling"];
	ds_list_add(pref_global, [
		get_text("pref_gui_scaling", "GUI scaling"),
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
		get_text("auto_save_time", "Autosave delay (-1 to disable)"),
		"auto_save_time",
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			PREF_MAP[? "auto_save_time"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_double_click_delay", "Double click delay"),
		"double_click_delay",
		new slider(0, 1, 0.01, function(val) { 
			PREF_MAP[? "double_click_delay"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_keyboard_hold_start", "Keyboard hold start"),
		"keyboard_repeat_start",
		new slider(0, 1, 0.01, function(val) { 
			PREF_MAP[? "keyboard_repeat_start"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_keyboard_repeat_delay", "Keyboard repeat delay"),
		"keyboard_repeat_speed",
		new slider(0, 1, 0.01, function(val) { 
			PREF_MAP[? "keyboard_repeat_speed"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_ui_frame_rate", "UI frame rate"),
		"ui_framerate",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "ui_framerate"] = max(15, round(real(str)));
			game_set_speed(PREF_MAP[? "ui_framerate"], gamespeed_fps);
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_default_surface_size", "Default surface size"),
		"default_surface_side",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "default_surface_side"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_show_node_render_time", "Show node render time"),
		"node_show_time",
		new checkBox(function() { 
			PREF_MAP[? "node_show_time"] = !PREF_MAP[? "node_show_time"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_show_node_render_status", "Show node render status"),
		"node_show_render_status",
		new checkBox(function() { 
			PREF_MAP[? "node_show_render_status"] = !PREF_MAP[? "node_show_render_status"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_collection_preview_speed", "Collection preview speed"),
		"collection_preview_speed",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "collection_preview_speed"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	
	ds_list_add(pref_global, [
		get_text("pref_inspector_line_break_width", "Inspector line break width"),
		"inspector_line_break_width",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "inspector_line_break_width"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_expand_hovering_panel", "Expand hovering panel"),
		"expand_hover",
		new checkBox(function() { 
			PREF_MAP[? "expand_hover"] = !PREF_MAP[? "expand_hover"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_graph_zoom_smoothing", "Graph zoom smoothing"),
		"graph_zoom_smoooth",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "graph_zoom_smoooth"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		get_text("pref_warning_notification_time", "Warning notification time"),
		"notification_time",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "notification_time"] = max(0, round(real(str)));
			PREF_SAVE();
		})
	]);

	ds_list_add(pref_global, [
		get_text("pref_enable_test_mode", "Enable test mode (require restart)"),
		"test_mode",
		new checkBox(function() { 
			PREF_MAP[? "test_mode"] = !PREF_MAP[? "test_mode"]; 
			PREF_SAVE();
		})
	]);

	ds_list_add(pref_global, [
		get_text("pref_legacy_exception", "Use legacy exception handler"),
		"use_legacy_exception",
		new checkBox(function() { 
			PREF_MAP[? "use_legacy_exception"] = !PREF_MAP[? "use_legacy_exception"]; 
			PREF_APPLY();
			PREF_SAVE();
		})
	]);
	
#endregion

#region //NODE
	pref_node = ds_list_create();
	
	ds_list_add(pref_node, "Particle");
	ds_list_add(pref_node, [
		get_text("pref_max_particles", "Max particles"),
		"part_max_amount",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "part_max_amount"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Separate shape");
	ds_list_add(pref_node, [
		get_text("pref_max_shapes", "Max shapes"),
		"shape_separation_max",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "shape_separation_max"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Levels");
	ds_list_add(pref_node, [
		get_text("pref_histogram_resolution", "Histogram resolution"),
		"level_resolution",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "level_resolution"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, [
		get_text("pref_maximum_sampling", "Maximum sampling"),
		"level_max_sampling",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "level_max_sampling"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Physics");
	ds_list_add(pref_node, [
		get_text("pref_verlet_iteration", "Verlet iteration"),
		"verlet_iteration",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "verlet_iteration"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, [
		get_text("pref_gravity", "Gravity"),
		"physics_gravity",
		new vectorBox(2, TEXTBOX_INPUT.number, function(index, val) { 
			PREF_MAP[? "physics_gravity"][index] = val; 
			physics_world_gravity(PREF_MAP[? "physics_gravity"][0], PREF_MAP[? "physics_gravity"][1]);
			PREF_SAVE();
		})
	]);
#endregion

#region appearance
	pref_appr = ds_list_create();
	
	ds_list_add(pref_appr, "Graph");
	ds_list_add(pref_appr, [
		get_text("pref_connection_thickness", "Connection thickness"),
		"connection_line_width",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "connection_line_width"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_appr, [
		get_text("pref_connection_curve_smoothness", "Connection curve smoothness"),
		"connection_line_sample",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "connection_line_sample"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_appr, [
		get_text("pref_connection_aa", "Connection anti aliasing"),
		"connection_line_aa",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "connection_line_aa"] = max(1, real(str)); 
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
	
	sp_colors = new scrollPane(dialog_w - ui(padding + padding + page_width), dialog_h - (title_height + ui(padding) + ui(40)), function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hh		= 0;
		var th		= ui(28);
		var x1		= sp_colors.surface_w;
		var yy		= _y + ui(8);
		var padd	= ui(6);
		var ind		= 0;
		
		var cw = ui(100);
		var ch = th - ui(4);
		var cx = x1 - cw - ui(8);
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
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy - padd, sp_colors.surface_w, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
					
			var keyStr = string_replace_all(key, "_", " ");
			keyStr = string_replace(keyStr, cat + " ", "");
			keyStr = string_title(keyStr);
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(8), yy + th / 2, keyStr);
			
			var b = buttonInstant(THEME.button, cx, yy + ui(2), cw, ch, _m, sFOCUS, sHOVER && sp_colors.hover);
			draw_sprite_stretched_ext(THEME.color_picker_sample, 0, cx + ui(2), yy + ui(2 + 2), cw - ui(4), ch - ui(4), val, 1);
			
			if(b == 2) {
				var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
				dialog.setDefault(val);
				self.key = key;
				dialog.onApply = function(color) { 
					variable_struct_set(COLORS, self.key, color); 
					overrideColor();
				};
				dialog.selector.onApply = dialog.onApply;
				
				addChildren(dialog);
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
	
	sp_pref = new scrollPane(dialog_w - ui(padding + padding + page_width), dialog_h - ui(title_height + padding), function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hh		= 0;
		var th		= TEXTBOX_HEIGHT;
		var x1		= sp_pref.surface_w;
		var yy		= _y + ui(8);
		var padd	= ui(6);
		var ind		= 0;
		
		for(var i = 0; i < ds_list_size(current_list); i++) {
			var _pref = current_list[| i];
			if(is_string(_pref)) continue;
			
			var name = _pref[0];
			if(search_text != "" && string_pos(string_lower(search_text), string_lower(name)) == 0)
				continue;
			
			_pref[2].register(sp_pref);
		}
		
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
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy - padd, sp_pref.surface_w, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
				
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(8), yy + th / 2, _pref[0]);
			_pref[2].setActiveFocus(sFOCUS, sHOVER && sp_pref.hover); 
				
			switch(instanceof(_pref[2])) {
				case "textBox" :
					_pref[2].draw(x1 - ui(4), yy + th / 2, ui(88), th, PREF_MAP[? _pref[1]], _m,, fa_right, fa_center);
					break;
				case "vectorBox" :
					_pref[2].draw(x1 - ui(4 + 200), yy, ui(200), th, PREF_MAP[? _pref[1]], _m);
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
	tb_search.align	= fa_left;
	
	search_text = "";
#endregion

#region hotkey
	vk_list = [ 
		vk_left, vk_right, vk_up, vk_down, vk_space, vk_backspace, vk_tab, vk_home, vk_end, vk_delete, vk_insert, 
		vk_pageup, vk_pagedown, vk_pause, vk_printscreen, 
		vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
	];
	hk_editing = noone;
	
	sp_hotkey = new scrollPane(dialog_w - ui(padding + padding + page_width), dialog_h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var padd		= ui(8);
		var hh			= 0;
		var currGroup	= noone;
		var x1		= sp_hotkey.surface_w;
		var key_x1  = x1 - ui(32);
		var modified = false;
				
		for(var j = 0; j < ds_list_size(HOTKEY_CONTEXT); j++) {
			var ll = HOTKEYS[? HOTKEY_CONTEXT[| j]];
			
			for(var i = 0; i < ds_list_size(ll); i++) {
				var key = ll[| i];
				var group = key.context;
				var name  = key.name;
				var pkey  = key.key;
				var modi  = key.modi;
				
				var dkey  = key.dKey;
				var dmod  = key.dModi;
				
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
						sp_hotkey.surface_w, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
				}
			
				draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
				draw_text(ui(16), _y + hh, name);
				
				var dk = key.key == -1? "None" : key_get_name(key.key, key.modi);
				var kw = string_width(dk);
			
				if(hk_editing == key) {
					var _mod_prs = 0;
					
					if(key_mod_press(CTRL))		_mod_prs |= MOD_KEY.ctrl;
					if(key_mod_press(SHIFT))	_mod_prs |= MOD_KEY.shift;
					if(key_mod_press(ALT))		_mod_prs |= MOD_KEY.alt;
					
					if(keyboard_check_pressed(vk_escape)) {
						key.key	 = -1;
						key.modi = 0;
						
						PREF_SAVE();
					} else if(keyboard_check_pressed(vk_anykey)) {
						var press = false;
						
						for(var a = 0; a < array_length(vk_list); a++) {
							if(!keyboard_check_pressed(vk_list[a])) continue;
							key.key = vk_list[a];
							press = true; 
							break;
						}
												
						if(!press) {
							var k = ds_map_find_first(global.KEY_STRING_MAP);
							var amo = ds_map_size(global.KEY_STRING_MAP);
							repeat(amo) {
								if(!keyboard_check_pressed(k)) {
									k = ds_map_find_next(global.KEY_STRING_MAP, k);
									continue;
								}
								key.key	= k;
								press = true;
								break;
							}
						}
						
						if(press) key.modi = _mod_prs;
						PREF_SAVE();
					}
					
					draw_sprite_stretched(THEME.button_hide, 2, key_x1 - ui(40) - kw, _y + hh - ui(6), kw + ui(32), th + ui(12));
				} else {
					var bx = key_x1 - ui(40) - kw;
					var by = _y + hh - ui(6);
					if(buttonInstant(THEME.button_hide, bx, by, kw + ui(32), th + ui(12), _m, sFOCUS, sHOVER && sp_hotkey.hover) == 2) {
						hk_editing = key;
						keyboard_lastchar = pkey;
					}
				}
				
				var cc = key.key == -1? COLORS._main_text_sub : COLORS._main_text;
				if(hk_editing == key) cc = COLORS._main_text_accent;
				
				draw_set_text(f_p0, fa_right, fa_top, cc);
				draw_text(key_x1 - ui(24), _y + hh, dk);
				
				if(key.key != dkey || key.modi != dmod) {
					modified = true;
					var bx = x1 - ui(32);
					var by = _y + hh;
					if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), _m, sFOCUS, sHOVER && sp_hotkey.hover, get_text("reset", "Reset"), THEME.refresh_s) == 2) {
						key.key = dkey;
						key.modi = dmod;
					}
				}
				
				hh += th + padd * 2;
			}
		}
		
		if(modified) {
			var bx = x1 - ui(32);
			var by = _y + ui(2);
			if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), _m, sFOCUS, sHOVER && sp_hotkey.hover, get_text("reset_all", "Reset all"), THEME.refresh_s) == 2) {
				for(var j = 0; j < ds_list_size(HOTKEY_CONTEXT); j++) {
					var ll = HOTKEYS[? HOTKEY_CONTEXT[| j]];
					for(var i = 0; i < ds_list_size(ll); i++) {
						var key = ll[| i];
						key.key = key.dKey;
						key.modi = key.dModi;
					}
				}
			}
		}
		
		return hh;
	})
#endregion


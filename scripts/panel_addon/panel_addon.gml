function Panel_Addon() : PanelContent() constructor {
	title = "Addons";
	icon  = THEME.addon;
	
	showHeader	 = false;
	title_height = 64;
	padding		 = 24;
	
	#region data
		w = ui(400);
		h = ui(480);
		
		search_string = "";
		keyboard_lastchar = "";
		KEYBOARD_STRING = "";
		keyboard_lastkey = -1;
		
		search_res = [];
		tb_search = new textBox(TEXTBOX_INPUT.text, function(str) { 
			search_string = string(str); 
			searchAddons();
		});
		
		tb_search.align			= fa_left;
		tb_search.auto_update	= true;
		tb_search.boxColor		= COLORS._main_icon_light;
		WIDGET_CURRENT			= tb_search;
		
		function searchAddons() {
			search_res = [];
			
			for( var i = 0; i < array_length(ADDONS); i++ ) {
				if(string_pos(search_string, ADDONS[i].name))
					array_push(search_res, ADDONS[i]);
			}
		}
	#endregion
	
	function onResize() {
		PANEL_PADDING
		sc_addon.resize(w - ui(padding + padding), h - ui(title_height + padding + 40));
	}
	
	#region content
		sc_addon = new scrollPane(w - ui(padding + padding), h - ui(title_height + padding + 40), function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear, 0);
			var _h  = 0;
			var ww  = sc_addon.surface_w;
			var hg  = ui(40);
			var i   = 0;
		
			var arr = search_string == ""? ADDONS : search_res;
			
			for( var i = 0; i < array_length(arr); i++ ) {
				var _addon = arr[i];
				
				var bw = ui(28);
				var bh = ui(28);
				var bx = ww - ui(4) - bw;
				var by = _y;
				var hh = hg;
				var _act = addonActivated(_addon.name);
				
				if(_addon.open) {
					draw_set_font(f_p1);
					hh += ui(8);
					hh += string_height(_addon.meta.author) + ui(8);
					hh += string_height_ext(_addon.meta.description, -1, ww - ui(16)) + ui(8);
				}
				
				var hover = pHOVER && point_in_rectangle(_m[0], _m[1], 0, by, ww, by + hh);
				
				if(_addon.open)
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, by, ww, hh, COLORS._main_icon, 1);
					
				var cc = merge_color(COLORS._main_icon_light, COLORS._main_icon, hover? 0 : 0.25);
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, by, ww, hg, cc, 1);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(44), by + hg / 2, _addon.name);
				
				var chx0 = ui(6);
				var chy0 = by + ui(6);
				var chx1 = chx0 + ui(28);
				var chy1 = chy0 + ui(28);
				var _onStart = array_exists(ADDONS_ON_START, _addon.name);
				
				if(pHOVER && point_in_rectangle(_m[0], _m[1], chx0, chy0, chx1, chy1)) {
					if(!_act)			TOOLTIP = "Not activated";
					else if(!_onStart)	TOOLTIP = "Activated";
					else				TOOLTIP = "Run on start";
					
					draw_sprite_stretched_ext(THEME.checkbox, 1, chx0, chy0, ui(28), ui(28), c_white, 1);
					hover = false;
					
					if(mouse_press(mb_left, pFOCUS)) {
						if(!_act)
							addonTrigger(_addon.name);
						else if(!_onStart) {
							array_push(ADDONS_ON_START, _addon.name);
						} else {
							addonTrigger(_addon.name);
							array_remove(ADDONS_ON_START, _addon.name);
						}
						
						json_save_struct(DIRECTORY + "Addons\\__init.json", ADDONS_ON_START);
					}
				} else
					draw_sprite_stretched_ext(THEME.checkbox, 0, chx0, chy0, ui(28), ui(28), c_white, 1);
				
				if(_onStart) 
					draw_sprite_stretched_ext(THEME.checkbox_on_start, 0, chx0, chy0, ui(28), ui(28), COLORS._main_value_positive, 1);
				else if(_act) 
					draw_sprite_stretched_ext(THEME.checkbox, 2, chx0, chy0, ui(28), ui(28), COLORS._main_accent, 1);
				
				var _bx = bx - ui(4);
				var _by = by + ui(4);
				
				var b = buttonInstant(THEME.button_hide, _bx, _by, ui(32), ui(32), _m, pFOCUS, pHOVER, "Open in explorer", THEME.folder_content);
				if(b) hover = false;
				if(b == 2) shellOpenExplorer(DIRECTORY + "Addons\\" + _addon.name);
				
				_bx -= ui(36)
				if(_act && buttonInstant(THEME.button_hide, _bx, _by, ui(32), ui(32), _m, pFOCUS, pHOVER, "Addon settings", THEME.addon_setting) == 2) {
					var _addObj = noone;
					with(_addon_custom) if(name == _addon.name) _addObj = self;
						
					if(_addObj) {
						var arr = variable_struct_get_names(_addObj.panels);
						for( var i = 0; i < array_length(arr); i++ ) {
							var pane  = _addObj.panels[$ arr[i]];
							if(struct_has(pane, "main") && pane.main)
								dialogPanelCall(new addonPanel(_addObj, pane));
						}
					}
				}
				
				if(pHOVER && hover && _m[0] < _bx)
					if(mouse_press(mb_left, pFOCUS)) _addon.open = !_addon.open;
				
				if(_addon.open) {
					var _yy = by + hg + ui(8);
					
					draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
					draw_text_add(ui(8), _yy, "Author");
					draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text);
					draw_text_add(ww - ui(8), _yy, _addon.meta.author);
					
					_yy += string_height(_addon.meta.author) + ui(8);
					draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
					draw_text_ext_add(ui(8), _yy, _addon.meta.description, -1, ww - ui(16));
				}
				
				_y += hh + ui(4);
				_h += hh + ui(4);
			}
		
			return _h;
		})
	#endregion

	function drawContent(panel) {
		PANEL_PADDING
		PANEL_TITLE
		
		var px = ui(padding);
		var py = ui(title_height);
		var pw = w - ui(padding + padding);
		var ph = h - ui(title_height + padding);
	
		draw_sprite_stretched(THEME.ui_panel_bg, !in_dialog, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		if(pFOCUS) WIDGET_CURRENT = tb_search;
		tb_search.draw(px, py, pw, ui(32), search_string, [mx, my]);
		if(search_string == "") tb_search.sprite_index = 1;
		
		sc_addon.setActiveFocus(pFOCUS, pHOVER);
		sc_addon.draw(px, py + ui(40), mx - px, my - (py + ui(40)));
		
		//var bx = w - ui(32 + 16);
		//var by = title_height / 2 - ui(16 + !in_dialog * 2);
			
		//if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Create tunnel", THEME.tunnel, 1, c_white) == 2) {
		//	nodeBuild("Node_Tunnel_In", build_x, build_y);
		//	instance_destroy();
		//}
	}
}
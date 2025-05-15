function Panel_Addon() : PanelContent() constructor {
	title    = __txt("Addons");
	icon     = THEME.addon_icon;
	auto_pin = true;
	
	#region data
		w = ui(400);
		h = ui(480);
		
		search_string     = "";
		keyboard_lastchar = "";
		KEYBOARD_RESET
		keyboard_lastkey  = -1;
		
		search_res = [];
		tb_search = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_string = string(str); searchAddons(); });
		
		tb_search.align			= fa_left;
		tb_search.auto_update	= true;
		tb_search.boxColor		= COLORS._main_icon_light;
		WIDGET_CURRENT			= tb_search;
		
		function searchAddons() {
			search_res = [];
			
			for( var i = 0, n = array_length(ADDONS); i < n; i++ ) {
				if(string_pos(search_string, ADDONS[i].name))
					array_push(search_res, ADDONS[i]);
			}
		}
	#endregion
	
	function onResize() {
		sc_addon.resize(w - padding * 2, h - (padding * 2 + ui(40)));
	}
	
	#region content
		sc_addon = new scrollPane(w - padding * 2, h - (padding * 2 + ui(40)), function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear, 0);
			var _h  = 0;
			var ww  = sc_addon.surface_w;
			var hg  = ui(32);
			var i   = 0;
			
			var bsp = THEME.button_hide_fill;
			var bs  = hg - ui(8);
			var bc  = COLORS._main_icon;
			
			var arr = search_string == ""? ADDONS : search_res;
			
			
			
			for( var i = 0, n = array_length(arr); i < n; i++ ) {
				var _addon = arr[i];
				
				var bx   = ww - ui(4);
				var by   = _y;
				var hh   = hg;
				var _act = addonActivated(_addon.name);
				
				if(_addon.open) {
					draw_set_font(f_p1);
					hh += string_height(_addon.meta.author) + ui(8);
					hh += string_height_ext(_addon.meta.description, -1, ww - ui(16)) + ui(8);
				}
				
				var hover = pHOVER && point_in_rectangle(_m[0], _m[1], 0, by, ww, by + hh);
				
				if(_addon.open) draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, 0, by, ww, hh, COLORS._main_icon_light, 1);
				
				var cc = hover? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg;
				if(hover) sc_addon.hover_content = true;
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, by, ww, hg, cc, 1);
				
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(44), by + hg / 2, _addon.name);
				
				var chx0 = ui(4);
				var chy0 = by + ui(4);
				var chx1 = chx0 + bs;
				var chy1 = chy0 + bs;
				var _onStart = array_exists(ADDONS_ON_START, _addon.name);
				
				if(pHOVER && point_in_rectangle(_m[0], _m[1], chx0, chy0, chx1, chy1)) {
					sc_addon.hover_content = true;
					
					if(!_act)			TOOLTIP = __txtx("panel_addon_not_activated", "Not activated");
					else if(!_onStart)	TOOLTIP = __txtx("panel_addon_activated",     "Activated");
					else				TOOLTIP = __txtx("panel_addon_run_on_start",  "Run on start");
					
					draw_sprite_stretched_ext(THEME.checkbox_def, 1, chx0, chy0, bs, bs, c_white, 1);
					hover = false;
					
					if(mouse_press(mb_left, pFOCUS)) {
						if(!_act)
							addonLoad(_addon.name, true);
							
						else if(!_onStart) {
							array_push(ADDONS_ON_START, _addon.name);
							
						} else {
							addonUnload(_addon.name);
							array_remove(ADDONS_ON_START, _addon.name);
						}
						
						json_save_struct(DIRECTORY + "Addons/__init.json", ADDONS_ON_START);
					}
				} else
					draw_sprite_stretched_ext(THEME.checkbox_def, 0, chx0, chy0, bs, bs, c_white, 1);
				
				if(_onStart)  draw_sprite_stretched_ext(THEME.checkbox_def, 2, chx0, chy0, bs, bs, COLORS._main_value_positive, 1);
				else if(_act) draw_sprite_stretched_ext(THEME.checkbox_def, 2, chx0, chy0, bs, bs, COLORS._main_accent, 1);
				
				var _bx = bx - bs;
				var _by = by + ui(4);
				
				var b = buttonInstant(bsp, _bx, _by, bs, bs, _m, pHOVER, pFOCUS, __txt("Open in explorer"), THEME.folder, 0, bc, 1, .75);
				if(b) hover = false;
				if(b == 2) shellOpenExplorer(DIRECTORY + "Addons/" + _addon.name);
				
				_bx -= bs + ui(4);
				if(_act && buttonInstant(bsp, _bx, _by, bs, bs, _m, pHOVER, pFOCUS, __txt("Addon settings"), THEME.addon_setting, 0, bc, 1, .75) == 2) {
					var _addObj = noone;
					with(_addon_custom) if(name == _addon.name) _addObj = self;
					
					if(_addObj) {
						var arr = variable_struct_get_names(_addObj.panels);
						for( var i = 0, n = array_length(arr); i < n; i++ ) {
							var pane  = _addObj.panels[$ arr[i]];
							if(struct_has(pane, "main") && pane.main)
								dialogPanelCall(new addonPanel(_addObj, pane));
						}
					}
				}
				
				if(hover && _m[0] < _bx && mouse_press(mb_left, pFOCUS))
					_addon.open = !_addon.open;
				
				if(_addon.open) {
					var _yy = by + hg + ui(8);
					
					draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
					draw_text_add(ui(8), _yy, __txt("Author"));
					draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text);
					draw_text_add(ww - ui(8), _yy, _addon.meta.author);
					
					_yy += string_height(_addon.meta.author) + ui(4);
					draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
					draw_text_ext_add(ui(8), _yy, _addon.meta.description, -1, ww - ui(16));
				}
				
				_y += hh + ui(4);
				_h += hh + ui(4);
			}
		
			return _h;
		})
	#endregion

	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		if(pFOCUS) WIDGET_CURRENT = tb_search;
		tb_search.draw(px, py, pw, ui(32), search_string, [mx, my]);
		if(search_string == "") tb_search.sprite_index = 1;
		
		sc_addon.setFocusHover(pFOCUS, pHOVER);
		sc_addon.draw(px, py + ui(40), mx - px, my - (py + ui(40)));
	}
}
function Panel_Addon() : PanelContent() constructor {
	title    = __txt("Addons");
	icon     = THEME.addon_icon;
	auto_pin = true;
	
	w = ui(400);
	h = ui(480);
	
	#region data
		font_title   = f_p2;
		font_content = f_p3;
		
		search_string     = "";
		keyboard_lastchar = "";
		keyboard_lastkey  = -1;
		KEYBOARD_RESET
		
		search_res = [];
		tb_search  = textBox_Text(function(str) /*=>*/ { search_string = string(str); searchAddons(); })
			.setAlign(fa_left).setAutoupdate().setBoxColor(COLORS._main_icon_light).activate();
		
		function searchAddons() {
			search_res = [];
			
			for( var i = 0, n = array_length(ADDONS); i < n; i++ ) {
				if(string_pos(search_string, ADDONS[i].name))
					array_push(search_res, ADDONS[i]);
			}
		}
	#endregion
	
	#region content
		sc_addon = new scrollPane(w - padding * 2, h - (padding * 2 + ui(40)), function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear, 0);
			
			var _focus = sc_addon.active;
			var _hover = sc_addon.hover;
			
			var _h  = 0;
			var ww  = sc_addon.surface_w;
			var hg  = ui(28);
			var i   = 0;
			
			var bsp = THEME.button_hide_fill;
			var bpd = ui(4);
			var bs  = hg - bpd * 2;
			var bc  = COLORS._main_icon;
			
			var lh = line_get_height(font_content);
			
			var arr = search_string == ""? ADDONS : search_res;
			
			for( var i = 0, n = array_length(arr); i < n; i++ ) {
				var _addon = arr[i];
				
				var bx   = ww - bpd;
				var by   = _y;
				var hh   = hg;
				
				var _act    = _addon.isActivated();
				
				var _meta     = _addon.meta;
				var _meta_aut = _meta[$ "author"]      ?? "-";
				var _meta_des = _meta[$ "description"] ?? "no description";
				
				if(_addon.open) {
					draw_set_font(font_content);
					hh += ui(8);
					hh += max(lh, string_height(_meta_aut))                      + ui(4);
					hh += max(lh, string_height_ext(_meta_des, -1, ww - ui(16))) + ui(4);
					hh += ui(4);
				}
				
				var hover = _hover && point_in_rectangle(_m[0], _m[1], 0, by, ww, by + hh);
				
				if(_addon.open) draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, by, ww, hh, COLORS._main_icon_light, 1);
				
				var cc = hover? COLORS.section_hover : COLORS.section_bg;
				if(hover) sc_addon.hover_content = true;
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, by, ww, hg, cc, 1);
				draw_set_text(font_title, fa_left, fa_center, COLORS._main_text);
				draw_text_add(bpd + bs + ui(8), by + hg / 2, _addon.name);
				
				var chx0 = bpd;
				var chy0 = by + bpd;
				var chx1 = chx0 + bs;
				var chy1 = chy0 + bs;
				var _onStart = array_exists(ADDONS_ON_START, _addon.name);
				
				if(_hover && point_in_rectangle(_m[0], _m[1], chx0, chy0, chx1, chy1)) {
					sc_addon.hover_content = true;
					
					if(!_act)			TOOLTIP = __txt("panel_addon_not_activated", "Not activated");
					else if(!_onStart)	TOOLTIP = __txt("panel_addon_activated",     "Activated");
					else				TOOLTIP = __txt("panel_addon_run_on_start",  "Run on start");
					
					draw_sprite_stretched_ext(THEME.checkbox_def, 1, chx0, chy0, bs, bs, c_white, 1);
					hover = false;
					
					if(mouse_lpress(_focus)) {
						if(!_act) _addon.activate(true);
							
						else if(!_onStart) {
							array_push(ADDONS_ON_START, _addon.name);
							
						} else {
							_addon.deactivate();
							array_remove(ADDONS_ON_START, _addon.name);
						}
						
						json_save_struct(DIRECTORY + "Addons/__init.json", ADDONS_ON_START);
					}
					
				} else
					draw_sprite_stretched_ext(THEME.checkbox_def, 0, chx0, chy0, bs, bs, c_white, 1);
				
				if(_onStart)  draw_sprite_stretched_ext(THEME.checkbox_def, 2, chx0, chy0, bs, bs, COLORS._main_value_positive, 1);
				else if(_act) draw_sprite_stretched_ext(THEME.checkbox_def, 2, chx0, chy0, bs, bs, COLORS._main_accent, 1);
				
				var _bx = bx - bs;
				var _by = by + bpd;
				
				if(_addon.type == 1) {
					var bt = __txt("Open in explorer");
					var b  = buttonInstant_Pad(bsp, _bx, _by, bs, bs, _m, _hover, _focus, bt, THEME.folder, 0, bc, 1, ui(4));
					if(b) hover = false;
					if(b == 2) shellOpenExplorer(DIRECTORY + "Addons/" + _addon.name);
				}
				
				_bx -= bs + ui(4);
				var _addObj = _addon.activatedInstance;
				if(_act && _addObj && _addObj.panelMain) {
					var bt = __txt("Addon settings");
					
					if(buttonInstant_Pad(bsp, _bx, _by, bs, bs, _m, _hover, _focus, bt, THEME.addon_setting, 0, bc, 1, ui(4)) == 2) {
						if(_addon.type == 0)
							 dialogPanelCall(new _addObj.panelMain(_addObj));
						else dialogPanelCall(new addonPanel(_addObj, _addObj.panelMain));
					}
				}
				
				if(hover && _m[0] < _bx && mouse_lpress(_focus))
					_addon.open = !_addon.open;
				
				if(_addon.open) {
					var _yy = by + hg + ui(8);
					
					draw_set_text(font_content, fa_left, fa_top, COLORS._main_text_sub);
					draw_text_add(ui(8), _yy, __txt("Author"));
					draw_set_text(font_content, fa_right, fa_top, COLORS._main_text);
					draw_text_add(ww - ui(8), _yy, _meta_aut);
					
					_yy += string_height(_meta_aut) + ui(4);
					draw_set_text(font_content, fa_left, fa_top, COLORS._main_text_sub);
					draw_text_ext_add(ui(8), _yy, _meta_des, -1, ww - ui(16));
					
				}
				
				draw_sprite_stretched_add(THEME.ui_panel, 1, 0, by, ww, _addon.open? hh : hg, COLORS._main_icon, .4);
				
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
		if(pFOCUS) tb_search.activate();
		tb_search.draw(px, py, pw, ui(32), search_string, [mx, my]);
		if(search_string == "") tb_search.sprite_index = 1;
		
		sc_addon.verify(pw, ph - ui(40));
		sc_addon.setFocusHover(pFOCUS, pHOVER);
		sc_addon.draw(px, py + ui(40), mx - px, my - (py + ui(40)));
	}
}
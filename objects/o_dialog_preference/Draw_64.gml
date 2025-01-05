/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(56), dialog_y + ui(20), __txt("Preferences"));
	
	var bx = dialog_x + ui(24);
	var by = dialog_y + ui(18);
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sHOVER, sFOCUS, destroy_on_click_out? __txt("Pin") : __txt("Unpin"), 
		THEME.pin, !destroy_on_click_out, destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light) == 2)
			destroy_on_click_out = !destroy_on_click_out;
			
	if(should_restart) {
		var _txt = "Restart recommended";
		var _rx = dialog_x + ui(168);
		var _ry = dialog_y + ui(20);
		
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_accent);
		
		var _rw = string_width(_txt);
		var _rh = string_height(_txt);
		
		draw_sprite_stretched_ext(THEME.s_box_r5_clr, 0, _rx - ui(8), _ry - ui(4), _rw + ui(16), _rh + ui(8), COLORS._main_accent, 1);
		draw_text(_rx, _ry, _txt);
	}
#endregion

#region page
	sp_page.setFocusHover(sFOCUS, sHOVER);
	sp_page.draw(dialog_x + ui(padding), dialog_y + ui(title_height));
#endregion

#region draw
	section_current = "";
	var px = dialog_x + ui(padding) + page_width;
	var py = dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + padding) - page_width;
	var ph = dialog_h - ui(title_height + padding);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	
	tb_search.auto_update   = true;
	tb_search.no_empty		= false;
	tb_search.font			= f_p1;
	tb_search.active		= sFOCUS;
	tb_search.hover			= sHOVER;
	tb_search.draw(dialog_x + dialog_w - ui(padding - 8), dialog_y + ui(title_height) / 2, ui(200), ui(28), search_text, mouse_ui, fa_right, fa_center);
	draw_sprite_ui_uniform(THEME.search, 0, dialog_x + dialog_w - ui(padding + 208), dialog_y + ui(title_height) / 2, 1, COLORS._main_text_sub);
	
	if(page_current == 0) {
		current_list = pref_global;
		sp_pref.setFocusHover(sFOCUS, sHOVER);
		sp_pref.draw(px, py);
		
	} else if(page_current == 1) {
		current_list = pref_appr;
		sp_pref.setFocusHover(sFOCUS, sHOVER);
		sp_pref.draw(px, py);
		
	} else if(page_current == 2) {
		current_list = pref_node;
		sp_pref.setFocusHover(sFOCUS, sHOVER);
		sp_pref.draw(px, py);
		
	} else if(page_current == 3) {
		var _w = ui(200);
		var _h = ui(32);
		
		var _x   = dialog_x + dialog_w - ui(8);
		var bx   = _x - ui(48);
		var _txt = __txtx("pref_reset_color", "Reset colors");
		var b = buttonInstant(THEME.button_hide, bx, py, ui(32), ui(32), mouse_ui, sHOVER, sFOCUS, _txt, THEME.refresh_icon);
		if(b == 2) {
			var path = $"{DIRECTORY}Themes/{PREFERENCES.theme}/override.json";
			if(file_exists_empty(path)) file_delete(path);
			loadColor(PREFERENCES.theme);
		}
		
		var x1 = dialog_x + ui(padding) + page_width;
		var x2 = _x - ui(32);
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		draw_text(x1 + ui(8), py + _h / 2, __txt("Theme"));
		sb_theme.setFocusHover(sFOCUS, sHOVER);
		sb_theme.draw(x2 - ui(24) - _w, py, _w, _h, PREFERENCES.theme);
		
		sp_colors.setFocusHover(sFOCUS, sHOVER);
		sp_colors.draw(px, py + ui(40));
		
	} else if(page_current == 4) {
		if(mouse_press(mb_left, sFOCUS)) 
			hk_editing = noone;
		
		var hk_w = panel_width;
		var hk_h = hotkey_cont_h - ui(16);
		var kdsp = keyboards_display;
		var keys = keyboards_display.keys;
		
		var ks   = min(hk_w / kdsp.width, hk_h / kdsp.height);
		var _kww = ks * kdsp.width;
		var _khh = ks * kdsp.height;
		
		var _ksx = px + hk_w / 2 - _kww / 2;
		var _ksy = py + hk_h / 2 - _khh / 2;
		var _kp  = ui(2);
		
		var _keyUsing = {};
		var _ctxObj   = hotkeyContext[hk_page];
		var _cntx     = _ctxObj.context;
		var _list     = _ctxObj.list;
		
		for (var j = 0, m = array_length(_list); j < m; j++) {
			
			var _ky   = _list[j];
			var _kkey = _ky.key;
			var _kmod = _ky.modi;
			
			if(_kkey == noone && _kmod == MOD_KEY.none) continue;
			
			if(!struct_has(_keyUsing, _kkey))
				_keyUsing[$ _kkey] = {};
			
			var _kuse = _keyUsing[$ _kkey];
			if(!struct_has(_kuse, _kmod))
				_kuse[$ _kmod] = [];
				
			array_append(_kuse[$ _kmod], _ky);
		}
		
		var c_control = CDEF.orange, kc_control = colorMultiply(CDEF.main_dkgrey, c_control);
		var c_shift   = CDEF.blue,   kc_shift   = colorMultiply(CDEF.main_dkgrey, c_shift);
		var c_alt     = CDEF.lime,   kc_alt     = colorMultiply(CDEF.main_dkgrey, c_alt);
		var _sel      = true;
		
		var _mod_arr = [
			MOD_KEY.ctrl, MOD_KEY.shift, MOD_KEY.alt,
			MOD_KEY.ctrl | MOD_KEY.shift,
			MOD_KEY.ctrl | MOD_KEY.alt,
			MOD_KEY.shift | MOD_KEY.alt,
			MOD_KEY.ctrl | MOD_KEY.shift | MOD_KEY.alt,
		];
		
		var _cur_mod  = MOD_KEY.ctrl  * key_mod_press(CTRL)
		              + MOD_KEY.shift * key_mod_press(SHIFT)
		              + MOD_KEY.alt   * key_mod_press(ALT)
		
		var _cmod = _cur_mod == MOD_KEY.none? hk_modifiers : _cur_mod;
		
		draw_set_text(f_p4, fa_center, fa_center);
		for (var i = 0, n = array_length(keys); i < n; i++) {
			var _key = keys[i];
			var _kx  = _ksx + _key.x * ks;
			var _ky  = _ksy + _key.y * ks;
			var _kw  = _key.w * ks;
			var _kh  = _key.h * ks;
			var _vk  = _key.vk;
			
			_kx += _kw / 2 - (_kw - _kp) / 2;
			_ky += _kh / 2 - (_kh - _kp) / 2;
			_kw -= _kp;
			_kh -= _kp;
			
			if(_vk == -1) {
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, CDEF.main_black, 0.3);
				continue;
			}
			
			var _tc  = CDEF.main_grey;
			var _hov = sHOVER && point_in_rectangle(mouse_mx, mouse_my, _kx - _kp, _ky - _kp, _kx + _kw + _kp - 1, _ky + _kh + _kp - 1);
			
			if(_vk == vk_control) {
				_sel = bool(MOD_KEY.ctrl & _cmod);
				
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, _sel? c_control : kc_control);
				_tc = _sel? kc_control : c_control;
				
				if(mouse_press(mb_left, sFOCUS && _hov)) hk_modifiers ^= MOD_KEY.ctrl;
				
			} else if(_vk == vk_shift) {
				_sel = bool(MOD_KEY.shift & _cmod);
				
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, _sel? c_shift : kc_shift);
				_tc = _sel? kc_shift : c_shift;
				
				if(mouse_press(mb_left, sFOCUS && _hov)) hk_modifiers ^= MOD_KEY.shift;
					
			} else if(_vk == vk_alt) {
				_sel = bool(MOD_KEY.alt & _cmod);
				
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, _sel? c_alt : kc_alt);
				_tc = _sel? kc_alt : c_alt;
				
				if(mouse_press(mb_left, sFOCUS && _hov)) hk_modifiers ^= MOD_KEY.alt;
					
			} else if(struct_has(_keyUsing, _vk) && struct_has(_keyUsing[$ _vk], _cmod)) {
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, CDEF.main_ltgrey);
				draw_sprite_stretched_add(THEME.ui_panel, 1, _kx, _ky, _kw, _kh, c_white, 0.1);
				_tc = CDEF.main_mdblack;
				
				var _act = _keyUsing[$ _vk][$ _cmod];
				
				if(_hov) {
					TOOLTIP = new tooltipHotkey_assign(_act, key_get_name(_vk, _cmod));
					
					if(mouse_press(mb_left, sFOCUS)) {
						if(hotkey_focus_index >= array_length(_act))
							hotkey_focus_index = 0;
							
						hotkey_focus           = _act[hotkey_focus_index];
						hotkey_focus_highlight = _act[hotkey_focus_index];
						hotkey_focus_high_bg   = 1;
						
						hotkey_focus_index++;
					}
				}
				
			} else {
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, CDEF.main_black);
				_tc  = CDEF.main_grey;
				
				if(_hov) {
					TOOLTIP = new tooltipHotkey_assign(noone, key_get_name(_vk, _cmod));
				}
			}
			
			draw_sprite_stretched_add(THEME.ui_panel, 1, _kx, _ky, _kw, _kh, c_white, 0.1 + _hov * 0.2);
			
			if(is_string(_key.key)) {
				draw_set_color(_tc);
				draw_set_alpha(1);
				draw_text(_kx + _kw / 2, _ky + _kh / 2, _key.key);
			}
			
		}
		
		var _ppy = py + hotkey_cont_h;
		
		hk_scroll.font = f_p2;
		hk_scroll.setFocusHover(sFOCUS, sHOVER);
		hk_scroll.draw(px, _ppy, ui(200), ui(24), hk_page);
		
		sp_hotkey.setFocusHover(sFOCUS, sHOVER);
		sp_hotkey.draw(px, _ppy + ui(32));
		
	}
#endregion
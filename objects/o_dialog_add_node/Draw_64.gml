/// @description init
if !ready exit;

DIALOG_DRAW_BG
if(DIALOG_SHOW_FOCUS) {
	var cc = node_replace == noone? COLORS._main_accent : COLORS.dialog_add_node_replace_mode;
	draw_sprite_stretched_ext(THEME.dialog, 1, dialog_x - 8, dialog_y - 8, dialog_w + 16, dialog_h + 16, cc, 1);
}

#region content
	WIDGET_CURRENT = tb_search;
	
	var pd = ui(10);
	
	var tx = dialog_x + ui(14);
	var ty = dialog_y + ui(14);
	var tw = dialog_w - ui(28);
	var th = ui(28);
	
	var _content_y = ty + th + pd;
	
	var _content_w = dialog_w - category_width - ui(20) - pd; 
	var _content_h = dialog_h - ui(14) - th - pd - pd; 
	
	if(search_string == "") {
		catagory_pane.setFocusHover(sFOCUS, sHOVER);
		catagory_pane.verify(category_width, _content_h);
		catagory_pane.draw(dialog_x + ui(12), _content_y);
		
		var _content_x = dialog_x + category_width + ui(20);
		draw_sprite_stretched(THEME.ui_panel_bg, 1, _content_x, _content_y, _content_w, _content_h);
		
		if(array_length(recent_nodes)) {
			var _scis = gpu_get_scissor();
			var _rcs  = ui(20);
			var _rcx  = _content_x + ui(4);
			var _rcy  = _content_y + ui(4);
			var bb = noone;
			var bc = [COLORS._main_icon_light, c_white];
			var mm = [mouse_mx, mouse_my];
			var hv = sHOVER && point_in_rectangle(mouse_mx, mouse_my, _content_x, _content_y, _content_x + _content_w, _content_y + _rcs);
			
			gpu_set_scissor(_content_x, _content_y, _content_w, _rcs + ui(8));
			for( var i = 0, n = array_length(recent_nodes); i < n; i++ ) {
				var _rec = recent_nodes[i];
				var _nam = _rec.name;
				var _spr = _rec.spr;
				
				if(buttonInstant_Pad(bb, _rcx, _rcy, _rcs, _rcs, mm, hv, sFOCUS, _nam, _spr, 0, bc, .75, ui(4)) == 2)
					buildNode(_rec);
				
				_rcx += _rcs + ui(2);
			}
			
			_content_y += _rcs + ui(4);
			_content_h -= _rcs + ui(4);
			gpu_set_scissor(_scis);
			
			draw_set_color(COLORS._main_icon);
			draw_set_alpha(.3);
			draw_line(_content_x + 1, _content_y + ui(2), _content_x + _content_w - 2, _content_y + ui(2))
			draw_set_alpha(1);
			
			_content_y += ui(4);
			_content_h -= ui(4);
		}
		
		if(PREFERENCES.dialog_add_node_grouping == 2 && !array_empty(subgroups)) {
			var _subw = ui(128);
			subcatagory_pane.setFocusHover(sFOCUS, sHOVER);
			subcatagory_pane.verify(_subw, _content_h);
			subcatagory_pane.draw(_content_x, _content_y);
			
			_content_w -= _subw;
			_content_x += _subw;
		}
		
		content_pane.setFocusHover(sFOCUS, sHOVER);
		content_pane.verify(_content_w - ui(6), _content_h);
		content_pane.draw(_content_x, _content_y);
		
		node_selecting = 0;
		
	} else {
		draw_sprite_stretched(THEME.ui_panel_bg, 1, tx, _content_y, dialog_w - ui(28), _content_h - ui(2));
		
		search_pane.setFocusHover(sFOCUS, sHOVER);
		search_pane.verify(dialog_w - ui(36), _content_h - ui(2));
		search_pane.draw(dialog_x + ui(16), _content_y);
	}
	
	#region buttons
		var bb = THEME.button_hide_fill;
		var bc = COLORS._main_icon;
		var bs = ui(28);
		
		var bx = dialog_x + dialog_w - ui(44);
		var by = ty;
		var mm = mouse_ui;
		
		view_tooltip.index  = PREFERENCES.dialog_add_node_view;
		var bi = PREFERENCES.dialog_add_node_view;
		var b  = buttonInstant_Pad(bb, bx, by, bs, bs, mm, sHOVER, sFOCUS, view_tooltip, THEME.view_mode, bi, bc, 1, ui(4));
		if(b == 1) {
			if(key_mod_press(SHIFT) && MOUSE_WHEEL > 0) mod_dec_mf0 PREFERENCES.dialog_add_node_view mod_dec_mf1 PREFERENCES.dialog_add_node_view mod_dec_mf2  2 mod_dec_mf3  2 mod_dec_mf4;
			if(key_mod_press(SHIFT) && MOUSE_WHEEL < 0) mod_inc_mf0 PREFERENCES.dialog_add_node_view mod_inc_mf1 PREFERENCES.dialog_add_node_view mod_inc_mf2  2 mod_inc_mf3;
		}
		if(b == 2) mod_inc_mf0 PREFERENCES.dialog_add_node_view mod_inc_mf1 PREFERENCES.dialog_add_node_view mod_inc_mf2  2 mod_inc_mf3;
		tw -= bs + ui(4);
		
		bx -= bs + ui(4);
		group_tooltip.index = PREFERENCES.dialog_add_node_grouping;
		var bi = PREFERENCES.dialog_add_node_grouping;
		var b  = buttonInstant_Pad(bb, bx, by, bs, bs, mm, sHOVER, sFOCUS, group_tooltip, THEME.view_group, bi, bc, 1, ui(4));
		if(b == 1) {
			if(key_mod_press(SHIFT) && MOUSE_WHEEL > 0) mod_dec_mf0 PREFERENCES.dialog_add_node_grouping mod_dec_mf1 PREFERENCES.dialog_add_node_grouping mod_dec_mf2  3 mod_dec_mf3  3 mod_dec_mf4;
			if(key_mod_press(SHIFT) && MOUSE_WHEEL < 0) mod_inc_mf0 PREFERENCES.dialog_add_node_grouping mod_inc_mf1 PREFERENCES.dialog_add_node_grouping mod_inc_mf2  3 mod_inc_mf3;
		}
		if(b == 2) mod_inc_mf0 PREFERENCES.dialog_add_node_grouping mod_inc_mf1 PREFERENCES.dialog_add_node_grouping mod_inc_mf2  3 mod_inc_mf3;
		tw -= bs + ui(4);
		
		if(search_string != "") {
			bx -= bs + ui(4);
			var bt = __txt("Prioritize Favourite");
			var bi = PREFERENCES.dialog_add_node_search_fav;
			var b  = buttonInstant_Pad(bb, bx, by, bs, bs, mm, sHOVER, sFOCUS, bt, THEME.favorite, bi, bc, 1, ui(12));
			if(b == 2) PREFERENCES.dialog_add_node_search_fav = !PREFERENCES.dialog_add_node_search_fav;
			tw -= bs + ui(4);
		}
		
		if(junction_called != noone) {
			var txt = node_show_connectable? __txtx("add_node_show_connect", "Showing connectable") : 
			                                 __txtx("add_node_show_all", "Showing all");
			var cc  = node_show_connectable? COLORS._main_accent : COLORS._main_icon;
			
			bx -= bs + ui(4);
			var b = buttonInstant_Pad(bb, bx, by, bs, bs, mm, sHOVER, sFOCUS, txt, THEME.filter_type, node_show_connectable, cc, 1, ui(8));
			if(b == 2) node_show_connectable = !node_show_connectable;
			tw -= bs + ui(4);
		}
		
		tw -= ui(4);
	#endregion
	
	if(hk_editing == noone) {
		tb_search.setFocusHover(sFOCUS, sHOVER);
		
		draw_sprite_stretched_ext(THEME.textbox, 3, tx, ty, tw, th, COLORS._main_icon_light);
		tb_search.draw(tx, ty, tw, th, search_string, mouse_ui);
		draw_sprite_stretched_ext(THEME.textbox, 2, tx, ty, tw, th, COLORS._main_icon, .5);
		
	} else {
		draw_sprite_stretched_ext(THEME.textbox, 5, tx, ty, tw, th);
		draw_sprite_stretched_ext(THEME.textbox, 2, tx, ty, tw, th, COLORS._main_accent);
		
		var _name = hk_edit_node.name;
		var _txt  = $"Edit key for {_name} :  ";
		var _txx  = tx + ui(8);
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		draw_text(_txx, ty + th / 2, _txt);
		_txx += string_width(_txt);
		
		var _key  = hk_editing.getName();
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
		draw_text(_txx, ty + th / 2, _key);
	}
	
#endregion

#region tooltip
	if(sprite_exists(node_icon)) {
		var _sx = node_icon_x - ui(16);
		var _sy = node_icon_y;
		
		var _sw = ui(64);
		var _sh = ui(64);
		
		var _bgx = _sx - _sw / 2;
		var _bgy = _sy - _sh / 2;
		
		draw_sprite_stretched(THEME.node_junction_name_bg, 0, _bgx - ui(10), _bgy - ui(10), _sw + ui(20), _sh + ui(20));
		gpu_set_tex_filter(true);
		draw_sprite_stretched(node_icon, 0, _bgx, _bgy, _sw, _sh);
		gpu_set_tex_filter(false);
	}
	node_icon = noone;
	
	if(node_tooltip != noone) {
		var ww = ui(300 + 8);
		var hh = ui(16);
		var tw = ww - ui(16);
		
		var txt = node_tooltip.getTooltip();
		var spr = node_tooltip.getTooltipSpr();
		var hk  = is(node_tooltip, NodeObject)? struct_try_get(GRAPH_ADD_NODE_MAPS, node_tooltip.nodeName, noone) : noone;
		
		draw_set_font(f_p1);
		var _th = string_height_ext(txt, -1, tw);
		
		if(spr) {
			ww = ui(sprite_get_width(spr));
			hh = ui(sprite_get_height(spr)) + (_th - ui(8)) * (txt != "");
			
		} else {
			hh = ui(16) + _th;
			
			if(hk != noone) {
				draw_set_font(f_p2);
				ww += string_width(hk.getName()) + ui(8);
			}
		}
		
		tooltip_surface = surface_verify(tooltip_surface, ww, hh);
		surface_set_shader(tooltip_surface, noone);
			draw_clear_alpha(c_white, 0);
			
			if(spr) {
				DRAW_CLEAR
				
				gpu_set_texfilter(true);
				draw_sprite_uniform(spr, 0, 0, 0, UI_SCALE);
				gpu_set_texfilter(false);
				
				BLEND_NORMAL
				if(txt != "") draw_sprite_stretched_ext(THEME.add_node_bg, 0, 0, hh - _th - ui(32), ww, _th + ui(32), CDEF.main_dkblack);
			} 
			
			if(hk != noone) {
				draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text_sub);
				draw_text_add(ww - ui(8), ui(8), hk.getName());
			}
			
			draw_set_text(f_p1, fa_left, fa_bottom, COLORS._main_text)
			draw_text_ext_add(ui(8), hh - ui(8), txt, -1, tw);
			
			BLEND_MULTIPLY
			draw_sprite_stretched(THEME.ui_panel_bg, 4, 0, 0, ww, hh);
			BLEND_NORMAL
			
			var _aut = node_tooltip[$ "author"] ?? "";
			var _lic = node_tooltip[$ "license"] ?? "";
			
			draw_set_text(f_p2b, fa_right, fa_top, COLORS._main_text);
			draw_text_add(ww - ui(8), ui(8), _aut);
			
			draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text, 0.75);
			draw_text_ext_add(ww - ui(8), ui(8 + 20), _lic, -1, tw);
			
			draw_set_alpha(1);
		surface_reset_shader();
		
		var x0 = min(node_tooltip_x, WIN_W - ww - ui(8));
		var y0 = node_tooltip_y - hh - ui(8);
		
		draw_sprite_stretched(THEME.textbox, 3, x0, y0, ww, hh);
		draw_surface(tooltip_surface, x0, y0);
		draw_sprite_stretched(THEME.textbox, 0, x0, y0, ww, hh);
		node_tooltip = noone;
	}
	
	ADD_NODE_SCROLL = content_pane.scroll_y_to;
	if(mouse_release(mb_right)) right_free = true;
#endregion

#region hotkey
	destroy_on_escape = hk_editing == noone;
	if(hk_editing != noone) {
		if(KEYBOARD_ENTER)  { hk_editing = noone; keyboard_string = ""; search_string = ""; KEYBOARD_PRESSED_STRING = ""; }
		else hotkey_editing(hk_editing);
			
		if(keyboard_check_pressed(vk_escape)) { hk_editing = noone; keyboard_string = ""; search_string = ""; KEYBOARD_PRESSED_STRING = ""; }
	}
#endregion
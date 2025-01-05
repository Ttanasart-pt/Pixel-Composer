/// @description init
if !ready exit;

DIALOG_DRAW_BG
if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS

#region content
	WIDGET_CURRENT = tb_search;
	tb_search.setFocusHover(sFOCUS, sHOVER);
	
	var tw = dialog_w - ui(96);
	var th = ui(32);
	var tx = dialog_x + ui(14);
	var ty = dialog_y + ui(14);
	var sy = ty + th  + ui(6);
	
	if(search_string == "") {
		catagory_pane.setFocusHover(sFOCUS, sHOVER);
		catagory_pane.draw(dialog_x + ui(12), sy);
		
		var _x = dialog_x + category_width + ui(20);
		draw_sprite_stretched(THEME.ui_panel_bg, 1, _x, sy, dialog_w - category_width - ui(34), dialog_h - ui(66));
		
		var _content_w = dialog_w - category_width - ui(40); 
		var _content_h = dialog_h - ui(66); 
		var _content_x = _x;
		
		if(PREFERENCES.dialog_add_node_grouping == 2 && !array_empty(subgroups)) {
			var _subw = ui(128);
			_content_w -= _subw;
			_content_x += _subw;
			
			subcatagory_pane.verify(_subw, _content_h);
			subcatagory_pane.setFocusHover(sFOCUS, sHOVER);
			subcatagory_pane.draw(_x, sy);
		}
		
		content_pane.verify(_content_w, _content_h);
		content_pane.setFocusHover(sFOCUS, sHOVER);
		content_pane.draw(_content_x, sy);
		
		node_selecting = 0;
		
	} else {
		draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(14), sy, dialog_w - ui(28), dialog_h - ui(66));
		search_pane.setFocusHover(sFOCUS, sHOVER);
		search_pane.draw(dialog_x + ui(16), sy);
		
		tw -= ui(32);
	}
	
	if(junction_called != noone) tw -= ui(32);
	
	tb_search.draw(tx, ty, tw, th, search_string, mouse_ui);
	
	view_tooltip.index  = PREFERENCES.dialog_add_node_view;
	group_tooltip.index = PREFERENCES.dialog_add_node_grouping;
	
	var bx = dialog_x + dialog_w - ui(44);
	var by = dialog_y + ui(16);
	var b = buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, sFOCUS, view_tooltip, THEME.view_mode, PREFERENCES.dialog_add_node_view, COLORS._main_icon);
	if(b == 1) {
		if(key_mod_press(SHIFT) && mouse_wheel_up())   mod_dec_mf0 PREFERENCES.dialog_add_node_view mod_dec_mf1 PREFERENCES.dialog_add_node_view mod_dec_mf2  2 mod_dec_mf3  2 mod_dec_mf4;
		if(key_mod_press(SHIFT) && mouse_wheel_down()) mod_inc_mf0 PREFERENCES.dialog_add_node_view mod_inc_mf1 PREFERENCES.dialog_add_node_view mod_inc_mf2  2 mod_inc_mf3;
	}
	if(b == 2) mod_inc_mf0 PREFERENCES.dialog_add_node_view mod_inc_mf1 PREFERENCES.dialog_add_node_view mod_inc_mf2  2 mod_inc_mf3;
	
	bx -= ui(32);
	var b = buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, sFOCUS, group_tooltip, THEME.view_group, PREFERENCES.dialog_add_node_grouping, COLORS._main_icon);
	if(b == 1) {
		if(key_mod_press(SHIFT) && mouse_wheel_up())   mod_dec_mf0 PREFERENCES.dialog_add_node_grouping mod_dec_mf1 PREFERENCES.dialog_add_node_grouping mod_dec_mf2  3 mod_dec_mf3  3 mod_dec_mf4;
		if(key_mod_press(SHIFT) && mouse_wheel_down()) mod_inc_mf0 PREFERENCES.dialog_add_node_grouping mod_inc_mf1 PREFERENCES.dialog_add_node_grouping mod_inc_mf2  3 mod_inc_mf3;
	}
	if(b == 2) mod_inc_mf0 PREFERENCES.dialog_add_node_grouping mod_inc_mf1 PREFERENCES.dialog_add_node_grouping mod_inc_mf2  3 mod_inc_mf3;
	
	if(junction_called != noone) {
		var txt = node_show_connectable? __txtx("add_node_show_connect", "Showing connectable") : __txtx("add_node_show_all", "Showing all");
		var cc  = node_show_connectable? COLORS._main_accent : COLORS._main_icon;
		bx -= ui(32);
		
		var b = buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, sFOCUS, txt, THEME.filter_type, node_show_connectable, cc);
		if(b == 2) node_show_connectable = !node_show_connectable;
	}
	
	if(search_string != "") {
		var txt = __txtx("add_node_highlight", "Hightlight Query");
		bx -= ui(32);
		if(buttonInstant(THEME.button_hide_fill, bx, by, ui(28), ui(28), mouse_ui, sHOVER, sFOCUS, txt, THEME.add_node_search_high, PREFERENCES.dialog_add_node_search_high, COLORS._main_icon) == 2) 
			PREFERENCES.dialog_add_node_search_high = !PREFERENCES.dialog_add_node_search_high;
	}
#endregion

#region tooltip
	if(node_tooltip != noone) {
		var ww = ui(300 + 8);
		var hh = ui(16);
		
		var txt = node_tooltip.getTooltip();
		var spr = node_tooltip.tooltip_spr;
		
		draw_set_font(f_p1);
		var _th = string_height_ext(txt, -1, ww - ui(16));
		
		if(spr) {
			ww = sprite_get_width(spr);
			hh = sprite_get_height(spr) + (_th - ui(8)) * (txt != "");
		} else 
			hh = ui(16) + string_height_ext(txt, -1, ww - ui(16));
		
		tooltip_surface = surface_verify(tooltip_surface, ww, hh);
		surface_set_shader(tooltip_surface, noone);
			draw_set_text(f_p1, fa_left, fa_bottom, COLORS._main_text)
			
			if(spr) {
				draw_sprite(spr, 0, 0, 0);
				
				BLEND_NORMAL
				if(txt != "") draw_sprite_stretched_ext(THEME.add_node_bg, 0, 0, hh - _th - 32, ww, _th + 32, CDEF.main_dkblack);
			} else
				draw_clear_alpha(c_white, 0);
			
			draw_text_ext_add(ui(8), hh - ui(8), txt, -1, ww - ui(16));
			
			BLEND_MULTIPLY
			draw_sprite_stretched(THEME.ui_panel_bg, 4, 0, 0, ww, hh);
			BLEND_NORMAL
		surface_reset_shader();
		
		var x0 = min(node_tooltip_x, WIN_W - ww - ui(8));
		var y0 = node_tooltip_y - hh - ui(8);
		
		draw_sprite_stretched(THEME.textbox, 3, x0, y0, ww, hh);
		draw_surface(tooltip_surface, x0, y0);
		draw_sprite_stretched(THEME.textbox, 0, x0, y0, ww, hh);
		node_tooltip = noone;
	}
	
	if(node_icon != noone) {
		var _sx = node_icon_x - ui(16);
		var _sy = node_icon_y;
		
		var _sw = sprite_get_width(node_icon)  + ui(48);
		var _sh = sprite_get_height(node_icon) + ui(48);
		
		var _bgx = _sx - _sw / 2;
		var _bgy = _sy - _sh / 2;
		
		draw_sprite_stretched(s_node_junction_name_bg, 0, _bgx, _bgy, _sw, _sh);
		draw_sprite_ext(node_icon, 0, _sx, _sy, 1, 1);
		node_icon = noone;
	}
	
	ADD_NODE_SCROLL = content_pane.scroll_y_to;
	
	if(mouse_release(mb_right))
		right_free = true;
#endregion

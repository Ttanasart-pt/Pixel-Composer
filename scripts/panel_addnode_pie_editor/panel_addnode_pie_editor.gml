function Panel_Addnode_Pie_Editor() : PanelContent() constructor {
	title  = __txt("Editing Pie menu");
	menu   = PREFERENCES.dialog_add_node_pie;
	auto_pin = true;
	
	w      = min(WIN_W - ui(100), ui(1000));
	h      = ui(480);
	list_w = (w - padding * 2) / 2;
	list_h =  h - padding * 2;
	
	dragging  = "";
	
	#region categories
		category_page   = 0;
		categories_name = [];
		for( var i = 0, n = array_length(NODE_CATEGORY); i < n; i++ )
			categories_name[i] = NODE_CATEGORY[i].name;
		
		category_offset = array_find(categories_name, "IO");
		categories_name = array_copy_trim_start(categories_name, category_offset);
		
		sc_category = new scrollBox(categories_name, function(i) /*=>*/ { category_page = i; }).setFont(f_p3);
	#endregion
	
	#region search
		search_string = "";
		search_result = [];
		tb_search     = textBox_Text(function(s) /*=>*/ { setSearch(s); }).setFont(f_p3).setEmpty().setAutoupdate();
		
		static setSearch = function(s = search_string) {
			search_string = s;
			if(s == "") {
				search_result = [];
				return;
			}
			
			search_result = nodeSearchGlobal(s);
		}
	#endregion
	
	function drawMenu(hover, focus, _menu, xx, yy, ww, hh, _m) {
		var _txt  = _menu;
		var _tc   = COLORS._main_text;
		var _spr  = noone;
		var _spri = 0;
		
		if(_menu == -1) {
			_txt = "separator";
			_tc  = COLORS._main_text_sub;
			_spr = THEME.minus_16;
			
		} else if(has(ALL_NODES, _menu)) {
			var _mObj = ALL_NODES[$ _menu];
			
			_txt = _mObj.name;
			_spr = _mObj.spr;
			
		} else if(is(_menu, NodeObject)) {
			_txt = _menu.name;
			_spr = _menu.spr;
			
		}
		
		var _hov = _m == infinity || (hover && point_in_rectangle(_m[0], _m[1], xx, yy - ui(2), xx + ww, yy + hh + ui(2) - 1));
		
		if(_hov) {
			draw_sprite_stretched(THEME.box_r2_clr, 0, xx, yy, ww, hh);
			draw_sprite_stretched(THEME.box_r2_clr, 1, xx, yy, ww, hh);
			
		} else {
			draw_sprite_stretched_ext(THEME.box_r2_clr, 0, xx, yy, ww, hh, c_white, .3);
			
		}
		
		var tx = xx + ui(24 + 4);
		
		draw_set_text(f_p3, fa_left, fa_center, _tc);
		draw_text_add(tx, yy + hh / 2, _txt); 
		tx += string_width(_txt) + ui(8);
		
		draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(tx, yy + hh / 2, _menu);
		
		if(is_array(_spr)) {
			_spri = _spr[1];
			_spr  = _spr[0];
		}
		
		if(_spr) {
			var _ss = min((hh - ui(4)) / sprite_get_width(_spr), (hh - ui(4)) / sprite_get_height(_spr));
			gpu_set_texfilter(true);
			draw_sprite_ext(_spr, _spri, xx + ui(12), yy + hh / 2, _ss, _ss, 0, COLORS._main_icon);
			gpu_set_texfilter(false);
		}
		
		return _hov;
	}
	
	sp_current_list = new scrollPane(list_w, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var sw  = sp_current_list.surface_w;
		var hh  = ui(4);
		var hg  = ui(22);
		
		var xx = 0;
		var yy = _y + ui(4);
		
		var hover = sp_current_list.hover;
		var focus = sp_current_list.active;
		
		var hoverI = noone;
		
		var hoverX = 0;
		var hoverY = _y + ui(2);
		var delI   = noone;
		
		if(_m[0] > 0 && _m[0] < sw)
			hoverI = 0;
		
		for( var i = 0, n = array_length(menu); i < n; i++ ) {
			var _menu = menu[i];
			var _hov  = drawMenu(hover, focus, _menu, xx, yy, sw, hg, _m);
			if(_hov) {
				hoverI = _m[1] > yy + hg / 2? i + 1 : i;
				hoverX = 0;
				hoverY = _m[1] > yy + hg / 2? yy + hg + ui(2) : yy - ui(2);
				
				if(mouse_lpress(focus)) {
					dragging = _menu;
					delI     = i;
				}
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		if(_m[0] > 0 && _m[0] < sw && _m[1] > yy - ui(4)) {
			hoverI = n;
			hoverX = 0;
			hoverY = yy - ui(2);
		}
		
		if(delI != noone) {
			array_delete(menu, delI, 1);
			PREF_SAVE();
		}
		
		if(dragging != "") { 
			if(hoverI != noone) {
				draw_set_color(COLORS._main_accent);
				draw_line_width(hoverX + ui(4), hoverY - 1, sw - ui(8) - hoverX, hoverY - 1, 2);
				
				if(mouse_lrelease())
					array_insert(menu, hoverI, dragging);
			}
			
			if(mouse_lrelease()) {
				dragging  = "";
				PREF_SAVE();
			}
		}
		
		return hh + ui(16);
	});
	
	sp_all_list = new scrollPane(list_w, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var sw = sp_all_list.surface_w;
		var sh = sp_all_list.surface_h;
		
		var _list = NODE_CATEGORY[category_offset + category_page].list;
		if(search_string != "") _list = search_result;
		
		var hg = ui(22);
		var hh = array_length(_list) * (hg + ui(4)) + ui(16);
		
		var xx = 0;
		var yy = _y;
		
		var hover = sp_all_list.hover;
		var focus = sp_all_list.active;
		
		for( var i = 0, n = array_length(_list); i < n; i++ ) {
			var _menu = _list[i];
			var yy = _y + i * (hg + ui(4));
			
			if(yy + hg + ui(4) < 0) continue;
			if(yy > sh) break;
			
			if(is_string(_menu)) {
				if(string_starts_with(_menu, "/")) {
					draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text_sub);
					draw_text_add(xx + ui(16), yy + hg / 2, string_trim_start(_menu, ["/"]));
					
				} else {
					draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
					draw_text_add(xx + ui(8), yy + hg / 2, _menu);
				}
				continue;
			}
			
			var _hov = drawMenu(hover, focus, _menu, xx, yy, sw, hg, _m);
			
			if(_hov && mouse_lpress(focus))
				dragging  = _menu.nodeName;
		}
		
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		list_w = (w - padding * 2) / 2 - (padding + ui(8)) / 2;
		list_h = h - padding * 2;
		
		var px = padding;
		var py = padding;
		var pw = list_w;
		var ph = list_h;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_current_list.verify(list_w, list_h);
		sp_current_list.setFocusHover(pFOCUS, pHOVER);
		sp_current_list.drawOffset(px, py, mx, my);
		
		list_h -= ui(28);
		
		var px = padding + list_w + padding + ui(8);
		var py = padding + ui(28);
		var pw = list_w;
		var ph = list_h;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_all_list.verify(list_w, list_h);
		sp_all_list.setFocusHover(pFOCUS, pHOVER);
		sp_all_list.drawOffset(px, py, mx, my);
		
		var tx = px - ui(8);
		var ty = padding - ui(8);
		var tw = pw + ui(16);
		var th = ui(24);
		
		var bx = tx + tw - th;
		var bc = CARRAY.button_negative;
		if(buttonInstant(THEME.button_hide, bx, ty, th, th, [mx,my], pHOVER, pFOCUS, "Reset", THEME.refresh_16, 0, bc) == 2) 
			resetDefault()
		tw -= th + ui(4);
		
		var sw = ui(128);
		sc_category.setFocusHover(pFOCUS, pHOVER);
		sc_category.draw(tx, ty, sw, th, category_page, [mx,my], x, y);
		tx += sw + ui(4); tw -= sw + ui(4);
		
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(tx, ty, tw, th, search_string, [mx,my]);
		
	}
	
	function drawGUI() {
		if(dragging != "") drawMenu(false, false, dragging, mouse_mx, mouse_my, sp_current_list.surface_w, ui(22), infinity );
	}
	
	function resetDefault() {
		PREFERENCES.dialog_add_node_pie = array_clone(PREFERENCES_DEF.dialog_add_node_pie);
		PREF_SAVE();
	}
}
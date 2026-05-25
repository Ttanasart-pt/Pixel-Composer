function menuItemEdit(_mid, _pie = false) { dialogPanelCall(new Panel_MenuItems_Editor(_mid, _pie)); }
function menuItemReset(_mid) { variable_struct_remove(PREFERENCES_MENUITEMS, _mid); PREF_SAVE(); }

function Panel_MenuItems_Editor(_menuId, _pie = false) : PanelContent() constructor {
	title  = __txt("Editing") + ": " + _menuId;
	menuId = _menuId;
	menu   = variable_clone(menuItems_get(menuId));
	pie    = _pie;
	auto_pin = true;
	
	w      = min(WIN_W - ui(100), ui(1000));
	h      = ui(480);
	hg     = ui(22);
	list_w = (w - padding * 2) / 2;
	list_h = h - padding * 2;
	
	dragging  = "";
	drag_type = 0;
	
	#region categories
		category_page = 0;
		categories = [
			"All",
			"Global", 
			"Panel",
			-1,
			"Animation",
			"Collection",
			"Graph",
			"Inspector", 
			"Node",
			"Preset",
			"Preview",
		];
		
		cat_contents = {};
		
		var _menus = struct_get_names(MENU_ITEMS);
		cat_contents[$ "All"] = _menus;
		
		for( var i = 4, n = array_length(categories); i < n; i++ ) {
			var _cat = categories[i];
			if(_cat == -1) continue;
			
			__cat = string_lower(_cat) + "_";
			cat_contents[$ _cat] = array_filter(_menus, function(v) /*=>*/ {return string_starts_with(v, __cat)});
		}
		
		cat_contents[$ "Graph"]  = array_filter(_menus, function(v) /*=>*/ {return string_starts_with(v, "graph_") && !string_starts_with(v, "graph_add_")});
		cat_contents[$ "Node"]   = array_filter(_menus, function(v) /*=>*/ {return string_starts_with(v, "graph_add_")});
		cat_contents[$ "Panel"]  = array_filter(_menus, function(v) /*=>*/ {return string_ends_with(v, "_panel")});
		cat_contents[$ "Global"] = array_filter(_menus, function(v) /*=>*/ { return !string_starts_with(v, "animation")  && 
			                                                            !string_starts_with(v, "collection") &&
			                                                            !string_starts_with(v, "graph")      &&
			                                                            !string_starts_with(v, "inspector")  &&
			                                                            !string_starts_with(v, "preset")     &&
			                                                            !string_starts_with(v, "preview") 
		                                                       } );
		
		sc_types = new scrollBox(categories, function(i) /*=>*/ { category_page = i; setSearch(); }).setFont(f_p3);
	#endregion
	
	#region all list
		item_renaming = undefined;
		tb_rename     = textBox_Text(function(s) /*=>*/ { 
			if(item_renaming == undefined) return;
			item_renaming.name = s;
			item_renaming      = undefined;
		}).setFont(f_p3).setEmpty();
		
		show_type = 0;
		
		search_string = "";
		tb_search = textBox_Text(function(s) /*=>*/ { setSearch(s); }).setFont(f_p3).setEmpty().setAutoupdate();
		
		static setSearch = function(s = search_string) {
			search_string = s;
			
			if(show_type == 0) {
				var _cat = categories[category_page];
				all_menu = cat_contents[$ _cat];
				
			} else 
				all_menu = struct_get_names(MENUITEM_CONDITIONS);
				
			if(pie) all_menu = array_filter(all_menu, function(m,i) /*=>*/ { var it = MENU_ITEMS[$ m]; return is(it, MenuItem); });
			if(s == "") { array_sort(all_menu, true); return; }
			
			var _filt = [];
			var _inv = string_starts_with(s, "-");
			var _s   = string_trim_start(string_lower(s), ["-"]);
			
			for( var i = 0, n = array_length(all_menu); i < n; i++ ) {
				var _a = all_menu[i];
				var _match = bool(string_pos(_s, string_lower(_a)));
				if(_inv) _match = !_match;
				
				if(_match) array_push(_filt, _a);
			}
			
			array_sort(_filt, true);
			all_menu = _filt;
			
		} setSearch();
		
		static setShowType = function(_type) {
			show_type = _type;
			setSearch(search_string);
		}
		
	#endregion
	
	function drawGroup(hover, focus, _menu, xx, yy, ww, _m, _cont = false) {
		if(has(_menu, "name")) return drawSubmenu(   hover, focus, _menu, xx, yy, ww, _m, _cont );
		if(has(_menu, "cond")) return drawCondition( hover, focus, _menu, xx, yy, ww, _m, _cont );
		return false;
	}
	
	function drawSubmenu(hover, focus, _menu, xx, yy, ww, _m, _cont = false) {
		var _item  = _menu.items;
		var _cat_h = (array_length(_item) + 1) * (hg + ui(4));
		
		var _name = _menu.name;
		var _hov  = _m == infinity || (hover && point_in_rectangle(_m[0], _m[1], xx, yy - ui(2), xx + ww, yy + hg + ui(2) - 1));
		
		var _cc = CDEF.cyan;
		if(_cont) draw_sprite_stretched_ext(THEME.box_r2_clr, 0, xx, yy, ww, _cat_h, _cc, 1);
		draw_sprite_stretched_ext(THEME.box_r2_clr, 0, xx, yy, ww, hg, _cc, 1);
		draw_set_text(f_p3, fa_left, fa_center, _cc);
		if(item_renaming == _menu) {
			tb_rename.setFocusHover(pFOCUS, pHOVER);
			tb_rename.drawParam(new widgetParam(xx, yy, ww, hg, _name, undefined, _m));
			
		} else 
			draw_text_add(xx + ui(8), yy + hg / 2, _name);
		
		if(_hov) draw_sprite_stretched_ext(THEME.box_r2, 1, xx, yy, ww, hg, _cc, .5);
		
		return _hov;
	}
	
	function drawCondition(hover, focus, _menu, xx, yy, ww, _m, _cont = false) {
		var _item  = _menu.items;
		var _cat_h = (array_length(_item) + 1) * (hg + ui(4));
		
		var _cond = is_string(_menu)? _menu : _menu.cond;
		var _hov  = _m == infinity || (hover && point_in_rectangle(_m[0], _m[1], xx, yy - ui(2), xx + ww, yy + hg + ui(2) - 1));
		
		var _cc = COLORS._main_accent;
		if(_cont) draw_sprite_stretched_ext(THEME.box_r2_clr, 0, xx, yy, ww, _cat_h, _cc, 1);
		draw_sprite_stretched_ext(THEME.box_r2_clr, 0, xx, yy, ww, hg, _cc, 1);
		draw_set_text(f_p3, fa_left, fa_center, _cc);
		draw_text_add(xx + ui(8), yy + hg / 2, _cond);
		
		if(_hov) draw_sprite_stretched_ext(THEME.box_r2, 1, xx, yy, ww, hg, _cc, .5);
		
		return _hov;
	}
	
	function drawMenu(hover, focus, _menu, xx, yy, ww, _m) {
		var _txt  = _menu;
		var _tc   = COLORS._main_text;
		var _spr  = noone;
		var _spri = 0;
		
		if(_menu == -1) {
			_txt = "separator";
			_tc  = COLORS._main_text_sub;
			_spr = THEME.minus_16;
			
		} else if(struct_has(MENU_ITEMS, _menu)) {
			var _mObj = MENU_ITEMS[$ _menu];
			
			_txt = _mObj.name;
			_spr = _mObj.spr;
		}
		
		var _hov = _m == infinity || (hover && point_in_rectangle(_m[0], _m[1], xx, yy - ui(2), xx + ww, yy + hg + ui(2) - 1));
		
		if(_hov) {
			draw_sprite_stretched(THEME.box_r2_clr, 0, xx, yy, ww, hg);
			draw_sprite_stretched(THEME.box_r2_clr, 1, xx, yy, ww, hg);
			
		} else {
			draw_sprite_stretched_ext(THEME.box_r2_clr, 0, xx, yy, ww, hg, c_white, .3);
			
		}
		
		var tx = xx + ui(24 + 4);
		
		draw_set_text(f_p3, fa_left, fa_center, _tc);
		draw_text_add(tx, yy + hg / 2, _txt); 
		tx += string_width(_txt) + ui(8);
		
		draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(tx, yy + hg / 2, _menu);
		
		if(is_array(_spr)) {
			_spri = _spr[1];
			_spr  = _spr[0];
		}
		
		if(is_callable(_spr)) _spr = _spr();
		if(sprite_exists(_spr)) {
			var _ss = min((hg - ui(4)) / sprite_get_width(_spr), (hg - ui(4)) / sprite_get_height(_spr));
			gpu_set_texfilter(true);
			draw_sprite_ext(_spr, _spri, xx + ui(12), yy + hg / 2, _ss, _ss, 0, COLORS._main_icon);
			gpu_set_texfilter(false);
		}
		
		return _hov;
	}

	sp_current_list = new scrollPane(list_w, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var sw  = sp_current_list.surface_w;
		var hh  = ui(4);
		
		var xx = 0;
		var yy = _y + ui(4);
		
		var hover = sp_current_list.hover;
		var focus = sp_current_list.active;
		
		var hoverC = noone;
		var hoverI = noone;
		
		var hoverX = 0;
		var hoverY = _y + ui(2);
		var delI   = noone;
		
		if(_m[0] > 0 && _m[0] < sw) {
			hoverI = 0;
		}
		
		for( var i = 0, n = array_length(menu); i < n; i++ ) {
			var _menu = menu[i];
			
			if(!is_struct(_menu)) { // string
				var _hov = drawMenu(hover, focus, _menu, xx, yy, sw, _m);
				if(_hov) {
					hoverC = noone;
					hoverI = _m[1] > yy + hg / 2? i + 1 : i;
					hoverX = 0;
					hoverY = _m[1] > yy + hg / 2? yy + hg + ui(2) : yy - ui(2);
					
					if(mouse_lpress(focus)) {
						dragging  = _menu;
						drag_type = 0;
						delI = i;
					}
				}
				
				yy += hg + ui(4);
				hh += hg + ui(4);
				continue;
			}
			
			if(!has(_menu, "items")) continue;
			
			var _item  = _menu.items;
			var _cat_h = (array_length(_item) + 1) * (hg + ui(4));
			
			var _cc = COLORS._main_accent, _hov;
			_hov = drawGroup(hover, focus, _menu, xx, yy, sw, _m, true);
			
			if(drag_type == 1 && hover && point_in_rectangle(_m[0], _m[1], xx, yy + hg / 2, xx + sw, yy + _cat_h + ui(2) - 1)) {
				hoverC = noone;
				hoverI = i + 1;
				hoverX = 0;
				hoverY = yy + _cat_h + ui(2);
			}
			
			if(_hov) {
				if(_m[1] > yy + hg / 2) {
					if(drag_type == 0) {
						hoverC = _menu;
						hoverI = 0;
						hoverX = ui(4);
						hoverY = yy + hg + ui(2);
					}
					
				} else {
					hoverC = noone;
					hoverI = i;
					hoverX = 0;
					hoverY = yy - ui(2);
					
				}
				
				if(_m[0] < sw - hg && mouse_lpress(focus)) {
					hoverC    = noone;
					dragging  = _menu;
					drag_type = 1;
					delI      = i;
				}
			}
			
			var bs = ui(18);
			var bx = sw - bs - ui(2);
			var by = yy;
			if(buttonInstant(noone, bx, by, bs, hg, _m, hover, focus, "", THEME.cross_12, 0, COLORS._main_value_negative, .75) == 2) {
				hoverC = noone;
				delI   = i;
			} bx -= bs+1;
			
			if(has(_menu, "name")) {
				if(buttonInstant(noone, bx, by, bs, hg, _m, hover, focus, "", THEME.rename, 0, COLORS._main_icon_light, .75, .5) == 2) {
					hoverC = noone;
					item_renaming = _menu;
					tb_rename.activate(_menu.name);
					
				} bx -= bs+1;
					
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
			
			var _sx = xx + ui(8);
			var _sw = sw - ui(8 + 8);
			
			for( var j = 0, m = array_length(_item); j < m; j++ ) {
				var _subMenu = _item[j];
				
				var _hov = drawMenu(hover, focus, _subMenu, _sx, yy, _sw, _m);
				
				if(_hov) {
					if(drag_type == 0) {
						hoverC = _menu;
						hoverI = _m[1] > yy + hg / 2? j + 1 : j;
						hoverX = ui(4);
						hoverY = _m[1] > yy + hg / 2? yy + hg + ui(2) : yy - ui(2);
					}
					
					if(mouse_lpress(focus)) {
						dragging  = _subMenu;
						drag_type = 0;
						delI = j;
					}
				}
				
				yy += hg + ui(4);
				hh += hg + ui(4);
			}
			
			yy += ui(4);
			hh += ui(4);
		}
		
		if(_m[0] > 0 && _m[0] < sw && _m[1] > yy - ui(4)) {
			hoverC = noone;
			hoverI = n;
			hoverX = 0;
			hoverY = yy - ui(2);
		}
		
		if(delI != noone) {
			if(hoverC == noone) array_delete(menu, delI, 1);
			else array_delete(hoverC.items, delI, 1);
		}
		
		if(dragging != "") { 
			if(hoverI != noone) {
				draw_set_color(COLORS._main_accent);
				draw_line_width(hoverX + ui(4), hoverY - 1, sw - ui(8) - hoverX, hoverY - 1, 2);
				
				if(mouse_lrelease()) {
					if(drag_type == 0) {
						if(hoverC == noone) array_insert(menu, hoverI, dragging);
						else array_insert(hoverC.items, hoverI, dragging);
						
					} else {
						     if(is_struct(dragging))   array_insert(menu, hoverI, dragging);
						else if(is_string(dragging)) {
							if(dragging == "submenu") 
								 array_insert(menu, hoverI, { name: "submenu", items: [] });
							else array_insert(menu, hoverI, { cond: dragging,  items: [] });
						}
					}
				}
			}
			
			if(mouse_lrelease()) {
				dragging  = "";
				drag_type = 0;
				
				PREFERENCES_MENUITEMS[$ menuId] = menu;
				PREF_SAVE();
			}
		}
		
		return hh + ui(16);
	});
	
	sp_all_list = new scrollPane(list_w, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var sw = sp_all_list.surface_w;
		var sh = sp_all_list.surface_h;
		
		var hh = array_length(all_menu) * (hg + ui(4)) + ui(16);
		
		var xx = 0;
		var yy = _y;
		
		var hover = sp_all_list.hover;
		var focus = sp_all_list.active;
		
		for( var i = 0, n = array_length(all_menu); i < n; i++ ) {
			var _menu = all_menu[i];
			var yy = _y + i * (hg + ui(4));
			
			if(yy + hg + ui(4) < 0) continue;
			if(yy > sh) break;
			
			var _hov = false;
			
			if(show_type == 0) 
			     _hov = drawMenu(  hover, focus, _menu, xx, yy, sw, _m );
			else _hov = drawGroup( hover, focus, _menu, xx, yy, sw, _m );
			
			if(_hov && mouse_lpress(focus)) {
				dragging  = _menu;
				drag_type = show_type;
			}	
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
		
		if(buttonInstant(THEME.button_hide, tx, ty, th, th, [mx,my], pHOVER, pFOCUS, "Separator", THEME.minus_16) == 2) {
			dragging  = -1;
			drag_type =  0;
		}
		tx += th + ui(4); tw -= th + ui(4);
		
		var bc = show_type? COLORS._main_accent : COLORS._main_icon;
		if(buttonInstant(THEME.button_hide, tx, ty, th, th, [mx,my], pHOVER, pFOCUS, "Show Condition", THEME.arrow, 0, bc) == 2) 
			setShowType(!show_type);
		tx += th + ui(4); tw -= th + ui(4);
		
		var bc = COLORS._main_icon;
		if(buttonInstant(THEME.button_hide, tx, ty, th, th, [mx,my], pHOVER, pFOCUS, "Submenu", THEME.view_group, 2, bc, 1, .8) == 2) {
			dragging  = "submenu";
			drag_type = 1;
		}
		tx += th + ui(4); tw -= th + ui(4);
		
		var bx = tx + tw - th;
		var bc = CARRAY.button_negative;
		if(buttonInstant(THEME.button_hide, bx, ty, th, th, [mx,my], pHOVER, pFOCUS, "Reset", THEME.refresh_16, 0, bc) == 2) 
			resetDefault()
		tw -= th + ui(4);
		
		if(show_type == 0) {
			var sw = ui(104);
			sc_types.setFocusHover(pFOCUS, pHOVER);
			sc_types.draw(tx, ty, sw, th, category_page, [mx,my], x, y);
			tx += sw + ui(4); tw -= sw + ui(4);
		}
		
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(tx, ty, tw, th, search_string, [mx,my]);
		
	}
	
	function drawGUI() {
		if(dragging != "") {
			     if(drag_type == 0) drawMenu(  false, false, dragging, mouse_mx, mouse_my, sp_current_list.surface_w, infinity );
			else if(drag_type == 1) drawGroup( false, false, dragging, mouse_mx, mouse_my, sp_current_list.surface_w, infinity );
		}
	}
	
	function resetDefault() {
		variable_struct_remove(PREFERENCES_MENUITEMS, menuId);
		menu   = variable_clone(menuItems_get(menuId));
		setSearch(search_string);
		
		PREF_SAVE();
	}
}
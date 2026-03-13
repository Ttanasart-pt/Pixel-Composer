function Panel_Action_Manager() : PanelContent() constructor {
	title = __txt("Action Manager");
	showHeader = true;
	
	w     = min(WIN_W, ui(800));
	h     = ui(400);
	min_w = ui(640);
	min_h = ui(320);
	auto_pin = true;
	padding  = ui(6);
	
	action_selecting = undefined;
	closeOnCreate    = false;
	creating         = false;
	
	search_string = "";
	tb_search     = textBox_Text(function(t) /*=>*/ { search_string = t; }).setEmpty().setAutoupdate().setFont(f_p3);
	
	node_categories = [ "None" ];
	cat_value       = [ noone ];
	cat_index       = 0;
	for(var i = 0; i < array_length(NODE_CATEGORY); i++) {
		var _name = NODE_CATEGORY[i].name;
		switch(_name) {
			case "Action" :
			case "Custom" :
			case "Extra" :
				continue;
		}
		
		array_push(node_categories, _name);
		array_push(cat_value, [ _name, "" ]);
		
		var _list  = NODE_CATEGORY[i].list;
		
		for(var j = 0, m = array_length(_list); j < m; j++ ) {
			if(is_string(_list[j])) {
				array_push(node_categories, $"> {_list[j]}");
				array_push(cat_value, [ _name, _list[j] ]);
			}
		}
		
		array_push(node_categories, -1);
		array_push(cat_value, noone);
	}
	
	tb_name 	= textBox_Text(  function(s) /*=>*/ { if(action_selecting == undefined) return; action_selecting.name    = s; }).setAutoUpdate().setFont(f_p2);
	tb_tooltip  = textArea_Text( function(s) /*=>*/ { if(action_selecting == undefined) return; action_selecting.tooltip = s; }).setAutoUpdate().setFont(f_p2);
	tb_alias    = textArea_Text( function(s) /*=>*/ { if(action_selecting == undefined) return; action_selecting.tags    = s; }).setAutoUpdate().setFont(f_p2);
	tb_location = new scrollBox(node_categories, function(v) /*=>*/ { 
		if(action_selecting == undefined) return; 
		action_selecting.location = v >= 0? cat_value[v] : noone;
		cat_index = v; 
	}).setFont(f_p2).setAlign(fa_left).setHorizontal(true).setPadding(ui(16)).setPaddingItem(ui(4));

	b_create = button(function() /*=>*/ {
		if(action_selecting == undefined) return; 
		action_selecting.save();
		if(closeOnCreate) close();
		
		__initNodeActions(true);
	}).setText(__txtx("new_action_create", "Create"));
	
	sc_action_list = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _w = sc_action_list.surface_w;
		var _h = sc_action_list.surface_h;
		
		var hover = sc_action_list.hover;
		var focus = sc_action_list.active;
		
		var hh = 0;
		var hg = ui(24);
		var yy = _y;
		
		for( var i = 2, n = array_length(NODE_ACTION_LIST); i < n; i++ ) {
			var _act = NODE_ACTION_LIST[i];
			var _name = _act.name;
			if(search_string != "" && string_pos(string_lower(search_string), string_lower(_name)) == 0)
				continue;
				
			var _sel = _act == action_selecting;
			var _hov = hover && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + hg - 1);
			var _spr = _act.spr;
			
			var cc = _hov? COLORS._main_text : COLORS._main_text_sub;
			if(_sel) cc = COLORS._main_text_accent;
			
			if(_spr) draw_sprite_fit(_spr, 0, ui(4 + 16), yy + hg / 2, ui(16), ui(16));
			
			draw_set_text(f_p3, fa_left, fa_center, cc);
			draw_text_add(ui(4 + 32 + 4), yy + hg / 2, _name);
			
			if(_hov && mouse_lpress(focus)) {
				if(_sel) action_selecting = undefined;
				else setAction(_act);
			}
			
			yy += hg;
			hh += hg;
		}
		
		return hh;
	});
	
	function setAction(act) {
		action_selecting = act;
		cat_index = array_find(cat_value, action_selecting.location);
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var _pd = padding;
		
		var lstw =  ui(200);
		var ndx  = _pd;
		var ndy  = _pd;
		var ndw  = lstw;
		var ndh  = h - _pd * 2;
		
		var bs = ui(24);
		var bx = ndx + ndw - bs;
		var by = ndy;
		if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, [mx,my], pHOVER, pFOCUS, "", THEME.add, 0, COLORS._main_value_positive) == 2) {
			//
		}
		
		var tx = ndx;
		var ty = ndy;
		var tw = bx - tx - ui(4);
		var th = bs;
		
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(tx, ty, tw, th, search_string, [mx,my]);
		draw_sprite_ui(THEME.search, 0, tx + tw - th/2, ty + th/2, .75, .75, 0, COLORS._main_icon, .5);
		
		ndy += bs + ui(4);
		ndh -= bs + ui(4);
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_action_list.setFocusHover(pFOCUS, pHOVER);
		sc_action_list.verify(ndw - ui(8), ndh - ui(8));
		sc_action_list.drawOffset(ndx + ui(4), ndy + ui(4), mx, my);
		
		var metaW = ui(288);
		var ndx  = ndx + lstw + _pd;
		var ndy  = _pd;
		var ndw  = w - _pd - ndx - metaW - _pd;
		var ndh  = h - _pd * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		// Metadata
		var _tx = w - metaW;
		var _nm = ui(80);
		var _wx = _tx + _nm;
		var _wy = ui(8);
		var _ww = metaW - _pd - _nm;
		var _wh = TEXTBOX_HEIGHT;
		var _th = _wy;
		
		var tcc = action_selecting == undefined? COLORS._main_text_sub : COLORS._main_text;
		var act = action_selecting != undefined;
		
		tb_name.setInteract(act);     tb_name.setFocusHover(pFOCUS, pHOVER);     tb_name.register();
		tb_tooltip.setInteract(act);  tb_tooltip.setFocusHover(pFOCUS, pHOVER);  tb_tooltip.register();
		tb_alias.setInteract(act);    tb_alias.setFocusHover(pFOCUS, pHOVER);    tb_alias.register();
		tb_location.setInteract(act); tb_location.setFocusHover(pFOCUS, pHOVER); tb_location.register();
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx + ui(4), _wy + _wh / 2, __txt("Name"));
		var _tt = action_selecting == undefined? "" : action_selecting.name;
		var _hh = tb_name.draw(_wx, _wy, _ww, _wh, _tt, [ mx, my ]);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx + ui(4), _wy + _wh / 2, __txt("Alias"));
		var _tt = action_selecting == undefined? "" : action_selecting.tags;
		var _hh = tb_alias.draw(_wx, _wy, _ww, _wh, _tt, [ mx, my ]);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx + ui(4), _wy + _wh / 2, __txt("Tooltip"));
		var _tt = action_selecting == undefined? "" : action_selecting.tooltip;
		var _hh = tb_tooltip.draw(_wx, _wy, _ww, _wh * 2, _tt, [ mx, my ]);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx + ui(4), _wy + _wh / 2, __txt("Category"));
		var _hh = tb_location.draw(_wx, _wy, _ww, _wh, cat_index, [ mx, my ], x, y);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
	}
}
function Panel_Action_Manager() : PanelContent() constructor {
	title = __txt("Action Manager");
	showHeader = true;
	
	w     = min(WIN_W, ui(800));
	h     = ui(400);
	min_w = ui(640);
	min_h = ui(320);
	auto_pin = true;
	padding  = ui(8);
	
	action_selecting = undefined;
	closeOnCreate    = false;
	creating         = false;
	rawNodes         = [];
		
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
	tb_alias    = new textArrayCustom(function() /*=>*/ {}).setFont(f_p2);
	tb_tooltip  = textArea_Text( function(s) /*=>*/ { if(action_selecting == undefined) return; action_selecting.tooltip = s; }).setAutoUpdate().setFont(f_p2);
	tb_location = new scrollBox(node_categories, function(v) /*=>*/ { 
		if(action_selecting == undefined) return; 
		action_selecting.location = v >= 0? cat_value[v] : noone;
		cat_index = v; 
	}).setFont(f_p2).setAlign(fa_left).setHorizontal(true).setPadding(ui(16)).setPaddingItem(ui(4));
	
	sc_action_list = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _w = sc_action_list.surface_w;
		var _h = sc_action_list.surface_h;
		
		var hover = sc_action_list.hover;
		var focus = sc_action_list.active;
		
		var hh = 0;
		var hg = ui(24);
		var yy = _y;
		
		if(creating) {
			draw_sprite_fit(THEME.node_action_create, 0, ui(4 + 16), yy + hg / 2, ui(16), ui(16));
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_value_positive);
			draw_text_add(ui(4 + 32 + 4), yy + hg / 2, action_selecting.name);
			
			yy += hg;
			hh += hg;
		}
		
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
			
			if(!creating && _hov && mouse_lpress(focus)) {
				if(_sel) action_selecting = undefined;
				else setAction(_act);
			}
			
			yy += hg;
			hh += hg;
		}
		
		return hh;
	});
	
	sc_action_content = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		if(action_selecting == undefined) return 0;
		
		var _w = sc_action_content.surface_w;
		var _h = sc_action_content.surface_h;
		
		var hover = sc_action_content.hover;
		var focus = sc_action_content.active;
		
		var hh = 0;
		var yy = _y;
		var hg = line_get_height(f_p2, 6);
		
		var _nodes = action_selecting.nodes;
		for( var i = 0, n = array_length(_nodes); i < n; i++ ) {
			var __n = _nodes[i];
			
			var _id = __n[$ "id"   ] ?? i;
			var _nd = __n[$ "node" ] ?? "";
			var _nx = __n[$ "x"    ] ?? 160 * i;
			var _ny = __n[$ "y"    ] ?? 0;
			
			var _nodeData = ALL_NODES[$ _nd];
			if(_nodeData == undefined) continue;
			
			var _hv = pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + hg);
			if(_hv) sc_action_content.hover_content = true;
			var _cc = _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg;
			draw_sprite_stretched_ext(THEME.box_r5_clr, _hv, 0, yy, _w, hg, _cc);
			
			var tx = ui(8);
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(tx, yy + hg / 2, _nodeData.name);
			tx += string_width(_nodeData.name) + ui(4);
			draw_set_color(COLORS._main_text_sub)
			draw_text_add(tx, yy + hg / 2, $"[{_id}]");
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	});
	
	sc_action_creating = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _w  = sc_action_creating.surface_w;
		var _h  = ui(16);
		var yy  = _y;
		var _lh = line_get_height(f_p2);
		
		for (var i = 0, n = array_length(rawNodes); i < n; i++) {
			var _r    = rawNodes[i];
			var _n    = _r.node;
			var _name = _n.getFullName();
			var _nd   = action_selecting.nodes[i];
			
			var _bw = _w;
			var _bh = _lh + ui(4);
			
			var _hv = pHOVER && point_in_rectangle(_m[0], _m[1], _bw - ui(24), yy, _bw, yy + _bh);
			if(_hv) sc_action_creating.hover_content = true;
			var _cc = _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg;
			draw_sprite_stretched_ext(THEME.box_r5_clr, _hv, _bw - ui(24), yy, ui(24), _bh, _cc);
			
			var _bc = action_selecting.outputNode == i? COLORS._main_value_negative : COLORS._main_icon_dark;
			draw_sprite_ui(THEME.arrow, 1, _bw - ui(12), yy + _bh / 2, 1, 1, 0, _bc);
			if(_hv) TOOLTIP = __txt("Action Output");
			if(mouse_press(mb_left, _hv)) action_selecting.outputNode = action_selecting.outputNode == i? noone : i;
			_bw -= ui(28);
			
			var _hv = pHOVER && point_in_rectangle(_m[0], _m[1], _bw - ui(24), yy, _bw, yy + _bh);
			if(_hv) sc_action_creating.hover_content = true;
			var _cc = _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg;
			draw_sprite_stretched_ext(THEME.box_r5_clr, _hv, _bw - ui(24), yy, ui(24), _bh, _cc);
			
			var _bc = action_selecting.inputNode == i? COLORS._main_value_positive : COLORS._main_icon_dark;
			draw_sprite_ui(THEME.arrow, 3, _bw - ui(12), yy + _bh / 2, 1, 1, 0, _bc);
			if(_hv) TOOLTIP = __txt("Action Input");
			if(mouse_press(mb_left, _hv)) action_selecting.inputNode = action_selecting.inputNode == i? noone : i;
			_bw -= ui(28);
			
			var _hv = pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, _bw, yy + _bh);
			if(_hv) sc_action_creating.hover_content = true;
			var _cc = _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg;
			draw_sprite_stretched_ext(THEME.box_r5_clr, _hv, 0, yy, _bw, _bh, _cc);
			
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
			draw_text_add(ui(8), yy + ui(2), _name);
			
			if(mouse_press(mb_left, _hv)) _r.expanded = !_r.expanded;
			
			yy += _bh;
			_h += _bh;
			
			if(_r.expanded) {
				var _val = _nd.setValues;
				
				for(var j = 0; j < array_length(_n.inputs); j++) {
					var _in   = _n.inputs[j];
					if(!value_type_direct_settable(_in.type)) continue;
					
					var _vali = _val[$ j];
					var _ttg  = false;
					
					var _bx = ui(8 + 12);
					var _by = yy + _lh / 2;
					var _tg = struct_has(_vali, "value"); _ttg = _ttg || _tg;
					var _hv = pHOVER && point_in_circle(_m[0], _m[1], _bx, _by, ui(8));
					if(_hv) {
						TOOLTIP = "Save value";
						sc_action_creating.hover_content = true;
					}
					
					draw_sprite_ui(THEME.circle_toggle_8, _tg, _bx, _by, 1, 1, 0, _tg? c_white : COLORS._main_icon, .5 + .5 * (_hv || _tg));
					if(mouse_press(mb_left, _hv)) {
						if(_tg) struct_remove(_vali, "value");
						else    _vali[$ "value"] = _in.getValue();
					}
					_bx += ui(12);
					
					if(_in.expUse) {
						var _tg = struct_has(_vali, "expression"); _ttg = _ttg || _tg;
						var _hv = pHOVER && point_in_circle(_m[0], _m[1], _bx, _by, ui(8));
						if(_hv) {
							TOOLTIP = "Save expression";
							sc_action_creating.hover_content = true;
						}
						
						draw_sprite_ui(THEME.circle_toggle_8, _tg, _bx, _by, 1, 1, 0, _tg? c_white : COLORS._main_icon, .5 + .5 * (_hv || _tg));
						if(mouse_press(mb_left, _hv)) {
							if(_tg) struct_remove(_vali, "expression");
							else    _vali[$ "expression"] = _in.expression;
						}
					}
					_bx += ui(12);
					
					if(_in.unit.reference != noone) {
						var _tg = struct_has(_vali, "unit"); _ttg = _ttg || _tg;
						var _hv = pHOVER && point_in_circle(_m[0], _m[1], _bx, _by, ui(8));
						if(_hv) {
							TOOLTIP = "Save unit";
							sc_action_creating.hover_content = true;
						}
						
						draw_sprite_ui(THEME.circle_toggle_8, _tg, _bx, _by, 1, 1, 0, _tg? c_white : COLORS._main_icon, .5 + .5 * (_hv || _tg));
						if(mouse_press(mb_left, _hv)) {
							if(_tg) struct_remove(_vali, "unit");
							else    _vali[$ "unit"] = _in.unit.mode;
						}
					}
					_bx += ui(12);
					
					draw_set_text(f_p2, fa_left, fa_top, _ttg? c_white : COLORS._main_text_sub);
					draw_text_add(_bx, yy, _in.name);
					
					yy += _lh;
					_h += _lh;
				}
			}
			
			yy += ui(4);
			_h += ui(4);
		}
		
		return _h;
	});
	
	function setAction(act) {
		action_selecting = act;
		cat_index = array_find(cat_value, action_selecting.location);
	}
	
	function newAction(_nodes) { 
		action_selecting = new NodeAction();
		creating = true;
		rawNodes = [];
		
		if(array_empty(_nodes)) { close(); return; }
		
		var _nmap = {};
		var _minx = _nodes[0].x;
		var _miny = _nodes[0].y;
		
		for (var i = 0, n = array_length(_nodes); i < n; i++) {
			var _n = _nodes[i];
			rawNodes[i] = { node: _n, expanded: false };
			_nmap[$ _n.node_id] = i;
			
			_minx = min(_minx, _n.x);
			_miny = min(_miny, _n.y);
		}
		
		for (var i = 0, n = array_length(_nodes); i < n; i++) {
			var _n    = _nodes[i];
			var _idT  = i;
			var _vals = {};
			
			for(var j = 0; j < array_length(_n.inputs); j++) {
				var _in = _n.inputs[j];
				var _vf = _in.value_from;
				_vals[$ j] = {};
				
				if(_vf != noone && !struct_has(_nmap, _vf.node.node_id))
					action_selecting.inputNode = i;
				
				if(_vf == noone || !struct_has(_nmap, _vf.node.node_id)) {
					var _vl = _in.getValue(, false);
					if(!isEqual(_vl, _in.def_val))
						_vals[$ j].value = _vl;
					continue;
				}
				
				var _idF = _nmap[$ _vf.node.node_id];
				
				array_push(action_selecting.connections, {
					from: _idF,
					fromIndex: _vf.index,
					
					to: _idT,
					toIndex: j,
				});
			}
			
			for(var j = 0; j < array_length(_n.outputs); j++) {
				var _ou = _n.outputs[j];
				var _vt = _ou.getJunctionTo();
				
				for( var k = 0, m = array_length(_vt); k < m; k++ )
					if(!struct_has(_nmap, _vt[k].node.node_id)) action_selecting.outputNode = i;
			}
			
			action_selecting.nodes[i] = {
				node: instanceof(_n), 
				x   : _n.x - _minx,
				y   : _n.y - _miny,
				setValues : _vals,
			};
			
		}
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
		var _sel  = array_length(PANEL_GRAPH.nodes_selecting);
		var hover = !creating && pHOVER;
		var txt   = _sel? __txt("Create Action from Selection") : __txt("Select node to create action");
		var bc    = !creating && _sel? COLORS._main_value_positive : COLORS._main_icon;
		if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, [mx,my], hover, pFOCUS, txt, THEME.add, 0, bc) == 2) {
			if(_sel) newAction(PANEL_GRAPH.nodes_selecting);
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
		
		var metaW = ui(280);
		var ndx  = ndx + lstw + _pd;
		var ndy  = _pd;
		var ndw  = w - _pd - ndx - metaW - _pd;
		var ndh  = h - _pd * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		var sc = creating? sc_action_creating : sc_action_content;
		sc.setFocusHover(pFOCUS, pHOVER);
		sc.verify(ndw - ui(8), ndh - ui(8));
		sc.drawOffset(ndx + ui(4), ndy + ui(4), mx, my);
		
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
		tb_alias.setInteract(act);    tb_alias.setFocusHover(pFOCUS, pHOVER);    tb_alias.register();
		tb_tooltip.setInteract(act);  tb_tooltip.setFocusHover(pFOCUS, pHOVER);  tb_tooltip.register();
		tb_location.setInteract(act); tb_location.setFocusHover(pFOCUS, pHOVER); tb_location.register();
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Name"));
		var _tt = action_selecting == undefined? "" : action_selecting.name;
		var _hh = tb_name.draw(_wx, _wy, _ww, _wh, _tt, [ mx, my ]);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Alias"));
		var _tt = action_selecting == undefined? [] : action_selecting.tags;
		var _hh = tb_alias.draw(_wx, _wy, _ww, _wh, _tt, [ mx, my ]);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Tooltip"));
		var _tt = action_selecting == undefined? "" : action_selecting.tooltip;
		var _hh = tb_tooltip.draw(_wx, _wy, _ww, _wh * 2, _tt, [ mx, my ]);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p3, fa_left, fa_center, tcc);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Category"));
		var _hh = tb_location.draw(_wx, _wy, _ww, _wh, cat_index, [ mx, my ], x, y);
		_wy += _hh + ui(8); _th += _hh + ui(8);
		
		var bw = metaW - ui(40);
		var bh = ui(28);
		var bx = w - _pd - metaW;
		var by = h - _pd - bh;
		var hv = pHOVER && point_in_rectangle(mx, my, bx, by, bx + bw, by + bh);
		
		if(creating) {
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, COLORS._main_value_positive, .3 + hv * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, COLORS._main_value_positive, .6 + hv * .25);
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_value_positive);
			draw_text_add(bx + bw / 2, by + bh / 2, __txt("Create Action"));
			
			if(mouse_press(mb_left, pFOCUS && hv)) {
				action_selecting.save();
				__initNodeActions(true);
				close();
			}
			
			bw = ui(36);
			bx = w - _pd - bw;
			by = h - _pd - bh;
			hv = pHOVER && point_in_rectangle(mx, my, bx, by, bx + bw, by + bh);
			
			var cc = hv? COLORS._main_value_negative : COLORS._main_icon;
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, cc, .3 + hv * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, cc, .75 + hv * .15);
			draw_sprite_ui(THEME.cross, 0, bx + bw / 2, by + bh / 2, .75, .75, 0, cc);
			
			if(mouse_press(mb_left, pFOCUS && hv)) {
				action_selecting = undefined;
				creating = false;
			}
			
		} else if(action_selecting != undefined) {
			var cc = hv? COLORS._main_value_positive : COLORS._main_icon;
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, cc, .3 + hv * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, cc, .75 + hv * .15);
			draw_set_text(f_p2, fa_center, fa_center, cc);
			draw_text_add(bx + bw / 2, by + bh / 2, __txt("Update"));
			
			if(mouse_press(mb_left, pFOCUS && hv)) {
				action_selecting.save();
				__initNodeActions(true);
			}
			
			bw = ui(36);
			bx = w - _pd - bw;
			by = h - _pd - bh;
			hv = pHOVER && point_in_rectangle(mx, my, bx, by, bx + bw, by + bh);
			
			var cc = hv? COLORS._main_value_negative : COLORS._main_icon;
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, cc, .3 + hv * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, cc, .75 + hv * .15);
			draw_sprite_ui(THEME.icon_delete_24, 0, bx + bw / 2, by + bh / 2, .75, .75, 0, cc);
			
			if(mouse_press(mb_left, pFOCUS && hv)) {
				action_selecting.deleteFile();
				action_selecting = undefined;
				__initNodeActions(true);
			}
			
		}
	}
}
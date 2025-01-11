function Panel_Action_Create() : PanelContent() constructor {
	#region data
		title = __txt("Create Action");
		showHeader = true;
		padding    = ui(12);
		
		w     = min(WIN_W, ui(720));
		h     = ui(400);
		min_w = ui(640);
		min_h = ui(320);
		
		name     = "New Action";
		tooltip  = "";
		tags     = "";
		location = [];
		spr      = noone;
		
		rawNodes    = [];
		nodes       = [];
		connections = [];
		
		cat_index   = 0;
		node_categories = [ "None" ];
		cat_value   = [ noone ];
		
		for(var i = 0; i < ds_list_size(NODE_CATEGORY); i++) {
			var _name = NODE_CATEGORY[| i].name;
			switch(_name) {
				case "Action" :
				case "Custom" :
				case "Extra" :
					continue;
			}
			
			array_push(node_categories, _name);
			array_push(cat_value, [ _name, "" ]);
			
			var _list  = NODE_CATEGORY[| i].list;
			for(var j = 0, m = ds_list_size(_list); j < m; j++ ) {
				if(is_string(_list[| j])) {
					array_push(node_categories, $"> {_list[| j]}");
					array_push(cat_value, [ _name, _list[| j] ]);
				}
			}
			
			array_push(node_categories, -1);
			array_push(cat_value, noone);
		}
		
		tb_name 	= new textBox( TEXTBOX_INPUT.text, function(str) /*=>*/ { name    = str; }).setAutoUpdate();
		tb_tooltip  = new textArea(TEXTBOX_INPUT.text, function(str) /*=>*/ { tooltip = str; }).setAutoUpdate();
		tb_alias    = new textArea(TEXTBOX_INPUT.text, function(str) /*=>*/ { tags	  = str; }).setAutoUpdate();
		tb_location = new scrollBox(node_categories, function(val) /*=>*/ { cat_index = val; });
		tb_location.align      = fa_left;
		tb_location.horizontal = true;
		tb_location.padding    = ui(16);
		tb_location.item_pad   = ui(4);
		tb_location.font       = f_p2;
		
		b_create = button(function() /*=>*/ {
			var _path = $"{DIRECTORY}Actions/Nodes/{name}.json";
			var _map  = {
				name,
				sprPath : $"./{name}.png",
				tooltip,
				tags: string_split(tags, ",", true),
				location : cat_value[cat_index],
				nodes,
				connections,
			};
			
			json_save_struct(_path, _map);
			
			if(spr) surface_save(spr, $"{DIRECTORY}Actions/Nodes/{name}.png");
			close();
			
			__initNodeActions();
		});
		
		b_create.text = __txtx("new_action_create", "Create");
		
		KEYBOARD_STRING = "";
	#endregion
	
	function onResize() { sc_node_content.resize(w - padding * 2 - ui(320) - ui(16), h - padding * 2 - ui(16)); }
	
	#region content
		sc_node_content = new scrollPane(w - padding * 2 - ui(320) - ui(16), h - padding * 2 - ui(16), function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
			var _w  = sc_node_content.surface_w;
			var _h  = ui(16);
			var yy  = _y;
			var _lh = line_get_height(f_p2);
			
			for (var i = 0, n = array_length(rawNodes); i < n; i++) {
				var _r = rawNodes[i];
				var _n = _r.node;
				var _name = _n.getFullName();
				var _nd   = nodes[i];
				
				var _hv = pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + _lh + ui(4));
				
				if(_hv) sc_node_content.hover_content = true;
				draw_sprite_stretched_ext(THEME.box_r5_clr, _hv, 0, yy, _w, _lh + ui(4), CDEF.main_grey);
				
				draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
				draw_text_add(ui(8), yy + ui(2), _name);
				
				if(mouse_press(mb_left, _hv)) 
					_r.expanded = !_r.expanded;
				
				yy += _lh + ui(4);
				_h += _lh + ui(4);
				
				if(_r.expanded) {
					var _val = _nd.setValues;
					
					for(var j = 0; j < array_length(_n.inputs); j++) {
						var _in   = _n.inputs[j];
						if(!value_type_direct_settable(_in.type)) continue;
						
						var _vali = _val[$ j];
						var _ttg  = false;
						
						var _bx = ui(8 + 12);
						var _by = yy + _lh / 2;
						var _tg = struct_has(_vali, "value"); _ttg |= _tg;
						var _hv = pHOVER && point_in_circle(_m[0], _m[1], _bx, _by, 6);
						if(_hv) {
							TOOLTIP = "Save value";
							sc_node_content.hover_content = true;
						}
						
						draw_sprite_ext(THEME.circle_toggle_8, _tg, _bx, _by, 1, 1, 0, _tg? c_white : COLORS._main_icon, .5 + .5 * (_hv || _tg));
						if(mouse_press(mb_left, _hv)) {
							if(_tg) struct_remove(_vali, "value");
							else    _vali[$ "value"] = _in.getValue();
						}
						_bx += ui(12);
						
						if(_in.expUse) {
							var _tg = struct_has(_vali, "expression"); _ttg |= _tg;
							var _hv = pHOVER && point_in_circle(_m[0], _m[1], _bx, _by, 6);
							if(_hv) {
								TOOLTIP = "Save expression";
								sc_node_content.hover_content = true;
							}
							
							draw_sprite_ext(THEME.circle_toggle_8, _tg, _bx, _by, 1, 1, 0, _tg? c_white : COLORS._main_icon, .5 + .5 * (_hv || _tg));
							if(mouse_press(mb_left, _hv)) {
								if(_tg) struct_remove(_vali, "expression");
								else    _vali[$ "expression"] = _in.expression;
							}
						}
						_bx += ui(12);
						
						if(_in.unit.reference != noone) {
							var _tg = struct_has(_vali, "unit"); _ttg |= _tg;
							var _hv = pHOVER && point_in_circle(_m[0], _m[1], _bx, _by, 6);
							if(_hv) {
								TOOLTIP = "Save unit";
								sc_node_content.hover_content = true;
							}
							
							draw_sprite_ext(THEME.circle_toggle_8, _tg, _bx, _by, 1, 1, 0, _tg? c_white : COLORS._main_icon, .5 + .5 * (_hv || _tg));
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
		})
	#endregion
	
	function setNodes(_nodes) { 
		rawNodes    = [];
		nodes       = [];
		connections = [];
		
		if(array_empty(_nodes)) {
			close();
			return;
		}
		
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
				_vals[$ j] = {};
				
				if(_in.value_from == noone || !struct_has(_nmap, _in.value_from.node.node_id)) {
					var _vl = _in.getValue(, false);
					if(!isEqual(_vl, _in.def_val))
						_vals[$ j].value = _vl;
					continue;
				}
				
				var _idF = _nmap[$ _in.value_from.node.node_id];
				
				array_push(connections, {
					from: _idF,
					fromIndex: _in.value_from.index,
					
					to: _idT,
					toIndex: j,
				});
			}
			
			nodes[i] = {
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
		
		// Nodes
		
		var ndx = _pd;
		var ndy = _pd;
		var ndw = w - _pd * 2 - ui(320);
		var ndh = h - _pd * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_node_content.setFocusHover(pFOCUS, pHOVER);
		sc_node_content.draw(ndx + ui(8), ndy + ui(8), mx - ndx - ui(8), my - ndy - ui(8));
		
		// Metadata
		
		var _tx = w - ui(320);
		var _nm = ui(128);
		var _wx = _tx + _nm;
		var _wy = ui(8);
		var _ww = ui(320) - _pd - _nm;
		var _wh = TEXTBOX_HEIGHT;
		var _th = _wy;
		
		tb_name.setFocusHover(pFOCUS, pHOVER);		tb_name.register();
		tb_tooltip.setFocusHover(pFOCUS, pHOVER);	tb_tooltip.register();
		tb_alias.setFocusHover(pFOCUS, pHOVER); 	tb_alias.register();
		tb_location.setFocusHover(pFOCUS, pHOVER);	tb_location.register();
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Name"));
		var _hh = tb_name.draw(_wx, _wy, _ww, _wh, name, [ mx, my ]);			_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Alias"));
		var _hh = tb_alias.draw(_wx, _wy, _ww, _wh, tags, [ mx, my ]);			_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Tooltip"));
		var _hh = tb_tooltip.draw(_wx, _wy, _ww, _wh * 2, tooltip, [ mx, my ]);	_wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Category"));
		var _hh = tb_location.draw(_wx, _wy, _ww, _wh, cat_index, [ mx, my ], x, y); _wy += _hh + ui(8); _th += _hh + ui(8);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text_add(_tx, _wy + _wh / 2, __txt("Icon"));
		
		var spx = _wx;
		var spy = _wy;
		var spw = ui(64);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, spx, spy, spw, spw);
		if(spr) draw_surface_fit(spr, spx + spw / 2, spy + spw / 2, spw, spw);
		
		// Buttons
		
		var bw = ui(96);
		var bh = ui(32);
		var bx = w - _pd - bw;
		var by = h - _pd - bh;
		
		b_create.setFocusHover(pFOCUS, pHOVER);
		b_create.draw(bx, by, bw, bh, [ mx, my ]);
	}
}
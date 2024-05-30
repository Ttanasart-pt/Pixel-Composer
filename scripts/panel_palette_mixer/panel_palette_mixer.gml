function Panel_Palette_Mixer() : PanelContent() constructor {
	title    = __txt("Palettes Mixer");
	padding  = ui(8);
	auto_pin = true;
	
	w = ui(320);
	h = ui(400);
	
	connect_surf       = surface_create(1, 1);
	connect_blend_surf = surface_create(1, 1);
	
	content_surf = surface_create(1, 1);
	
	var _def = load_palette_mixer();
	palette_data = _def != noone? _def : {
		nodes: [
			{ color : cola(c_black), x : -64, y : 0 },
			{ color : cola(c_white), x :  64, y : 0 },
		],
		connections: [
			[ 0, 1 ],
		],
		blends: [],
	};
	
	palette = [];
	
	static centerView = function() {
		var _mx = 0, _my = 0;
		for (var i = 0, n = array_length(palette_data.nodes); i < n; i++) {
			var _node = palette_data.nodes[i];
			_mx += _node.x;
			_my += _node.y;
		}
		
		mixer_x = n? -_mx / n : 0;
		mixer_y = n? -_my / n : 0;
	} centerView();
	
	mixer_s = 1;
	
	mixer_dragging = false;
	mixer_drag_mx  = 0;
	mixer_drag_my  = 0;
	mixer_drag_sx  = 0;
	mixer_drag_sy  = 0;
	
	node_size      = ui(PREFERENCES.panel_menu_palette_node_size);
	node_size_to   = node_size;
	node_hovering  = noone;
	node_dragging  = noone;
	node_drag_mx   = 0;
	node_drag_my   = 0; 
	node_drag_sx   = 0;
	node_drag_sy   = 0;
	node_selecting = noone;
	
	blnd_hovering  = noone;
	
	conn_hovering   = noone;
	connection_drag = noone;
	conn_menu_ctx   = noone;
	
	pal_draging = false;
	pal_drag_mx = 0;
	pal_drag_my = 0;
	
	shade_mode = 0;
	
	pr_palette = ds_priority_create();
	
	function setColor(clr) {
		if(node_selecting == noone) return;
		node_selecting.color = clr;
		CURRENT_COLOR = clr;
	} 
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var _palettes    = palette_data.nodes;
		var _connections = palette_data.connections;
		var _blends      = palette_data.blends;
		
		if(key_mod_press(SHIFT)) shade_mode = lerp_float(shade_mode, 1, 20);
		else					 shade_mode = lerp_float(shade_mode, 0, 10);
		
		if(!in_dialog) draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, 0, w, h);
		
		#region blend points
			for (var i = 0, n = array_length(_blends); i < n; i++) {
				var _b = _blends[i];
				
				var _fr = _palettes[_b.from];
				var _to = _palettes[_b.to];
				var _rt = _b.amount;
				
				_b.x = lerp(_fr.x, _to.x, _rt);
				_b.y = lerp(_fr.y, _to.y, _rt);
				_b.color = merge_color(_fr.color, _to.color, _rt);
			}
		#endregion
		
		#region palette
			var pal_s = ui(16);
			var pal_w = in_dialog? w - padding * 2 : w - ui(16 * 2);
			
			var col = floor(pal_w / pal_s);
			var row = ceil(array_length(_palettes) / col);
			
			var pal_h = pal_s * max(1, row);
			var pal_x = in_dialog? padding : ui(16);
			var pal_y = in_dialog? h - pal_h - padding : h - pal_h - ui(16);
			
			var pbg_x = pal_x - ui(8);
			var pbg_y = pal_y - ui(8);
			var pbg_w = pal_w + ui(16);
			var pbg_h = pal_h + ui(16);
			
			draw_sprite_stretched(THEME.button_def, 0, pbg_x, pbg_y, pbg_w, pbg_h);
			
			if(pHOVER && point_in_rectangle(mx, my, pbg_x, pbg_y, pbg_x + pbg_w, pbg_y + pbg_h)) {
				
				draw_sprite_stretched_ext(THEME.button_def, 3, pbg_x, pbg_y, pbg_w, pbg_h, c_white, 0.5);
			}
			
			ds_priority_clear(pr_palette);
			for (var i = 0, n = array_length(_palettes); i < n; i++) 
				ds_priority_add(pr_palette, _palettes[i].color, _palettes[i].y * 10000 + _palettes[i].x);
				
			for (var i = 0, n = array_length(_blends); i < n; i++) 
				ds_priority_add(pr_palette, _blends[i].color, _blends[i].y * 10000 + _blends[i].x);
				
			var _ind = 0;
			palette = [];
			while(!ds_priority_empty(pr_palette))
				palette[_ind++] = ds_priority_delete_min(pr_palette);
			
			var _ppw = pal_w - ui(24 + 8);
			var _ppx = pal_x + ui(24 + 8);
			
			var _pw = pal_s;
			var _ph = pal_s;
			var amo = array_length(palette);
			var col = floor(_ppw / _pw);
			var row = ceil(amo / col);
			var cx  = -1, cy = -1;
			var _pd = ui(5);
			var _h  = row * _ph;
			_pw = _ppw / col;
			
			for(var i = 0; i < array_length(palette); i++) {
				draw_set_color(palette[i]);
				var _x0 = _ppx  + safe_mod(i, col) * _pw;
				var _y0 = pal_y + floor(i / col) * _ph;
				
				draw_rectangle(_x0, _y0 + 1, _x0 + _pw, _y0 + _ph, false);
				
				if(node_selecting) {
					if(color_diff(node_selecting.color, palette[i]) < 0.01) {
						cx = _x0; cy = _y0;
					}
					
				} else if(color_diff(CURRENT_COLOR, palette[i]) < 0.01) {
					cx = _x0; cy = _y0;
				}
				
				if(pHOVER && point_in_rectangle(mx, my, _x0, _y0 + 1, _x0 + _pw, _y0 + _ph)) {
					if(mouse_press(mb_left)) {
						node_selecting = noone;
						CURRENT_COLOR  = palette[i];
						
						DRAGGING = {
							type: "Color",
							data: palette[i]
						}
						MESSAGE = DRAGGING;
					}
				}
			}
			
			if(cx) draw_sprite_stretched_ext(THEME.palette_selecting, 0, cx - _pd, cy + 1 - _pd, _pw + _pd * 2, _ph + _pd * 2);
			
			var _bx = pal_x;
			var _by = pal_y;
			var _bs = ui(24);
			
			var _b = buttonInstant(THEME.button_hide, _bx, _by, _bs, pal_h, [ mx, my ], pFOCUS, pHOVER, "", THEME.hamburger_s);
			if(_b == 2) {
				menuCall("",,, [
					menuItem("Save palette as...", function() {
						var _path = get_save_filename_pxc("Hex paleete|*.hex", "Palette");
						if(_path != "") {
							var _str = palette_string_hex(palette, false);
							file_text_write_all(_path, _str);
							
							var noti  = log_message("PALETTE", $"Export palette complete.", THEME.noti_icon_tick, COLORS._main_value_positive, false);
							noti.path = _path;
							noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
						}
					}), 
				]);
				
				pal_draging = true;
				pal_drag_mx = mx;
				pal_drag_my = my;
			}
			
			if(pal_draging) {
				if(point_distance(pal_drag_mx, pal_drag_my, mx, my) > 8) {
					DRAGGING = { type: "Palette", data: palette };
					MESSAGE = DRAGGING;
					pal_draging = false;
					
					instance_destroy(o_dialog_menubox);
				}
				
				if(mouse_release(mb_left))
					pal_draging = false;
			}
		#endregion
		
		var px = padding;
		var py = padding;
		var pw = w - padding - padding;
		var ph = h - padding - padding - pal_h - ui(16);
		
		if(in_dialog)
			draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16 - 4));
		else 
			ph -= ui(8);
		
		connect_surf = surface_verify(connect_surf, pw, ph);
		content_surf = surface_verify(content_surf, pw, ph);
		
		var _mx_x = pw / 2 + mixer_x;
		var _mx_y = ph / 2 + mixer_y;
		
		var _msx = (mx - px);
		var _msy = (my - py);
		
		var _mmx = mx - px - _mx_x;
		var _mmy = my - py - _mx_y;
		
		#region draw mixer
			surface_set_target(connect_surf)
				DRAW_CLEAR
				
				var _gs  = key_mod_press(SHIFT)? ui(12) : node_size;
				var _gs2 = _gs / 2;
				var _ind         = noone;
				var _hov         = node_hovering;
				var _con_hover   = conn_hovering;
				var _bln_hover   = blnd_hovering;
				var _con_rat     = 0;
				var _pHover      = pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph);
				
				node_hovering  = noone;
				conn_hovering  = noone;
				blnd_hovering  = noone;
				
				for (var i = 0, n = array_length(_connections); i < n; i++) {
					var conn = _connections[i];
					
					var _fr = _palettes[conn[0]];
					var _to = _palettes[conn[1]];
					
					var _frx = round(_mx_x + _fr.x);
					var _fry = round(_mx_y + _fr.y);
					var _tox = round(_mx_x + _to.x);
					var _toy = round(_mx_y + _to.y);
					
					var _hv = _hov == noone && _con_hover == i;
					if(shade_mode == 0) {
						draw_set_alpha(0.75);
						draw_line_width_color(_frx, _fry, _tox, _toy, (_hv? 8 : 4) + 2, c_white, c_white);
						draw_set_alpha(1);
					}
					
					draw_line_width_color(_frx, _fry, _tox, _toy, _hv? 8 : 4, _fr.color, _to.color);
					
					if(_pHover && _bln_hover == noone && shade_mode == 0 && distance_to_line(_msx, _msy, _frx, _fry, _tox, _toy) < 6) {
						conn_hovering = i;
						
						var _d0 = point_distance(_frx, _fry, _msx, _msy);
						var _d1 = point_distance(_tox, _toy, _msx, _msy);
						_con_rat = _d0 / (_d0 + _d1);
					}
				}
				
				var _bs = key_mod_press(SHIFT)? ui(12) : node_size * 0.75;
				for (var i = 0, n = array_length(_blends); i < n; i++) {
					var _blend = _blends[i];
					
					var _c  = _blend.color;
					var _px = round(_mx_x + _blend.x);
					var _py = round(_mx_y + _blend.y);
					var _hv = _pHover && point_in_rectangle(_msx, _msy, _px - _bs / 2, _py - _bs / 2, _px + _bs / 2, _py + _bs / 2);
					
					draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _px - _bs / 2, _py - _bs / 2, _bs, _bs, _c, 1);
					
					if(shade_mode > 0)
						continue;
					
					BLEND_ADD
					draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _px - _bs / 2, _py - _bs / 2, _bs, _bs, c_white, 0.25 + 0.5 * (_bln_hover == i));
					BLEND_NORMAL
					
					if(_hv) blnd_hovering = i;
				}
				
				if(connection_drag >= 0) {
					var _fr = _palettes[connection_drag];
					
					var _frx = round(_mx_x + _fr.x);
					var _fry = round(_mx_y + _fr.y);
					
					if(_hov) {
						var _tox = round(_mx_x + _hov.x);
						var _toy = round(_mx_y + _hov.y);
						draw_line_width_color(_frx, _fry, _tox, _toy, 8, _fr.color, _hov.color);
						
					} else
						draw_line_width_color(_frx, _fry, _msx, _msy, 8, _fr.color, _fr.color);
				}
			surface_reset_target();
			
			surface_set_target(content_surf)
				DRAW_CLEAR
				
				for (var i = 0, n = array_length(_palettes); i < n; i++) {
					var pal = _palettes[i];
					
					var _c  = pal.color;
					var _px = round(_mx_x + pal.x);
					var _py = round(_mx_y + pal.y);
					var _hv = _pHover && point_in_rectangle(_msx, _msy, _px - _gs2, _py - _gs2, _px + _gs2, _py + _gs2);
					
					if(shade_mode == 0)
						draw_sprite_stretched(THEME.button_def, _hov == pal, _px - _gs2, _py - _gs2, _gs, _gs);
					draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _px - _gs2 + 2, _py - _gs2 + 2, _gs - 4, _gs - 4, _c, 1);
					
					BLEND_ADD
					draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _px - _gs2 + 2, _py - _gs2 + 2, _gs - 4, _gs - 4, c_white, 0.25);
					BLEND_NORMAL
					
					if(shade_mode > 0) continue;
					
					if(pal == node_selecting)
						draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _px - _gs2, _py - _gs2, _gs, _gs, COLORS._main_accent, 1);
					
					if(_hv) {
						node_hovering = pal;
						_ind = i;
					}
				}
				
				if(node_hovering) {
					if(mouse_press(mb_left)) {
						node_selecting = node_hovering;
						node_dragging = node_hovering;
						node_drag_mx  = mx;
						node_drag_my  = my;
						node_drag_sx  = node_hovering.x;
						node_drag_sy  = node_hovering.y;
						
						CURRENT_COLOR = node_hovering.color;
					}
					
					if(DOUBLE_CLICK) {
						node_selecting = node_hovering;
						
						var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
						dialog.selector.onApply = setColor;
						dialog.onApply = setColor;
						dialog.setDefault(node_selecting.color);
						
						save_palette_mixer(palette_data);
					}
					
					if(mouse_press(mb_right))
						connection_drag = _ind;
				
				} else if(blnd_hovering != noone) {
					
					if(mouse_click(mb_left)) {
						node_selecting = noone;
						CURRENT_COLOR = palette_data.blends[blnd_hovering].color;
					}
					
					if(mouse_press(mb_right)) {
						conn_menu_ctx = [ blnd_hovering ];
						
						menuCall(,,, [
							menuItem("Delete Blend point", function() { array_delete(palette_data.blends, conn_menu_ctx[0], 1); } ),
						]);
					}
				
				} else if(conn_hovering != noone) {
					var conn = palette_data.connections[conn_hovering];
					var _fr  = _palettes[conn[0]];
					var _to  = _palettes[conn[1]];
					
					var _cc = merge_color(_fr.color, _to.color, _con_rat);
					var _xx = lerp(_fr.x, _to.x, _con_rat);
					var _yy = lerp(_fr.y, _to.y, _con_rat);
					var _gs = ui(16);
					
					_xx = round(_mx_x + _xx);
					_yy = round(_mx_y + _yy);
					
					draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _xx - _gs / 2, _yy - _gs / 2, _gs, _gs, _cc, 1);
					
					BLEND_ADD
					draw_sprite_stretched_ext(THEME.button_def,       3, _xx - _gs / 2, _yy - _gs / 2, _gs, _gs, c_white, 0.25);
					BLEND_NORMAL
					
					if(DOUBLE_CLICK) {
						var _node = { 
							color : _cc, 
							x : _xx - _mx_x,
							y : _yy - _mx_y,
						};
						
						var _idx = array_length(palette_data.nodes);
						array_push(palette_data.nodes, _node);
						
						array_delete(palette_data.connections, conn_hovering, 1);
						array_push(  palette_data.connections, [ conn[0], _idx ]);
						array_push(  palette_data.connections, [ _idx, conn[1] ]);
						
						node_selecting = _node;
						
						save_palette_mixer(palette_data);
					}
					
					if(mouse_click(mb_left)) {
						node_selecting = noone;
						CURRENT_COLOR = _cc;
					}
					
					if(mouse_press(mb_right)) {
						conn_menu_ctx = [ conn[0], conn[1], _con_rat ];
						
						menuCall(,,, [
							menuItem("New Blend point", function() { array_push(palette_data.blends, { from : conn_menu_ctx[0], to : conn_menu_ctx[1], amount : conn_menu_ctx[2] }) } ),
						]);
					}
					
				} else if(_pHover) {
					
					if(mouse_press(mb_left)) 
						node_selecting = noone;
						
					if(DOUBLE_CLICK) {
						var _node = { color : cola(c_black), x : value_snap(_mmx, 8), y : value_snap(_mmy, 8) };
						array_push(palette_data.nodes, _node);
						node_selecting = _node;
						
						var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
						dialog.selector.onApply = setColor;
						dialog.onApply = setColor;
						dialog.setDefault(node_selecting.color);
						
						save_palette_mixer(palette_data);
					}
					
					if(mouse_press(mb_right)) {
						menuCall(,,, [
							menuItem("Center view", function() { centerView(); } ),
							-1,
							menuItem("Save mixed...", function() { 
								var _path = get_save_filename_pxc("JSON|*.json", "New mixed");
								if(_path != "") save_palette_mixer(palette_data, _path);
							}, THEME.save),
							menuItem("Load mixed...", function() { 
								var _path = get_open_filename_pxc("JSON|*.json", "");
								if(_path != "") palette_data = load_palette_mixer(_path);
							}, THEME.noti_icon_file_load),
							-1,
							menuItem("Clear palette", function() { palette_data = { nodes: [], connections: [], blends: [], } }, THEME.cross),
						]);
					}
				}
				
				if(connection_drag >= 0) {
					if(mouse_release(mb_right)) {
						if(_ind == noone) {
							var _pal  = _palettes[connection_drag];
							var _node = { color : _pal.color, x : value_snap(_mmx, 8), y : value_snap(_mmy, 8) };
							array_push(palette_data.nodes, _node);
							
							var _conn  = [ connection_drag, array_length(palette_data.nodes) - 1 ];
							array_push(palette_data.connections, _conn);
							
						} else {
							var _exist = noone;
							var _conn  = [ connection_drag, _ind ];
							
							for (var i = 0, n = array_length(_connections); i < n; i++) {
								var conn = _connections[i];
								if(array_equals(_conn, conn) || array_equals(_conn, [ conn[1], conn[0] ]))
									_exist = i;
							}
							
							if(_exist == noone) array_push(palette_data.connections, _conn);
							else				array_delete(palette_data.connections, _exist, 1);
							
							save_palette_mixer(palette_data);
						}
						
						connection_drag = noone;
					}
				}
				
				if(node_dragging) {
					node_dragging.x = value_snap(node_drag_sx + (mx - node_drag_mx), 8);
					node_dragging.y = value_snap(node_drag_sy + (my - node_drag_my), 8);
					
					if(mouse_release(mb_left)) {
						node_dragging = false;
						save_palette_mixer(palette_data);
					}
				}
				
				if(node_selecting) {
					node_selecting.color = CURRENT_COLOR;
					
					if(keyboard_check_pressed(vk_delete)) { /////////////////// Node Delete 
					
						var _delId = array_find(_palettes, node_selecting);
						
						array_delete(_palettes, _delId, 1);
						
						for (var i = array_length(_connections) - 1; i >= 0; i--) {
							var conn = _connections[i];
							
							if(conn[0] == _delId || conn[1] == _delId)
								array_delete(palette_data.connections, i, 1);
							else {
								if(conn[0] > _delId) palette_data.connections[i][0]--;
								if(conn[1] > _delId) palette_data.connections[i][1]--;
							}
						}
						
						for (var i = array_length(_blends) - 1; i >= 0; i--) {
							var _blend = _blends[i];
							
							if(_blend.from == _delId || _blend.to == _delId)
								array_delete(palette_data.connections, i, 1);
							else {
								if(_blend.from > _delId) _blend.from--;
								if(_blend.to   > _delId) _blend.to--;
							}
						}
						
						save_palette_mixer(palette_data);
					}
				}
				
				if(_pHover && DRAGGING) {
					var _rx = value_snap(_mmx, 8);
					var _ry = value_snap(_mmy, 8);
					
					_xx = _rx;
					_yy = _ry;
					
					if(DRAGGING.type == "Color") {
						draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _mx_x + _xx - _gs / 2, _mx_y + _yy - _gs / 2, _gs, _gs, DRAGGING.data, 0.75);
						
						if(mouse_release(mb_left)) {
							var _node = { color : DRAGGING.data, x : _rx, y : _ry };
							array_push(palette_data.nodes, _node);
								
							DRAGGING = noone;
							
							save_palette_mixer(palette_data);
						}
					} else if(DRAGGING.type == "Palette") {
						var _pal = DRAGGING.data;
						var _amo = array_length(_pal);
						var _pxs = array_create(_amo);
						var _pys = array_create(_amo);
						var _px = _xx;
						var _py = _yy;
						var _colRow, _colPrev, _colCurr;
						var _ligInc = 0;
						
						for (var i = 0; i < _amo; i++) {
							_colCurr = _pal[i];
							
							if(i == 0) {
								_colRow  = _colCurr;
							} else {
								var _lPrev = _color_get_light(_colPrev);
								var _lCurr = _color_get_light(_colCurr);
								var _sg  = sign(_lCurr - _lPrev);
								
								if(_ligInc == 0) _ligInc = _sg;
								else if(_ligInc != _sg) {
									_ligInc = 0;
									_px  = _xx;
									_py += _gs * 2;
								}
							}
							
							_pxs[i] = _px;
							_pys[i] = _py;
							
							draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _mx_x + _px - _gs / 2, _mx_y + _py - _gs / 2, _gs, _gs, _colCurr, 0.75);
							_px += _gs * 2;
							
							_colPrev = _colCurr;
						}
						
						if(mouse_release(mb_left)) {
							for (var i = 0; i < _amo; i++) {
								var _node = { color : _pal[i], x : _pxs[i], y : _pys[i] };
								array_push(palette_data.nodes, _node);
							}
								
							DRAGGING = noone;
							
							save_palette_mixer(palette_data);
						}
					}
				}
				
			surface_reset_target();
		#endregion
		
		#region draw surfaces
			if(shade_mode > 0) {
				
				var _shade_pal = array_create(array_length(palette) * 4);
				var _shade_pos = array_create(array_length(palette) * 2);
				var _ind = 0;
				
				for (var i = 0, n = array_length(_palettes); i < n; i++) {
					var _x = _palettes[i].x;
					var _y = _palettes[i].y;
					var _c = _palettes[i].color;
					
					_shade_pal[_ind * 4 + 0] = _color_get_red(_c);
					_shade_pal[_ind * 4 + 1] = _color_get_green(_c);
					_shade_pal[_ind * 4 + 2] = _color_get_blue(_c);
					_shade_pal[_ind * 4 + 3] = _color_get_alpha(_c);
					
					_shade_pos[_ind * 2 + 0] = _mx_x + _x;
					_shade_pos[_ind * 2 + 1] = _mx_y + _y;
					
					_ind++;
				}
					
				for (var i = 0, n = array_length(_blends); i < n; i++) {
					var _x = _blends[i].x;
					var _y = _blends[i].y;
					var _c = _blends[i].color;
					
					_shade_pal[_ind * 4 + 0] = _color_get_red(_c);
					_shade_pal[_ind * 4 + 1] = _color_get_green(_c);
					_shade_pal[_ind * 4 + 2] = _color_get_blue(_c);
					_shade_pal[_ind * 4 + 3] = _color_get_alpha(_c);
					
					_shade_pos[_ind * 2 + 0] = _mx_x + _x;
					_shade_pos[_ind * 2 + 1] = _mx_y + _y;
					
					_ind++;
				}
				
				connect_blend_surf = surface_verify(connect_blend_surf, pw, ph);
				
				surface_set_shader(connect_blend_surf, sh_palette_mixer_atlas_expand_palette);
					shader_set_f("dimension", pw, ph);
					shader_set_i("paletteSize", array_length(palette));
					
					shader_set_f("palette",   _shade_pal);
					shader_set_f("positions", _shade_pos);
					shader_set_f("influence", node_size / ui(4));
					shader_set_f("progress",  shade_mode);
					
					draw_surface(connect_surf, 0, 0);
				surface_reset_shader();
				
				draw_surface(connect_blend_surf, px, py);
				
			} else {
				shader_set(sh_FXAA);
				gpu_set_tex_filter(true);
					shader_set_f("dimension", pw, ph);
					shader_set_f("cornerDis", 0.5);
					shader_set_f("mixAmo",    1);
					
					draw_surface(connect_surf, px, py);
				gpu_set_tex_filter(false);
				shader_reset();
			}
			
			draw_surface(content_surf, px, py);
		#endregion
		
		if(_pHover && mouse_press(mb_middle)) {
			mixer_dragging = true;
			mixer_drag_mx  = mx;
			mixer_drag_my  = my;
			mixer_drag_sx  = mixer_x;
			mixer_drag_sy  = mixer_y;
		}
		
		if(mixer_dragging) {
			mixer_x = round(mixer_drag_sx + (mx - mixer_drag_mx));
			mixer_y = round(mixer_drag_sy + (my - mixer_drag_my));
			
			if(mouse_release(mb_middle))
				mixer_dragging = false;
		}
		
		draw_set_text(f_p2, fa_right, fa_bottom, COLORS._main_text_sub);
		var _gs  = ui(16);
		var _nhx = px + pw - _gs;
		var _nhy = py + ph + ui(4);
		var _cc  = noone;
		var _txt = "";
		
		if(shade_mode > 0) {
			_cc = surface_getpixel(connect_blend_surf, mx - px, my - py);
			_txt = $"Sampled #{color_get_hex(_cc)}";
			
		} else if(node_hovering) {
			_cc  = node_hovering.color;
			_txt = $"Node #{color_get_hex(_cc)}";
			
		} else if(blnd_hovering >= 0) {
			_cc  = palette_data.blends[blnd_hovering].color;
			_txt = $"Blend point #{color_get_hex(_cc)}";
			
		} else if(conn_hovering >= 0) {
			var conn = palette_data.connections[conn_hovering];
			var _fr  = _palettes[conn[0]];
			var _to  = _palettes[conn[1]];
			_cc  = merge_color(_fr.color, _to.color, _con_rat);
			_txt = $"Connection #{color_get_hex(_fr.color)} -  #{color_get_hex(_to.color)} [{round(_con_rat * 100)}%]";
			
		}
		
		if(_cc != noone) {
			draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _nhx, _nhy - _gs, _gs, _gs, _cc, 1);
			BLEND_ADD
			draw_sprite_stretched_ext(THEME.button_def,       3, _nhx, _nhy - _gs, _gs, _gs, c_white, 0.25);
			BLEND_NORMAL
			
			draw_text(_nhx - ui(4), _nhy, _txt);
		}
		
		if(pHOVER && key_mod_press(CTRL)) {
			if(mouse_wheel_down()) node_size_to = clamp(node_size_to - ui(4), ui(12), ui(64));
			if(mouse_wheel_up())   node_size_to = clamp(node_size_to + ui(4), ui(12), ui(64));
		}
		node_size = lerp_float(node_size, node_size_to, 3);
		
	}
}

function save_palette_mixer(data, path = "") {
	var _dirr = $"{DIRECTORY}/Palettes/Mixer";
	directory_verify(_dirr);
	
	var _path = path == ""? _dirr + "/current.json" : path;
	
	json_save_struct(_path, data);
}

function load_palette_mixer(path = "") {
	var _dirr = $"{DIRECTORY}/Palettes/Mixer";
	directory_verify(_dirr);
	
	var _path = path == ""? _dirr + "/current.json" : path;
	if(!file_exists(_path)) return noone;
	
	var _str = json_load_struct(_path);
	if(!struct_has(_str, "blends")) _str.blends = [];
	
	return _str;
}
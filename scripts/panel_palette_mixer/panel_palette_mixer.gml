function Panel_Palette_Mixer() : PanelContent() constructor {
	title    = __txt("Palettes Mixer");
	padding  = ui(8);
	auto_pin = true;
	
	w = ui(320);
	h = ui(400);
	
	content  = surface_create(1, 1);
	var _def = load_palette_mixer();
	palette_data = _def != noone? _def : {
		nodes: [
			{ color : cola(c_black), x : -64, y : 0 },
			{ color : cola(c_white), x :  64, y : 0 },
		],
		connections: [
			[ 0, 1 ],
		],
	};
	
	palette = [];
	
	var _mx = 0, _my = 0;
	for (var i = 0, n = array_length(palette_data.nodes); i < n; i++) {
		var _node = palette_data.nodes[i];
		_mx += _node.x;
		_my += _node.y;
	}
	
	mixer_x = n? -_mx / n : 0;
	mixer_y = n? -_my / n : 0;
	mixer_s = 1;
	
	mixer_dragging = false;
	mixer_drag_mx  = 0;
	mixer_drag_my  = 0;
	mixer_drag_sx  = 0;
	mixer_drag_sy  = 0;
	
	node_size      = ui(PREFERENCES.panel_menu_palette_node_size);
	node_hovering  = noone;
	node_dragging  = noone;
	node_drag_mx   = 0;
	node_drag_my   = 0;
	node_drag_sx   = 0;
	node_drag_sy   = 0;
	node_selecting = noone;
	
	conn_hovering   = noone;
	connection_drag = noone;
	
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
				
		#region palette
			var pal_s = ui(16);
			var pal_w = w - padding - padding;
			
			var col = floor(pal_w / pal_s);
			var row = ceil(array_length(_palettes) / col);
			
			var pal_h = pal_s * row;
			var pal_x = padding;
			var pal_y = h - padding - pal_h;
			
			draw_sprite_stretched(THEME.button_def, 0, pal_x - ui(8), pal_y - ui(8), pal_w + ui(16), pal_h + ui(16));
			
			ds_priority_clear(pr_palette);
			for (var i = 0, n = array_length(_palettes); i < n; i++) 
				ds_priority_add(pr_palette, _palettes[i], _palettes[i].y * 10000 + _palettes[i].x);
				
			palette = [];
			for (var i = 0, n = array_length(_palettes); i < n; i++) {
				var pal = ds_priority_delete_min(pr_palette);
				palette[i] = pal.color;
			}
			
			var _pw = pal_s;
			var _ph = pal_s;
			var amo = array_length(palette);
			var col = floor(pal_w / _pw);
			var row = ceil(amo / col);
			var cx  = -1, cy = -1;
			var _pd = ui(5);
			var _h  = row * _ph;
			_pw = pal_w / col;
			
			for(var i = 0; i < array_length(palette); i++) {
				draw_set_color(palette[i]);
				var _x0 = pal_x + safe_mod(i, col) * _pw;
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
		#endregion
		
		var px = padding;
		var py = padding;
		var pw = w - padding - padding;
		var ph = h - padding - padding - pal_h - ui(16);
		if(in_dialog) ph -= ui(4);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		content = surface_verify(content, pw, ph);
		
		var _mx_x = pw / 2 + mixer_x;
		var _mx_y = ph / 2 + mixer_y;
		
		var _msx = (mx - px);
		var _msy = (my - py);
		
		var _mmx = mx - px - _mx_x;
		var _mmy = my - py - _mx_y;
		
		#region draw mixer
			surface_set_target(content)
				DRAW_CLEAR
				
				var _gs  = node_size;
				var _gs2 = _gs / 2;
				var _ind         = noone;
				var _hov         = node_hovering;
				var _con_hover   = conn_hovering;
				var _con_rat     = 0;
				var _pHover      = pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph);
				
				node_hovering  = noone;
				conn_hovering  = noone;
				
				for (var i = 0, n = array_length(_connections); i < n; i++) {
					var conn = _connections[i];
					
					var _fr = _palettes[conn[0]];
					var _to = _palettes[conn[1]];
					
					var _frx = round(_mx_x + _fr.x);
					var _fry = round(_mx_y + _fr.y);
					var _tox = round(_mx_x + _to.x);
					var _toy = round(_mx_y + _to.y);
					
					var _hv = _hov == noone && _con_hover == i;
					draw_line_width_color(_frx, _fry, _tox, _toy, _hv? 8 : 4, _fr.color, _to.color);
					
					if(distance_to_line(_msx, _msy, _frx, _fry, _tox, _toy) < 6) {
						conn_hovering = i;
						
						var _d0 = point_distance(_frx, _fry, _msx, _msy);
						var _d1 = point_distance(_tox, _toy, _msx, _msy);
						_con_rat = _d0 / (_d0 + _d1);
					}
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
				
				for (var i = 0, n = array_length(_palettes); i < n; i++) {
					var pal = _palettes[i];
					
					var _c  = pal.color;
					var _px = round(_mx_x + pal.x);
					var _py = round(_mx_y + pal.y);
					var _hv = _pHover && point_in_rectangle(_msx, _msy, _px - _gs2, _py - _gs2, _px + _gs2, _py + _gs2);
					
					draw_sprite_stretched(THEME.button_def, _hov == pal, _px - _gs2, _py - _gs2, _gs, _gs);
					draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _px - _gs2 + 2, _py - _gs2 + 2, _gs - 4, _gs - 4, _c, 1);
					
					BLEND_ADD
					draw_sprite_stretched_ext(THEME.button_def,       3, _px - _gs2 + 2, _py - _gs2 + 2, _gs - 4, _gs - 4, c_white, 0.25);
					BLEND_NORMAL
					
					if(pal == node_selecting)
						draw_sprite_stretched_ext(THEME.button_def, 3, _px - _gs2, _py - _gs2, _gs, _gs, COLORS._main_accent, 1);
					
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
				
				} else if(conn_hovering != noone) {
					
					if(DOUBLE_CLICK) {
						var conn = palette_data.connections[conn_hovering];
						var _fr  = _palettes[conn[0]];
						var _to  = _palettes[conn[1]];
						
						var _cc  = merge_color(_fr.color, _to.color, _con_rat);
						var _node = { 
							color : _cc, 
							x : lerp(_fr.x, _to.x, _con_rat), 
							y : lerp(_fr.y, _to.y, _con_rat) 
						};
						
						var _idx = array_length(palette_data.nodes);
						array_push(palette_data.nodes, _node);
						
						array_delete(palette_data.connections, conn_hovering, 1);
						array_push(  palette_data.connections, [ conn[0], _idx ]);
						array_push(  palette_data.connections, [ _idx, conn[1] ]);
						
						node_selecting = _node;
						
						save_palette_mixer(palette_data);
					}
					
				} else {
					if(_pHover && mouse_press(mb_left)) 
						node_selecting = noone;
						
					if(_pHover && DOUBLE_CLICK) {
						var _node = { color : cola(c_black), x : value_snap(_mmx, 8), y : value_snap(_mmy, 8) };
						array_push(palette_data.nodes, _node);
						node_selecting = _node;
						
						var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
						dialog.selector.onApply = setColor;
						dialog.onApply = setColor;
						dialog.setDefault(node_selecting.color);
						
						save_palette_mixer(palette_data);
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
					
					if(keyboard_check_pressed(vk_delete)) {
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
						
						save_palette_mixer(palette_data);
					}
				}
				
				if(_pHover && DRAGGING && DRAGGING.type == "Color") {
					if(mouse_release(mb_left)) {
						var _node = { color : DRAGGING.data, x : value_snap(_mmx, 8), y : value_snap(_mmy, 8) };
						array_push(palette_data.nodes, _node);
							
						DRAGGING = noone;
						
						save_palette_mixer(palette_data);
					}
				}
			surface_reset_target();
		#endregion
		
		draw_surface(content, px, py);
		
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
		if(node_hovering)
			draw_text(px + pw, py + ph + ui(4), $"Node #{color_get_hex(node_hovering.color)}");
			
		else if(conn_hovering >= 0) {
			var conn = palette_data.connections[conn_hovering];
			var _fr  = _palettes[conn[0]];
			var _to  = _palettes[conn[1]];
			
			draw_text(px + pw, py + ph + ui(4), $"Connection #{color_get_hex(_fr.color)} -  #{color_get_hex(_to.color)} [{round(_con_rat * 100)}%]");
		}
	}
}

function save_palette_mixer(data) {
	var _dirr = $"{DIRECTORY}/Palettes/Mixer";
	directory_verify(_dirr);
	
	var _path = _dirr + "/current.json";
	
	json_save_struct(_path, data);
}

function load_palette_mixer() {
	var _dirr = $"{DIRECTORY}/Palettes/Mixer";
	directory_verify(_dirr);
	
	var _path = _dirr + "/current.json";
	if(!file_exists(_path)) return noone;
	
	return json_load_struct(_path);
}
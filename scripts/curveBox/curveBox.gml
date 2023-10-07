function curveBox(_onModify) : widget() constructor {
	onModify = _onModify;
	
	curve_surface = surface_create(1, 1);
	node_dragging = -1;
	node_drag_typ = -1;
	zoom_level    = 1;
	zoom_level_to = 1;
	zoom_min = 1;
	zoom_max = 3;
	zooming = false;
	
	miny = 0;
	maxy = 1;
	
	progress_draw = -1;
	
	display_pos_x = 0;
	display_pos_y = 0;
	display_sel = false;
	
	grid_snap = false;
	grid_step = 0.05;
	grid_show = false;
	
	static get_x = function(val, _x, _w) { return _x + _w * val; }
	static get_y = function(val, _y, _h) { return _y + _h * (1 - (val - miny) / (maxy - miny)); }
	
	static register = function() {}
	
	static drawParam = function(params) {
		rx = params.rx;
		ry = params.ry;
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x; 
		y = _y;
		w = _w; 
		h = _h;
		
		var cw = _w - ui(32);
		
		if(!is_array(_data) || array_length(_data) == 0) return 0;
		if(is_array(_data[0])) return 0;
		
		var points    = array_length(_data) / 6;
		
		#region display
			zoom_level = lerp_float(zoom_level, zoom_level_to, 2);
			miny = 0.5 - 0.5 * zoom_level;
			maxy = 0.5 + 0.5 * zoom_level;
			
			display_pos_x = clamp((_m[0] - _x) / cw, 0, 1);
			display_pos_y = lerp(miny, maxy, 1 - (_m[1] - _y) / _h);
			display_sel   = false;
		#endregion
		
		curve_surface = surface_verify(curve_surface, cw, _h);
		
		if(node_dragging != -1) { #region editing
			if(node_drag_typ == 0) { 
				var node_point = (node_dragging - 2) / 6;
				if(node_point > 0 && node_point < points - 1) {
					var _mx = (_m[0] - _x) / cw;
						_mx = clamp(_mx, 0, 1);
					if(key_mod_press(CTRL) || grid_snap)
						_mx = value_snap(_mx, grid_step);
					
					var bfx = _data[node_dragging - 6];
					var afx = _data[node_dragging + 6];
					
					if(_mx == bfx)		node_dragging -= 6;
					else if(_mx == afx) node_dragging += 6;
					else				_data[node_dragging + 0] = _mx;
				}
				
				var _my = 1 - (_m[1] - _y) / _h;
					_my = clamp(_my * (maxy - miny) + miny, 0, 1);
				if(key_mod_press(CTRL) || grid_snap) _my = value_snap(_my, grid_step);
				_data[node_dragging + 1] = _my;
				
				display_pos_x = _data[node_dragging + 0];
				display_pos_y = _data[node_dragging + 1];
				display_sel   = 1;
				
				//sort by x
				var _xindex = [];
				var _pindex = [];
				for( var i = 0; i < points; i++ ) {
					var ind = i * 6;
					var _x0 = _data[ind + 2];
					array_push(_xindex, _x0);
					array_push(_pindex, _x0);
				}
				array_sort(_xindex, true);
				
				if(node_point > 0 && node_point < points - 1) {
					var sorted = [];
					for( var i = 0; i < points; i++ ) {
						var prog = _xindex[i];
						var ind  = array_find(_pindex, prog);
				
						array_push(sorted, _data[ind * 6 + 0]);
						array_push(sorted, _data[ind * 6 + 1]);
						array_push(sorted, _data[ind * 6 + 2]);
						array_push(sorted, _data[ind * 6 + 3]);
						array_push(sorted, _data[ind * 6 + 4]);
						array_push(sorted, _data[ind * 6 + 5]);
					}
					
					if(onModify(sorted))
						UNDO_HOLDING = true;
				} else if(onModify(_data))
					UNDO_HOLDING = true;
			} else { 
				var _px = _data[node_dragging + 0];
				var _py = _data[node_dragging + 1];
				
				var _mx = (_m[0] - _x) / cw;
					_mx = clamp(_mx, 0, 1);
				if(key_mod_press(CTRL) || grid_snap) _mx = value_snap(_mx, grid_step);
				_data[node_dragging - 2] = (_px - _mx) * node_drag_typ;
				_data[node_dragging + 2] = (_mx - _px) * node_drag_typ;
				
				var _my = 1 - (_m[1] - _y) / _h;
					_my = lerp(miny, maxy, _my);
				if(key_mod_press(CTRL) || grid_snap) _my = value_snap(_my, grid_step);
				_data[node_dragging - 1] = clamp(_py - _my, -1, 1) * node_drag_typ;
				_data[node_dragging + 3] = clamp(_my - _py, -1, 1) * node_drag_typ;
				
				display_pos_x = node_drag_typ? _data[node_dragging - 2] : _data[node_dragging + 2];
				display_pos_y = node_drag_typ? _data[node_dragging - 1] : _data[node_dragging + 3];
				display_sel   = 2;
				
				if(onModify(_data))
					UNDO_HOLDING = true;
			} 
			
			if(mouse_release(mb_left)) {
				node_dragging = -1;
				node_drag_typ = -1;
				
				UNDO_HOLDING = false;
			}
		} #endregion
		
		var node_hovering  = -1;
		var node_hover_typ = -1;
		var point_insert   = 1;
		var _x1 = 0;
		
		var msx = _m[0] - _x;
		var msy = _m[1] - _y;
		
		#region ==== draw ====
			surface_set_target(curve_surface);
			DRAW_CLEAR
				draw_set_color(COLORS.widget_curve_line);
				draw_set_alpha(0.75);
				
				if(grid_show) {
					var st = max(grid_step, 0.02);
					
					for( var i = st; i < 1; i += st ) {
						var y0 = _h - _h * (i - miny) / (maxy - miny);
						draw_line(0, y0, cw, y0);
						
						var x0 = cw * i;
						draw_line(x0, 0, x0, _h);
					}
				}
				
				draw_set_alpha(0.9);
				var y0 = _h - _h * (0 - miny) / (maxy - miny);
				draw_line(0, y0, cw, y0);
				var y1 = _h - _h * (1 - miny) / (maxy - miny);
				draw_line(0, y1, cw, y1);
				draw_set_alpha(1);
				
				if(progress_draw > -1) {
					var _prg = clamp(progress_draw, 0, 1);
					
					var _px = cw * _prg;
					draw_set_color(COLORS.widget_curve_line);
					draw_line(_px, 0, _px, _h);
				}
				
				for( var i = 0; i < points; i++ ) {
					var ind = i * 6;
					var _x0 = _data[ind + 2];
					var _y0 = _data[ind + 3];
					var bx0 = _x0 + _data[ind + 0];
					var by0 = _y0 + _data[ind + 1];
					var ax0 = _x0 + _data[ind + 4];
					var ay0 = _y0 + _data[ind + 5];
			
					bx0 = get_x(bx0, 0, cw);
					by0 = get_y(by0, 0, _h);
					_x0 = get_x(_x0, 0, cw);
					_y0 = get_y(_y0, 0, _h);
					ax0 = get_x(ax0, 0, cw);
					ay0 = get_y(ay0, 0, _h);
				
					draw_set_color(COLORS.widget_curve_line);
					if(i > 0) { //draw pre line
						draw_line(bx0, by0, _x0, _y0);
				
						draw_circle_prec(bx0, by0, 3, false);
						if(hover && point_in_circle(msx, msy, bx0, by0, 10)) {
							draw_circle_prec(bx0, by0, 5, false);
							node_hovering = ind + 2;
							node_hover_typ = -1;
							
							display_pos_x = _data[ind + 0];
							display_pos_y = _data[ind + 1];
							display_sel   = 2;
						}
					}
			
					if(i < points - 1) { //draw post line
						draw_line(ax0, ay0, _x0, _y0);
				
						draw_circle_prec(ax0, ay0, 3, false);
						if(hover && point_in_circle(msx, msy, ax0, ay0, 10)) {
							draw_circle_prec(ax0, ay0, 5, false);
							node_hovering = ind + 2;
							node_hover_typ = 1;
							
							display_pos_x = _data[ind + 4];
							display_pos_y = _data[ind + 5];
							display_sel   = 2;
						}
					}
			
					draw_set_color(COLORS._main_accent);
					draw_circle_prec(_x0, _y0, 3, false);
					if(hover && point_in_circle(msx, msy, _x0, _y0, 10)) {
						draw_circle_prec(_x0, _y0, 5, false);
						node_hovering = ind + 2;
						node_hover_typ = 0;
							
						display_pos_x = _data[ind + 2];
						display_pos_y = _data[ind + 3];
						display_sel   = 1;
					}
			
					if(msx >= _x1 && msy <= _x0)
						point_insert = i;
					_x1 = _x0;
				}
		
				draw_set_color(COLORS._main_accent);
				draw_curve(0, 0, cw, -_h, _data, miny, maxy);
		
			surface_reset_target();
		#endregion
		
		#region ==== buttons ====
			var bs  = ui(20);
			
			var bxF = _x + cw + ui(8);
			var bx  = bxF + ui(0);
			
			var by0 = _y;
			var by1 = _y + _h - bs + ui(2);
			
			var byF = _y + (bs + ui(6));
			var byH = _h + ui(2) - (bs + ui(6)) * 2;
			
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, bxF, byF, bs, byH, COLORS.assetbox_current_bg, 1);
			
			var zH = ui(16);
			var zy = byF + zH / 2 + (byH - zH) * (zoom_level_to - zoom_min) / (zoom_max - zoom_min);
			
			if(zooming) {
				zoom_level_to = lerp(zoom_min, zoom_max, clamp((_m[1] - byF - zH / 2) / (byH - zH), 0, 1));
				
				if(mouse_release(mb_left))
					zooming = false;
			}
			
			var cc = merge_color(COLORS._main_icon, COLORS._main_icon_dark, 0.5);
			if(point_in_rectangle(_m[0], _m[1], bxF, byF, _x + _w, byF + byH)) {
				cc = COLORS._main_icon;
				if(mouse_click(mb_left, active)) 
					zooming = true;
			}
			
			draw_sprite_stretched_ext(THEME.timeline_dopesheet_bg, 0, bxF, zy - zH / 2, bs, zH, cc, 1);
			
			if(buttonInstant(THEME.button_hide, bx, by0, bs, bs, _m, active, hover,, THEME.add_16) == 2) 
				zoom_level_to = clamp(zoom_level_to - 1, zoom_min, zoom_max);
				
			if(buttonInstant(THEME.button_hide, bx, by1, bs, bs, _m, active, hover,, THEME.minus_16) == 2) 
				zoom_level_to = clamp(zoom_level_to + 1, zoom_min, zoom_max);
		#endregion
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + cw, _y + _h)) { #region
			if(mouse_press(mb_left, active)) {
				if(node_hovering == -1) {
					var _ind = point_insert * 6;
					var _px = (_m[0] - _x) / cw;
					var _py = 1 - (_m[1] - _y) / _h;
				
					array_insert(_data, _ind + 0, -0.1);
					array_insert(_data, _ind + 1, 0);
					array_insert(_data, _ind + 2, _px);
					array_insert(_data, _ind + 3, _py);
					array_insert(_data, _ind + 4, 0.1);
					array_insert(_data, _ind + 5, 0);
					if(onModify(_data))
						UNDO_HOLDING = true;
				
					node_dragging = _ind + 2;
					node_drag_typ = 0;
				} else {
					node_dragging = node_hovering;
					node_drag_typ = node_hover_typ;
				}
			} else if(mouse_press(mb_right, active)) {
				var node_point = (node_hovering - 2) / 6;
				if(node_hover_typ == 0 && node_point > 0 && node_point < points - 1) {
					array_delete(_data, node_point * 6, 6);
					if(onModify(_data))
						UNDO_HOLDING = true;
				}
			}
			
			if(mouse_press(mb_right, active)) {
				menuCall("widget_curve", rx + _m[0], ry + _m[1], [
					menuItem(grid_show? __txt("Hide grid") : __txt("Show grid"), function() { grid_show = !grid_show; }),
					menuItem(__txt("Snap to grid"), function() { grid_snap = !grid_snap; },,, function() { return grid_snap } ),
					menuItemGroup("Grid size", [
						[ "1%",  function() { grid_step = 0.01; } ],
						[ "5%",  function() { grid_step = 0.05; } ],
						[ "10%", function() { grid_step = 0.10; } ],
						[ "25%", function() { grid_step = 0.25; } ],
					])
				]);
			}
		} #endregion
		
		draw_surface(curve_surface, _x, _y);
		draw_set_color(COLORS.widget_curve_outline);
		draw_rectangle(_x, _y, _x + cw, _y + _h, true);
		
		var tx = _x + cw - ui(6);
		var ty = _y + _h - ui(6);
			
		draw_set_text(f_p2, fa_right, fa_bottom, display_sel? COLORS._main_text: COLORS._main_text_sub);
		draw_text_add(tx, ty, $"{display_sel == 2? "dy" : "y"}: {string_format(display_pos_y * 100, -1, 2)}%");
			
		ty -= line_get_height();
		draw_text_add(tx, ty, $"{display_sel == 2? "dx" : "x"}: {string_format(display_pos_x * 100, -1, 2)}%");
			
			
		resetFocus();
		
		return h;
	}
}
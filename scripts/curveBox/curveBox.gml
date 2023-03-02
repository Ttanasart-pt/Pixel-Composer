function curveBox(_onModify) : widget() constructor {
	onModify = _onModify;
	
	curve_surface = surface_create(1, 1);
	node_dragging = -1;
	node_drag_typ = -1;
	miny = 0;
	maxy = 1;
	
	static get_x = function(val, _x, _w) { return _x + _w * val; }
	static get_y = function(val, _y, _h) { return _y + _h * (1 - (val - miny) / (maxy - miny)); }
	
	static register = function() {}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x; y = _y;
		w = _w; h = _h;
		
		curve_surface = surface_verify(curve_surface, _w, _h);
		
		var points = array_length(_data) / 6;
		
		if(node_dragging != -1) {
			if(node_drag_typ == 0) { 
				var node_point = (node_dragging - 2) / 6;
				if(node_point > 0 && node_point < points - 1) {
					var _mx = (_m[0] - _x) / _w;
						_mx = clamp(_mx, 0, 1);
					
					var bfx = _data[node_dragging - 6];
					var afx = _data[node_dragging + 6];
					
					if(_mx == bfx)		node_dragging -= 6;
					else if(_mx == afx) node_dragging += 6;
					else				_data[node_dragging + 0] = _mx;
				}
				
				var _my = 1 - (_m[1] - _y) / _h;
					_my = clamp(_my * (maxy - miny) + miny, 0, 1);
				_data[node_dragging + 1] = _my;
				
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
				
				var _mx = (_m[0] - _x) / _w;
					_mx = clamp(_mx, 0, 1);
				_data[node_dragging - 2] = (_px - _mx) * node_drag_typ;
				_data[node_dragging + 2] = (_mx - _px) * node_drag_typ;
				
				var _my = 1 - (_m[1] - _y) / _h;
					_my = _my * (maxy - miny) + miny;
				_data[node_dragging - 1] = clamp(_py - _my, -1, 1) * node_drag_typ;
				_data[node_dragging + 3] = clamp(_my - _py, -1, 1) * node_drag_typ;
				
				if(onModify(_data))
					UNDO_HOLDING = true;
			} 
			
			if(mouse_release(mb_left)) {
				node_dragging = -1;
				node_drag_typ = -1;
				
				UNDO_HOLDING = false;
			}
		}
		
		var node_hovering  = -1;
		var node_hover_typ = -1;
		var point_insert   = 1;
		var _x1 = 0;
		
		var msx = _m[0] - _x;
		var msy = _m[1] - _y;
		
		surface_set_target(curve_surface);
		draw_clear_alpha(0, 0);
			draw_set_color(COLORS.widget_curve_line);
			draw_set_alpha(0.75);
			var y0 = _h - _h * (0 - miny) / (maxy - miny);
			draw_line(0, y0, _w, y0);
			var y1 = _h - _h * (1 - miny) / (maxy - miny);
			draw_line(0, y1, _w, y1);
			draw_set_alpha(1);
		
			for( var i = 0; i < points; i++ ) {
				var ind = i * 6;
				var _x0 = _data[ind + 2];
				var _y0 = _data[ind + 3];
				var bx0 = _x0 + _data[ind + 0];
				var by0 = _y0 + _data[ind + 1];
				var ax0 = _x0 + _data[ind + 4];
				var ay0 = _y0 + _data[ind + 5];
			
				bx0 = get_x(bx0, 0, _w);
				by0 = get_y(by0, 0, _h);
				_x0 = get_x(_x0, 0, _w);
				_y0 = get_y(_y0, 0, _h);
				ax0 = get_x(ax0, 0, _w);
				ay0 = get_y(ay0, 0, _h);
				
				draw_set_color(COLORS.widget_curve_line);
				if(i > 0) { //draw pre line
					draw_line(bx0, by0, _x0, _y0);
				
					draw_circle(bx0, by0, 3, false);
					if(hover && point_in_circle(msx, msy, bx0, by0, 10)) {
						draw_circle(bx0, by0, 5, false);
						node_hovering = ind + 2;
						node_hover_typ = -1;
					}
				}
			
				if(i < points - 1) { //draw post line
					draw_line(ax0, ay0, _x0, _y0);
				
					draw_circle(ax0, ay0, 3, false);
					if(hover && point_in_circle(msx, msy, ax0, ay0, 10)) {
						draw_circle(ax0, ay0, 5, false);
						node_hovering = ind + 2;
						node_hover_typ = 1;
					}
				}
			
				draw_set_color(COLORS._main_accent);
				draw_circle(_x0, _y0, 3, false);
				if(hover && point_in_circle(msx, msy, _x0, _y0, 10)) {
					draw_circle(_x0, _y0, 5, false);
					node_hovering = ind + 2;
					node_hover_typ = 0;
				}
			
				if(msx >= _x1 && msy <= _x0)
					point_insert = i;
				_x1 = _x0;
			}
		
			draw_set_color(COLORS._main_accent);
			draw_curve(0, 0, _w, -_h, _data, miny, maxy);
		
		surface_reset_target();
		
		var bx = _x + _w - ui(6 + 24);
		var by = _y + _h - ui(6 + 24);
				
		if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), _m, active, hover,, THEME.add) == 2) {
			miny = 0;
			maxy = 1;
		}
				
		bx -= ui(24 + 4);
		if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), _m, active, hover,, THEME.minus) == 2) {
			miny = -1;
			maxy =  2;
		}
		
		if(hover) {
			if(point_in_rectangle(_m[0], _m[1], _x + _w - ui(6 + 24 * 2 + 4), _y + _h - ui(6 + 24), _x + _w + ui(5), _y + _h + ui(5))) {
			} else if(point_in_rectangle(msx, msy, -ui(5), -ui(5), _w + ui(5), _h + ui(5))) {
				if(mouse_press(mb_left, active)) {
					if(node_hovering == -1) {
						var _ind = point_insert * 6;
						var _px = (_m[0] - _x) / _w;
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
			}
		}
		
		draw_surface(curve_surface, _x, _y);
		draw_set_color(COLORS.widget_curve_outline);
		draw_rectangle(_x, _y, _x + _w, _y + _h, true);
		
		resetFocus();
	}
}
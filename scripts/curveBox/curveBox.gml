function curveBox(_onModify) constructor {
	onModify = _onModify;
	
	active = false;
	hover  = false;
	
	node_dragging = -1;
	
	drag_range = 0;
	drag_max   = 0;
	
	static get_y = function(val, _y, _h, y_max, y_range) {
		return _y + _h * clamp((y_max - val) / y_range, 0, 1);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		static curve_amo = 3;
		var curve_h = _h;
		
		var					yS = _data[0];
		var x0 = _data[1],	y0 = _data[2];
		var x1 = _data[3],	y1 = _data[4];
		var					yE = _data[5];
		
		var _range = bezier_range(_data);
		var y_min = min(0, _range[0]);
		var y_max = max(1, _range[1]);
		var y_range = y_max - y_min;
		
		var yS = get_y(yS, _y, curve_h, y_max, y_range);
		var yE = get_y(yE, _y, curve_h, y_max, y_range);
			
		#region draw frame
			draw_set_color(COLORS.widget_curve_outline);
			draw_set_alpha(0.5);
			draw_line(_x, yS, _x + _w, yS);
			draw_line(_x, yE, _x + _w, yE);
			draw_set_alpha(1);
			
			draw_rectangle(_x, _y, _x + _w, _y + curve_h, true);
		#endregion
			
		if(node_dragging == 0 || node_dragging == 3) {
			var targ = node_dragging == 0? 0 : 5;
			var _my = -((_m[1] - _y) / curve_h * drag_range - drag_max);
			_my = clamp(_my, 0, 1);
				
			_data[targ] = _my;
			
			if(mouse_release(mb_left)) {
				onModify(_data);
				node_dragging = -1;
			}
		} else if(node_dragging != -1) {
			var _mx =   (_m[0] - _x) / _w;
			_mx = clamp(_mx, 0, 1);
			
			var _my = -((_m[1] - _y) / curve_h * drag_range - drag_max);
			_my = clamp(_my, 0, 1);
				
			_data[1 + (node_dragging - 1) * 2 + 0] = _mx;
			_data[1 + (node_dragging - 1) * 2 + 1] = _my;
			
			if(mouse_release(mb_left)) {
				onModify(_data);
				node_dragging = -1;
			}
		}
			
		var node_hovering = -1;
		var points = [ [0, _data[0]], [_data[1], _data[2]], [_data[3], _data[4]], [1, _data[5]] ];
		
		var _sx = _x + points[0][0] * _w
		var _sy = get_y(points[0][1], _y, curve_h, y_max, y_range);
		var _ex = _x + points[3][0] * _w
		var _ey = get_y(points[3][1], _y, curve_h, y_max, y_range);
		
		draw_set_color(COLORS.widget_curve_line);
		
		for(var i = 0; i < 4; i++) {
			var _nx = _x + points[i][0] * _w;
			var _ny = get_y(points[i][1], _y, curve_h, y_max, y_range);
			
			if(i == 1)
				draw_line(_sx, _sy, _nx, _ny);
			else if(i == 2)
				draw_line(_nx, _ny, _ex, _ey);
			
			draw_circle(_nx, _ny, 3, false);
			
			if(hover && point_in_circle(_m[0], _m[1], _nx, _ny, 6)) {
				draw_circle(_nx, _ny, 5, false);
				node_hovering = i;
			}
		}
		
		var _dy = _y + (y_max - 1) / y_range * curve_h;
		var _dh = -curve_h / y_range;
		
		draw_set_color(COLORS._main_accent);
		draw_line_bezier_cubic(_x, _dy, _w, _dh, _data);
		
		if(mouse_press(mb_left, active) && node_hovering != -1) {
			node_dragging = node_hovering;
			drag_range = y_range;
			drag_max   = y_max;
		}
		
		active = false;
		hover  = false;
	}
}
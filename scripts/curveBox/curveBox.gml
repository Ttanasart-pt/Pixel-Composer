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
		var curve_h = _h - 32;
		
		#region curve
			var _range;
			_range = bezier_range(_data[0], _data[1], _data[2], _data[3]);
			var y_min = min(0, _range[0]);
			var y_max = max(1, _range[1]);
			var y_range = y_max - y_min;
		
			var _y_0 = get_y(0, _y, curve_h, y_max, y_range);
			var _y_1 = get_y(1, _y, curve_h, y_max, y_range);
		
			draw_set_color(COLORS.widget_curve_outline);
			draw_set_alpha(0.5);
			draw_line(_x + _w / 3, _y, _x + _w / 3, _y + curve_h);
			draw_line(_x + _w / 3 * 2, _y, _x + _w / 3 * 2, _y + curve_h);
			
			draw_line(_x, _y_0, _x + _w, _y_0);
			draw_line(_x, _y_1, _x + _w, _y_1);
			draw_set_alpha(1);
			
			draw_rectangle(_x, _y, _x + _w, _y + curve_h, true);
		
			if(node_dragging != -1) {
				var _my = -((_m[1] - _y) / curve_h * drag_range - drag_max);
			
				_data[node_dragging] = _my;
			
				if(mouse_check_button_released(mb_left)) {
					onModify(_data);
					node_dragging = -1;
				}
			}
		
			var _y0 = _data[0];
			var _y1 = _data[1];
			var _y2 = _data[2];
			var _y3 = _data[3];
		
			var _dy = _y + (y_max - 1) / y_range * curve_h;
			var _dh = -curve_h / y_range;
		
			draw_set_color(COLORS.widget_curve_line);
			draw_line_bezier_cubic(_x, _dy, _w, _dh, _y0, _y1, _y2, _y3);
			
			var node_hovering = -1;
			for(var i = 0; i < 4; i++) {
				var _nx = i / 3 * _w + _x;
				var _ny = get_y(_data[i], _y, curve_h, y_max, y_range);
			
				draw_set_color(COLORS.widget_curve_outline);
				draw_circle(_nx, _ny, 3, false);
			
				if(hover && point_in_circle(_m[0], _m[1], _nx, _ny, 6)) {
					draw_circle(_nx, _ny, 5, false);
					node_hovering = i;
				}
			}
		
			if(active) {
				if(mouse_check_button_pressed(mb_left)) {
					if(node_hovering != -1) {
						node_dragging = node_hovering;
						drag_range = y_range;
						drag_max   = y_max;
					}
				} else if(mouse_check_button_pressed(mb_right)) {
					switch(node_hovering) {
						case 0 : _data[0] = 0; break;
						case 1 : _data[1] = 0; break;
						case 2 : _data[2] = 1; break;
						case 3 : _data[3] = 1; break;
					}
					onModify(_data);
				} 
			}
		#endregion
		
		active = false;
		hover  = false;
	}
}
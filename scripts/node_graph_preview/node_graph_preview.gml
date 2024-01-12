function Node_Graph_Preview(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Graph Preview";
	preview_draw = true;
	
	min_h = 128;
	
	inputs[| 0]  = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.rejectArray();
	
	inputs[| 1]  = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 2]  = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.rejectArray();

	inputs[| 3]  = nodeValue("Sticky", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray();
		
	inputs[| 4]  = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
		
	input_display_list = [ 0,
		["Display", false], 1, 2, 4, 3, 
	]
	
	surf  = noone;
	stick = true;
	pos_x = x;
	pos_y = y;
	sca   = 1;
	alpha = 1;
	
	dragging = noone;
	drag_sx  = 0;
	drag_sy  = 0;
	drag_mx  = 0;
	drag_my  = 0;
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _surf = getInputData(0);
		var _posi = getInputData(1);
		var _scal = getInputData(2);
		var _stck = getInputData(3);
		var _alph = getInputData(4);
		
		surf  = _surf;
		pos_x = _posi[0];
		pos_y = _posi[1];
		sca   = _scal;
		stick = _stck;
		alpha = _alph;
	} #endregion
	
	static getGraphPreviewSurface = function() { return surf; }
	
	static drawPreviewBackground = function(_x, _y, _mx, _my, _s) {
		if(!is_surface(surf)) return false;
		
		var xx = stick? pos_x : _x + pos_x * _s;
		var yy = stick? pos_y : _y + pos_y * _s;
		var ss = stick? sca   : sca * _s;
		
		draw_surface_ext(surf, xx, yy, ss, ss, 0, c_white, alpha);
		
		if(dragging == 1) {
			var _x0 = stick? drag_sx + (_mx - drag_mx) : drag_sx + (_mx - drag_mx) / _s;
			var _y0 = stick? drag_sy + (_my - drag_my) : drag_sy + (_my - drag_my) / _s;
			
			inputs[| 1].setValue([ _x0, _y0 ]);
			
			if(mouse_release(mb_left))
				dragging = noone;
		}
		
		if(dragging == 2) {
			var _sw = surface_get_width_safe(surf);
			var _sh = surface_get_height_safe(surf);
			var _ss = min((_mx - drag_sx) / _sw, (_my - drag_sy) / _sh);
			
			inputs[| 2].setValue(stick? _ss : _ss / _s);
			
			if(mouse_release(mb_left))
				dragging = noone;
		}
		
		var _hov = false;
		
		if(PANEL_INSPECTOR.inspecting == self) {
			var _sw = surface_get_width_safe(surf);
			var _sh = surface_get_height_safe(surf);
			
			var _x1 = xx + _sw * ss;
			var _y1 = yy + _sh * ss;
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle(xx, yy, _x1, _y1, true);
			draw_sprite_colored(THEME.anchor_selector, 0, _x1, _y1);
			
			if(point_in_circle(_mx, _my, _x1, _y1, 12)) {
				_hov = true;
				
				if(mouse_press(mb_left, is_instanceof(FOCUS, Panel) && FOCUS.getContent() == PANEL_GRAPH)) {
					dragging = 2;
					drag_sx  = xx;
					drag_sy  = yy;
					drag_mx  = _mx;
					drag_my  = _my;
				}
			} else if(point_in_rectangle(_mx, _my, xx, yy, _x1, _y1)) {
				_hov = true;
				
				if(mouse_press(mb_left, is_instanceof(FOCUS, Panel) && FOCUS.getContent() == PANEL_GRAPH)) {
					dragging = 1;
					drag_sx  = pos_x;
					drag_sy  = pos_y;
					drag_mx  = _mx;
					drag_my  = _my;
				}
			}
		}
		
		return _hov;
	}
}
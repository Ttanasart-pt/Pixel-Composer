function canvas_s_tool_line() : canvas_s_tool() constructor {
	icon     = THEME.canvas_tools_line;
	tooltip  = "Line";
	hotkey   = new KeyCombination("L");
	isDrawer = true;
	
	mouse_drawing = false;
	shape_x = undefined;
	shape_y = undefined;
	
	brush = new canvas_s_brush();
	
	settings = [
		brush.settings, 
	]
	
	////- Functions
	
	function drawBrush(_brushSurface) { return brush.drawBrush(_brushSurface); }
		
	function drawing(_drawingSurface) {
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		var dim = surface_get_dimension(_drawingSurface);
		
		brush.step(canvas, dim);
		
		if(mouse_drawing) {
			var x0 = shape_x;
			var y0 = shape_y;
			
			var x1 = mpx;
			var y1 = mpy;
			
			if(key_mod_press(SHIFT)) {
				var _dx = x1 - x0;
				var _dy = y1 - y0;
				
				if(_dx != 0 && _dy != 0 && _dx != _dy) {
					var _ddx = _dx;
					var _ddy = _dy;
					
					     if(abs(_dx) > abs(_dy)) _ddx = _ddy * round(_ddx / _ddy);
					else if(abs(_dx) < abs(_dy)) _ddy = _ddx * round(_ddy / _ddx);
					
					x1 = x0 + _ddx - sign(_ddx);
					y1 = y0 + _ddy - sign(_ddy);
				}
			}

			if(key_mod_press(CTRL)) {
				x0 = x0 - (x1 - x0);
				y0 = y0 - (y1 - y0);
			}
			
			surface_set_target(_drawingSurface);
				DRAW_CLEAR
				draw_set_color(c_white);
				BLEND_MAX
				brush.drawLine(x0, y0, x1, y1);
				BLEND_NORMAL
			surface_reset_target();
			
			if(mouse_lrelease()) {
				mouse_drawing = false;
				canvas.applySurface(_drawingSurface, erase);
			}
			
		} else {
			surface_set_target(_drawingSurface);
				DRAW_CLEAR
				draw_set_color(c_white);
				BLEND_MAX
				brush.drawPixel(mpx, mpy);
				BLEND_NORMAL
			surface_reset_target();
				
			if(hover && mouse_lpress(focus)) {
				mouse_drawing = true;
				
				shape_x = mpx;
				shape_y = mpy;
			}
		}
	}
}
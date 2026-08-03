function canvas_s_tool_shape_rectangle(_fill = false) : canvas_s_tool() constructor {
	fill = _fill;
	
	icon     = _fill? THEME.canvas_tools_rect_fill : THEME.canvas_tools_rect;
	tooltip  = _fill? "Rectangle Fill" : "Rectangle Outline";
	hotkey   = new KeyCombination("U");
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
				var dx = x1 - x0;
				var dy = y1 - y0;

				if(abs(dx) > abs(dy)) y1 = y0 + sign(dy) * abs(dx);
				else                  x1 = x0 + sign(dx) * abs(dy);
			}

			if(key_mod_press(CTRL)) {
				x0 = x0 - (x1 - x0);
				y0 = y0 - (y1 - y0);
			}
			
			surface_set_target(_drawingSurface);
				DRAW_CLEAR
				BLEND_MAX
				draw_set_color(c_white);
				brush.drawLine(x0, y0, x1, y0);
				brush.drawLine(x0, y1, x1, y1);
				
				brush.drawLine(x1, y1, x1, y0);
				brush.drawLine(x0, y1, x0, y0);
				
				if(fill) {
					draw_rectangle(x0, y0, x1, y1, false);
					
					var px0 = x0;
					var py0 = y0;
					var px1 = x1;
					var py1 = y1;
					
					if(canvas.tile[0]) {
						draw_rectangle(px0 - dim[0], py0, px1 - dim[0], py1, false);
						draw_rectangle(px0 + dim[0], py0, px1 + dim[0], py1, false);
					}
					
					if(canvas.tile[1]) {
						draw_rectangle(px0, py0 - dim[1], px1, py1 - dim[1], false);
						draw_rectangle(px0, py0 + dim[1], px1, py1 + dim[1], false);
					}
					
					if(canvas.tile[0] && canvas.tile[1]) {
						draw_rectangle(px0 - dim[0], py0 - dim[1], px1 - dim[0], py1 - dim[1], false);
						draw_rectangle(px0 + dim[0], py0 - dim[1], px1 + dim[0], py1 - dim[1], false);
						
						draw_rectangle(px0 - dim[0], py0 + dim[1], px1 - dim[0], py1 + dim[1], false);
						draw_rectangle(px0 + dim[0], py0 + dim[1], px1 + dim[0], py1 + dim[1], false);
					}
					
				}
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
				brush.drawPixel(mpx, mpy);
			surface_reset_target();
				
			if(hover && mouse_lpress(focus)) {
				mouse_drawing = true;
				
				shape_x = mpx;
				shape_y = mpy;
			}
		}
	}
}
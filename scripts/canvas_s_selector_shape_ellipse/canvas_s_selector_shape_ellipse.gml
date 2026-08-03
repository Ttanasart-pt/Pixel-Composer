function canvas_s_selector_shape_ellipse() : canvas_s_tool() constructor {
	icon       = THEME.canvas_tools_selection_circle;
	tooltip    = "Circle Selector";
	hotkey     = new KeyCombination("S");
	isSelector = true;
	selecting  = false;
	
	mouse_drawing = false;
	shape_x = undefined;
	shape_y = undefined;
	
	selection_mask = undefined;
	
	function drawing(_drawingSurface) {
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		selecting = mouse_drawing;
		
		if(mouse_drawing) {
			var dim = surface_get_dimension(_drawingSurface);
			selection_mask = surface_verify(selection_mask, dim[0], dim[1]);
			
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
			
			surface_set_target(selection_mask);
				DRAW_CLEAR
				draw_set_color(c_white);
				draw_ellipse(x0, y0, x1, y1, false);
			surface_reset_target();
			
			if(mouse_lrelease()) {
				if(abs(mpx - shape_x) + abs(mpy - shape_y) > 1)
					canvas.createSelection(selection_mask);
				else 
					canvas.applySelection();
				mouse_drawing = false;
			}
			
		} else {
			if(hover && mouse_lpress(focus)) {
				mouse_drawing = true;
				
				shape_x = mpx;
				shape_y = mpy;
			}
		}
	}
	
	function drawOutline(_x, _y, _s) {
		if(mouse_drawing) draw_surface_ext_safe(selection_mask, _x, _y, _s, _s, 0, c_white, 1);
	}
}
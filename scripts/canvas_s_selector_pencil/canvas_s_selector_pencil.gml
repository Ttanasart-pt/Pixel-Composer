function canvas_s_selector_pencil() : canvas_s_tool() constructor {
	icon       = THEME.canvas_tools_selection_brush;
	tooltip    = "Brush Selector";
	hotkey     = new KeyCombination("S");
	isSelector = true;
	selecting  = false;
	
	mouse_drawing = false;
	line_drawing  = false;
	has_selection = false;
	
	draw_px0 = undefined; draw_py0 = undefined;
	draw_px1 = undefined; draw_py1 = undefined;
	
	draw_last_x = undefined;
	draw_last_y = undefined;
	
	selection_mask = undefined;
	
	brush = new canvas_s_brush();
	pixel_perfect = true;
	
	settings = [
		new __Simple_Editor( "Size", textBox_Number(function(s) /*=>*/ { brush.size = round(s); }), 
			function() /*=>*/ {return brush.size}, function(b) /*=>*/ { brush.size = round(b); } ),
			
		new __Simple_Editor( THEME.pixel_diag, new checkBox(function() /*=>*/ { pixel_perfect = !pixel_perfect; }), 
			function() /*=>*/ {return pixel_perfect}, function(b) /*=>*/ { pixel_perfect = b; } )
			.setTooltip(__txt("Pixel Perfect")),
	]
	
	////- Functions
	
	function drawBrush(_brushSurface) { return brush.drawBrush(_brushSurface); }
		
	function drawing(_drawingSurface) {
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		var dim = surface_get_dimension(_drawingSurface);
		selection_mask = surface_verify(selection_mask, dim[0], dim[1]);
		selecting = mouse_drawing;
		
		brush.tile    = canvas.tile;
		brush.tileDim = dim;
		
		if(mouse_drawing) {
			var ppx = pixel_perfect && brush.size == 1;
			
			if(ppx) {
				var _drawPx = abs(mpx - draw_px1) > 1 || abs(mpy - draw_py1) > 1;
						
				if(_drawPx) {
					surface_set_target(selection_mask);
						draw_set_color(c_white);
						brush.drawLine(draw_px1, draw_py1, draw_px0, draw_py0);
					surface_reset_target();
					
					draw_px1 = draw_px0;
					draw_py1 = draw_py0;
					has_selection = true;
				} 
				
				if(mouse_lrelease()) {
					surface_set_target(selection_mask);
						draw_set_color(c_white);
						brush.drawPixel(mpx, mpy);
					surface_reset_target();
				}
				
				draw_last_x = mpx;
				draw_last_y = mpy;
				
			} else {
				if(draw_px0 != mpx || draw_py0 != mpy) {
					surface_set_target(selection_mask);
						draw_set_color(c_white);
						brush.drawLine(draw_px0, draw_py0, mpx, mpy);
					surface_reset_target();
					has_selection = true;
				}
				
				draw_px1 = draw_px0;
				draw_py1 = draw_py0;
				
				draw_last_x = mpx;
				draw_last_y = mpy;
			}
			
			draw_px0 = mpx;
			draw_py0 = mpy;
			
			if(mouse_lrelease()) {
				draw_last_x = mpx;
				draw_last_y = mpy;
				
				mouse_drawing = false;
				
				if(has_selection) canvas.createSelection(selection_mask);
				else 			  canvas.applySelection();
			}
			
		} else {
			surface_set_target(selection_mask);
				DRAW_CLEAR
				
				draw_set_color(c_white);
				
				if(key_mod_press(SHIFT)) {
					var lx = mpx;
					var ly = mpy;
						
					if(key_mod_press(CTRL)) {
						var _dx = lx - draw_last_x;
						var _dy = ly - draw_last_y;
						
						if(_dx != 0 && _dy != 0 && _dx != _dy) {
							var _ddx = _dx;
							var _ddy = _dy;
							
							     if(abs(_dx) > abs(_dy)) _ddx = _ddy * round(_ddx / _ddy);
							else if(abs(_dx) < abs(_dy)) _ddy = _ddx * round(_ddy / _ddx);
							
							lx = draw_last_x + _ddx - sign(_ddx);
							ly = draw_last_y + _ddy - sign(_ddy);
						}
					}
					
					brush.drawLine(draw_last_x, draw_last_y, lx, ly);
					
				} else 
					brush.drawPixel(mpx, mpy);
				
			surface_reset_target();
				
			if(hover && mouse_lpress(focus)) {
				if(key_mod_press(SHIFT)) {
					canvas.createSelection(selection_mask);
					draw_last_x = mpx;
					draw_last_y = mpy;
				
				} else {
					mouse_drawing = true;
					has_selection = false;
					
					draw_px0 = mpx; draw_py0 = mpy;
					draw_px1 = mpx; draw_py1 = mpy;
					
					selection_mask = surface_verify(selection_mask, dim[0], dim[1]);
					surface_set_target(selection_mask);
						DRAW_CLEAR
						draw_set_color(c_white);
						brush.drawPixel(mpx, mpy);
					surface_reset_target();
				}
			}
		}
	}
	
	function drawOutline(_x, _y, _s) {
		if(mouse_drawing) draw_surface_ext_safe(selection_mask, _x, _y, _s, _s, 0, c_white, 1);
	}
}
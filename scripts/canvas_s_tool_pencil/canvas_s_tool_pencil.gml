function canvas_s_tool_pencil() : canvas_s_tool() constructor {
	icon     = THEME.canvas_tools_pencil;
	tooltip  = "Brush";
	hotkey   = new KeyCombination("B");
	isDrawer = true;
	
	mouse_drawing = false;
	line_drawing  = false;
	
	draw_px0 = undefined; draw_py0 = undefined;
	draw_px1 = undefined; draw_py1 = undefined;
	
	draw_last_x = undefined;
	draw_last_y = undefined;
	
	brush = new canvas_s_brush();
	pixel_perfect = true;
	
	settings = [
		brush.settings,
			
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
		
		brush.step(canvas, dim);
		
		if(mouse_drawing) {
			var ppx = pixel_perfect && brush.size == 1;
			
			if(ppx) {
				var _drawPx = abs(mpx - draw_px1) > 1 || abs(mpy - draw_py1) > 1;
						
				if(_drawPx) {
					surface_set_target(_drawingSurface);
						BLEND_MAX
						draw_set_color(c_white);
						brush.drawLine(draw_px1, draw_py1, draw_px0, draw_py0);
						BLEND_NORMAL
					surface_reset_target();
					
					draw_px1 = draw_px0;
					draw_py1 = draw_py0;
				} 
				
				if(mouse_lrelease()) {
					surface_set_target(_drawingSurface);
						BLEND_MAX
						draw_set_color(c_white);
						brush.drawPixel(mpx, mpy);
						BLEND_NORMAL
					surface_reset_target();
				}
				
				draw_last_x = mpx;
				draw_last_y = mpy;
				
			} else {
				if(draw_px0 != mpx || draw_py0 != mpy) {
					surface_set_target(_drawingSurface);
						BLEND_MAX
						draw_set_color(c_white);
						brush.drawLine(draw_px0, draw_py0, mpx, mpy);
						BLEND_NORMAL
					surface_reset_target();
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
				canvas.applySurface(_drawingSurface, erase);
			}
			
		} else {
			surface_set_target(_drawingSurface);
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
					canvas.applySurface(_drawingSurface, erase);
					draw_last_x = mpx;
					draw_last_y = mpy;
				
				} else {
					mouse_drawing = true;
					
					draw_px0 = mpx; draw_py0 = mpy;
					draw_px1 = mpx; draw_py1 = mpy;
					
					surface_set_target(_drawingSurface);
						DRAW_CLEAR
						draw_set_color(c_white);
						brush.drawPixel(mpx, mpy);
					surface_reset_target();
				}
			}
		}
	}
}
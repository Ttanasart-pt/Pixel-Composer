function canvas_s_tool_shape_ellipse(_fill = false) : canvas_s_tool() constructor {
	fill = _fill;
	
	icon     = _fill? THEME.canvas_tools_ellip_fill : THEME.canvas_tools_ellip;
	tooltip  = _fill? "Circle Fill" : "Circle Outline";
	hotkey   = new KeyCombination("U", MOD_KEY.shift);
	isDrawer = true;
	
	mouse_drawing = false;
	line_drawing  = false;
	
	shape_x = undefined;
	shape_y = undefined;
	
	brush = new canvas_s_brush();
	precision = 32;
	
	settings = [
		brush.settings,
		
		new __Simple_Editor( "Sides", textBox_Number(function(s) /*=>*/ { precision = round(s); }), 
			function() /*=>*/ {return precision}, function(b) /*=>*/ { precision = round(b); } ),
			
	]
	
	////- Functions
	
	function drawBrush(_brushSurface) { return brush.drawBrush(_brushSurface); }
		
	function drawing(_drawingSurface) {
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		var dim = surface_get_dimension(_drawingSurface);
		
		brush.step(canvas, dim);
		
		if(mouse_drawing) {
			var _prec = precision;
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
			
			x0 = round(x0);
			y0 = round(y0);
			
			x1 = round(x1);
			y1 = round(y1);
			
			var cx = (x0 + x1) / 2;
			var cy = (y0 + y1) / 2;
			
			var cw = abs(x0 - x1) / 2;
			var ch = abs(y0 - y1) / 2;
			
			surface_set_target(_drawingSurface);
				DRAW_CLEAR
				BLEND_MAX
				draw_set_color(c_white);
				if(!fill && brush.size == 1) {
					for( var i = 0; i <= _prec; i++ ) {
						var oa = (i+0) / _prec * 360;
						var na = (i+1) / _prec * 360;
						
						var ox = round(cx + lengthdir_x(cw, oa));
						var oy = round(cy + lengthdir_y(ch, oa));
						
						var nx = round(cx + lengthdir_x(cw, na));
						var ny = round(cy + lengthdir_y(ch, na));
						
						brush.drawLinePx(ox, oy, nx, ny);
					}
					
				} else {
					if(fill) draw_ellipse( x0, y0, x1, y1, false);
					draw_ellipse_border(   x0, y0, x1, y1, brush.size);
					
					if(canvas.tile[0]) {
						if(fill) draw_ellipse( x0 - dim[0], y0, x1 - dim[0], y1, false);
						draw_ellipse_border(   x0 - dim[0], y0, x1 - dim[0], y1, brush.size);
					
						if(fill) draw_ellipse( x0 + dim[0], y0, x1 + dim[0], y1, false);
						draw_ellipse_border(   x0 + dim[0], y0, x1 + dim[0], y1, brush.size);
					}
					
					if(canvas.tile[1]) {
						if(fill) draw_ellipse( x0, y0 - dim[1], x1, y1 - dim[1], false);
						draw_ellipse_border(   x0, y0 - dim[1], x1, y1 - dim[1], brush.size);
					
						if(fill) draw_ellipse( x0, y0 + dim[1], x1, y1 + dim[1], false);
						draw_ellipse_border(   x0, y0 + dim[1], x1, y1 + dim[1], brush.size);
					}
					
					if(canvas.tile[0] && canvas.tile[1]) {
						if(fill) draw_ellipse( x0 - dim[0], y0 - dim[1], x1 - dim[0], y1 - dim[1], false);
						draw_ellipse_border(   x0 - dim[0], y0 - dim[1], x1 - dim[0], y1 - dim[1], brush.size);
					
						if(fill) draw_ellipse( x0 + dim[0], y0 - dim[1], x1 + dim[0], y1 - dim[1], false);
						draw_ellipse_border(   x0 + dim[0], y0 - dim[1], x1 + dim[0], y1 - dim[1], brush.size);
					
						if(fill) draw_ellipse( x0 - dim[0], y0 + dim[1], x1 - dim[0], y1 + dim[1], false);
						draw_ellipse_border(   x0 - dim[0], y0 + dim[1], x1 - dim[0], y1 + dim[1], brush.size);
					
						if(fill) draw_ellipse( x0 + dim[0], y0 + dim[1], x1 + dim[0], y1 + dim[1], false);
						draw_ellipse_border(   x0 + dim[0], y0 + dim[1], x1 + dim[0], y1 + dim[1], brush.size);
					
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
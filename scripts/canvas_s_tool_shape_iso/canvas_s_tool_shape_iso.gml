function canvas_s_tool_shape_iso(_type) : canvas_s_tool() constructor {
	type = _type;
	switch(type) {
		case 0 : icon     = THEME.canvas_tools_iso_cube;
			     tooltip  = "Iso Cube"; break;
			
		case 1 : icon     = THEME.canvas_tools_iso_cube_wire;
			     tooltip  = "Iso Cube"; break;
			     
		case 2 : icon     = THEME.canvas_tools_iso_cube_fill;
			     tooltip  = "Iso Cube"; break;
		
	}
	
	hotkey   = new KeyCombination("I", MOD_KEY.shift);
	isDrawer = true;
	
	use_color_3d    = true;
	brush_resizable = true;
	mouse_holding   = 0;
	mouse_points    = [ [ 0, 0 ], [ 0, 0 ], 0 ];
	
	brush     = new canvas_s_brush();
	iso_angle = 0;
	colors    = [ ca_white, ca_black, cola(c_grey) ];
	
	settings = [
		brush.settings,
			
		new __Simple_Editor( "", new buttonColor(function(c) /*=>*/ { colors[0] = c; }), function() /*=>*/ {return colors[0]}, function(b) /*=>*/ { colors[0] = b; } ),
		new __Simple_Editor( "", new buttonColor(function(c) /*=>*/ { colors[1] = c; }), function() /*=>*/ {return colors[1]}, function(b) /*=>*/ { colors[1] = b; } ),
		new __Simple_Editor( "", new buttonColor(function(c) /*=>*/ { colors[2] = c; }), function() /*=>*/ {return colors[2]}, function(b) /*=>*/ { colors[2] = b; } ),
			
		new __Simple_Editor( "", new buttonGroup( array_create(2, THEME.canvas_iso_angle), function(v) /*=>*/ { iso_angle = v; })
			.setTooltips( [ "2:1", "1:1" ] ).setCollapse(false), function() /*=>*/ {return iso_angle}, function(b) /*=>*/ { iso_angle = round(b); } ),
	]
	
	////- Functions
	
	function drawBrush(_brushSurface) { 
		return type == 2? undefined : brush.drawBrush(_brushSurface);
	}
		
	function drawing(_drawingSurface) {
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		var dim = surface_get_dimension(_drawingSurface);
		
		brush.step(canvas, dim);
		brush.colors = colors;
		
		if(mouse_holding) {
			surface_set_shader(_drawingSurface, noone, true);
				BLEND_MAX
					 if(iso_angle == 0) canvas_draw_iso_cube( brush, mouse_points, type);
				else if(iso_angle == 1) canvas_draw_diag_cube(brush, mouse_points, type);
				BLEND_NORMAL
			surface_reset_shader();
		}
		
		switch(mouse_holding) {
			case 0 :
				mouse_points[0][0] = mpx;
				mouse_points[0][1] = mpy;
				
				if(mouse_lpress(focus)) {
					mouse_points[1][0] = mpx;
					mouse_points[1][1] = mpy;
				
					mouse_points[2] = 0;
					mouse_holding = 1;
				}
				break;
				
			case 1 :
				if(key_mod_press(SHIFT)) {
					var x0 = mouse_points[0][0];
					var y0 = mouse_points[0][1];
						
					var _dx = mpx - x0;
					var _dy = mpy - y0;
					
					if(abs(_dx) > abs(_dy)) x0 = x0 + _dx;
					else y0 = y0 + _dy;
					
					mouse_points[1][0] = x0;
					mouse_points[1][1] = y0;
					
				} else {
					mouse_points[1][0] = mpx;
					mouse_points[1][1] = mpy;
				}
				
				if(mouse_lrelease())
					mouse_holding = 2;
				
				break;
				
			case 2 :
				mouse_points[2] = mpy - mouse_points[1][1];
				
				if(mouse_lpress(focus)) {
					canvas.applySurface(_drawingSurface);
					mouse_holding = 0;
				}
					
				break;
		}
		
		if(key_press(vk_escape)) {
			mouse_holding = 0;
			surface_clear(_drawingSurface);
		}
		
	}
}
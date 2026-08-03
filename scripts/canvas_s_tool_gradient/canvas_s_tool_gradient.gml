function canvas_s_tool_gradient() : canvas_s_tool() constructor {
	icon = THEME.canvas_tools_gradient;
	tooltip = "Gradient";
	hotkey  = new KeyCombination("G");
	
	overrideColor = true;
	overrideLayer = true;
	
	threshold = 0;
	diagonal  = false;
	
	dragging  = false;
	grad_x    = 0;
	grad_y    = 0;
	
	gradient     = gra_black_white;
	mask_surface = undefined;
	
	settings = [
		new __Simple_Editor( "", new buttonGradient(function(g) /*=>*/ { gradient = g; }).setExpandable(false).setMinWidth(ui(96)), 
			function() /*=>*/ {return gradient}, function(b) /*=>*/ { gradient = b; } ),
		-1, 
		
		new __Simple_Editor( "Threshold", textBox_Number(function(s) /*=>*/ { threshold = s; }), function() /*=>*/ {return threshold}, function(b) /*=>*/ { threshold = b; } ),
		new __Simple_Editor( "", new buttonGroup(array_create(2, THEME.canvas_fill_type), function(s) /*=>*/ { diagonal = s; }), 
			function() /*=>*/ {return diagonal}, function(b) /*=>*/ { diagonal = b; } ).setTooltip("Fill Type"),
			
	]
	
	////- Functions
	
	function drawing(_drawingSurface) {
		var mpx = (mx - preview_x) / preview_s;
		var mpy = (my - preview_y) / preview_s;
		
		var content = content_surface;
		var dim = surface_get_dimension(content);
		var hov = hover && point_in_rectangle(mpx, mpy, 0, 0, dim[0], dim[1]);
		
		if(dragging) {
			var x0 = grad_x;
			var y0 = grad_y;
			
			var x1 = mpx;
			var y1 = mpy;
			
			surface_set_shader(_drawingSurface, sh_canvas_tool_gradient);
				shader_set_2( "dimension", dim );
				shader_set_2( "p1",    [x0,y0] );
				shader_set_2( "p2",    [x1,y1] );
				shader_set_gradient(gradient);
				
				draw_surface(mask_surface, 0, 0);
			surface_reset_shader();
			
			var px0 = preview_x + x0 * preview_s;
			var py0 = preview_y + y0 * preview_s;
			
			var px1 = preview_x + x1 * preview_s;
			var py1 = preview_y + y1 * preview_s;
			
			draw_set_color(c_white);
			draw_line(px0, py0, px1, py1);
			
			draw_anchor(0, px0, py0, ui(6), 0);
			draw_anchor(0, px1, py1, ui(6), 0);
			
			if(mouse_lrelease()) {
				canvas.applySurface(_drawingSurface);
				dragging = false;
			}
		}
		
		if(hov && mouse_lpress(focus)) {
			var _ping = [ surface_create(dim[0], dim[1]), surface_create(dim[0], dim[1]) ];
					
			dragging  = true;
			grad_x    = mpx;
			grad_y    = mpy;
			
			surface_set_target(_ping[1]);
				DRAW_CLEAR
				draw_set_color(c_white);
				draw_point(mpx, mpy);
			surface_reset_target();
			
			var bcolor = surface_get_pixel_ext(content, mpx, mpy);
			
			var itr = dim[0] + dim[1];
			var bg  = 0;
			
			repeat(itr) {
				surface_set_shader(_ping[bg], sh_canvas_tool_flood_fill);
					shader_set_2( "dimension",   dim     );
					shader_set_s( "baseSurface", content );
					shader_set_c( "baseColor",   bcolor  );
					
					shader_set_f( "threshold",   threshold/255 );
					shader_set_i( "diagonal",    diagonal      );
					draw_surface(_ping[!bg], 0, 0);
				surface_reset_shader();
				
				bg = !bg;
			}
			
			mask_surface = surface_verify(mask_surface, dim[0], dim[1]);
			surface_set_target(mask_surface);
				DRAW_CLEAR
				draw_surface(_ping[!bg], 0, 0);
			surface_reset_target();
			
		}
	}
}
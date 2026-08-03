function canvas_s_tool_fill() : canvas_s_tool() constructor {
	icon = THEME.canvas_tools_bucket;
	tooltip = "Fill";
	hotkey  = new KeyCombination("G");
	
	overrideLayer = true;
	
	threshold = 0;
	diagonal  = false;
	
	settings = [
		new __Simple_Editor( "Threshold", textBox_Number(function(s) /*=>*/ { threshold = s; }), function() /*=>*/ {return threshold}, function(b) /*=>*/ { threshold = b; } ),
		new __Simple_Editor( "", new buttonGroup(array_create(2, THEME.canvas_fill_type), function(s) /*=>*/ { diagonal = s; }), 
			function() /*=>*/ {return diagonal}, function(b) /*=>*/ { diagonal = b; } ).setTooltip("Fill Type"),
			
	]
	
	////- Functions
	
	function drawBrush(_brushSurface) { 
		_brushSurface = surface_verify(_brushSurface, 1, 1);
		surface_set_target(_brushSurface);
			DRAW_CLEAR
			draw_set_color(c_white);
			draw_point(0, 0);
		surface_reset_target();
		
		return _brushSurface;
	}
		
	function drawing(_drawingSurface) {
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		
		var content = content_surface;
		var dim = surface_get_dimension(content);
		var hov = hover && point_in_rectangle(mpx, mpy, 0, 0, dim[0], dim[1]);
		
		if(hov && mouse_lpress(focus)) {
			var _ping = [ surface_create(dim[0], dim[1]), surface_create(dim[0], dim[1]) ];
			
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
			
			surface_set_target(_drawingSurface);
				DRAW_CLEAR
				draw_surface(_ping[!bg], 0, 0);
			surface_reset_target();
			
			canvas.applySurface(_drawingSurface);
		}
	}
}
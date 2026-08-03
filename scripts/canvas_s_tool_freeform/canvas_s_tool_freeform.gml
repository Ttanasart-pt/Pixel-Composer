function canvas_s_tool_freeform() : canvas_s_tool() constructor {
	icon     = THEME.canvas_tools_freeform;
	tooltip  = "Freeform";
	hotkey   = new KeyCombination("D");
	isDrawer = true;
	
	mouse_holding   = false;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	
	freeform_shape  = [];
	freeform_points = [];
	
	freeform_algo   = 1;
	
	settings = [
		
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
		
		var _dim = surface_get_dimension(_drawingSurface);
		
		if(mouse_holding) {
			if(abs(mpx - mouse_pre_x) + abs(mpy - mouse_pre_y) >= 1) {
					
				surface_set_target(_drawingSurface);
					draw_line(round(mouse_pre_x - .5), round(mouse_pre_y - .5), round(mpx - .5), round(mpy - .5));
				surface_reset_target();
					
				mouse_pre_x = mpx;
				mouse_pre_y = mpy;
						
				array_push(freeform_shape, new __vec2(mpx, mpy) );
			}
				
			if(mouse_lrelease()) {
				surface_set_target(_drawingSurface);
					draw_line(round(mpx - .5), round(mpy - .5), round(freeform_shape[0].x - .5), round(freeform_shape[0].y - .5));
				surface_reset_target();
				
				var temp_surface = surface_create(_dim[0], _dim[1]);
				
				switch(freeform_algo) {
					case 0 : 
						if(array_length(freeform_shape) > 3) {
							var _triangles   = polygon_triangulate(freeform_shape, 1)[0];
								
							surface_set_target(temp_surface);
								DRAW_CLEAR 
								
								draw_set_color(c_white);
								draw_primitive_begin(pr_trianglelist);
									for( var i = 0, n = array_length(_triangles); i < n; i++ ) {
										var p0 = _triangles[i][0];
										var p1 = _triangles[i][1];
										var p2 = _triangles[i][2];
											
										draw_vertex(round(p0.x), round(p0.y));
										draw_vertex(round(p1.x), round(p1.y));
										draw_vertex(round(p2.x), round(p2.y));
									}							 
								draw_primitive_end();
								draw_surface_safe(_drawingSurface);
							surface_reset_target();
						}
						break;
						
					case 1: 
						var len = array_length(freeform_shape);
						freeform_points = array_create(len * 2);
						
						for( var i = 0; i < len; i++ ) {
							var p = freeform_shape[i];
							freeform_points[i * 2 + 0] = p.x;
							freeform_points[i * 2 + 1] = p.y;
						}
						
						freeform_points[len * 2 + 0] = freeform_shape[0].x;
						freeform_points[len * 2 + 1] = freeform_shape[0].y;
						
						surface_set_shader(temp_surface, sh_canvas_freeform_scanfill);
							shader_set_2( "dimension", _dim            );
							shader_set_f( "points",    freeform_points );
							shader_set_i( "pointAmo",  len + 1         );
							
							shader_set_c( "color",     ca_white        );
							
							draw_surface(_drawingSurface, 0, 0);
						surface_reset_shader();
						break;
				}
				
				surface_set_shader(_drawingSurface, sh_freeform_fill_cleanup);
					shader_set_2( "dimension", _dim );
					draw_surface(temp_surface, 0, 0);
				surface_reset_shader();
				
				surface_free(temp_surface);
				
				canvas.applySurface(_drawingSurface);
				mouse_holding = false;
			}
				
		} else if(mouse_lpress(focus)) {
			mouse_pre_x = mpx;
			mouse_pre_y = mpy;
					
			mouse_holding  = true;
			freeform_shape = [ new __vec2(mpx, mpy) ];
					
			surface_clear(_drawingSurface);
		}
	}
}
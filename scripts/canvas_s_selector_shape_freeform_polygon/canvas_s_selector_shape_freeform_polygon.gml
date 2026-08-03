function canvas_s_selector_shape_freeform_polygon() : canvas_s_tool() constructor {
	icon       = THEME.canvas_tools_freeform_polygon_selection;
	tooltip    = "Polygon Selector";
	hotkey     = new KeyCombination("S");
	isSelector = true;
	selecting  = false;
	
	mouse_holding = false;
	has_selection = false;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	
	freeform_drawing = false;
	freeform_shape   = [];
	freeform_points  = [];
	
	freeform_algo    = 1;
	
	selection_mask = undefined;
	
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
		var dim = surface_get_dimension(_drawingSurface);
		selecting = freeform_drawing;
		
		if(freeform_drawing) {
			selection_mask = surface_verify(selection_mask, dim[0], dim[1]);
			
			if(mouse_rpress(focus)) {
				freeform_drawing = false;
				return false;
			}
			
			if(DOUBLE_CLICK) {
				var temp_surface = surface_create(dim[0], dim[1]);
				has_selection    = array_length(freeform_shape) > 2;
				
				switch(freeform_algo) {
					case 0 :
						if(array_length(freeform_shape) >= 3) {
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
							surface_reset_target();
						}
						break;
						
					case 1: 
						var len = array_length(freeform_shape);
						freeform_points = array_create(len * 2);
						
						for( var i = 0; i < len; i++ ) {
							var p = freeform_shape[i];
							freeform_points[i * 2 + 0] = p.x+1;
							freeform_points[i * 2 + 1] = p.y+1;
						}
						
						freeform_points[len * 2 + 0] = freeform_shape[0].x+1;
						freeform_points[len * 2 + 1] = freeform_shape[0].y+1;
						
						surface_set_shader(temp_surface, sh_canvas_freeform_scanfill);
							shader_set_2( "dimension", dim             );
							shader_set_f( "points",    freeform_points );
							shader_set_i( "pointAmo",  len + 1         );
							
							shader_set_c( "color",     ca_white        );
							
							draw_surface(selection_mask, 0, 0);
						surface_reset_shader();
						break;
				}
				
				surface_set_shader(selection_mask, sh_freeform_fill_cleanup);
					shader_set_2( "dimension", dim );
					draw_surface(temp_surface, 0, 0);
				surface_reset_shader();
				
				surface_free(temp_surface);
				
				if(has_selection) canvas.createSelection(selection_mask);
				else              canvas.applySelection();
				freeform_drawing = false;
				return;
				
			} else if(mouse_lpress(focus)) {
				mouse_pre_x = mpx;
				mouse_pre_y = mpy;
						
				array_push(freeform_shape, new __vec2(mpx, mpy) );
			}
				
			surface_set_target(selection_mask);
				DRAW_CLEAR
				draw_set_color(c_white);
				
				var ox, oy, nx, ny;
				for( var i = 0, n = array_length(freeform_shape); i < n; i++ ) {
					var p = freeform_shape[i];
					nx = p.x;
					ny = p.y;
					
					if(i) draw_line(ox, oy, nx, ny);
					
					ox = nx;
					oy = ny;
				}
				
				if(n) draw_line(ox, oy, mpx, mpy);
			surface_reset_target();
			
		} else if(mouse_lpress(focus)) {
			mouse_pre_x = mpx;
			mouse_pre_y = mpy;
			
			freeform_drawing = true;
			has_selection    = false;
			freeform_shape   = [ new __vec2(mpx, mpy) ];
			
			surface_clear(selection_mask);
					
			selection_mask = surface_verify(selection_mask, dim[0], dim[1]);
			surface_clear(selection_mask);
		}
		
	}
	
	function drawOutline(_x, _y, _s) {
		if(freeform_drawing) draw_surface_ext_safe(selection_mask, _x, _y, _s, _s, 0, c_white, 1);
	}
}
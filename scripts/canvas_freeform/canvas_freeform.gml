function canvas_freeform_step(active, _x, _y, _s, _mx, _my, _draw) {
	var _dim = attributes.dimension;
	
	var _mmx = (_mx - _x) / _s;
	var _mmy = (_my - _y) / _s;
		
	if(mouse_holding) {
		if(abs(_mmx - mouse_pre_x) + abs(_mmy - mouse_pre_y) >= 1) {
				
			if(_draw) {
				surface_set_target(drawing_surface);
					draw_line(round(mouse_pre_x - .5), round(mouse_pre_y - .5), round(_mmx - .5), round(_mmy - .5));
				surface_reset_target();
			}
					
			mouse_pre_x = _mmx;
			mouse_pre_y = _mmy;
					
			array_push(freeform_shape, new __vec2(_mmx, _mmy) );
		}
			
		if(mouse_lrelease()) {
			surface_set_target(drawing_surface);
				draw_line(round(_mmx - .5), round(_mmy - .5), round(freeform_shape[0].x - .5), round(freeform_shape[0].y - .5));
			surface_reset_target();
			
			var temp_surface = surface_create(_dim[0], _dim[1]);
			
			switch(node.tool_attribute.freeform_algo) {
				case 0 : 
					if(array_length(freeform_shape) > 3) {
						var _triangles   = polygon_triangulate(freeform_shape, 1)[0];
							
						surface_set_target(temp_surface);
							DRAW_CLEAR 
							
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
							draw_surface_safe(drawing_surface);
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
					freeform_points[len * 2 + 1] = freeform_shape[1].y;
					
					surface_set_shader(temp_surface, sh_canvas_freeform_scanfill);
						shader_set_2( "dimension", _dim            );
						shader_set_f( "points",    freeform_points );
						shader_set_i( "pointAmo",  len + 1         );
						
						shader_set_c( "color",     draw_get_color() );
						
						draw_surface(drawing_surface, 0, 0);
					surface_reset_shader();
					break;
			}
			
			surface_set_shader(drawing_surface, sh_freeform_fill_cleanup);
				shader_set_2( "dimension", _dim );
				draw_surface_ext(temp_surface, 0, 0, 1, 1, 0, draw_get_color(), draw_get_alpha());
			surface_reset_shader();
			
			surface_free(temp_surface);
			mouse_holding = false;
		}
			
	} else if(mouse_lpress(active)) {
		mouse_pre_x = _mmx;
		mouse_pre_y = _mmy;
				
		mouse_holding  = true;
		freeform_shape = [ new __vec2(_mmx, _mmy) ];
		
		node.tool_pick_color(_mmx, _mmy);
				
		surface_clear(drawing_surface);
	}
}
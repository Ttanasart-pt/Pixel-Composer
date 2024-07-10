function canvas_freeform_step(active, _x, _y, _s, _mx, _my, _draw) { #region
	var _dim = attributes.dimension;
		
	var _mmx = (_mx - _x) / _s;
	var _mmy = (_my - _y) / _s;
		
	if(mouse_holding) {
		if(abs(_mmx - mouse_pre_x) + abs(_mmy - mouse_pre_y) >= 1) {
				
			if(_draw) {
				surface_set_target(drawing_surface);
					canvas_draw_line_brush(brush, round(mouse_pre_x - 0.5), round(mouse_pre_y - 0.5), round(_mmx - 0.5), round(_mmy - 0.5), true);
				surface_reset_target();
			}
					
			mouse_pre_x = _mmx;
			mouse_pre_y = _mmy;
					
			array_push(freeform_shape, new __vec2(_mmx, _mmy) );
		}
			
		if(mouse_release(mb_left)) {
					
			surface_set_target(drawing_surface);
				canvas_draw_line_brush(brush, _mmx, _mmy, freeform_shape[0].x, freeform_shape[0].y, true);
			surface_reset_target();
				
			if(array_length(freeform_shape) > 3) {
				var _triangles = polygon_triangulate(freeform_shape, 1)[0];
					
				var temp_surface = surface_create(_dim[0], _dim[1]);
					
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
					
				surface_set_shader(drawing_surface, sh_freeform_fill_cleanup);
					shader_set_f("dimension", _dim);
						
					draw_surface_ext(temp_surface, 0, 0, 1, 1, 0, draw_get_color(), draw_get_alpha());
				surface_reset_shader();
				
				surface_free(temp_surface);
			}
				
			mouse_holding = false;
		}
			
	} else if(mouse_press(mb_left, active)) {
		mouse_pre_x = _mmx;
		mouse_pre_y = _mmy;
				
		mouse_holding  = true;
		freeform_shape = [ new __vec2(_mmx, _mmy) ];
		
		node.tool_pick_color(_mmx, _mmy);
				
		surface_clear(drawing_surface);
	}
} #endregion
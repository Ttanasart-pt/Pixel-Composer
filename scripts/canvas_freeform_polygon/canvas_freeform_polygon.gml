function canvas_freeform_polygon_step(active, _x, _y, _s, _mx, _my, _draw) {
	var _dim = attributes.dimension;
	
	var _mmx = (_mx - _x) / _s;
	var _mmy = (_my - _y) / _s;
	
	if(freeform_drawing) {
		if(mouse_rpress(active)) {
			freeform_drawing = false;
			return false;
		}
		
		if(DOUBLE_CLICK) {
			var temp_surface = surface_create(_dim[0], _dim[1]);
			
			switch(node.tool_attribute.freeform_algo) {
				case 0 :
					if(array_length(freeform_shape) >= 3) {
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
						
						shader_set_c( "color",     draw_get_color() );
					surface_reset_shader();
					break;
			}
			
			surface_set_shader(drawing_surface, sh_freeform_fill_cleanup);
				shader_set_2( "dimension", _dim );
				draw_surface_ext(temp_surface, 0, 0, 1, 1, 0, draw_get_color(), draw_get_alpha());
			surface_reset_shader();
			
			surface_free(temp_surface);
			
			freeform_drawing = false;
			return true;
			
		} else if(mouse_lpress(active)) {
			mouse_pre_x = _mmx;
			mouse_pre_y = _mmy;
					
			array_push(freeform_shape, new __vec2(_mmx, _mmy) );
		}
			
	} else if(mouse_lpress(active)) {
		mouse_pre_x = _mmx;
		mouse_pre_y = _mmy;
				
		freeform_drawing = true;
		freeform_shape   = [ new __vec2(_mmx, _mmy) ];
		
		node.tool_pick_color(_mmx, _mmy);
				
		surface_clear(drawing_surface);
	}
	
	return false;
}

function canvas_freeform_polygon_draw_px(active, _x, _y, _s, _mx, _my, _draw) {
	if(!freeform_drawing) return;
	
	if(array_empty(freeform_shape)) return;
	
	var ox = 0;
	var oy = 0;
	
	var nx = 0;
	var ny = 0;
	
	var _mmx = round((_mx - _x) / _s - .5);
	var _mmy = round((_my - _y) / _s - .5);
	
	draw_set_color(COLORS._main_icon);
	for( var i = 0, n = array_length(freeform_shape); i < n; i++ ) {
		var _f = freeform_shape[i];
		nx = round(_f.x - .5);
		ny = round(_f.y - .5);
		
		if(i) draw_line(ox, oy, nx, ny);
		
		ox = nx;
		oy = ny;
	}
	
	draw_line(ox, oy, _mmx, _mmy);
}

function canvas_freeform_polygon_draw(active, _x, _y, _s, _mx, _my, _draw) {
	if(!freeform_drawing) return;
	
	if(array_empty(freeform_shape)) return;
	
	var ox = 0;
	var oy = 0;
	
	var nx = 0;
	var ny = 0;
	
	draw_set_color(COLORS._main_icon);
	for( var i = 0, n = array_length(freeform_shape); i < n; i++ ) {
		var _f = freeform_shape[i];
		nx = _x + _f.x * _s;
		ny = _y + _f.y * _s;
		
		if(i) draw_line(ox, oy, nx, ny);
		
		ox = nx;
		oy = ny;
	}
	
	draw_line(ox, oy, _mx, _my);
}
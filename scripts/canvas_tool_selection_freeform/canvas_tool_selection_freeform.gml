function canvas_tool_selection_freeform(_selector, _brush) : canvas_tool_selection(_selector) constructor {
	brush = _brush;
	
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	freeform_shape = [];
	
	function onStep(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		attributes = node.attributes;
		var _dim   = attributes.dimension;
		
		if(!selector.is_select_drag && mouse_press(mb_left, active)) {
			is_selecting = true;
			selection_sx = mouse_cur_x;
			selection_sy = mouse_cur_y;
					
			surface_free_safe(selection_mask);
		}
		
		if(is_selecting) {
			draw_set_color(c_white);
			canvas_freeform_step(active, _x, _y, _s, _mx, _my, false);
			
			if(mouse_release(mb_left)) {
				is_selecting = false;
				
				var _bbox = surface_get_bbox(drawing_surface);
				var sel_x = _bbox[0];
				var sel_y = _bbox[1];
				var sel_w = _bbox[2];
				var sel_h = _bbox[3];
				
				if(sel_w > 1 && sel_h > 1) {
					selection_mask = surface_verify(selection_mask, sel_w, sel_h);
					surface_set_target(selection_mask);
						DRAW_CLEAR
						draw_surface(drawing_surface, -sel_x, -sel_y);
					surface_reset_target();
				}
				
				surface_clear(drawing_surface);
				
				selector.createSelection(selection_mask, sel_x, sel_y, sel_w, sel_h);
				surface_free_safe(selection_mask);
			}
					
		}
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!is_selecting) return;
		
		var ox, oy, nx, ny;
					
		draw_set_color(c_white);
						
		for( var i = 0, n = array_length(freeform_shape); i < n; i++ ) {
			nx = _x + freeform_shape[i].x * _s;
			ny = _y + freeform_shape[i].y * _s;
						
			if(i) draw_line(ox, oy, nx, ny);
							
			ox = nx;
			oy = ny;
		}
	}
	
}
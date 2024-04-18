function canvas_tool_selection_freeform(selector, brush) : canvas_tool_selection(selector) constructor {
	
	self.brush = brush;
	
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	freeform_shape = [];
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
			
		attributes = node.attributes;
		var _dim   = attributes.dimension;
		
		if(is_selected) { onSelected(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); return; }
		
		if(!selector.is_select_drag && mouse_press(mb_left, active)) {
			is_selecting = true;
			selection_sx = mouse_cur_x;
			selection_sy = mouse_cur_y;
					
			surface_free_safe(selection_mask);
		}
		
		if(is_selecting) {
			var sel_x0, sel_y0, sel_x1, sel_y1;
			var sel_w = 1, sel_h = 1;
			
			draw_set_color(c_white);
			canvas_freeform_step(active, _x, _y, _s, _mx, _my, false);
			
			if(mouse_release(mb_left)) {
				is_selecting = false;
							
				sel_x0 = _dim[0];
				sel_y0 = _dim[1];
				sel_x1 = 0;
				sel_y1 = 0;
				
				for( var i = 0, n = array_length(freeform_shape); i < n; i++ ) {
					var _f = freeform_shape[i];
								
					sel_x0 = min(sel_x0, round(_f.x - 0.5));
					sel_y0 = min(sel_y0, round(_f.y - 0.5));
					sel_x1 = max(sel_x1, round(_f.x - 0.5));
					sel_y1 = max(sel_y1, round(_f.y - 0.5));
				}
				
				sel_w = sel_x1 - sel_x0 + 1;
				sel_h = sel_y1 - sel_y0 + 1;
							
				if(sel_w > 1 && sel_h > 1) {
					selection_mask = surface_verify(selection_mask, sel_w, sel_h);
					surface_set_target(selection_mask);
						DRAW_CLEAR
						draw_surface(drawing_surface, -sel_x0, -sel_y0);
					surface_reset_target();
				}
							
				surface_clear(drawing_surface);
				
				selector.createSelection(selection_mask, sel_x0, sel_y0, sel_w, sel_h);
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
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
}
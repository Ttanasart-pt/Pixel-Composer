function canvas_tool_selection_brush(_selector, _brush) : canvas_tool_selection(_selector) constructor {
	brush = _brush;
	brush_resizable = true;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = undefined;
	mouse_pre_draw_y = undefined;
	
	sel_x0 = 0;
	sel_y0 = 0;
	sel_x1 = 0;
	sel_y1 = 0;
	
	function onStep(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		attributes = node.attributes;
		var _dim   = attributes.dimension;
		
		if(!selector.is_select_drag && mouse_press(mb_left, active)) {
			selection_mask = surface_verify(selection_mask, _dim[0], _dim[1]);
			
			surface_set_shader(selection_mask, noone);
				canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y, true);
			surface_reset_shader();
				
			is_selecting = true;
			
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
			
			sel_x0 = mouse_cur_x - brush.brush_size;
			sel_y0 = mouse_cur_y - brush.brush_size;
			sel_x1 = mouse_cur_x + brush.brush_size;
			sel_y1 = mouse_cur_y + brush.brush_size;
		}
			
		if(is_selecting) {
			var _move = mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y;
			var _1stp = brush.brush_dist_min == brush.brush_dist_max && brush.brush_dist_min == 1;
				
			if(_move || !_1stp) {
				surface_set_target(selection_mask);
					BLEND_ADD
					if(_1stp) canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y, true);
					canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, true);
					BLEND_NORMAL
				surface_reset_target();
			}
				
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
			
			sel_x0 = min(sel_x0, mouse_cur_x - brush.brush_size);
			sel_y0 = min(sel_y0, mouse_cur_y - brush.brush_size);
			sel_x1 = max(sel_x1, mouse_cur_x + brush.brush_size);
			sel_y1 = max(sel_y1, mouse_cur_y + brush.brush_size);
				
			var _sel_w = sel_x1 - sel_x0;
			var _sel_h = sel_y1 - sel_y0;
				
			if(mouse_release(mb_left)) {
				var _sel = surface_create(_sel_w, _sel_h);
				surface_set_shader(_sel);
					draw_surface(selection_mask, -sel_x0, -sel_y0);
				surface_reset_shader();
				
				is_selecting   = false;
				
				selector.createSelection(_sel, sel_x0, sel_y0, _sel_w, _sel_h);
				surface_free_safe(selection_mask);
			}
		}
			
		BLEND_NORMAL
			
		mouse_pre_x = mouse_cur_x;
		mouse_pre_y = mouse_cur_y;
			
	}
		
	function onDrawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
}
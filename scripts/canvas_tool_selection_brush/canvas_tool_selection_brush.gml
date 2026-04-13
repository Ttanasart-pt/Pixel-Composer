function canvas_tool_selection_brush() : canvas_selection_tool() constructor {
	brush_resizable = true;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = undefined;
	mouse_pre_draw_y = undefined;
	
	static onStep = function(hover, active, _x, _y, _s, _mx, _my) {
		attributes = node.attributes;
		var _dim   = attributes.dimension;
		
		if(!node.selection.selection_hovering && mouse_lpress(active)) {
			selection_mask = surface_verify(selection_mask, _dim[0], _dim[1]);
			
			surface_set_shader(selection_mask, sh_canvas_tool_selection_brush_mask);
				draw_set_color(c_white);
				brush.drawPoint(mouse_cur_x, mouse_cur_y, true);
			surface_reset_shader();
				
			is_selecting = true;
			
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
		}
			
		if(is_selecting) {
			var _move = mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y;
			var _1stp = brush.dist_min == brush.dist_max && brush.dist_min == 1;
				
			if(_move || !_1stp) {
				surface_set_shader(selection_mask, sh_canvas_tool_selection_brush_mask, false, BLEND.add);
					draw_set_color(c_white);
					if(_1stp) brush.drawPoint(mouse_cur_x, mouse_cur_y, true);
					brush.drawLine(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, true);
				surface_reset_shader();
			}
				
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
			
			if(mouse_lrelease()) {
				var _bbox = surface_get_bbox(selection_mask);
				var sel_x = _bbox[0];
				var sel_y = _bbox[1];
				var sel_w = _bbox[2];
				var sel_h = _bbox[3];
				
				if(sel_w > 1 && sel_h > 1) {
					var _sel = surface_create(sel_w, sel_h);
					surface_set_shader(_sel);
						draw_surface(selection_mask, -sel_x, -sel_y);
					surface_reset_shader();
					node.selection.createSelection(_sel, sel_x, sel_y, sel_w, sel_h);
					
				} else node.selection.apply();
				
				is_selecting = false;
				surface_free_safe(selection_mask);
			}
		}
			
		BLEND_NORMAL
			
		mouse_pre_x = mouse_cur_x;
		mouse_pre_y = mouse_cur_y;
			
	}
		
	static onDrawMask = function(hover, active, _x, _y, _s, _mx, _my) {
		if(node.selection.selection_hovering) return;
		
		var _dx = _x + mouse_cur_x * _s;
		var _dy = _y + mouse_cur_y * _s;
		
		brush.drawPointExt(_dx, _dy, _s);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my) {}
}
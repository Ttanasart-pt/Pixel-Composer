function canvas_tool_selection_shape(_selector, _shape) : canvas_selection_tool(_selector) constructor {
	shape       = _shape;
	select_snap = false;
	
	static onStep = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(is_selecting) {
			var sel_x0, sel_y0, sel_x1, sel_y1;
			var sel_w = 1, sel_h = 1;
			
			sel_x0 = min(selection_sx, mouse_cur_x);
			sel_y0 = min(selection_sy, mouse_cur_y);
			sel_x1 = max(selection_sx, mouse_cur_x);
			sel_y1 = max(selection_sy, mouse_cur_y);
				
    		if(select_snap) {
        		var _gridSize = PROJECT.previewGrid.size;
        		
        		sel_x0 = floor( sel_x0 / _gridSize[0] ) * _gridSize[0];
				sel_y0 = floor( sel_y0 / _gridSize[1] ) * _gridSize[1];
				sel_x1 = ceil(  sel_x1 / _gridSize[0] ) * _gridSize[0];
				sel_y1 = ceil(  sel_y1 / _gridSize[1] ) * _gridSize[1];
				
				sel_w = sel_x1 - sel_x0;
				sel_h = sel_y1 - sel_y0;
    			
    		} else {
				sel_w = sel_x1 - sel_x0 + 1;
				sel_h = sel_y1 - sel_y0 + 1;
    			
    		}
        	
			selection_mask = surface_verify(selection_mask, sel_w, sel_h);
			surface_set_target(selection_mask);
				DRAW_CLEAR
				draw_set_color(c_white);
				
				switch(shape) {
					case CANVAS_TOOL_SHAPE.rectangle : draw_rectangle(0, 0, sel_w, sel_h, false);              break;
					case CANVAS_TOOL_SHAPE.ellipse   : draw_ellipse_prec(-1, -1, sel_w - 1, sel_h - 1, false); break;
				}
			surface_reset_target();
			
			PANEL_PREVIEW.mouse_pos_string = $"[{sel_w}, {sel_h}]";
			
			selection_position[0] = sel_x0;
			selection_position[1] = sel_y0;
			selection_size[0]     = sel_w;
			selection_size[1]     = sel_h;
			
			if(mouse_release(mb_left)) {
				is_selecting = false;
				selector.createSelection(selection_mask, sel_x0, sel_y0, sel_w, sel_h);
				surface_free_safe(selection_mask);
			}
			
		} else if(!selector.selection_hovering && active) {
			if(mouse_press(mb_left)) {
				is_selecting = true;
				select_snap  = DOUBLE_CLICK && PROJECT.previewGrid.show;
				selection_sx = mouse_cur_x;
				selection_sy = mouse_cur_y;
				surface_free_safe(selection_mask);
			}
					
		}
	}
	
}
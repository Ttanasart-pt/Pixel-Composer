function canvas_tool_selection_magic(selector, toolAttr) : canvas_tool_selection(selector) constructor {
	 
	self.tool_attribute = toolAttr;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(is_selected) { onSelected(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); return; }
		
		var _thr		= tool_attribute.thres;
		var _fill_type	= tool_attribute.fill8;
		
		if(!selector.is_select_drag && mouse_press(mb_left, active)) {
			
			canvas_buffer = node.canvas_buffer;
			preview_index = node.preview_index;
		
			surface_w	= surface_get_width(_canvas_surface);
			surface_h	= surface_get_height(_canvas_surface);
			
			if(point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, surface_w - 1, surface_h - 1)) {
				var bb = [ 0, 0, surface_w, surface_h ];
				
				var _temp_surface = surface_create(surface_w, surface_h);
				draw_set_color(c_white);
				surface_set_target(_temp_surface);
					DRAW_CLEAR
				
					switch(_fill_type) {
						case 0 : bb = canvas_magic_selection_scanline(_canvas_surface, mouse_cur_x, mouse_cur_y, _thr, false); break;
						case 1 : bb = canvas_magic_selection_scanline(_canvas_surface, mouse_cur_x, mouse_cur_y, _thr, true);  break;
					}	
				
				surface_reset_target();
				
				var sel_x0 = bb[0];
				var sel_y0 = bb[1];
				var sel_x1 = bb[2];
				var sel_y1 = bb[3];
				var sel_w = 1, sel_h = 1;
				
				sel_w = sel_x1 - sel_x0 + 1;
				sel_h = sel_y1 - sel_y0 + 1;
				
				selection_mask = surface_verify(selection_mask, sel_w, sel_h);
				surface_set_target(selection_mask);
					DRAW_CLEAR
					draw_surface(_temp_surface, -sel_x0, -sel_y0);
				surface_reset_target();
				surface_free(_temp_surface);
				
				selector.createSelection(selection_mask, sel_x0, sel_y0, sel_w, sel_h);
				surface_free_safe(selection_mask);
				
				if(node.selection_tool_after != noone)
					node.selection_tool_after.toggle();
					node.selection_tool_after  = noone;
			}
		}
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		canvas_draw_point_size(brush, mouse_cur_x, mouse_cur_y);
	}
}
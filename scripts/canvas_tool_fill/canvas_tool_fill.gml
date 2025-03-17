function canvas_tool_fill(toolAttr) : canvas_tool() constructor {
	tool_attribute = toolAttr;
	
	relative = true;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _thr		= tool_attribute.thres;
		var _fill_type	= tool_attribute.fillType;
		var _use_output	= tool_attribute.useBG;
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		surface_w	= surface_get_width(canvas_surface);
		surface_h	= surface_get_height(canvas_surface);
		
		if(mouse_press(mb_left, active) && point_in_rectangle(mouse_cur_x, mouse_cur_y, 0, 0, surface_w - 1, surface_h - 1)) {
			node.storeAction();
			var _surf = _use_output? output_surface : canvas_surface;
			
			surface_set_target(canvas_surface);
				switch(_fill_type) {
					case 0 : 
					case 1 : canvas_flood_fill_scanline(_surf, mouse_cur_x, mouse_cur_y, _thr, _fill_type); break;
					case 2 : canvas_flood_fill_all(     _surf, mouse_cur_x, mouse_cur_y, _thr);             break;
				}
			surface_reset_target();
			
			node.surface_store_buffer();
		}
			
	}
}
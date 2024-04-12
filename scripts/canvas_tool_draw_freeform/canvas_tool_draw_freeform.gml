function canvas_tool_draw_freeform(brush) : canvas_tool() constructor {
	self.brush = brush;
	
	brush_resizable = true;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	
	freeform_shape = [];
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		attributes = node.attributes;
		
		canvas_freeform_step(active, _x, _y, _s, _mx, _my, true);
			
		if(mouse_release(mb_left))
			apply_draw_surface();
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		canvas_draw_point_size(brush, mouse_cur_x, mouse_cur_y);
	}
	
}
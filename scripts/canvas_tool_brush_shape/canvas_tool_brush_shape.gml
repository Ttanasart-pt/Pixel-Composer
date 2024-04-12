enum CANVAS_TOOL_SHAPE {
	rectangle,
	ellipse
}

function canvas_tool_shape(brush, shape) : canvas_tool() constructor {
	self.brush   = brush;
	self.shape   = shape;
	self.fill    = false;
	
	brush_resizable = true;
	mouse_holding   = false;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(mouse_holding && key_mod_press(SHIFT)) {
			var ww = mouse_cur_x - mouse_pre_x;
			var hh = mouse_cur_y - mouse_pre_y;
			var ss = max(abs(ww), abs(hh));
				
			mouse_cur_x = mouse_pre_x + ss * sign(ww);
			mouse_cur_y = mouse_pre_y + ss * sign(hh);
		}
			
		if(mouse_holding) {
			
			surface_set_shader(drawing_surface, noone);
			
				if(shape == CANVAS_TOOL_SHAPE.rectangle)
					canvas_draw_rect_size(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, fill);
					
				else if(shape == CANVAS_TOOL_SHAPE.ellipse)
					canvas_draw_ellp_size(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, fill);
					
			surface_reset_shader();
				
			if(mouse_release(mb_left)) {
				apply_draw_surface();
				mouse_holding = false;
			}
			
		} else if(mouse_press(mb_left, active)) {
			mouse_pre_x = mouse_cur_x;
			mouse_pre_y = mouse_cur_y;
				
			mouse_holding = true;
		}
			
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		if(!mouse_holding) {
			canvas_draw_point_size(brush, mouse_cur_x, mouse_cur_y);
			return;
		}
		
		if(shape == CANVAS_TOOL_SHAPE.rectangle)
			canvas_draw_rect_size(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, fill);
			
		if(shape == CANVAS_TOOL_SHAPE.ellipse)
			canvas_draw_ellp_size(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, fill); 
	}
	
}
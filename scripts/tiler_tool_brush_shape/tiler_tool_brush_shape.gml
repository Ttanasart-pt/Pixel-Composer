function tiler_tool_shape(_node, _brush, _shape) : tiler_tool(_node) constructor {
    self.brush = _brush;
    self.shape = _shape;
    
	brush_resizable = true;
	mouse_holding   = false;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = floor(round((_mx - _x) / _s - 0.5) / tile_size[0]);
		mouse_cur_y = floor(round((_my - _y) / _s - 0.5) / tile_size[1]);
		
		var _auto = brush.autoterrain;
		
		if(mouse_holding && key_mod_press(SHIFT)) {
			var ww = mouse_cur_x - mouse_pre_x;
			var hh = mouse_cur_y - mouse_pre_y;
			var ss = max(abs(ww), abs(hh));
				
			mouse_cur_x = mouse_pre_x + ss * sign(ww);
			mouse_cur_y = mouse_pre_y + ss * sign(hh);
		}
			
		if(mouse_holding) {
			
			node.reset_surface(drawing_surface);
			surface_set_target(drawing_surface);
				switch(shape) {
					case CANVAS_TOOL_SHAPE.rectangle : tiler_draw_rect_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, true); break;
					case CANVAS_TOOL_SHAPE.ellipse   : tiler_draw_ellp_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, true); break;
				}
			surface_reset_target();
				
			if(_auto != noone) {
				_auto.drawing_start(drawing_surface, false);
				switch(shape) {
					case CANVAS_TOOL_SHAPE.rectangle : tiler_draw_rect_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, true); break;
					case CANVAS_TOOL_SHAPE.ellipse   : tiler_draw_ellp_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, true); break;
				}
				_auto.drawing_end();
			}
					
			if(mouse_release(mb_left)) {
				mouse_holding = false;
				apply_draw_surface();
			}
			
		} else if(mouse_press(mb_left, active)) {
			mouse_pre_x = mouse_cur_x;
			mouse_pre_y = mouse_cur_y;
				
			node.storeAction();
			mouse_holding = true;
		}
			
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		if(!mouse_holding) {
			tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
			return;
		}
		
		switch(shape) {
			case CANVAS_TOOL_SHAPE.rectangle : tiler_draw_rect_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, true); break;
			case CANVAS_TOOL_SHAPE.ellipse   : tiler_draw_ellp_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, true); break;
		}   
	}
	
	static drawMask = function() {
	    draw_set_color(c_white);
	    tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
}
function tiler_tool_brush(node, _brush, eraser = false) : tiler_tool(node) constructor {
    self.brush = _brush;
    isEraser   = eraser;
	brush_resizable = true;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = undefined;
	mouse_pre_draw_y = undefined;
	
	mouse_holding = false;
	
	mouse_line_drawing = false;
	mouse_line_x0 = 0;
	mouse_line_y0 = 0;
	mouse_line_x1 = 0;
	mouse_line_y1 = 0;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		brush.brush_erase = isEraser;
		
		mouse_cur_x = floor(round((_mx - _x) / _s - 0.5) / tile_size[0]);
		mouse_cur_y = floor(round((_my - _y) / _s - 0.5) / tile_size[1]);
		
		var _auto = brush.autoterrain;
		
		if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_presses(SHIFT, CTRL)) {
			
			var _dx = mouse_cur_x - mouse_pre_draw_x;
			var _dy = mouse_cur_y - mouse_pre_draw_y;
			
			if(_dx != _dy) {
				var _ddx = _dx;
				var _ddy = _dy;
				
				if(abs(_dx) > abs(_dy)) {
					var _rat = round(_ddx / _ddy);
					_ddx = _ddy * _rat;
					
				} else if(abs(_dx) < abs(_dy)) {
					var _rat = round(_ddy / _ddx);
					_ddy = _ddx * _rat;
					
				}
				
				mouse_cur_x = mouse_pre_draw_x + _ddx - sign(_ddx);
				mouse_cur_y = mouse_pre_draw_y + _ddy - sign(_ddy);
			}
		}
			
		if(mouse_press(mb_left, active)) {
			
			surface_set_target(drawing_surface);
				tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
			surface_reset_target();
			
			if(_auto != noone) {
				_auto.drawing_start(drawing_surface, isEraser);
				tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y, false);
				_auto.drawing_end();
			}
					
			mouse_holding = true;
			if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) { 
				surface_set_target(drawing_surface);
					tiler_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
				surface_reset_target();
				
				if(_auto != noone) {
					_auto.drawing_start(drawing_surface, isEraser);
					tiler_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, false);
					_auto.drawing_end();
				}
				
				mouse_holding = false;
				apply_draw_surface();
			}
			
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
		}
		
		if(mouse_holding) {
			if(mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y) {
				surface_set_target(drawing_surface);
					tiler_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
				surface_reset_target();
				
				if(_auto != noone) {
					_auto.drawing_start(drawing_surface, isEraser);
					tiler_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, false);
					_auto.drawing_end();
				}
				
				apply_draw_surface();
			}
				
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
				
			if(mouse_release(mb_left)) {
				mouse_holding   = false;
				apply_draw_surface();
			}
		}
	    
		mouse_pre_x = mouse_cur_x;
		mouse_pre_y = mouse_cur_y;
		
	}
	
	function drawPreview() {
		mouse_line_drawing = false;
		
		if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) {
			
			tiler_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
			mouse_line_drawing = true;
			mouse_line_x0 = min(mouse_cur_x, mouse_pre_draw_x);
			mouse_line_y0 = min(mouse_cur_y, mouse_pre_draw_y);
			mouse_line_x1 = max(mouse_cur_x, mouse_pre_draw_x) + 1;
			mouse_line_y1 = max(mouse_cur_y, mouse_pre_draw_y) + 1;
			
		} else
			tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
	
	static drawMask = function() {
	    draw_set_color(c_white);
	    tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
}
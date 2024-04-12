function canvas_tool_brush(brush, eraser = false) : canvas_tool() constructor {
	self.brush = brush;
	isEraser   = eraser;
	
	brush_resizable = true;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = undefined;
	mouse_pre_draw_y = undefined;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT) && key_mod_press(CTRL)) {
			var aa = point_direction(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
			var dd = point_distance(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
			var _a = round(aa / 45) * 45;
			dd = dd * cos(degtorad(_a - aa));
				
			mouse_cur_x = mouse_pre_draw_x + lengthdir_x(dd, _a);
			mouse_cur_y = mouse_pre_draw_y + lengthdir_y(dd, _a);
		}
			
		if(mouse_press(mb_left, active)) {
			brush_next_dist = 0;
				
			surface_set_shader(drawing_surface, noone);
				canvas_draw_point_size(brush, mouse_cur_x, mouse_cur_y, true);
			surface_reset_shader();
				
			mouse_holding = true;
			if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) { ///////////////// shift line
				surface_set_shader(drawing_surface, noone, true, BLEND.alpha);
					brush_next_dist = 0;
					canvas_draw_line_size(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, true);
				surface_reset_shader();
				mouse_holding = false;
					
				apply_draw_surface();
			}
				
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
		}
			
		if(mouse_holding) {
			var _move = mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y;
			var _1stp = brush.brush_dist_min == brush.brush_dist_max && brush.brush_dist_min == 1;
				
			if(_move || !_1stp) {
				surface_set_shader(drawing_surface, noone, false, BLEND.alpha);
					if(_1stp) canvas_draw_point_size(brush, mouse_cur_x, mouse_cur_y, true);
					canvas_draw_line_size(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, true);
				surface_reset_shader();
			}
				
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
				
			if(mouse_release(mb_left)) {
				mouse_holding   = false;
				apply_draw_surface();
			}
		}
			
		BLEND_NORMAL;
			
		mouse_pre_x = mouse_cur_x;
		mouse_pre_y = mouse_cur_y;
			
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(isEraser) draw_set_color(c_white);
		
		if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) 
			canvas_draw_line_size(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
		else
			canvas_draw_point_size(brush, mouse_cur_x, mouse_cur_y);
	}
}
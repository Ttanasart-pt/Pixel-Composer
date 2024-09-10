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
	
	mouse_line_drawing = false;
	mouse_line_x0 = 0;
	mouse_line_y0 = 0;
	mouse_line_x1 = 0;
	mouse_line_y1 = 0;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
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
			
			surface_set_shader(drawing_surface, noone);
				canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y, true);
			surface_reset_shader();
				
			mouse_holding = true;
			if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) { ///////////////// shift line
				surface_set_shader(drawing_surface, noone, true, BLEND.alpha);
					canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, true);
				surface_reset_shader();
				mouse_holding = false;
					
				apply_draw_surface();
			}
			
			node.tool_pick_color(mouse_cur_x, mouse_cur_y);
				
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
		}
			
		if(mouse_holding) {
			var _move = mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y;
			var _1stp = brush.brush_dist_min == brush.brush_dist_max && brush.brush_dist_min == 1;
				
			if(_move || !_1stp) {
				surface_set_shader(drawing_surface, noone, false, BLEND.alpha);
					if(_1stp) canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y, true);
					canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, true);
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
		
		mouse_line_drawing = false;
		//print($"Drawing {mouse_cur_x}, {mouse_cur_y}, [{draw_get_color()}, {draw_get_alpha()}] {surface_get_target()}");
		
		if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) {
			
			canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y);
			mouse_line_drawing = true;
			mouse_line_x0 = min(mouse_cur_x, mouse_pre_draw_x);
			mouse_line_y0 = min(mouse_cur_y, mouse_pre_draw_y);
			mouse_line_x1 = max(mouse_cur_x, mouse_pre_draw_x) + 1;
			mouse_line_y1 = max(mouse_cur_y, mouse_pre_draw_y) + 1;
			
		} else
			canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!mouse_line_drawing) return;
		if(brush.brush_sizing)  return;
		if(!node.attributes.show_slope_check)  return;
		
		var _x0 = _x + mouse_line_x0 * _s;
		var _y0 = _y + mouse_line_y0 * _s;
		var _x1 = _x + mouse_line_x1 * _s;
		var _y1 = _y + mouse_line_y1 * _s;
		
		var _w  = mouse_line_x1 - mouse_line_x0;
		var _h  = mouse_line_y1 - mouse_line_y0;
		var _as = max(_w, _h) % min(_w, _h) == 0;
		
		draw_set_alpha(0.5);
		draw_set_color(_as? COLORS._main_value_positive : COLORS._main_accent);
		draw_rectangle(_x0, _y0, _x1, _y1, true);
		
		draw_set_text(f_p3, fa_center, fa_top);
		draw_text((_x0 + _x1) / 2, _y1 + 8, _w);
		
		draw_set_text(f_p3, fa_left, fa_center);
		draw_text(_x1 + 8, (_y0 + _y1) / 2, _h);
		draw_set_alpha(1);
	}
}
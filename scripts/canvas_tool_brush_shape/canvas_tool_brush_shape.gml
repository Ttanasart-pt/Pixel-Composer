enum CANVAS_TOOL_SHAPE {
	rectangle,
	ellipse
}

function canvas_tool_shape(brush, shape) : canvas_tool() constructor {
	self.brush   = brush;
	self.shape   = shape;
	
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
				switch(shape) {
					case CANVAS_TOOL_SHAPE.rectangle : canvas_draw_rect_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
					case CANVAS_TOOL_SHAPE.ellipse   : canvas_draw_ellp_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
				}
			surface_reset_shader();
				
			if(mouse_release(mb_left)) {
				apply_draw_surface();
				mouse_holding = false;
			}
			
		} else if(mouse_press(mb_left, active)) {
			mouse_pre_x = mouse_cur_x;
			mouse_pre_y = mouse_cur_y;
				
			mouse_holding = true;
			
			node.tool_pick_color(mouse_cur_x, mouse_cur_y);
		}
			
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		if(!mouse_holding) {
			canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
			return;
		}
		
		switch(shape) {
			case CANVAS_TOOL_SHAPE.rectangle : canvas_draw_rect_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
			case CANVAS_TOOL_SHAPE.ellipse   : canvas_draw_ellp_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
		}   
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!mouse_holding)      return;
		if(brush.brush_sizing)  return;
		if(!node.attributes.show_slope_check)  return;
		
		var mx0 = min(mouse_cur_x, mouse_pre_x);
		var mx1 = max(mouse_cur_x, mouse_pre_x) + 1;
		var my0 = min(mouse_cur_y, mouse_pre_y);
		var my1 = max(mouse_cur_y, mouse_pre_y) + 1;
		
		var _w  = mx1 - mx0;
		var _h  = my1 - my0;
		
		var _x0 = _x + mx0 * _s;
		var _y0 = _y + my0 * _s;
		var _x1 = _x + mx1 * _s;
		var _y1 = _y + my1 * _s;
		
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
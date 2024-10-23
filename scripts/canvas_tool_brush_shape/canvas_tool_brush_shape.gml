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
	
	draw_w = 1;
	draw_h = 1;
	
	function draw_point_wrap(_draw = true) {
		var _oxn = mouse_cur_tx - brush.brush_range < 0;
		var _oxp = mouse_cur_tx + brush.brush_range > draw_w;
		var _oyn = mouse_cur_ty - brush.brush_range < 0;
		var _oyp = mouse_cur_ty + brush.brush_range > draw_h;
		
		if(brush.tileMode & 0b01) {
			     if(_oxn) canvas_draw_point_brush(brush, draw_w + mouse_cur_tx, mouse_cur_ty, _draw);
			else if(_oxp) canvas_draw_point_brush(brush, mouse_cur_tx - draw_w, mouse_cur_ty, _draw);
		}
		
		if(brush.tileMode & 0b10) {
			     if(_oyn) canvas_draw_point_brush(brush, mouse_cur_tx, draw_h + mouse_cur_ty, _draw);
			else if(_oyp) canvas_draw_point_brush(brush, mouse_cur_tx, mouse_cur_ty - draw_h, _draw);
		}
		
		if(brush.tileMode == 0b11) {
			     if(_oxn && _oyn) canvas_draw_point_brush(brush, draw_w + mouse_cur_tx, draw_h + mouse_cur_ty, _draw);
			else if(_oxn && _oyp) canvas_draw_point_brush(brush, draw_w + mouse_cur_tx, mouse_cur_ty - draw_h, _draw);
			
			else if(_oxp && _oyn) canvas_draw_point_brush(brush, mouse_cur_tx - draw_w, draw_h + mouse_cur_ty, _draw);
			else if(_oxp && _oyp) canvas_draw_point_brush(brush, mouse_cur_tx - draw_w, mouse_cur_ty - draw_h, _draw);
		}
		
		canvas_draw_point_brush(brush, mouse_cur_tx, mouse_cur_ty, _draw);
	}
	
	function draw_shape() {
		var _x0 = min(mouse_pre_x, mouse_cur_x);
		var _x1 = max(mouse_pre_x, mouse_cur_x);
		var _y0 = min(mouse_pre_y, mouse_cur_y);
		var _y1 = max(mouse_pre_y, mouse_cur_y);
		
		var _x0b = _x0 - brush.brush_range;
		var _x1b = _x1 + brush.brush_range;
		var _y0b = _y0 - brush.brush_range;
		var _y1b = _y1 + brush.brush_range;
		
		var _bx0 = floor(_x0b / draw_w);
		var _bx1 = floor(_x1b / draw_w);
		var _by0 = floor(_y0b / draw_h);
		var _by1 = floor(_y1b / draw_h);
		
		var _drawFn = canvas_draw_rect_brush;
		
		switch(shape) {
			case CANVAS_TOOL_SHAPE.rectangle : _drawFn = canvas_draw_rect_brush; break;
			case CANVAS_TOOL_SHAPE.ellipse   : _drawFn = canvas_draw_ellp_brush; break;
		}
		
		if(brush.tileMode == 0) {
			_drawFn(brush, _x0, _y0, _x1, _y1, subtool);
			return;
		}
		
		var _x0t = safe_mod(_x0, draw_w, MOD_NEG.wrap); 
		var _x1t = _x1 + (_x0t - _x0); 
		var _y0t = safe_mod(_y0, draw_w, MOD_NEG.wrap); 
		var _y1t = _y1 + (_y0t - _y0); 
		
		if(_bx0 == _bx1 && _by0 == _by1) {
			_drawFn(brush, _x0t, _y0t, _x1t, _y1t, subtool); 
			return;
		}
		
		_drawFn(brush, _x0t, _y0t, _x1t, _y1t, subtool); 
		
		if(brush.tileMode & 0b01) {
			_drawFn(brush, _x0t + draw_w, _y0t, _x1t + draw_w, _y1t, subtool); 
			_drawFn(brush, _x0t - draw_w, _y0t, _x1t - draw_w, _y1t, subtool); 
		}
		
		if(brush.tileMode & 0b10) {
			_drawFn(brush, _x0t, _y0t + draw_h, _x1t, _y1t + draw_h, subtool); 
			_drawFn(brush, _x0t, _y0t - draw_h, _x1t, _y1t - draw_h, subtool); 
		}
		
		if(brush.tileMode & 0b11) {
			_drawFn(brush, _x0t + draw_w, _y0t + draw_h, _x1t + draw_w, _y1t + draw_h, subtool); 
			_drawFn(brush, _x0t + draw_w, _y0t - draw_h, _x1t + draw_w, _y1t - draw_h, subtool); 
			
			_drawFn(brush, _x0t - draw_w, _y0t + draw_h, _x1t - draw_w, _y1t + draw_h, subtool); 
			_drawFn(brush, _x0t - draw_w, _y0t - draw_h, _x1t - draw_w, _y1t - draw_h, subtool); 
		}
	}
	
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
			
		mouse_cur_tx = mouse_cur_x;
		mouse_cur_ty = mouse_cur_y;
		draw_w = surface_get_width(drawing_surface);
		draw_h = surface_get_height(drawing_surface);
		
		if(brush.tileMode & 0b01) mouse_cur_tx = safe_mod(mouse_cur_tx, draw_w, MOD_NEG.wrap); 
		if(brush.tileMode & 0b10) mouse_cur_ty = safe_mod(mouse_cur_ty, draw_h, MOD_NEG.wrap); 
		
		if(mouse_holding) {
			
			surface_set_shader(drawing_surface, noone);
				draw_shape();
			surface_reset_shader();
				
			if(mouse_release(mb_left)) {
				apply_draw_surface();
				mouse_holding = false;
			}
			
		} else if(mouse_press(mb_left, active)) {
				
			mouse_holding = true;
			
			mouse_pre_x = mouse_cur_x;
			mouse_pre_y = mouse_cur_y;
			
			node.tool_pick_color(mouse_cur_x, mouse_cur_y);
		}
			
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		if(!mouse_holding) {
			draw_point_wrap(false);
			return;
		}
		
		draw_shape();
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
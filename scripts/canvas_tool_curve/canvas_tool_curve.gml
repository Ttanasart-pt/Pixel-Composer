function canvas_tool_curve_bezier() : canvas_tool() constructor {
	brush_resizable = true;
	drawBrushMask   = false;
	
	anchors = [];
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	editing = [ noone, 0 ];
	
	mouse_edit_mx = 0;
	mouse_edit_my = 0;
	mouse_edit_sx = 0;
	mouse_edit_sy = 0;
	
	mouse_hovering = [ noone, 0 ];
		
	static clear = function() {
		anchors = [];
		editing = [ noone, 0 ];
		surface_clear(drawing_surface);
	}
	
	static init      = function() /*=>*/ { clear();   }
	static apply     = function() /*=>*/ { apply_draw_surface(); disable(); }
	static cancel    = function() /*=>*/ { disable(); }
	static onDisable = function() /*=>*/ { clear();   }
	
	////- Draw
	
	static step = function(hover, active, _x, _y, _s, _mx, _my) {
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(editing[0] != noone) {
			updated = true;
			
			var _a  = anchors[editing[0]];
			var _dx = mouse_cur_x - mouse_edit_mx;
			var _dy = mouse_cur_y - mouse_edit_my;
			
			if(editing[1] == 0) {
				_a[2] += _dx;
				_a[3] += _dy;
				
			} else if(editing[1] == -1) {
				_a[0] += _dx;
				_a[1] += _dy;
				
				_a[4] -= _dx;
				_a[5] -= _dy;
				
			} else if(editing[1] == 1) {
				_a[0] -= _dx;
				_a[1] -= _dy;
				
				_a[4] += _dx;
				_a[5] += _dy;
				
			}
			
			mouse_edit_mx = mouse_cur_x;
			mouse_edit_my = mouse_cur_y;
			
			if(mouse_lrelease())
				editing[0] = noone;
		}
		
		if(mouse_lpress(active)) {
			recordAction(ACTION_TYPE.var_modify, self, [ array_clone(anchors), "anchors" ]);
			
			if(mouse_hovering[0] == noone) {
				array_push(anchors, [ 0, 0, mouse_cur_x, mouse_cur_y, 0, 0 ]);
				editing[0] = array_length(anchors) - 1;
				editing[1] = 1;
				
			} else {
				if(key_mod_press(SHIFT))
					array_delete(anchors, mouse_hovering[0], 1);
				else {
					editing[0] = mouse_hovering[0];
					editing[1] = mouse_hovering[1];
				}
			}
			
			mouse_edit_mx = mouse_cur_x;
			mouse_edit_my = mouse_cur_y;
			mouse_edit_sx = mouse_cur_x;
			mouse_edit_sy = mouse_cur_y;
		} 
		
		var _1px = brush.draw_type == BRUSH_DRAW_TYPE.line && !brush.use_surface && brush.dist_min == brush.dist_max && brush.dist_min == 1;
		var _prc = 32;
		var _st  = 1 / _prc;
		
		surface_set_shader(drawing_surface, noone);
			var ox, oy, nx, ny;
			var oax1, oay1, nax0, nay0;
			
			for (var i = 0, n = array_length(anchors); i < n; i++) {
				nx = anchors[i][2];
				ny = anchors[i][3];
				
				nax0 = nx + anchors[i][0];
				nay0 = ny + anchors[i][1];
				
				if(i) {
					var _ox, _oy, _nx, _ny;
					
					var _x0  = ox;
					var _y0  = oy;
					var _cx0 = oax1;
					var _cy0 = oay1;
					var _cx1 = nax0;
					var _cy1 = nay0;
					var _x1  = nx;
					var _y1  = ny;
					
					_ox  = ox;
					_oy  = oy;
					
					for (var j = 1; j <= _prc; j++) {
						var _t  = _st * j;
						var _t1 = 1 - _t;
						
						_nx =     _t1 * _t1 * _t1 *  _x0 + 
						      3 * _t1 * _t1 * _t  * _cx0 + 
						      3 * _t1 * _t  * _t  * _cx1 + 
						          _t  * _t  * _t  *  _x1;
						     
						_ny =     _t1 * _t1 * _t1 *  _y0 + 
						      3 * _t1 * _t1 * _t  * _cy0 + 
						      3 * _t1 * _t  * _t  * _cy1 + 
						          _t  * _t  * _t  *  _y1;
						
						var dist = point_distance(_ox, _oy, _nx, _ny);
						
						if(dist > 3 || j == _prc) {
							if(_1px) {
								if(brush.size == 1)
									draw_line(_ox - 1, _oy - 1, _nx - 1, _ny - 1);
								else 
									draw_line_round(_ox - 1, _oy - 1, _nx - 1, _ny - 1, brush.size);
							} else 
								brush.drawLine(_ox, _oy, _nx, _ny, false, true);
								
							_ox = _nx;
							_oy = _ny;
							
						}
					}	
					// drawCurve(ox, oy, oax1, oay1, nax0, nay0, nx, ny, false);
				}
				
				oax1 = nx + anchors[i][4];
				oay1 = ny + anchors[i][5];
				
				ox = nx;
				oy = ny;
			}
			
		surface_reset_shader();
		
		if(key_press(vk_enter))  apply();
		if(key_press(vk_escape)) disable();
		
		pactive     = active;
	}
	
	static drawPostOverlay = function(hover, active, _x, _y, _s, _mx, _my) {
		var ox, oy, nx, ny, ax0, ay0, ax1, ay1;
		var oax1, oay1, nax0, nay0;
		
		draw_set_color(COLORS._main_icon);
		for (var i = 0, n = array_length(anchors); i < n; i++) {
			nx = _x + anchors[i][2]  * _s;
			ny = _y + anchors[i][3]  * _s;
			
			nax0 = nx + anchors[i][0] * _s;
			nay0 = ny + anchors[i][1] * _s;
			
			if(i) draw_curve_bezier(ox, oy, oax1, oay1, nax0, nay0, nx, ny);
			
			oax1 = nx + anchors[i][4] * _s;
			oay1 = ny + anchors[i][5] * _s;
			
			draw_line(nx, ny, nax0, nay0);
			draw_line(nx, ny, oax1, oay1);
			
			ox = nx;
			oy = ny;
		}
		
		var _hovInd = mouse_hovering[0];
		var _hovTyp = mouse_hovering[1];
		mouse_hovering = [ noone, 0 ];
		
		for (var i = 0, n = array_length(anchors); i < n; i++) {
			nx = _x + anchors[i][2] * _s;
			ny = _y + anchors[i][3] * _s;
			
			ax0 = nx + anchors[i][0] * _s;
			ay0 = ny + anchors[i][1] * _s;
			
			ax1 = nx + anchors[i][4] * _s;
			ay1 = ny + anchors[i][5] * _s;
			
			draw_anchor( 0,  nx,  ny, ui(7 + 2 * (_hovInd == i && _hovTyp ==  0)) );
			draw_anchor( 0, ax0, ay0, ui(5 + 2 * (_hovInd == i && _hovTyp == -1)) );
			draw_anchor( 0, ax1, ay1, ui(5 + 2 * (_hovInd == i && _hovTyp ==  1)) );
			
			     if(point_in_circle(_mx, _my, nx, ny,   ui(10))) mouse_hovering = [ i,  0 ];
			else if(point_in_circle(_mx, _my, ax0, ay0, ui(10))) mouse_hovering = [ i, -1 ];
			else if(point_in_circle(_mx, _my, ax1, ay1, ui(10))) mouse_hovering = [ i,  1 ];
		}
		
		var index = mouse_hovering[0] != noone? mouse_hovering[0] * 3 + mouse_hovering[1] + 1 : noone;
		if(mouse_hovering[0] == noone && editing[0] == noone) draw_anchor(0, _mx, _my, ui(7));
	}
	
	static drawCurve = function(x0, y0, cx0, cy0, cx1, cy1, x1, y1, _draw = false, prec = 32) { 
		var ox, oy, nx, ny;
		var odx, ody;
		var _st = 1 / prec;
		
		for (var i = 0; i <= prec; i++) {
			var _t  = _st * i;
			var _t1 = 1 - _t;
			
			nx =     _t1 * _t1 * _t1 *  x0 + 
			     3 * _t1 * _t1 * _t  * cx0 + 
			     3 * _t1 * _t  * _t  * cx1 + 
			         _t  * _t  * _t  *  x1;
			     
			ny =     _t1 * _t1 * _t1 *  y0 + 
			     3 * _t1 * _t1 * _t  * cy0 + 
			     3 * _t1 * _t  * _t  * cy1 + 
			         _t  * _t  * _t  *  y1;
			     
		    if(i) {
		    	var dist = point_distance(odx, ody, nx, ny);
		    	if(dist > 3 || i == prec) {
		    		brush.drawLine(odx, ody, nx, ny, _draw, true);
		    		odx = nx;
		    		ody = ny;
		    	}
		    	
		    } else {
		    	odx = nx;
		    	ody = ny;
		    }
			     
			ox = nx;
			oy = ny;
		}
	
	}
}
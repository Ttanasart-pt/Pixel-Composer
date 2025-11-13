function canvas_brush() constructor {
	#region data
		seed        = irandom_range(100000, 999999);
		node        = noone;
		draw_type   = 0;
		tileMode    = 0;
		colors      = [ c_white, c_black ];
	#endregion
	
	#region surface
		use_surface = false;
		surface     = noone;
		surface_w   = 1;
		surface_h   = 1;
		size        = 1;
		range       = 0;
	#endregion
	
	#region draw
		next_dist   = 0;
		dist_min    = 1;
		dist_max    = 1;
		
		direction   = 0;
		auto_rotate = false;
		random_dir  = [ 0, 0, 0, 0, 0 ];
		
		scatter     = 0;
		scatt_range = 0;
	#endregion
	
	#region actions
		sizing      = false;
		sizing_s    = 0;
		sizing_mx   = 0;
		sizing_my   = 0;
		sizing_dx   = 0;
		sizing_dy   = 0;
		
		mouse_pre_dir_x = undefined;
		mouse_pre_dir_y = undefined;
	#endregion
		
	static setSurface = function(_s) {
		surface     = _s;
		surface_w   = surface_get_width_safe(surface);
		surface_h   = surface_get_height_safe(surface);
		use_surface = is_surface(_s);
		
		range = use_surface? max(surface_w, surface_h) / 2 : ceil(size / 2);
	}
	
	static step = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var attr = node.tool_attribute;
		size = attr.size;
		
		if(PEN_USE && attr.pressure) 
			size = round(lerp(attr.pressure_size[0], attr.pressure_size[1], power(PEN_PRESSURE / 1024, 2)));
		
		if(!auto_rotate) 
			direction = 0;
			
		else if(mouse_pre_dir_x == undefined) {
			mouse_pre_dir_x = _mx;
			mouse_pre_dir_y = _my;
			
		} else if(point_distance(mouse_pre_dir_x, mouse_pre_dir_y, _mx, _my) > _s) {
			direction = point_direction(mouse_pre_dir_x, mouse_pre_dir_y, _mx, _my);
			mouse_pre_dir_x = _mx;
			mouse_pre_dir_y = _my;
		}
		
	}
	
	static doResize = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var attr = node.tool_attribute;
		var _siz = attr.size;
		
		if(sizing) {
			var s = sizing_s + (_mx - sizing_mx) / 16;
				s = max(1, s);
			attr.size = s;
			
			if(mouse_release(mb_right)) 
				sizing = false;
					
		} else if(mouse_press(mb_right, active) && key_mod_press(SHIFT) && surface == noone) {
			sizing    = true;
			sizing_s  = _siz;
			sizing_mx = _mx;
			sizing_my = _my;
			
			sizing_dx = round((_mx - _x) / _s - 0.5);
			sizing_dy = round((_my - _y) / _s - 0.5);
		}
	}
	
	////- Draw
	
	static drawPixel = function(_x, _y, _randomize = false) {
		if(use_surface) {
			var _r  = direction + rotation_random_eval(random_dir, seed);
			var _p  = point_rotate(-surface_w / 2, -surface_h / 2, 0, 0, _r);
				
			draw_surface_ext_safe(surface, round(_x + _p[0]), round(_y + _p[1]), 1, 1, _r, draw_get_color(), draw_get_alpha());
			return;
		} 
		
		if(size <= 1) 
			draw_point(_x, _y);
				
		else if(size < global.FIX_POINTS_AMOUNT) { 
			var fx = global.FIX_POINTS[size];
			for( var i = 0, n = array_length(fx); i < n; i++ )
				draw_point(_x + fx[i][0], _y + fx[i][1]);	
					
		} else
			draw_circle_prec(_x, _y, size / 2, 0);
	}
	
	static drawPoint = function(_x, _y, _randomize = false) {
		if(_randomize) seed = irandom_range(100000, 999999);
		random_set_seed(seed);
		
		if(scatter == 0) {
			drawPixel(_x, _y, _randomize);
			return;
		}
		
		var _amo = scatter >= 1? scatter : random(1) < scatter;
		repeat(_amo) {
			var _dis = random(scatt_range);
			var _dir = random(360);
			var _xx  = _x + lengthdir_x(_dis, _dir);
			var _yy  = _y + lengthdir_y(_dis, _dir);
			
			drawPixel(_xx, _yy, _randomize);
		}
	}
	
	static drawPointExt = function(_x, _y, _s = 1, _randomize = false) {
		if(use_surface) {
			var _sw = surface_get_width_safe(surface);
			var _sh = surface_get_height_safe(surface);
			var _r  = direction + rotation_random_eval(random_dir, seed);
			var _p  = point_rotate(-_sw / 2, -_sh / 2, 0, 0, _r);
				
			draw_surface_ext_safe(surface, round(_x + _p[0]), round(_y + _p[1]), _s, _s, _r, draw_get_color(), draw_get_alpha());
			if(_randomize) seed = irandom_range(100000, 999999);
			return;
		}
		
		if(size <= 1) 
			draw_rectangle(_x, _y, _x + _s, _y + _s, false);
				
		else if(size < global.FIX_POINTS_AMOUNT) { 
			var fx = global.FIX_POINTS[size];
			for( var i = 0, n = array_length(fx); i < n; i++ ) {
				var _xx = _x + fx[i][0] * _s;
				var _yy = _y + fx[i][1] * _s;
				
				draw_rectangle(_xx, _yy, _xx + _s, _yy + _s, false);	
			}
					
		} else
			draw_circle_prec(_x, _y, size / 2 * _s, 0);
		
	}
	
	static drawLine = function(_x0, _y0, _x1, _y1, _draw = false, _cap = false) { 
		if(use_surface || draw_type == 1) {
			var diss  = point_distance(_x0, _y0, _x1, _y1);
			var dirr  = point_direction(_x0, _y0, _x1, _y1);
			var st_x  = lengthdir_x(1, dirr);
			var st_y  = lengthdir_y(1, dirr);
				
			var _i   = _draw? next_dist : 0;
			var _dst = diss;
				
			if(_i < diss) {
				while(_i < diss) {
					var _px = _x0 + st_x * _i;
					var _py = _y0 + st_y * _i;
						
					drawPoint(_px, _py, _draw);
						
					next_dist = random_range(dist_min, dist_max);
					_i   += next_dist;
					_dst -= next_dist;
				}
				
				next_dist -= _dst;
			} else 
				next_dist -= diss;
				
			if(dist_min == dist_max && dist_min == 1)
				drawPoint(_x1, _y1, _draw);
			return;
			
		} 
		
		if(size < global.FIX_POINTS_AMOUNT) {
			if(_x1 > _x0) _x0--;
			if(_x1 < _x0) _x1--;
			
			if(_y1 > _y0) _y0--;
			if(_y1 < _y0) _y1--;
		}
			
		if(size == 1) {
			draw_line(_x0, _y0, _x1, _y1);
				
		} else if(size < global.FIX_POINTS_AMOUNT) { 
				
			var fx = global.FIX_POINTS[size];
			for( var i = 0, n = array_length(fx); i < n; i++ )
				draw_line(_x0 + fx[i][0], _y0 + fx[i][1], _x1 + fx[i][0], _y1 + fx[i][1]);	
					
		} else {
			draw_line_width(_x0, _y0, _x1, _y1, size);
			if(_cap) {
				drawPoint(_x0, _y0, true);
				drawPoint(_x1, _y1, true);
			}
		}
	}
			
	static drawRect = function(_x0, _y0, _x1, _y1, _fill) {
		if(_x0 == _x1 && _y0 == _y1) {
			drawPoint(_x0, _y0);
			return;
			
		} else if(_x0 == _x1) {
			drawPoint(_x0, _y0);
			drawPoint(_x1, _y1);
			drawLine(_x0, _y0, _x0, _y1);
			return;
			
		} else if(_y0 == _y1) {
			drawPoint(_x0, _y0);
			drawPoint(_x1, _y1);
			drawLine(_x0, _y0, _x1, _y0);
			return;
		}
			
		var _min_x = min(_x0, _x1);
		var _max_x = max(_x0, _x1);
		var _min_y = min(_y0, _y1);
		var _may_y = max(_y0, _y1);
			
		if(_fill) draw_rectangle(_min_x, _min_y, _max_x, _may_y, 0);
			
		if(size == 1 && !use_surface)
			draw_rectangle(_min_x + 1, _min_y + 1, _max_x - 1, _may_y - 1, 1);
		else {
			drawLine(_min_x, _min_y, _max_x, _min_y);
			drawLine(_min_x, _min_y, _min_x, _may_y);
			drawLine(_max_x, _may_y, _max_x, _min_y);
			drawLine(_max_x, _may_y, _min_x, _may_y);
		}
	}
		
	static drawEllipse = function(_x0, _y0, _x1, _y1,  _fill) {
		if(_x0 == _x1 && _y0 == _y1) {
			drawPoint(_x0, _y0);
			return;
			
		} else if(_x0 == _x1) {
			drawPoint(_x0, _y0);
			drawPoint(_x1, _y1);
			drawLine(_x0, _y0, _x0, _y1);
			return;
			
		} else if(_y0 == _y1) {
			drawPoint(_x0, _y0);
			drawPoint(_x1, _y1);
			drawLine(_x0, _y0, _x1, _y0);
			return;
		}
			
		draw_set_circle_precision(64);
		var _min_x = min(_x0, _x1) - 0.5;
		var _max_x = max(_x0, _x1) - 0.5;
		var _min_y = min(_y0, _y1) - 0.5;
		var _max_y = max(_y0, _y1) - 0.5;
		
		if(!use_surface) {
			if(_fill) draw_ellipse(_min_x, _min_y, _max_x, _max_y, 0);
			
			if(size == 1) {
				draw_ellipse(_min_x, _min_y, _max_x, _max_y, 1);
				
			} else if(size < global.FIX_POINTS_AMOUNT) {
				
				var fx = global.FIX_POINTS[size];
				for( var i = 0, n = array_length(fx); i < n; i++ )
					draw_ellipse(_min_x + fx[i][0], _min_y + fx[i][1], _max_x + fx[i][0], _max_y + fx[i][1], 1);
				
			} else {
				draw_ellipse(_min_x, _min_y, _max_x, _max_y, size);
				
			}
			return;
		}
		
		if(_fill) draw_ellipse(_min_x, _min_y, _max_x, _max_y, 0);
			
		var samp = 64;
		var cx = (_min_x + _max_x) / 2;
		var cy = (_min_y + _max_y) / 2;
		var rx = abs(_x0 - _x1) / 2;
		var ry = abs(_y0 - _y1) / 2;
				
		var ox, oy, nx, ny;
		for( var i = 0; i <= samp; i++ ) {
			nx = round(cx + lengthdir_x(rx, 360 / samp * i));
			ny = round(cy + lengthdir_y(ry, 360 / samp * i));
					
			if(i) drawLine(ox, oy, nx, ny);
					
			ox = nx;
			oy = ny;
		}
	}
	
	static drawCurve = function(x0, y0, cx0, cy0, cx1, cy1, x1, y1, prec = 32) { 
		var ox, oy, nx, ny;
		
		var _st = 1 / prec;
		
		for (var i = 0; i <= prec; i++) {
			var _t  = _st * i;
			var _t1 = 1 - _t;
			
			nx = _t1 * _t1 * _t1 * x0 + 
			     3 * (_t1 * _t1 * _t) * cx0 + 
			     3 * (_t1 * _t  * _t) * cx1 + 
			     _t * _t * _t * x1;
			     
			ny = _t1 * _t1 * _t1 * y0 + 
			     3 * (_t1 * _t1 * _t) * cy0 + 
			     3 * (_t1 * _t  * _t) * cy1 + 
			     _t * _t * _t * y1;
			     
		     if(i) drawLine(ox, oy, nx, ny, true, true);
			     
			ox = nx;
			oy = ny;
		}
	}

}
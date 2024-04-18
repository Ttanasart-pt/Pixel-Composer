function canvas_draw_point_brush(brush, _x, _y, _draw = false) { #region
	if(brush.brush_surface == noone) {
			
		if(brush.brush_size <= 1) 
			draw_point(_x, _y);
				
		else if(brush.brush_size < global.FIX_POINTS_AMOUNT) { 
			var fx = global.FIX_POINTS[brush.brush_size];
			for( var i = 0, n = array_length(fx); i < n; i++ )
				draw_point(_x + fx[i][0], _y + fx[i][1]);	
					
		} else
			draw_circle_prec(_x, _y, brush.brush_size / 2, 0);
				
	} else {
		var _sw = surface_get_width_safe(brush.brush_surface);
		var _sh = surface_get_height_safe(brush.brush_surface);
		var _r  = brush.brush_direction + angle_random_eval(brush.brush_rand_dir, brush.brush_seed);
		var _p  = point_rotate(-_sw / 2, -_sh / 2, 0, 0, _r);
			
		draw_surface_ext_safe(brush.brush_surface, _x + _p[0], _y + _p[1], 1, 1, _r, draw_get_color(), draw_get_alpha());
			
		if(_draw) brush.brush_seed = irandom_range(100000, 999999);
	}
} #endregion
	
function canvas_draw_line_brush(brush, _x0, _y0, _x1, _y1, _draw = false, _cap = false) { #region 
		
	if(brush.brush_surface == noone) {
			
		if(brush.brush_size < global.FIX_POINTS_AMOUNT) {
			if(_x1 > _x0) _x0--;
			if(_y1 > _y0) _y0--;
			if(_y1 < _y0) _y1--;
			if(_x1 < _x0) _x1--;
		}
			
		if(brush.brush_size == 1) {
			draw_line(_x0, _y0, _x1, _y1);
				
		} else if(brush.brush_size < global.FIX_POINTS_AMOUNT) { 
				
			var fx = global.FIX_POINTS[brush.brush_size];
			for( var i = 0, n = array_length(fx); i < n; i++ )
				draw_line(_x0 + fx[i][0], _y0 + fx[i][1], _x1 + fx[i][0], _y1 + fx[i][1]);	
					
		} else {
			draw_line_width(_x0, _y0, _x1, _y1, brush.brush_size);
			if(_cap) {
				canvas_draw_point_brush(brush, _x0, _y0, true);
				canvas_draw_point_brush(brush, _x1, _y1, true);
			}
		}
			
	} else {
		var diss  = point_distance(_x0, _y0, _x1, _y1);
		var dirr  = point_direction(_x0, _y0, _x1, _y1);
		var st_x  = lengthdir_x(1, dirr);
		var st_y  = lengthdir_y(1, dirr);
			
		var _i   = _draw? brush.brush_next_dist : 0;
		var _dst = diss;
			
		if(_i < diss) {
			while(_i < diss) {
				var _px = _x0 + st_x * _i;
				var _py = _y0 + st_y * _i;
					
				canvas_draw_point_brush(brush, _px, _py, _draw);
					
				brush.brush_next_dist = random_range(brush.brush_dist_min, brush.brush_dist_max);
				_i   += brush.brush_next_dist;
				_dst -= brush.brush_next_dist;
			}
			
			brush.brush_next_dist -= _dst;
		} else 
			brush.brush_next_dist -= diss;
			
		if(brush.brush_dist_min == brush.brush_dist_max && brush.brush_dist_min == 1)
			canvas_draw_point_brush(brush, _x1, _y1, _draw);
	}
} #endregion
	
function canvas_draw_rect_brush(brush, _x0, _y0, _x1, _y1, _fill) { #region
	if(_x0 == _x1 && _y0 == _y1) {
		canvas_draw_point_brush(brush, _x0, _y0);
		return;
		
	} else if(_x0 == _x1) {
		canvas_draw_point_brush(brush, _x0, _y0);
		canvas_draw_point_brush(brush, _x1, _y1);
		canvas_draw_line_brush(brush, _x0, _y0, _x0, _y1);
		return;
		
	} else if(_y0 == _y1) {
		canvas_draw_point_brush(brush, _x0, _y0);
		canvas_draw_point_brush(brush, _x1, _y1);
		canvas_draw_line_brush(brush, _x0, _y0, _x1, _y0);
		return;
	}
		
	var _min_x = min(_x0, _x1);
	var _max_x = max(_x0, _x1);
	var _min_y = min(_y0, _y1);
	var _may_y = max(_y0, _y1);
		
	if(_fill) draw_rectangle(_min_x, _min_y, _max_x, _may_y, 0);
		
	if(brush.brush_size == 1 && brush.brush_surface == noone)
		draw_rectangle(_min_x + 1, _min_y + 1, _max_x - 1, _may_y - 1, 1);
	else {
		canvas_draw_line_brush(brush, _min_x, _min_y, _max_x, _min_y);
		canvas_draw_line_brush(brush, _min_x, _min_y, _min_x, _may_y);
		canvas_draw_line_brush(brush, _max_x, _may_y, _max_x, _min_y);
		canvas_draw_line_brush(brush, _max_x, _may_y, _min_x, _may_y);
	}
} #endregion
	
function canvas_draw_ellp_brush(brush, _x0, _y0, _x1, _y1,  _fill) { #region
	if(_x0 == _x1 && _y0 == _y1) {
		canvas_draw_point_brush(brush, _x0, _y0);
		return;
		
	} else if(_x0 == _x1) {
		canvas_draw_point_brush(brush, _x0, _y0);
		canvas_draw_point_brush(brush, _x1, _y1);
		canvas_draw_line_brush(brush, _x0, _y0, _x0, _y1);
		return;
		
	} else if(_y0 == _y1) {
		canvas_draw_point_brush(brush, _x0, _y0);
		canvas_draw_point_brush(brush, _x1, _y1);
		canvas_draw_line_brush(brush, _x0, _y0, _x1, _y0);
		return;
	}
		
	draw_set_circle_precision(64);
	var _min_x = min(_x0, _x1) - 0.5;
	var _max_x = max(_x0, _x1) - 0.5;
	var _min_y = min(_y0, _y1) - 0.5;
	var _max_y = max(_y0, _y1) - 0.5;
	
	if(brush.brush_surface == noone) {
		if(_fill) draw_ellipse(_min_x, _min_y, _max_x, _max_y, 0);
		
		if(brush.brush_size == 1) {
			draw_ellipse(_min_x, _min_y, _max_x, _max_y, 1);
			
		} else if(brush.brush_size < global.FIX_POINTS_AMOUNT) {
			
			var fx = global.FIX_POINTS[brush.brush_size];
			for( var i = 0, n = array_length(fx); i < n; i++ )
				draw_ellipse(_min_x + fx[i][0], _min_y + fx[i][1], _max_x + fx[i][0], _max_y + fx[i][1], 1);
			
		} else {
			draw_ellipse(_min_x, _min_y, _max_x, _max_y, brush.brush_size);
			
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
				
		if(i) canvas_draw_line_brush(brush, ox, oy, nx, ny);
				
		ox = nx;
		oy = ny;
	}
} #endregion

function canvas_draw_curve_brush(brush, x0, y0, cx0, cy0, cx1, cy1, x1, y1, prec = 32) { #region 
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
		     
	     if(i) canvas_draw_line_brush(brush, ox, oy, nx, ny, true, true);
		     
		ox = nx;
		oy = ny;
	}
} #endregion
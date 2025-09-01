enum AREA_DISTRIBUTION {
	area,
	border
}

enum AREA_SCATTER {
	uniform,
	random
}

function area_get_bbox(area) {
	return [ area[0] - area[2], area[1] - area[3], area[0] + area[2], area[1] + area[3] ];
}

function area_get_random_point(area, distrib = AREA_DISTRIBUTION.area, scatter = AREA_SCATTER.random, index = 0, total = 1, seed = undefined) {
	if(total == 0) return [0, 0];
	
	var _sed    = seed ?? random_get_seed();
	var _area_x = array_safe_get_fast(area, 0);
	var _area_y = array_safe_get_fast(area, 1);
	var _area_w = array_safe_get_fast(area, 2);
	var _area_h = array_safe_get_fast(area, 3);
	var _area_t = array_safe_get_fast(area, 4);
	var xx = 0, yy = 0;
	
	index = safe_mod(index, total);
	
	switch(distrib) {
		case AREA_DISTRIBUTION.area : 
			if(scatter == AREA_SCATTER.uniform) {
				if(_area_t == AREA_SHAPE.rectangle) {
					
					var _col = ceil(sqrt(total));
					var _row = ceil(total / _col);
					
					var _iwid = _area_w * 2 / _col;
					var _ihig = _area_h * 2 / _row;
					
					var _irow = floor(index / _col);
					var _icol = safe_mod(index, _col);
					
					xx = _area_x - _area_w + (_icol + 0.5) * _iwid;
					yy = _area_y - _area_h + (_irow + 0.5) * _ihig;
					
				} else {
					if(index == 0) {
						xx = _area_x;
						yy = _area_y;
						break;
					}
					
					var _r = _area_w;
					var _a = _area_w / _area_h;
					
					var _tm = floor(total / (2 * pi));
					var _tn = ceil(sqrt(2 * _tm + 1 / 2) - 1 / 2);
					var _s  = _r / _tn;
					
					var _m = floor(index / (2 * pi));
					var _n = floor(sqrt(2 * _m + 1 / 2) - 1 / 2);
					
					var _sr = (_n + 1) * _s;
					var _tt = floor((_n * (_n + 1)) / 2 * pi * 2);
					var _sa = (index - _tt) / (min(total - _tt, floor((_n + 1) * 2 * pi)) - 1) * 360;
					
					xx = _area_x + lengthdir_x(_sr, _sa);
					yy = _area_y + lengthdir_y(_sr, _sa) / _a;
				}
				
			} else if(scatter == AREA_SCATTER.random) {
				if(_area_t == AREA_SHAPE.rectangle) {
					xx = _area_x + random_range_seed(-_area_w, _area_w, _sed++);
					yy = _area_y + random_range_seed(-_area_h, _area_h, _sed++);
					
				} else if(_area_t == AREA_SHAPE.elipse) {
					var rr = random(360);
					xx = _area_x + lengthdir_x(1, rr) * random_seed(_area_w, _sed++);
					yy = _area_y + lengthdir_y(1, rr) * random_seed(_area_h, _sed++);
					
				}
			}
			break;
		
		case AREA_DISTRIBUTION.border :
			if(scatter == AREA_SCATTER.uniform) {
				if(_area_t == AREA_SHAPE.rectangle) {
					var perimeter = _area_w * 4 + _area_h * 4;
					var d = perimeter / total;
					var l = perimeter * index / total;
					
					if(l <= _area_w * 2) {
						xx = _area_x - _area_w + l;
						yy = _area_y - _area_h;
						break;
					} l -= _area_w * 2;
					
					if(l <= _area_h * 2) {
						xx = _area_x + _area_w;
						yy = _area_y - _area_h + l;
						break;
					} l -= _area_h * 2;
					
					if(l <= _area_w * 2) {
						xx = _area_x + _area_w - l;
						yy = _area_y + _area_h;
						break;
					} l -= _area_w * 2;
					
					if(l <= _area_h * 2) {
						xx = _area_x - _area_w;
						yy = _area_y + _area_h - l;
						break;
					} l -= _area_h * 2;
					
				} else if(_area_t == AREA_SHAPE.elipse) {
					var rr = 360 * index / total;
					xx = _area_x + lengthdir_x(_area_w, rr);
					yy = _area_y + lengthdir_y(_area_h, rr);
				}
				
			} else if(scatter == AREA_SCATTER.random) {
				if(_area_t == AREA_SHAPE.rectangle) {
					var perimeter = _area_w * 2 + _area_h * 2;
					var i = random_seed(perimeter, _sed++);
					
					if(i < _area_w) {
						xx = _area_x + random_range_seed(-_area_w, _area_w, _sed++);
						yy = _area_y - _area_h;
						
					} else if(i < _area_w + _area_h) {
						xx = _area_x - _area_w;
						yy = _area_y + random_range_seed(-_area_h, _area_h, _sed++);
						
					} else if(i < _area_w * 2 + _area_h) {
						xx = _area_x + random_range_seed(-_area_w, _area_w, _sed++);
						yy = _area_y + _area_h;	
						
					} else {
						xx = _area_x + _area_w;
						yy = _area_y + random_range_seed(-_area_h, _area_h, _sed++);
					}
					
				} else if(_area_t == AREA_SHAPE.elipse) {
					var rr = random_seed(360, _sed++);
					xx = _area_x + lengthdir_x(_area_w, rr);
					yy = _area_y + lengthdir_y(_area_h, rr);
				}
			}
			break;
	}
	
	return [xx, yy];
}

function area_get_random_point_poisson(_area, _distance, _seed) {
	var _sed    = _seed ?? random_get_seed();
    var _area_x = array_safe_get_fast(_area, 0);
	var _area_y = array_safe_get_fast(_area, 1);
	var _area_w = array_safe_get_fast(_area, 2);
	var _area_h = array_safe_get_fast(_area, 3);
	var _area_t = array_safe_get_fast(_area, 4);

    var x0 = _area_x - _area_w;
    var y0 = _area_y - _area_h;
    var x1 = _area_x + _area_w;
    var y1 = _area_y + _area_h;
    var ww = _area_w * 2;
    var hh = _area_h * 2;
    var cs = floor(_distance / sqrt(2));

    var cell_nw = ceil(ww / cs) + 1;
    var cell_nh = ceil(hh / cs) + 1;
    
    var grid   = array_create(cell_nw * cell_nh, -1);
    var points = [];
    var active = [];
    
    random_set_seed(_sed);
    
    var i      = 0;
    var _p     = [ random_range(x0, x1), random_range(y0, y1) ];
    var cell_x = floor((_p[0] - x0) / cs);
    var cell_y = floor((_p[1] - y0) / cs);
    var cell   = cell_x + (cell_y * cell_nw);
    
    array_push(points, _p);
    array_push(active, _p);
    grid[cell] = i++;

    while (array_length(active)) {
        var j = random_range(0, array_length(active) - 1);
        var p = active[j];
        var found = false;

        repeat(32) {
            var _dir = random_range(0, 360);
            var _rad = random_range(_distance, _distance * 2);
            var _px  = p[0] + lengthdir_x(_rad, _dir);
            var _py  = p[1] + lengthdir_y(_rad, _dir);
            if (_px < x0 || _px > x1 || _py < y0 || _py > y1) continue;
            
            var cell_x = floor((_px - x0) / cs);
            var cell_y = floor((_py - y0) / cs);
            var cell   = cell_x + (cell_y * cell_nw);
            if (grid[cell] != -1) continue;
			
			var cull = false;
			for (var k = -1; k <= 1; k++)
            for (var l = -1; l <= 1; l++) {
                var _cell_x = cell_x + k;
                var _cell_y = cell_y + l;
                if (_cell_x < 0 || _cell_x >= cell_nw) continue;
                if (_cell_y < 0 || _cell_y >= cell_nh) continue;
                var _cell = _cell_x + (_cell_y * cell_nw);
                if (grid[_cell] != -1) {
                    var p2 = points[grid[_cell]];
                    if (point_distance(_px, _py, p2[0], p2[1]) < _distance) cull = true;
                }
            }
            
            if(cull) continue;
            
			var _p = [_px, _py];
            array_push(points, _p);
            array_push(active, _p);
            grid[cell] = i++;
            found      = true;
            break;
        }

        if (!found) array_delete(active, j, 1);
    }
    
    if(_area_t == AREA_SHAPE.elipse) {
    	for(var i = array_length(points) - 1; i >= 0; i--) {
    		var p  = points[i];
    		var px = p[0];
    		var py = p[1];
    		
    		var _dir = point_direction(_area_x, _area_y, px, py);
			var _epx = _area_x + lengthdir_x(_area_w, _dir);
			var _epy = _area_y + lengthdir_y(_area_h, _dir);
			
			if(point_distance(_area_x, _area_y, px, py) > point_distance(_area_x, _area_y, _epx, _epy))
				array_delete(points, i, 1);
    	}
    }

    return points;
}

function area_get_random_point_poisson_c(_area, _distance, _seed) {
	static MAX_POINT = 4096;
	var _sed = _seed ?? random_get_seed();
	
	var _sbuf = buffer_create(8 * 2 * MAX_POINT, buffer_fixed, 8); 
	var _args = buffer_create(1, buffer_grow, 1); 
	
	buffer_to_start(_args);
	buffer_write(_args, buffer_u64, buffer_get_address(_sbuf));
	
	buffer_write(_args, buffer_f64, array_safe_get_fast(_area, 0));
	buffer_write(_args, buffer_f64, array_safe_get_fast(_area, 1));
	buffer_write(_args, buffer_f64, array_safe_get_fast(_area, 2));
	buffer_write(_args, buffer_f64, array_safe_get_fast(_area, 3));
	buffer_write(_args, buffer_f64, array_safe_get_fast(_area, 4));
	
	buffer_write(_args, buffer_f64, max(_distance, 2));
	buffer_write(_args, buffer_f64, _seed);
	buffer_write(_args, buffer_f64, MAX_POINT);
	
	var _pointAmount = poisson_get_points(buffer_get_address(_args));
	if(_pointAmount >= MAX_POINT) noti_warning($"Scatter amount higher than max points ({MAX_POINT}) results may not be correct.");
	var _points      = array_create(_pointAmount);
	var i = 0;
	
	
	buffer_to_start(_sbuf);
	repeat(_pointAmount) {
		var p1 = buffer_read(_sbuf, buffer_f64);
		var p2 = buffer_read(_sbuf, buffer_f64);
		
		_points[i++] = [ p1, p2 ];
	}
	
	buffer_delete(_args);
	buffer_delete(_sbuf);
	
	return _points;
}

function area_point_in(_area, _x, _y) {
	var _area_x = _area[0];
	var _area_y = _area[1];
	var _area_w = _area[2];
	var _area_h = _area[3];
	var _area_t = _area[4];
	
	var _area_x0 = _area_x - _area_w;
	var _area_x1 = _area_x + _area_w;
	var _area_y0 = _area_y - _area_h;
	var _area_y1 = _area_y + _area_h;
	
	if(_area_t == AREA_SHAPE.rectangle)
		return point_in_rectangle(_x, _y, _area_x0, _area_y0, _area_x1, _area_y1);
		
	if(_area_t == AREA_SHAPE.elipse) {
		var _dir = point_direction(_area_x, _area_y, _x, _y);
		var _epx = _area_x + lengthdir_x(_area_w, _dir);
		var _epy = _area_y + lengthdir_y(_area_h, _dir);
		
		return point_distance(_area_x, _area_y, _x, _y) < point_distance(_area_x, _area_y, _epx, _epy);
	}
	
	return false;
}

function area_point_in_fallout(_area, _x, _y, _fall_distance) {
	if(_fall_distance == 0) return area_point_in(_area, _x, _y);
	
	var _area_x = _area[0];
	var _area_y = _area[1];
	var _area_w = _area[2];
	var _area_h = _area[3];
	var _area_t = _area[4];
	
	var _area_x0 = _area_x - _area_w;
	var _area_x1 = _area_x + _area_w;
	var _area_y0 = _area_y - _area_h;
	var _area_y1 = _area_y + _area_h;
	
	var _inn, _dst;
	
	if(_area_t == AREA_SHAPE.rectangle) {
		_inn = point_in_rectangle(_x, _y, _area_x0, _area_y0, _area_x1, _area_y1)
		_dst = min(	distance_to_line(_x, _y, _area_x0, _area_y0, _area_x1, _area_y0), 
					distance_to_line(_x, _y, _area_x0, _area_y1, _area_x1, _area_y1), 
					distance_to_line(_x, _y, _area_x0, _area_y0, _area_x0, _area_y1), 
					distance_to_line(_x, _y, _area_x1, _area_y0, _area_x1, _area_y1));
					
	} else if(_area_t == AREA_SHAPE.elipse) {
		var _dirr = point_direction(_area_x, _area_y, _x, _y);
		var _epx  = _area_x + lengthdir_x(_area_w, _dirr);
		var _epy  = _area_y + lengthdir_y(_area_h, _dirr);
		
		_inn = point_distance(_area_x, _area_y, _x, _y) < point_distance(_area_x, _area_y, _epx, _epy);
		_dst = point_distance(_x, _y, _epx, _epy);
	}
	
	var str = 0, 
	
	if(_dst <= _fall_distance) {
		var inf = _inn? .5 + _dst / _fall_distance * .5 : .5 - _dst / _fall_distance * .5;
		str = clamp(inf, 0., 1.);
		
	} else if(_inn)
		str = 1;
	
	return str;
}
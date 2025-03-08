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
	
	var in = false;
	
	if(_area_t == AREA_SHAPE.rectangle) {
		in = point_in_rectangle(_x, _y, _area_x0, _area_y0, _area_x1, _area_y1);
	} else if(_area_t == AREA_SHAPE.elipse) {
		var _dirr = point_direction(_area_x, _area_y, _x, _y);
		var _epx = _area_x + lengthdir_x(_area_w, _dirr);
		var _epy = _area_y + lengthdir_y(_area_h, _dirr);
		
		in = point_distance(_area_x, _area_y, _x, _y) < point_distance(_area_x, _area_y, _epx, _epy);
	}
	
	return in;
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
	
	var str = 0, in, _dst;
	
	if(_area_t == AREA_SHAPE.rectangle) {
		in = point_in_rectangle(_x, _y, _area_x0, _area_y0, _area_x1, _area_y1)
		_dst = min(	distance_to_line(_x, _y, _area_x0, _area_y0, _area_x1, _area_y0), 
					distance_to_line(_x, _y, _area_x0, _area_y1, _area_x1, _area_y1), 
					distance_to_line(_x, _y, _area_x0, _area_y0, _area_x0, _area_y1), 
					distance_to_line(_x, _y, _area_x1, _area_y0, _area_x1, _area_y1));
					
	} else if(_area_t == AREA_SHAPE.elipse) {
		var _dirr = point_direction(_area_x, _area_y, _x, _y);
		var _epx = _area_x + lengthdir_x(_area_w, _dirr);
		var _epy = _area_y + lengthdir_y(_area_h, _dirr);
		
		in   = point_distance(_area_x, _area_y, _x, _y) < point_distance(_area_x, _area_y, _epx, _epy);
		_dst = point_distance(_x, _y, _epx, _epy);
	}
	
	if(_dst <= _fall_distance) {
		var inf = in? 0.5 + _dst / _fall_distance : 0.5 - _dst / _fall_distance;
		str = clamp(inf, 0., 1.);
		
	} else if(in)
		str = 1;
	
	return str;
}
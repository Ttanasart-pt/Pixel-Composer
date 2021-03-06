enum AREA_DISTRIBUTION {
	area,
	border
}

enum AREA_SCATTER {
	uniform,
	random
}

function area_get_random_point(area, distrib, scatter, index = 0, total = 1) {
	if(total == 0) return [0, 0];
	
	var _area_x = array_safe_get(area, 0);
	var _area_y = array_safe_get(area, 1);
	var _area_w = array_safe_get(area, 2);
	var _area_h = array_safe_get(area, 3);
	var _area_t = array_safe_get(area, 4);
	var xx = 0, yy = 0;
	
	switch(distrib) {
		case AREA_DISTRIBUTION.area : 
			if(scatter == AREA_SCATTER.uniform) {
				var _col = ceil(sqrt(total));
				var _iwid = _area_w * 2 / _col;
				var _ihig = _area_h * 2 / _col;
	
				var _irow = floor(index / _col);
				var _icol = safe_mod(index, _col);
						
				xx = _area_x - _area_w + _icol * _iwid;
				yy = _area_y - _area_h + _irow * _ihig;
			} else if(scatter == AREA_SCATTER.random) {
				if(_area_t == AREA_SHAPE.rectangle) {
					xx = _area_x + random_range(-_area_w, _area_w);
					yy = _area_y + random_range(-_area_h, _area_h);
				} else {
					var rr = random(360);
					xx = _area_x + lengthdir_x(1, rr) * random(_area_w);
					yy = _area_y + lengthdir_y(1, rr) * random(_area_h);
				}
			}
			break;
		
		case AREA_DISTRIBUTION.border :
			if(scatter == AREA_SCATTER.uniform) {
				if(_area_t == AREA_SHAPE.rectangle) {
					var perimeter = _area_w * 2 + _area_h * 2;
					var i = perimeter * index / total;
					if(i < _area_w) {
						xx = _area_x + random_range(-_area_w, _area_w);
						yy = _area_y - _area_h;
					} else if(i < _area_w + _area_h) {
						xx = _area_x - _area_w;
						yy = _area_y + random_range(-_area_h, _area_h);
					} else if(i < _area_w * 2 + _area_h) {
						xx = _area_x + random_range(-_area_w, _area_w);
						yy = _area_y + _area_h;	
					} else {
						xx = _area_x + _area_w;
						yy = _area_y + random_range(-_area_h, _area_h);
					}
				} else {
					var rr = 360 * index / total;
					xx = _area_x + lengthdir_x(_area_w, rr);
					yy = _area_y + lengthdir_y(_area_h, rr);
				}
			} else if(scatter == AREA_SCATTER.random) {
				if(_area_t == AREA_SHAPE.rectangle) {
					var perimeter = _area_w * 2 + _area_h * 2;
					var i = random(perimeter);
					if(i < _area_w) {
						xx = _area_x + random_range(-_area_w, _area_w);
						yy = _area_y - _area_h;
					} else if(i < _area_w + _area_h) {
						xx = _area_x - _area_w;
						yy = _area_y + random_range(-_area_h, _area_h);
					} else if(i < _area_w * 2 + _area_h) {
						xx = _area_x + random_range(-_area_w, _area_w);
						yy = _area_y + _area_h;	
					} else {
						xx = _area_x + _area_w;
						yy = _area_y + random_range(-_area_h, _area_h);
					}
				} else {
					var rr = random(360);
					xx = _area_x + lengthdir_x(_area_w, rr);
					yy = _area_y + lengthdir_y(_area_h, rr);
				}
			}
			break;
	}
	
	return [xx, yy];
}
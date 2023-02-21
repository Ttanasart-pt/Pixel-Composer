#macro AREA_DEF [ 16, 16, 4, 4, AREA_SHAPE.rectangle ]

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

function area_get_random_point(area, distrib = AREA_DISTRIBUTION.area, scatter = AREA_SCATTER.random, index = 0, total = 1, _sed = 999) {
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
					xx = _area_x + random_range_seed(-_area_w, _area_w, _sed); _sed++;
					yy = _area_y + random_range_seed(-_area_h, _area_h, _sed); _sed++;
				} else {
					var rr = random_seed(360, _sed); _sed++;
					xx = _area_x + lengthdir_x(1, rr) * random_seed(_area_w, _sed); _sed++;
					yy = _area_y + lengthdir_y(1, rr) * random_seed(_area_h, _sed); _sed++;
				}
			}
			break;
		
		case AREA_DISTRIBUTION.border :
			if(scatter == AREA_SCATTER.uniform) {
				if(_area_t == AREA_SHAPE.rectangle) {
					var perimeter = _area_w * 2 + _area_h * 2;
					var i = perimeter * index / total;
					if(i < _area_w) {
						xx = _area_x + random_range_seed(-_area_w, _area_w, _sed); _sed++;
						yy = _area_y - _area_h;
					} else if(i < _area_w + _area_h) {
						xx = _area_x - _area_w;
						yy = _area_y + random_range_seed(-_area_h, _area_h, _sed); _sed++;
					} else if(i < _area_w * 2 + _area_h) {
						xx = _area_x + random_range_seed(-_area_w, _area_w, _sed); _sed++;
						yy = _area_y + _area_h;	
					} else {
						xx = _area_x + _area_w;
						yy = _area_y + random_range_seed(-_area_h, _area_h, _sed); _sed++;
					}
				} else {
					var rr = 360 * index / total;
					xx = _area_x + lengthdir_x(_area_w, rr);
					yy = _area_y + lengthdir_y(_area_h, rr);
				}
			} else if(scatter == AREA_SCATTER.random) {
				if(_area_t == AREA_SHAPE.rectangle) {
					var perimeter = _area_w * 2 + _area_h * 2;
					var i = random_seed(perimeter, _sed); _sed++;
					if(i < _area_w) {
						xx = _area_x + random_range_seed(-_area_w, _area_w, _sed); _sed++;
						yy = _area_y - _area_h;
					} else if(i < _area_w + _area_h) {
						xx = _area_x - _area_w;
						yy = _area_y + random_range_seed(-_area_h, _area_h, _sed); _sed++;
					} else if(i < _area_w * 2 + _area_h) {
						xx = _area_x + random_range_seed(-_area_w, _area_w, _sed); _sed++;
						yy = _area_y + _area_h;	
					} else {
						xx = _area_x + _area_w;
						yy = _area_y + random_range_seed(-_area_h, _area_h, _sed); _sed++;
					}
				} else {
					var rr = random_seed(360, _sed); _sed++;
					xx = _area_x + lengthdir_x(_area_w, rr);
					yy = _area_y + lengthdir_y(_area_h, rr);
				}
			}
			break;
	}
	
	return [xx, yy];
}
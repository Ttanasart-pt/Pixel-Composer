function draw_line_elbow_color(x0, y0, x1, y1, cx = noone, cy = noone, _s = 1, thick = 1, col1 = c_white, col2 = c_white, params = {}) {
	var extend    = params.extend;
    // var corner    = min(extend, params.corner);
    var corner    = params.corner;
	var type      = params.type;
	
	if(cx == noone) cx = (x0 + x1) / 2;
	if(cy == noone) cy = (y0 + y1) / 2;
	
	var _x0 = min(x0, x1);	
	var _x1 = max(x0, x1);
	var _y0 = min(y0, y1);	
	var _y1 = max(y0, y1);
	var th  = thick / 2;
	var inv = x1 <= x0;
	var rat = inv?  (_y1 == _y0? 0.5 : (cy - _y0) / (_y1 - _y0)) : 
					(_x1 == _x0? 0.5 : (cx - _x0) / (_x1 - _x0));
	var cm  = merge_color(col1, col2, clamp(rat, 0, 1));
	
	corner = min(corner, abs(x0 - x1) / 2 + 32, abs(y0 - y1) / 2);
	var sample = clamp(corner / 4, 1, 8);
	
	var iy  = sign(y1 - y0);
	var iy0 = sign(cy - y0);
	var iy1 = sign(y1 - cy);
	
	if(y0 != y1 && inv) {
		var xx0   = x0;
		var xx1   = x1;
		var corns = min(corner, 16 * _s); 
		corner = min(corner, abs(cy - y0) / 2, abs(cy - y1) / 2, abs(xx1 - xx0) / 2);
		
		if(type == LINE_STYLE.solid) {
			__draw_set_color(col1);	draw_line_width(x0, y0, xx0 - corns, y0, thick);
			__draw_set_color(col2);	draw_line_width(xx1 + corns, y1, x1, y1, thick);
		
			draw_line_width_color(xx0, y0 + corns * iy0, xx0, cy - corner * iy0, thick, col1,   cm);
			draw_line_width_color(xx0 - corner * sign(xx0 - xx1), cy, xx1 + corner * sign(xx0 - xx1), cy, thick,   cm,   cm);
			draw_line_width_color(xx1, cy + corner * iy1, xx1, y1 - corns * iy1, thick,   cm, col2);
			
			if(corns) {
				draw_corner(xx0 - corns, y0, xx0, y0, xx0, y0 + corns * iy0, thick, col1, sample);
				draw_corner(xx1, y1 - corns * iy1, xx1, y1, xx1 + corns, y1, thick, col2, sample);
			}
			
			if(corner) {	
				draw_corner(xx0, cy - corner * iy0, xx0, cy, xx0 - corner, cy, thick, cm, sample);
				draw_corner(xx1 + corner, cy, xx1, cy, xx1, cy + corner * iy1, thick, cm, sample);
			}
		} else {
			__draw_set_color(col1);	draw_line_width(x0, y0, xx0, y0, thick);
			__draw_set_color(col2);	draw_line_width(xx1, y1, x1, y1, thick);
		
			draw_line_dashed_color(xx0, y0, xx0, cy, thick, col1,   cm, 6 * _s);
			draw_line_dashed_color(xx0, cy, xx1, cy, thick,   cm,   cm, 6 * _s);
			draw_line_dashed_color(xx1, cy, xx1, y1, thick,   cm, col2, 6 * _s);
		}
	} else {
		if(type == LINE_STYLE.solid) {
			corner = min(corner, abs(y1 - y0) / 2, abs(x0 - cx), abs(x1 - cx), abs(x1 - x0) / 2);
			
			draw_line_width_color(x0, y0, cx - corner * sign(cx - x0), y0, thick, col1,   cm);
			draw_line_width_color(cx, y0 + corner * iy, cx, y1 - corner * iy, thick,   cm,   cm);
			draw_line_width_color(cx + corner * sign(x1 - cx), y1, x1, y1, thick,   cm, col2);
			
			if(corner) {
				draw_corner(cx - corner * sign(cx - x0), y0, cx, y0, cx, y0 + corner * iy, thick, cm, sample);
				draw_corner(cx, y1 - corner * iy, cx, y1, cx + corner * sign(x1 - cx), y1, thick, cm, sample);
			}
		} else {
			draw_line_dashed_color(x0, y0, cx, y0, thick, col1,   cm, 6 * _s);
			draw_line_dashed_color(cx, y0, cx, y1, thick,   cm,   cm, 6 * _s);
			draw_line_dashed_color(cx, y1, x1, y1, thick,   cm, col2, 6 * _s);
		}
	}
}

function draw_line_elbow_corner(x0, y0, x1, y1, _s = 1, thick = 1, col1 = c_white, col2 = c_white, params = {}) {
	var extend    = params.extend;
    var corner    = min(extend, params.corner);
	var type      = params.type;
	
	var sample = clamp(corner / 4, 1, 8);
	
	var rat  = abs(x0 - x1) / (abs(x0 - x1) + abs(y0 - y1));
	var colc = merge_color(col1, col2, rat);
	corner = min(corner, abs(x0 - x1), abs(y0 - y1));
	
	var sx = sign(x1 - x0);
	var sy = sign(y1 - y0);
	
	draw_line_round_color(x0, y0, x1 - corner * sx, y0, thick, col1, colc);
	draw_line_round_color(x1, y0 + corner * sy, x1, y1, thick, colc, col2);
	draw_corner(x1 - corner * sx, y0, x1, y0, x1, y0 + corner * sy, thick, colc, sample);
}

function point_to_elbow(mx, my, x0, y0, x1, y1, cx, cy, _s, _p = undefined) {
	var inv  = x1 <= x0;
	var xx0  = x0;
	var xx1  = x1;
	var dist = infinity;
		
	if(y0 != y1 && inv) {
		dist = point_closer(_p, dist, mx, my, xx0, y0, xx0, cy);
		dist = point_closer(_p, dist, mx, my, xx0, cy, xx1, cy);
		dist = point_closer(_p, dist, mx, my, xx1, cy, xx1, y1);
		return _p;
		
	} else {
		dist = point_closer(_p, dist, mx, my, cx, y0, cx, y1);
		dist = point_closer(_p, dist, mx, my, x0, y0, cx, y0);
		dist = point_closer(_p, dist, mx, my, cx, y1, x1, y1);
		return _p;
	}
}

function point_to_elbow_corner(mx, my, x0, y0, x1, y1, _p = undefined) {
	var dist = infinity;
	dist = point_closer(_p, dist, mx, my, x0, y0, x1, y0);
	dist = point_closer(_p, dist, mx, my, x1, y0, x1, y1);
	return _p;
}
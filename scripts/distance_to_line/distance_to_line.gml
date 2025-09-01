function point_to_line(_px, _py, _x0, _y0, _x1, _y1, _p = undefined) {
	var l2 = sqr(_x0 - _x1) + sqr(_y0 - _y1);
	if (l2 == 0) return [ _x0, _y0 ];
	
	var t = ((_px - _x0) * (_x1 - _x0) + (_py - _y0) * (_y1 - _y0)) / l2;
	    t = clamp(t, 0, 1);
	    
	_p ??= [ 0, 0 ];
	_p[@ 0] = lerp(_x0, _x1, t);
	_p[@ 1] = lerp(_y0, _y1, t);
	return _p;
}

function distance_to_line(_px, _py, _x0, _y0, _x1, _y1) {
	var l2 = sqr(_x0 - _x1) + sqr(_y0 - _y1);
	if (l2 == 0) return point_distance(_px, _py, _x0, _y0);
	  
	var t = ((_px - _x0) * (_x1 - _x0) + (_py - _y0) * (_y1 - _y0)) / l2;
	t = clamp(t, 0, 1);
	
	var dd = point_distance(_px, _py, _x0 + t * (_x1 - _x0), _y0 + t * (_y1 - _y0));
	return dd;
}

function distance_to_line_signed(_px, _py, _x0, _y0, _x1, _y1) {
	var l2 = sqr(_x0 - _x1) + sqr(_y0 - _y1);
	if (l2 == 0) return point_distance(_px, _py, _x0, _y0);
	  
	var t = ((_px - _x0) * (_x1 - _x0) + (_py - _y0) * (_y1 - _y0)) / l2;
	if(t < 0 || t > 1) {
		var d0 = point_distance(_px, _py, _x0, _y0);
		var d1 = point_distance(_px, _py, _x1, _y1);
		return (d0 < d1) ? d0 : d1;
	}
	
	var dd = point_distance(_px, _py, _x0 + t * (_x1 - _x0), _y0 + t * (_y1 - _y0));
	
	var cross = (_x1 - _x0) * (_py - _y0) - (_y1 - _y0) * (_px - _x0);
	if (cross > 0) dd = -dd;
	
	return dd;
}

function point_closer(_p, _dist, _px, _py, _x0, _y0, _x1, _y1) {
	var l2 = sqr(_x0 - _x1) + sqr(_y0 - _y1);
	if (l2 == 0) return point_distance(_px, _py, _x0, _y0);
	  
	var t = ((_px - _x0) * (_x1 - _x0) + (_py - _y0) * (_y1 - _y0)) / l2;
	t = clamp(t, 0, 1);
	
	var cx = lerp(_x0, _x1, t);
	var cy = lerp(_y0, _y1, t);
	var dx = _px - cx;
	var dy = _py - cy;
	var dd = dx * dx + dy * dy;
	
	if(dd >= _dist) return _dist;
	
	_p[@ 0] = cx;
	_p[@ 1] = cy;
	return dd;
}

function distance_to_line_angle_signed(px, py, lx, ly, aa) { 
	var x0 = lx - lengthdir_x(.5, aa);
	var y0 = ly - lengthdir_y(.5, aa);
	var x1 = lx + lengthdir_x(.5, aa);
	var y1 = ly + lengthdir_y(.5, aa);
	
	return (x1 - x0) * (y0 - py) - (x0 - px) * (y1 - y0);
}
	
function distance_to_line_infinite_signed(px, py, x0, y0, x1, y1) { return ((x1 - x0) * (y0 - py) - (x0 - px) * (y1 - y0)) / sqrt(sqr(x1 - x0) + sqr(y1 - y0)); }
function distance_to_line_infinite(px, py, x0, y0, x1, y1)        { return abs((x1 - x0) * (y0 - py) - (x0 - px) * (y1 - y0)) / sqrt(sqr(x1 - x0) + sqr(y1 - y0)); }

function point_project_line(px, py, l0x, l0y, l1x, l1y) {
	var mag = point_distance(l0x, l0y, l1x, l1y);
	var dir = point_direction(l0x, l0y, l1x, l1y);
	var dt  = dot_product(px - l0x, py - l0y, l1x - l0x, l1y - l0y) / mag;
	
	return [l0x + lengthdir_x(dt, dir), l0y + lengthdir_y(dt, dir)];
}

function point_project_curve(mx, my, x0, y0, x1, y1) {
	var xc = (x0 + x1) / 2;
	var sample = ceil((abs(x0 - x1) + abs(y0 - y1)) / 16 * PROJECT.graphConnection.line_sample);
	sample = clamp(sample, 8, 128);
	
	var dist = 999999;
	var ox, oy, nx, ny, t, it;
	var pp = [mx, my];
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx = x0 * t * t * t + 3 * xc * it * t * t + 3 * xc * it * it * t + x1 * it * it * it;
		ny = y0 * t * t * t + 3 * y0 * it * t * t + 3 * y1 * it * it * t + y1 * it * it * it;
		
		if(i && dist < distance_to_line(mx, my, ox, oy, nx, ny)) {
			dist = distance_to_line(mx, my, ox, oy, nx, ny);
			pp = point_project_line(mx, my, ox, oy, nx, ny);
		}
		
		ox = nx;
		oy = ny;
	}
	
	return pp;
}

function point_project_elbow(px, py, x0, y0, x1, y1) {
	var cx = (x0 + x1) / 2;
	var maxy = max(y0, y1);
	var miny = min(y0, y1);
	
	if(py < miny) return [ px, miny ];
	if(py > maxy) return [ px, maxy ];
	return [ cx, py ];
}
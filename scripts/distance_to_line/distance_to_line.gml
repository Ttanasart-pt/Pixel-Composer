function distance_to_line(px, py, x0, y0, x1, y1) {
	  var l2 = sqr(x0 - x1) + sqr(y0 - y1);
	  if (l2 == 0) return point_distance(px, py, x0, y0);
	  
	  var t = ((px - x0) * (x1 - x0) + (py - y0) * (y1 - y0)) / l2;
	  t = clamp(t, 0, 1);
	  
	  return point_distance(px, py, x0 + t * (x1 - x0), y0 + t * (y1 - y0));
}

function distance_to_line_infinite(px, py, x0, y0, x1, y1) {
	return abs((x1 - x0) * (y0 - py) - (x0 - px) * (y1 - y0)) / sqrt(sqr(x1 - x0) + sqr(y1 - y0));	
}
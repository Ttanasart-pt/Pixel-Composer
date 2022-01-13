function point_rotate(px, py, ox, oy, a) {
	var cx = px - ox;
	var cy = py - oy;
	var d  = -degtorad(a);
	
	return [ox + cx * cos(d) - cy * sin(d), 
			oy + cx * sin(d) + cy * cos(d)];
}
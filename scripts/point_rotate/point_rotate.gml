function point_rotate(px, py, ox, oy, a) {
	gml_pragma("forceinline");
	
	a = angle_difference(a, 0);
	if(a == 0)   return [ px, py ];
	if(a == 180) return [ ox + (ox - px), oy + (oy - py) ];
	
	var cx = px - ox;
	var cy = py - oy;
	var d  = -degtorad(a);
	
	return [ox + cx * cos(d) - cy * sin(d), 
			oy + cx * sin(d) + cy * cos(d)];
}
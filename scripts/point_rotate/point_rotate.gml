function point_rotate(px, py, ox, oy, a, p = undefined) {
	INLINE
	
	p ??= [ px, py ];
	
	a = angle_difference(a, 0);
	if(a == 0) {
		p[0] = px;
		p[1] = py;
		return p;
	}
	
	if(a == 180) {
		p[0] = ox + (ox - px);
		p[1] = oy + (oy - py);
		return p;
	}
	
	var cx = px - ox;
	var cy = py - oy;
	var d  = -degtorad(a);
	
	p[0] = ox + cx * cos(d) - cy * sin(d);
	p[1] = oy + cx * sin(d) + cy * cos(d);
	
	return p;
}
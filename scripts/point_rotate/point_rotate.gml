function point_rotate(px, py, ox, oy, a, p = undefined) {
	INLINE
	
	p ??= [ px, py ];
	
	a = angle_difference(a, 0);
		 if(a ==   0) { p[0] = px;             p[1] = py;             return p; }
	else if(a == 180) { p[0] = ox + (ox - px); p[1] = oy + (oy - py); return p; }
	
	var cx = px - ox;
	var cy = py - oy;
	
	var dc = dcos(-a);
	var ds = dsin(-a);
	
	p[0] = ox + cx * dc - cy * ds;
	p[1] = oy + cx * ds + cy * dc;
	
	return p;
}

function point_rotate_origin(px, py, a, p) {
	INLINE
	
	a = angle_difference(a, 0);
		 if(a ==   0) { p[0] =  px; p[1] =  py; return p; }
	else if(a == 180) { p[0] = -px; p[1] = -py; return p; }
	
	var dc = dcos(-a);
	var ds = dsin(-a);
	
	p[0] = px * dc - py * ds;
	p[1] = px * ds + py * dc;
	
	return p;
}
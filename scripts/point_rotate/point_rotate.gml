function point_rotate(px, py, ox, oy, a, p = undefined) {
	p ??= [ px, py ];
	
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

function point_rotate_array(p, o, a) {
	var px = p[0], py = p[1];
	var ox = o[0], oy = o[1];
	
		 if(a ==   0) { return p; }
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
	if(a == 180) { p[0] = -px; p[1] = -py; return p; }
	
	var dc = dcos(-a);
	var ds = dsin(-a);
	
	p[0] = px * dc - py * ds;
	p[1] = px * ds + py * dc;
	
	return p;
}

function point_vec2_rotate(p, ox, oy, a) {
	var px = p.x;
	var py = p.y;
	
	if(a ==   0) return p;
	if(a == 180) { p.x = ox + (ox - px); p.y = oy + (oy - py); return p; }
	
	var cx = px - ox;
	var cy = py - oy;
	
	var dc = dcos(-a);
	var ds = dsin(-a);
	
	p.x = ox + cx * dc - cy * ds;
	p.y = oy + cx * ds + cy * dc;
	
	return p;
}
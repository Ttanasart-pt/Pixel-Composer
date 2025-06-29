function __verlet_vec2() : __vec2() constructor {
	px = 0; py = 0;
	sx = 0; sy = 0;
	vx = 0; vy = 0;
	u  = 0; v  = 0;
	
	pin = false;
	
	static set2 = function(_v2) {
		x  = _v2.x; y  = _v2.y;
		px = _v2.x; py = _v2.y;
		sx = _v2.x; sy = _v2.y;
		return self;
	}
}

function __verlet_edge(_p0, _p1, _k) constructor {
	p0 = _p0;
	p1 = _p1;
	k  = _k;
	
	distance = point_distance(p0.x, p0.y, p1.x, p1.y);
}

function __verlet_Mesh() : Mesh() constructor {
	
}
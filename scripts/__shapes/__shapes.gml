global.SHAPES = [];

enum SHAPE_TYPE {
	points,
	triangles,
	rectangle
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function SHAPE_rectangle(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	
	var triangles = [ [ new __vec2(-w, -h), new __vec2(-w,  h), new __vec2( w, -h), c_white ],
					  [ new __vec2( w, -h), new __vec2(-w,  h), new __vec2( w,  h), c_white ], ];
	var segment = [ new __vec2(-w, -h), new __vec2(w, -h), new __vec2(w, h), new __vec2(-w, h), new __vec2(-w, -h) ];
	
	return [ [ { type: SHAPE_TYPE.rectangle, triangles: triangles } ], segment ];
}

function SHAPE_diamond(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	
	var triangles = [ [ new __vec2( 0,  0), new __vec2( w,  0), new __vec2( 0, -h), c_white ],
	                  [ new __vec2( 0,  0), new __vec2( 0, -h), new __vec2(-w,  0), c_white ],
	                  [ new __vec2( 0,  0), new __vec2(-w,  0), new __vec2( 0,  h), c_white ],
	                  [ new __vec2( 0,  0), new __vec2( 0,  h), new __vec2( w,  0), c_white ], ];
	var segment = [ new __vec2(w, 0), new __vec2(0, -h), new __vec2(-w, 0), new __vec2(0, h), new __vec2(w, 0) ];
	
	return [ [ { type: SHAPE_TYPE.rectangle, triangles: triangles } ], segment ];
}

function SHAPE_trapezoid(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	var v = w * data.trep;
	
	var triangles = [ [ new __vec2(-v, -h), new __vec2(-w,  h), new __vec2( v, -h), c_white ],
					  [ new __vec2( v, -h), new __vec2(-w,  h), new __vec2( w,  h), c_white ], ];
	var segment = [ new __vec2(-v, -h), new __vec2(v, -h), new __vec2(w, h), new __vec2(-w, h), new __vec2(-v, -h) ];
	
	return [ [ { type: SHAPE_TYPE.rectangle, triangles: triangles } ], segment ];
}

function SHAPE_parallelogram(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	var a = data.palAng;
	
	var x0 = -w, x1 = w;
	var x2 = -w, x3 = w;
	
	if(a > 0) {
		x0 = lerp(w, -w, 1 - abs(a));
		x3 = lerp(-w, w, 1 - abs(a));
	} else {
		x2 = lerp(w, -w, 1 - abs(a));
		x1 = lerp(-w, w, 1 - abs(a));
	}
	
	var triangles = [ [ new __vec2(x0, -h), new __vec2(x2,  h), new __vec2(x1, -h), c_white ],
					  [ new __vec2(x1, -h), new __vec2(x2,  h), new __vec2(x3,  h), c_white ], ];
	var segment = [ new __vec2(x0, -h), new __vec2(x1, -h), new __vec2(x3, h), new __vec2(x2, h), new __vec2(x0, -h) ];
	
	return [ [ { type: SHAPE_TYPE.rectangle, triangles: triangles } ], segment ];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function SHAPE_circle(_sca, data = {}) {
	var prec	  = max(3, data.side);
	var ang		  = 360 / prec;
	var triangles = array_create(prec);
	var segment   = array_create(prec + 1);
	var explode   = data.explode;
	
	for( var i = 0; i < prec; i++ ) {
		var d0 = (i + 0.) * ang;
		var d5 = (i + .5) * ang;
		var d1 = (i + 1.) * ang;
		
		var dx = lengthdir_x(explode * _sca[0], d5);
		var dy = lengthdir_y(explode * _sca[1], d5);
		
		var x0 = lengthdir_x(_sca[0], d0) + dx;
		var y0 = lengthdir_y(_sca[1], d0) + dy;
		var x1 = lengthdir_x(_sca[0], d1) + dx;
		var y1 = lengthdir_y(_sca[1], d1) + dy;
		
		triangles[i] = [ new __vec2(dx, dy), new __vec2(x0, y0), new __vec2(x1, y1), c_white ];
		
		if(i == 0) segment[0] = new __vec2(x0, y0);
		segment[i + 1] = new __vec2(x1, y1);
	}
	
	return [ [{ type: SHAPE_TYPE.triangles, triangles: triangles }], segment ];
}

function SHAPE_ring(_sca, data = {}) {
	var w  = _sca[0], h = _sca[1];
	var s  = max(3, data.side);
	var ow = w;
	var oh = h;
	var iw = w * data.inner;
	var ih = h * data.inner;
	var an = 360 / s;
	
	var triangles = [];
	var segment   = [];
	
	for( var i = 0; i < s; i++ ) {
		var a0 =  i * an;
		var a1 = a0 + an;
		
		var ix0 = lengthdir_x(iw, a0);
		var iy0 = lengthdir_y(ih, a0);
		var ix1 = lengthdir_x(iw, a1);
		var iy1 = lengthdir_y(ih, a1);
		
		var ox0 = lengthdir_x(ow, a0);
		var oy0 = lengthdir_y(oh, a0);
		var ox1 = lengthdir_x(ow, a1);
		var oy1 = lengthdir_y(oh, a1);
		
		array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(ox0, oy0), new __vec2(ox1, oy1), c_white ]);
		array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(ox1, oy1), new __vec2(ix1, iy1), c_white ]);
		
		if(i == 0) array_push(segment, new __vec2(ox0, oy0));
		           array_push(segment, new __vec2(ox1, oy1));
	}
	
	return [ [{ type: SHAPE_TYPE.rectangle, triangles: triangles }], segment ];
}

function SHAPE_arc(_sca, data = {}) {
	var prec   = max(3, data.side);
	var inner  = data.inner;
	var radRan = data.radRan;
	var cap    = data.cap;
	var triangles = [];
	var segment   = [];
	
	var oa, na;		
	var sgArcI = [], sgArcO = [];
	
	for( var i = 0; i <= prec; i++ ) {
		na = lerp(radRan[0], radRan[1], i / prec);
		
		var ix1 = lengthdir_x(0.5 * inner, na) * _sca[0] * 2;
		var iy1 = lengthdir_y(0.5 * inner, na) * _sca[1] * 2;
		
		var nx1 = lengthdir_x(0.5, na) * _sca[0] * 2;
		var ny1 = lengthdir_y(0.5, na) * _sca[1] * 2;
			
		if(i) {
			var ix0 = lengthdir_x(0.5 * inner, oa) * _sca[0] * 2;
			var iy0 = lengthdir_y(0.5 * inner, oa) * _sca[1] * 2;
		
			var nx0 = lengthdir_x(0.5, oa) * _sca[0] * 2;
			var ny0 = lengthdir_y(0.5, oa) * _sca[1] * 2;
		
			array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(nx0, ny0), new __vec2(nx1, ny1), c_white ]);
			array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(nx1, ny1), new __vec2(ix1, iy1), c_white ]);
		}
		
		array_push(sgArcI, new __vec2(ix1, iy1));
		array_push(sgArcO, new __vec2(nx1, ny1));
		
		oa = na;
	}
	
	if(cap) { 
		var cx = lengthdir_x(0.5 * (inner + 1) / 2, radRan[0]) * _sca[0] * 2;
		var cy = lengthdir_y(0.5 * (inner + 1) / 2, radRan[0]) * _sca[1] * 2;
		var ox, oy, nx, ny, oa, na;
		var sgCapI = [], sgCapO = [];
		prec = max(ceil(prec / 2), 2);
		
		for( var i = 0; i <= prec; i++ ) {
			na = radRan[0] - 180 * i / prec;
			nx = cx + lengthdir_x((1 - inner) / 2, na) * _sca[0];
			ny = cy + lengthdir_y((1 - inner) / 2, na) * _sca[1];
		
			if(i) array_push(triangles, [ new __vec2(cx, cy), new __vec2(ox, oy), new __vec2(nx, ny), c_white ]);
			
			array_push(sgCapI, new __vec2(nx, ny));
			
			oa = na;
			ox = nx;
			oy = ny;
		}
		
		var cx = lengthdir_x(0.5 * (inner + 1) / 2, radRan[1]) * _sca[0] * 2;
		var cy = lengthdir_y(0.5 * (inner + 1) / 2, radRan[1]) * _sca[1] * 2;
		var ox, oy, nx, ny, oa, na;
		
		for( var i = 0; i <= prec; i++ ) {
			na = radRan[1] + 180 * i / prec;
			nx = cx + lengthdir_x((1 - inner) / 2, na) * _sca[0];
			ny = cy + lengthdir_y((1 - inner) / 2, na) * _sca[1];
			
			if(i) array_push(triangles, [ new __vec2(cx, cy), new __vec2(ox, oy), new __vec2(nx, ny), c_white ]);
			
			array_push(sgCapO, new __vec2(nx, ny));
			
			oa = na;
			ox = nx;
			oy = ny;
		}
		
		array_append(segment, sgArcI);
		array_append(segment, array_reverse(sgCapO));
		
		array_append(segment, array_reverse(sgArcO));
		array_append(segment, sgCapI);
	} else {
		array_append(segment, sgArcI);
		array_append(segment, array_reverse(sgArcO));
		array_push(segment, sgArcI[0].clone());
	}
	
	return [ [{ type: SHAPE_TYPE.rectangle, triangles: triangles }], segment ];
}

function SHAPE_crescent(_sca, data = {}) {
	var w  = _sca[0], h = _sca[1];
	var s  = max(3, data.side);
	var ow = w;
	var oh = h;
	var iw = w * data.inner;
	var ih = h * data.inner;
	var an = 360 / s;
	
	var cx = w - w * data.inner;
	var cy = 0;
	
	var triangles = [];
	var segment   = [];
	
	for( var i = 0; i < s; i++ ) {
		var a0 = i  * an;
		var a1 = a0 + an;
		
		var ox0 = lengthdir_x(ow, a0);
		var oy0 = lengthdir_y(oh, a0);
		var ox1 = lengthdir_x(ow, a1);
		var oy1 = lengthdir_y(oh, a1);
		
		var ix0 = cx + lengthdir_x(iw, a0);
		var iy0 = cy + lengthdir_y(ih, a0);
		var ix1 = cx + lengthdir_x(iw, a1);
		var iy1 = cy + lengthdir_y(ih, a1);
		
		if(triangle_area_points(ix0, iy0, ox0, oy0, ox1, oy1) > 0.1) array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(ox0, oy0), new __vec2(ox1, oy1), c_white ]);
		if(triangle_area_points(ix0, iy0, ox1, oy1, ix1, iy1) > 0.1) array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(ox1, oy1), new __vec2(ix1, iy1), c_white ]);
		
		if(array_empty(segment)) array_push(segment, new __vec2(ox0, oy0)); array_push(segment, new __vec2(ox1, oy1));
	}
	
	return [ [{ type: SHAPE_TYPE.triangles, triangles: triangles }], segment ];
}

function SHAPE_pie(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	var p = max(3, data.side);
	var a = 1 / p;
	var r = data.radRan;
	
	var triangles = array_create(p);
	var segment   = array_create(p + 1);
	
	for( var i = 0; i < p; i++ ) {
		var d0 = lerp(r[0], r[1], i * a);
		var d1 = lerp(r[0], r[1], i * a + a);
		
		var x0 = lengthdir_x(w, d0);
		var y0 = lengthdir_y(h, d0);
		var x1 = lengthdir_x(w, d1);
		var y1 = lengthdir_y(h, d1);
		
		triangles[i] = [ new __vec2(0, 0), new __vec2(x0, y0), new __vec2(x1, y1), c_white ];
		
		if(i == 0) segment[0]   = new __vec2(x0, y0);
		           segment[i+1] = new __vec2(x1, y1);
	}
	
	return [ [{ type: SHAPE_TYPE.triangles, triangles: triangles }], segment ];
}

function SHAPE_squircle(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	var s = max(3, data.side);
	var a = 360 / s;
	var f = max(.001, data.factor);
	var triangles = [];
	var segment   = [];
	
	var ox, oy, nx, ny;
	var s2 = sqrt(2);
	
	for( var i = 0; i <= s; i++ ) {
		var d  = i * a;
		var r  = 1 / power(power(abs(dcos(d)), f) + power(abs(dsin(d)), f), 1 / f);
		
		var nx = lengthdir_x(r * w, d);
		var ny = lengthdir_y(r * h, d);
		
		if(i) array_push(triangles, [ new __vec2(0, 0), new __vec2(ox, oy), new __vec2(nx, ny), c_white ]);
		array_push(segment, new __vec2(nx, ny));
		
		ox = nx;
		oy = ny;
	}
	
	segment[s] = segment[0].clone();
	
	return [ [{ type: SHAPE_TYPE.triangles, triangles: triangles }], segment ];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function SHAPE_reg_poly(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	var p = max(3, data.side);
	var a = 360 / p;
	
	var triangles = array_create(p);
	var segment   = array_create(p + 1);
	
	for( var i = 0; i < p; i++ ) {
		var d0 =  i * a;
		var d1 = d0 + a;
		
		var x0 = lengthdir_x(w, d0);
		var y0 = lengthdir_y(h, d0);
		var x1 = lengthdir_x(w, d1);
		var y1 = lengthdir_y(h, d1);
		
		triangles[i] = [ new __vec2(0, 0), new __vec2(x0, y0), new __vec2(x1, y1), c_white ];
		
		if(i == 0) segment[0]   = new __vec2(x0, y0);
		           segment[i+1] = new __vec2(x1, y1);
	}
	
	return [ [{ type: SHAPE_TYPE.triangles, triangles: triangles }], segment ];
}

function SHAPE_star(_sca, data = {}) {
	var prec  = max(3, data.side);
	var inner = data.inner;
	var triangles = [];
	var segment   = [];
	
	for( var i = 0; i < prec; i++ ) {
		var otx = lengthdir_x(0.5, i / prec * 360) * _sca[0] * 2;
		var oty = lengthdir_y(0.5, i / prec * 360) * _sca[1] * 2;
		
		var inx = lengthdir_x(inner / 2, (i + 0.5) / prec * 360) * _sca[0] * 2;
		var iny = lengthdir_y(inner / 2, (i + 0.5) / prec * 360) * _sca[1] * 2;
		array_push(triangles, [ new __vec2(0, 0), new __vec2(otx, oty), new __vec2(inx, iny), c_white ]);
		
		var pi0 = new __vec2(inx, iny);
		
		var inx = lengthdir_x(inner / 2, (i - 0.5) / prec * 360) * _sca[0] * 2;
		var iny = lengthdir_y(inner / 2, (i - 0.5) / prec * 360) * _sca[1] * 2;
		array_push(triangles, [ new __vec2(0, 0), new __vec2(inx, iny), new __vec2(otx, oty), c_white ]);
		
		array_push(segment, new __vec2(inx, iny));
		array_push(segment, new __vec2(otx, oty));
		array_push(segment, pi0);
	}
	
	return [ [{ type: SHAPE_TYPE.triangles, triangles: triangles }], segment ];
}

function SHAPE_cross(_sca, data = {}) {
	var inner     = data.inner;
	var triangles = [];
	var segment   = [];
	var side      = min(_sca[0], _sca[1]) * inner;
	
	array_push(triangles,
		[ new __vec2(-side, -side), new __vec2(-side, side), new __vec2( side, -side), c_white ],
		[ new __vec2( side, -side), new __vec2(-side,  side), new __vec2( side, side), c_white ],
	);
	
	array_push(triangles, //top
		[ new __vec2(-side, -side), new __vec2( side,    -side), new __vec2(-side, -_sca[1]), c_white ],
		[ new __vec2( side, -side), new __vec2( side, -_sca[1]), new __vec2(-side, -_sca[1]), c_white ],
	);
	
	array_push(triangles, //bottom
		[ new __vec2(-side, _sca[1]), new __vec2( side, _sca[1]), new __vec2(-side, side), c_white ],
		[ new __vec2( side, _sca[1]), new __vec2( side, side), new __vec2(-side,    side), c_white ],
	);
	
	array_push(triangles, //left
		[ new __vec2(   -side, -side), new __vec2(-_sca[0], -side), new __vec2(-side,    side), c_white ],
		[ new __vec2(-_sca[0], -side), new __vec2(-_sca[0], side), new __vec2(-side,     side), c_white ],
	);
	
	array_push(triangles, //right
		[ new __vec2(_sca[0], -side), new __vec2( side,   -side), new __vec2(_sca[0], side), c_white ],
		[ new __vec2(   side, -side), new __vec2(   side, side), new __vec2(_sca[0],  side), c_white ],
	);
	
	array_push(segment, new __vec2(-side,    -side),   new __vec2(-side,    -_sca[1]), new __vec2( side, -_sca[1]), new __vec2(side, -side) );
	array_push(segment, new __vec2( _sca[0], -side),   new __vec2( _sca[0],  side),    new __vec2( side,  side));
	array_push(segment, new __vec2( side,    _sca[1]), new __vec2(-side,     _sca[1]), new __vec2(-side,  side));
	array_push(segment, new __vec2(-_sca[0],  side),   new __vec2(-_sca[0], -side),    new __vec2(-side, -side));
	
	return [ [{ type: SHAPE_TYPE.rectangle, triangles: triangles }], segment ];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function SHAPE_capsule(_sca, data = {}) {
	var rad		= data.radius;
	var prec    = max(2, data.side);
	var hh		= _sca[1] * rad;
	var shapes  = [];
	var segment = [];
	array_push(segment, new __vec2(-_sca[0] + _sca[1], _sca[1]), new __vec2( _sca[0] - hh, hh));
	
	var triangles = [
		[ new __vec2(-_sca[0] + _sca[1], -_sca[1]), new __vec2(-_sca[0] + _sca[1], _sca[1]), new __vec2(_sca[0] - hh, -hh), c_white ],
		[ new __vec2(_sca[0] - hh, -hh), new __vec2(-_sca[0] + _sca[1], _sca[1]), new __vec2(_sca[0] - hh, hh),             c_white ],
	];
	shapes[0] = { type: SHAPE_TYPE.rectangle, triangles: triangles };
	
	var triangles = [];
	var cx = -_sca[0] + _sca[1];
	var cy = 0;
	var ox, oy, nx, ny, oa, na;
	for( var i = 0; i <= prec; i++ ) {
		na = lerp(270, 90, i / prec);
		nx = cx + lengthdir_x(_sca[1], na);
		ny = cy + lengthdir_y(_sca[1], na);
		
		if(i) {
			array_push(triangles, [ new __vec2(cx, cy), new __vec2(nx, ny), new __vec2(ox, oy), c_white ]);
			array_push(segment, new __vec2(ox, oy));
		}
		array_push(segment, new __vec2(nx, ny));
		
		oa = na;
		ox = nx;
		oy = ny;
	}
	
	array_push(segment, new __vec2(-_sca[0] + _sca[1], -_sca[1]), new __vec2( _sca[0] - hh, -hh));
	shapes[1] = { type: SHAPE_TYPE.triangles, triangles: triangles };
	
	var triangles = [];
	var cx = _sca[0] - hh;
	var cy = 0;
	var _seg = [];
	var ox, oy, nx, ny, oa, na;
	for( var i = 0; i <= prec; i++ ) {
		na = lerp(-90, 90, i / prec);
		nx = cx + lengthdir_x(hh, na);
		ny = cy + lengthdir_y(hh, na);
		
		if(i) {
			array_push(triangles, [ new __vec2(cx, cy), new __vec2(ox, oy), new __vec2(nx, ny), c_white ]);
			array_push(_seg, new __vec2(ox, oy));
		}
		array_push(_seg, new __vec2(nx, ny));
		
		oa = na;
		ox = nx;
		oy = ny;
	}
	
	for( var i = 0, n = array_length(_seg); i < n; i++ )
		array_push(segment, _seg[array_length(_seg) - i - 1]);
	
	shapes[2] = { type: SHAPE_TYPE.triangles, triangles: triangles };
	
	return [ shapes, segment ];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function SHAPE_leaf(_sca, data = {}) {
	var w = _sca[0], h = _sca[1];
	var p = max(3, data.side);
	var a = 180 / (p - 1);
	
	var triangles = [];
	var s0 = [], s1 = [];
	
	var _oy, _ox0, _ox1;

	for( var i = 0; i < p; i++ ) {
		var d = lerp(-60, 60, i / (p - 1));
		
		var _ny  = lengthdir_y(h, d) / dsin(60);
		var _nx0 = -w + lengthdir_x(w * 2, d);
		var _nx1 =  w - lengthdir_x(w * 2, d);
		
		if(i) {
			array_push(triangles, [ new __vec2(_nx0, _ny), new __vec2(_nx1, _ny), new __vec2(_ox0, _oy), c_white ]);
			array_push(triangles, [ new __vec2(_ox0, _oy), new __vec2(_nx1, _ny), new __vec2(_ox1, _oy), c_white ]);
			
			if(array_empty(s0)) array_push(s0, new __vec2(_ox0, _oy)); array_push(s0, new __vec2(_nx0, _ny));
			if(array_empty(s1)) array_push(s1, new __vec2(_ox1, _oy)); array_push(s1, new __vec2(_nx1, _ny));
		}
		
		_oy  = _ny;
		_ox0 = _nx0;
		_ox1 = _nx1;
	}
	
	array_reverse_ext(s1);
	var segment = array_merge(s0, s1);
	
	return [ [{ type: SHAPE_TYPE.rectangle, triangles: triangles }], segment ];
}

function SHAPE_gear(_sca, data = {}) {
	var teeth  = max(3, data.teeth);
	var teethH = data.teethH;
	var teethT = data.teethT;
	var prec   = teeth * 2;
	var inner  = data.inner;
	var body   = 0.5 * (1 - teethH);
	var teth   = 0.5 * teethH;
	var triangles = [];
	var segment   = [];
	
	for( var i = 0; i < prec; i++ ) {
		var ix0 = lengthdir_x(body * inner, i / prec * 360) * _sca[0] * 2;
		var iy0 = lengthdir_y(body * inner, i / prec * 360) * _sca[1] * 2;
		
		var nx0 = lengthdir_x(body, i / prec * 360) * _sca[0] * 2;
		var ny0 = lengthdir_y(body, i / prec * 360) * _sca[1] * 2;
		
		var ix1 = lengthdir_x(body * inner, (i + 1) / prec * 360) * _sca[0] * 2;
		var iy1 = lengthdir_y(body * inner, (i + 1) / prec * 360) * _sca[1] * 2;
		
		var nx1 = lengthdir_x(body, (i + 1) / prec * 360) * _sca[0] * 2;
		var ny1 = lengthdir_y(body, (i + 1) / prec * 360) * _sca[1] * 2;
		
		array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(nx0, ny0), new __vec2(nx1, ny1), c_white ]);
		array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(nx1, ny1), new __vec2(ix1, iy1), c_white ]);
		
		if(i == 0)
			array_push(segment, new __vec2(nx0, ny0));
		
		if(i % 2) {
			var tx0 = nx0 + lengthdir_x(teth, (i + 0.5 - teethT) / prec * 360) * _sca[0] * 2;
			var ty0 = ny0 + lengthdir_y(teth, (i + 0.5 - teethT) / prec * 360) * _sca[1] * 2;
		
			var tx1 = nx1 + lengthdir_x(teth, (i + 0.5 + teethT) / prec * 360) * _sca[0] * 2;
			var ty1 = ny1 + lengthdir_y(teth, (i + 0.5 + teethT) / prec * 360) * _sca[1] * 2;
			
			array_push(triangles, [ new __vec2(tx0, ty0), new __vec2(nx1, ny1), new __vec2(nx0, ny0), c_white ]);
			array_push(triangles, [ new __vec2(tx0, ty0), new __vec2(tx1, ty1), new __vec2(nx1, ny1), c_white ]);
			
			array_push(segment, new __vec2(tx0, ty0));
			array_push(segment, new __vec2(tx1, ty1));
		}
		
		array_push(segment, new __vec2(nx1, ny1));
	}
	
	return [ [{ type: SHAPE_TYPE.rectangle, triangles: triangles }], segment ];
}

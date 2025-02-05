global.SHAPES = [];

enum SHAPE_TYPE {
	points,
	triangles,
	rectangle
}

function SHAPE_rectangle(_sca) {
	var triangles = [
						[ new __vec2(-_sca[0], -_sca[1]), new __vec2(-_sca[0],  _sca[1]), new __vec2( _sca[0], -_sca[1]), c_white ],
						[ new __vec2( _sca[0], -_sca[1]), new __vec2(-_sca[0],  _sca[1]), new __vec2( _sca[0],  _sca[1]), c_white ],
					];
	var segment = [ new __vec2(-_sca[0], -_sca[1]), new __vec2( _sca[0], -_sca[1]), 
					new __vec2( _sca[0],  _sca[1]), new __vec2(-_sca[0],  _sca[1]),
					new __vec2(-_sca[0], -_sca[1]) ];
	
	return [
		[ { type: SHAPE_TYPE.rectangle, triangles: triangles } ],
		segment
	];
}

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
	
	return [
		[{ type: SHAPE_TYPE.triangles, triangles: triangles }],
		segment
	];
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
	
	return [
		[{ type: SHAPE_TYPE.triangles, triangles: triangles }],
		segment
	];
}

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
	var ox, oy, nx, ny, oa, na;
	var _seg = [];
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
	
	return [
		shapes,
		segment
	];
}

function SHAPE_ring(_sca, data = {}) {
	var prec  = max(3, data.side);
	var inner = data.inner;
	var triangles = [];
	var segment   = [];
	
	for( var i = 0; i < prec; i++ ) {
		var ix0 = lengthdir_x(0.5 * inner, i / prec * 360) * _sca[0] * 2;
		var iy0 = lengthdir_y(0.5 * inner, i / prec * 360) * _sca[1] * 2;
		
		var nx0 = lengthdir_x(0.5, i / prec * 360) * _sca[0] * 2;
		var ny0 = lengthdir_y(0.5, i / prec * 360) * _sca[1] * 2;
		
		var ix1 = lengthdir_x(0.5 * inner, (i + 1) / prec * 360) * _sca[0] * 2;
		var iy1 = lengthdir_y(0.5 * inner, (i + 1) / prec * 360) * _sca[1] * 2;
		
		var nx1 = lengthdir_x(0.5, (i + 1) / prec * 360) * _sca[0] * 2;
		var ny1 = lengthdir_y(0.5, (i + 1) / prec * 360) * _sca[1] * 2;
		
		array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(nx0, ny0), new __vec2(nx1, ny1), c_white ]);
		array_push(triangles, [ new __vec2(ix0, iy0), new __vec2(nx1, ny1), new __vec2(ix1, iy1), c_white ]);
		
		if(i == 0)
			array_push(segment, new __vec2(nx0, ny0));
		array_push(segment, new __vec2(nx1, ny1));
	}
	
	return [
		[{ type: SHAPE_TYPE.rectangle, triangles: triangles }],
		segment
	];
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
	
	return [
		[{ type: SHAPE_TYPE.rectangle, triangles: triangles }],
		segment
	];
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
	
	return [
		[{ type: SHAPE_TYPE.rectangle, triangles: triangles }],
		segment
	];
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
	
	return [
		[{ type: SHAPE_TYPE.rectangle, triangles: triangles }],
		segment
	];
}

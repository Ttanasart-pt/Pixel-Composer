#region shapes
	global.SHAPES = [];
	
	enum SHAPE_TYPE {
		points,
		triangles,
	}
	
	function SHAPE_rectangle(_sca) {
		var triangles = [
							[ new Point(-_sca[0], -_sca[1]), new Point( _sca[0], -_sca[1]), new Point(-_sca[0],  _sca[1]) ],
							[ new Point( _sca[0], -_sca[1]), new Point(-_sca[0],  _sca[1]), new Point( _sca[0],  _sca[1]) ],
						];
		var segment = [ new Point(-_sca[0], -_sca[1]), new Point( _sca[0], -_sca[1]), 
						new Point( _sca[0],  _sca[1]), new Point(-_sca[0],  _sca[1]),
						new Point(-_sca[0], -_sca[1]) ];
		
		return [
			[{ type: SHAPE_TYPE.triangles, triangles: triangles }],
			segment
		];
	}
	
	function SHAPE_circle(_sca, data = {}) {
		var prec	  = max(3, data.side);
		var triangles = [];
		var ang		  = 360 / prec;
		var segment   = [];
		
		for( var i = 0; i < prec; i++ ) {
			var x0 = lengthdir_x(0.5, (i + 0) * ang) * _sca[0] * 2;
			var y0 = lengthdir_y(0.5, (i + 0) * ang) * _sca[1] * 2;
			var x1 = lengthdir_x(0.5, (i + 1) * ang) * _sca[0] * 2;
			var y1 = lengthdir_y(0.5, (i + 1) * ang) * _sca[1] * 2;
			
			array_push(triangles, [ new Point(0, 0), new Point(x0, y0), new Point(x1, y1) ]);
			
			if(i == 0) array_push(segment, new Point(x0, y0));
			array_push(segment, new Point(x1, y1));
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
			array_push(triangles, [ new Point(0, 0), new Point(otx, oty), new Point(inx, iny) ]);
			
			var pi0 = new Point(inx, iny);
			
			var inx = lengthdir_x(inner / 2, (i - 0.5) / prec * 360) * _sca[0] * 2;
			var iny = lengthdir_y(inner / 2, (i - 0.5) / prec * 360) * _sca[1] * 2;
			array_push(triangles, [ new Point(0, 0), new Point(otx, oty), new Point(inx, iny) ]);
			
			array_push(segment, new Point(inx, iny));
			array_push(segment, new Point(otx, oty));
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
		array_push(segment, new Point(-_sca[0] + _sca[1], _sca[1]), new Point( _sca[0] - hh, hh));
		
		var triangles = [
			[ new Point(-_sca[0] + _sca[1], -_sca[1]), new Point( _sca[0] - hh, -hh),           new Point(-_sca[0] + _sca[1],  _sca[1]) ],
			[ new Point( _sca[0] - hh,      -hh),      new Point(-_sca[0] + _sca[1],  _sca[1]), new Point( _sca[0] - hh,       hh) ],
		];
		shapes[0] = { type: SHAPE_TYPE.triangles, triangles: triangles };
		
		var triangles = [];
		var cx = -_sca[0] + _sca[1];
		var cy = 0;
		var ox, oy, nx, ny, oa, na;
		for( var i = 0; i <= prec; i++ ) {
			na = lerp(270, 90, i / prec);
			nx = cx + lengthdir_x(_sca[1], na);
			ny = cy + lengthdir_y(_sca[1], na);
			
			if(i) {
				array_push(triangles, [ new Point(cx, cy), new Point(ox, oy), new Point(nx, ny) ]);
				array_push(segment, new Point(ox, oy));
			}
			array_push(segment, new Point(nx, ny));
			
			oa = na;
			ox = nx;
			oy = ny;
		}
		
		array_push(segment, new Point(-_sca[0] + _sca[1], -_sca[1]), new Point( _sca[0] - hh, -hh));
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
				array_push(triangles, [ new Point(cx, cy), new Point(ox, oy), new Point(nx, ny) ]);
				array_push(_seg, new Point(ox, oy));
			}
			array_push(_seg, new Point(nx, ny));
			
			oa = na;
			ox = nx;
			oy = ny;
		}
		
		for( var i = 0; i < array_length(_seg); i++ )
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
			
			array_push(triangles, [ new Point(ix0, iy0), new Point(nx0, ny0), new Point(nx1, ny1) ]);
			array_push(triangles, [ new Point(ix0, iy0), new Point(nx1, ny1), new Point(ix1, iy1) ]);
			
			if(i == 0)
				array_push(segment, new Point(nx0, ny0));
			array_push(segment, new Point(nx1, ny1));
		}
		
		return [
			[{ type: SHAPE_TYPE.triangles, triangles: triangles }],
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
			
			array_push(triangles, [ new Point(ix0, iy0), new Point(nx0, ny0), new Point(nx1, ny1) ]);
			array_push(triangles, [ new Point(ix0, iy0), new Point(nx1, ny1), new Point(ix1, iy1) ]);
			
			if(i == 0)
				array_push(segment, new Point(nx0, ny0));
			
			if(i % 2) {
				var tx0 = nx0 + lengthdir_x(teth, (i + 0.5 - teethT) / prec * 360) * _sca[0] * 2;
				var ty0 = ny0 + lengthdir_y(teth, (i + 0.5 - teethT) / prec * 360) * _sca[1] * 2;
			
				var tx1 = nx1 + lengthdir_x(teth, (i + 0.5 + teethT) / prec * 360) * _sca[0] * 2;
				var ty1 = ny1 + lengthdir_y(teth, (i + 0.5 + teethT) / prec * 360) * _sca[1] * 2;
				
				array_push(triangles, [ new Point(tx0, ty0), new Point(nx0, ny0), new Point(nx1, ny1) ]);
				array_push(triangles, [ new Point(tx0, ty0), new Point(nx1, ny1), new Point(tx1, ty1) ]);
				
				array_push(segment, new Point(tx0, ty0));
				array_push(segment, new Point(tx1, ty1));
			}
			
			array_push(segment, new Point(nx1, ny1));
		}
		
		return [
			[{ type: SHAPE_TYPE.triangles, triangles: triangles }],
			segment
		];
	}
	
	function SHAPE_cross(_sca, data = {}) {
		var inner = data.inner;
		var triangles = [];
		var segment   = [];
		var side = min(_sca[0], _sca[1]) * inner;
		
		array_push(triangles,
			[ new Point(-side, -side), new Point( side, -side), new Point(-side, side) ],
			[ new Point( side, -side), new Point(-side,  side), new Point( side, side) ],
		);
		
		array_push(triangles, //top
			[ new Point(-side, -side), new Point( side,    -side), new Point(-side, -_sca[1]) ],
			[ new Point( side, -side), new Point(-side, -_sca[1]), new Point( side, -_sca[1]) ],
		);
		
		array_push(triangles, //bottom
			[ new Point(-side, _sca[1]), new Point( side, _sca[1]), new Point(-side, side) ],
			[ new Point( side, _sca[1]), new Point(-side,    side), new Point( side, side) ],
		);
		
		array_push(triangles, //left
			[ new Point(   -side, -side), new Point(-_sca[0], -side), new Point(-side,    side) ],
			[ new Point(-_sca[0], -side), new Point(-side,     side), new Point(-_sca[0], side) ],
		);
		
		array_push(triangles, //right
			[ new Point(_sca[0], -side), new Point( side,   -side), new Point(_sca[0], side) ],
			[ new Point(   side, -side), new Point(_sca[0],  side), new Point(   side, side) ],
		);
		
		array_push(segment, new Point(-side, -side),   new Point(-side, -_sca[1]), new Point( side, -_sca[1]), new Point(side, -side) );
		array_push(segment, new Point(_sca[0], -side), new Point(_sca[0], side), new Point( side, side));
		array_push(segment, new Point(side, _sca[1]), new Point(-side, _sca[1]), new Point(-side, side));
		array_push(segment, new Point(-_sca[0], side), new Point(-_sca[0], -side), new Point(-side, -side));
		
		return [
			[{ type: SHAPE_TYPE.triangles, triangles: triangles }],
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
			
				array_push(triangles, [ new Point(ix0, iy0), new Point(nx0, ny0), new Point(nx1, ny1) ]);
				array_push(triangles, [ new Point(ix0, iy0), new Point(nx1, ny1), new Point(ix1, iy1) ]);
			}
			
			array_push(sgArcI, new Point(ix1, iy1));
			array_push(sgArcO, new Point(nx1, ny1));
			
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
			
				if(i) array_push(triangles, [ new Point(cx, cy), new Point(ox, oy), new Point(nx, ny) ]);
				
				array_push(sgCapI, new Point(nx, ny));
				
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
				
				if(i) array_push(triangles, [ new Point(cx, cy), new Point(ox, oy), new Point(nx, ny) ]);
				
				array_push(sgCapO, new Point(nx, ny));
				
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
			[{ type: SHAPE_TYPE.triangles, triangles: triangles }],
			segment
		];
	}
	
#endregion
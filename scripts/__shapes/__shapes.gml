#region shapes
	global.SHAPES = [];
	
	enum SHAPE_TYPE {
		points,
		triangles,
	}
	
	function SHAPE_rectangle(_sca) {
		var triangles = [
							[[-_sca[0], -_sca[1]], [ _sca[0], -_sca[1]], [-_sca[0],  _sca[1]]],
							[[ _sca[0], -_sca[1]], [-_sca[0],  _sca[1]], [ _sca[0],  _sca[1]]],
						];
		return [{ type: SHAPE_TYPE.triangles, triangles: triangles }];
	}
	
	function SHAPE_circle(_sca, data = {}) {
		var prec = max(3, data.side);
		var points = [];
		
		for( var i = 0; i < prec; i++ ) 
			array_push(points, [ lengthdir_x(0.5, i / prec * 360) * _sca[0] * 2, lengthdir_y(0.5, i / prec * 360) * _sca[1] * 2 ]);
		
		return [{ type: SHAPE_TYPE.points, points: points }];
	}
	
	function SHAPE_star(_sca, data = {}) {
		var prec  = max(3, data.side);
		var inner = data.inner;
		var triangles = [];
		
		for( var i = 0; i < prec; i++ ) {
			var otx = lengthdir_x(0.5, i / prec * 360) * _sca[0] * 2;
			var oty = lengthdir_y(0.5, i / prec * 360) * _sca[1] * 2;
			
			var inx = lengthdir_x(inner / 2, (i + 0.5) / prec * 360) * _sca[0] * 2;
			var iny = lengthdir_y(inner / 2, (i + 0.5) / prec * 360) * _sca[1] * 2;
			
			array_push(triangles, [ [0, 0], [otx, oty], [inx, iny] ]);
			
			var inx = lengthdir_x(inner / 2, (i - 0.5) / prec * 360) * _sca[0] * 2;
			var iny = lengthdir_y(inner / 2, (i - 0.5) / prec * 360) * _sca[1] * 2;
			
			array_push(triangles, [ [0, 0], [otx, oty], [inx, iny] ]);
		}
		
		return [{ type: SHAPE_TYPE.triangles, triangles: triangles }];
	}
	
	function SHAPE_capsule(_sca, data = {}) {
		var rad		= data.radius;
		var prec    = max(2, data.side);
		var hh		= _sca[1] * rad;
		var shapes  = [];
		
		var triangles = [
			[[-_sca[0] + _sca[1], -_sca[1]], [ _sca[0] - hh, -hh],           [-_sca[0] + _sca[1],  _sca[1]]],
			[[ _sca[0] - hh,      -hh],      [-_sca[0] + _sca[1],  _sca[1]], [ _sca[0] - hh,       hh]],
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
			
			if(i) array_push(triangles, [[cx, cy], [ox, oy], [nx, ny]]);
			
			oa = na;
			ox = nx;
			oy = ny;
		}
	
		shapes[1] = { type: SHAPE_TYPE.triangles, triangles: triangles };
		
		var triangles = [];
		var cx = _sca[0] - hh;
		var cy = 0;
		var ox, oy, nx, ny, oa, na;
		for( var i = 0; i <= prec; i++ ) {
			na = lerp(-90, 90, i / prec);
			nx = cx + lengthdir_x(hh, na);
			ny = cy + lengthdir_y(hh, na);
			
			if(i) array_push(triangles, [[cx, cy], [ox, oy], [nx, ny]]);
			
			oa = na;
			ox = nx;
			oy = ny;
		}
	
		shapes[2] = { type: SHAPE_TYPE.triangles, triangles: triangles };
		
		return shapes;
	}
	
	function SHAPE_ring(_sca, data = {}) {
		var prec  = max(3, data.side);
		var inner = data.inner;
		var triangles = [];
		
		for( var i = 0; i < prec; i++ ) {
			var ix0 = lengthdir_x(0.5 * inner, i / prec * 360) * _sca[0] * 2;
			var iy0 = lengthdir_y(0.5 * inner, i / prec * 360) * _sca[1] * 2;
			
			var nx0 = lengthdir_x(0.5, i / prec * 360) * _sca[0] * 2;
			var ny0 = lengthdir_y(0.5, i / prec * 360) * _sca[1] * 2;
			
			var ix1 = lengthdir_x(0.5 * inner, (i + 1) / prec * 360) * _sca[0] * 2;
			var iy1 = lengthdir_y(0.5 * inner, (i + 1) / prec * 360) * _sca[1] * 2;
			
			var nx1 = lengthdir_x(0.5, (i + 1) / prec * 360) * _sca[0] * 2;
			var ny1 = lengthdir_y(0.5, (i + 1) / prec * 360) * _sca[1] * 2;
			
			array_push(triangles, [[ix0, iy0], [nx0, ny0], [nx1, ny1]]);
			array_push(triangles, [[ix0, iy0], [nx1, ny1], [ix1, iy1]]);
		}
		
		return [{ type: SHAPE_TYPE.triangles, triangles: triangles }];
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
		
		for( var i = 0; i < prec; i++ ) {
			var ix0 = lengthdir_x(body * inner, i / prec * 360) * _sca[0] * 2;
			var iy0 = lengthdir_y(body * inner, i / prec * 360) * _sca[1] * 2;
			
			var nx0 = lengthdir_x(body, i / prec * 360) * _sca[0] * 2;
			var ny0 = lengthdir_y(body, i / prec * 360) * _sca[1] * 2;
			
			var ix1 = lengthdir_x(body * inner, (i + 1) / prec * 360) * _sca[0] * 2;
			var iy1 = lengthdir_y(body * inner, (i + 1) / prec * 360) * _sca[1] * 2;
			
			var nx1 = lengthdir_x(body, (i + 1) / prec * 360) * _sca[0] * 2;
			var ny1 = lengthdir_y(body, (i + 1) / prec * 360) * _sca[1] * 2;
			
			array_push(triangles, [[ix0, iy0], [nx0, ny0], [nx1, ny1]]);
			array_push(triangles, [[ix0, iy0], [nx1, ny1], [ix1, iy1]]);
			
			if(i % 2) {
				var tx0 = nx0 + lengthdir_x(teth, (i + 0.5 - teethT) / prec * 360) * _sca[0] * 2;
				var ty0 = ny0 + lengthdir_y(teth, (i + 0.5 - teethT) / prec * 360) * _sca[1] * 2;
			
				var tx1 = nx1 + lengthdir_x(teth, (i + 0.5 + teethT) / prec * 360) * _sca[0] * 2;
				var ty1 = ny1 + lengthdir_y(teth, (i + 0.5 + teethT) / prec * 360) * _sca[1] * 2;
				
				array_push(triangles, [[tx0, ty0], [nx0, ny0], [nx1, ny1]]);
				array_push(triangles, [[tx0, ty0], [nx1, ny1], [tx1, ty1]]);
			}
		}
		
		return [{ type: SHAPE_TYPE.triangles, triangles: triangles }];
	}
	
	function SHAPE_cross(_sca, data = {}) {
		var inner = data.inner;
		var triangles = [];
		var side = min(_sca[0], _sca[1]) * inner;
		
		array_push(triangles,
			[[-side, -_sca[1]], [ side, -_sca[1]], [-side,  _sca[1]]],
			[[ side, -_sca[1]], [-side,  _sca[1]], [ side,  _sca[1]]],
		);
		
		array_push(triangles, 
			[[-_sca[0], -side], [ _sca[0], -side], [-_sca[0],  side]],
			[[ _sca[0], -side], [-_sca[0],  side], [ _sca[0],  side]],
		);
		
		return [{ type: SHAPE_TYPE.triangles, triangles: triangles }];
	}
	
	function SHAPE_arc(_sca, data = {}) {
		var prec   = max(3, data.side);
		var inner  = data.inner;
		var radRan = data.radRan;
		var cap    = data.cap;
		var triangles = [];
		
		var oa, na;		
		for( var i = 0; i <= prec; i++ ) {
			na = lerp(radRan[0], radRan[1], i / prec);
			
			if(i) {
				var ix0 = lengthdir_x(0.5 * inner, oa) * _sca[0] * 2;
				var iy0 = lengthdir_y(0.5 * inner, oa) * _sca[1] * 2;
			
				var nx0 = lengthdir_x(0.5, oa) * _sca[0] * 2;
				var ny0 = lengthdir_y(0.5, oa) * _sca[1] * 2;
			
				var ix1 = lengthdir_x(0.5 * inner, na) * _sca[0] * 2;
				var iy1 = lengthdir_y(0.5 * inner, na) * _sca[1] * 2;
			
				var nx1 = lengthdir_x(0.5, na) * _sca[0] * 2;
				var ny1 = lengthdir_y(0.5, na) * _sca[1] * 2;
			
				array_push(triangles, [[ix0, iy0], [nx0, ny0], [nx1, ny1]]);
				array_push(triangles, [[ix0, iy0], [nx1, ny1], [ix1, iy1]]);
			}
			
			oa = na;
		}
		
		if(cap) { 
			var cx = lengthdir_x(0.5 * (inner + 1) / 2, radRan[0]) * _sca[0] * 2;
			var cy = lengthdir_y(0.5 * (inner + 1) / 2, radRan[0]) * _sca[1] * 2;
			var ox, oy, nx, ny, oa, na;
			
			for( var i = 0; i <= prec; i++ ) {
				na = radRan[0] - 180 * i / prec;
				nx = cx + lengthdir_x((1 - inner) / 2, na) * _sca[0];
				ny = cy + lengthdir_y((1 - inner) / 2, na) * _sca[1];
			
				if(i) array_push(triangles, [[cx, cy], [ox, oy], [nx, ny]]);
			
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
				
				if(i) array_push(triangles, [[cx, cy], [ox, oy], [nx, ny]]);
			
				oa = na;
				ox = nx;
				oy = ny;
			}
		}
		
		return [{ type: SHAPE_TYPE.triangles, triangles: triangles }];
	}
	
#endregion
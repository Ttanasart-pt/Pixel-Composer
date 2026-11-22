function point_in_triangle_3d(px, py, pz, t0x, t0y, t0z, t1x, t1y, t1z, t2x, t2y, t2z) {
	var v0x = t2x - t0x, v0y = t2y - t0y, v0z = t2z - t0z;
	var v1x = t1x - t0x, v1y = t1y - t0y, v1z = t1z - t0z;
	var v2x = px - t0x, v2y = py - t0y, v2z = pz - t0z;
	
	var dot00 = dot_product_3d(v0x, v0y, v0z, v0x, v0y, v0z);
	var dot01 = dot_product_3d(v0x, v0y, v0z, v1x, v1y, v1z);
	var dot02 = dot_product_3d(v0x, v0y, v0z, v2x, v2y, v2z);
	var dot11 = dot_product_3d(v1x, v1y, v1z, v1x, v1y, v1z);
	var dot12 = dot_product_3d(v1x, v1y, v1z, v2x, v2y, v2z);
	
	var invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
	var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	var v = (dot00 * dot12 - dot01 * dot02) * invDenom;
	
	return (u >= 0) && (v >= 0) && (u + v <= 1);
}

function calculate_polygon_normal(verticies) {
	var len = array_length(verticies);
	var nx = 0, ny = 0, nz = 0;
	
	for( var i = 0; i < len; i++ ) {
		var v0 = verticies[i];
		var v1 = verticies[(i + 1) % len];
		var v2 = verticies[(i + 2) % len];
		var cp = cross_product_3d(v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
		
		nx += cp.x;
		ny += cp.y;
		nz += cp.z;
	}
	
	var len_norm = sqrt(nx * nx + ny * ny + nz * nz);
	if(len_norm == 0) return new __vec3(0, 0, 1);
	
	return new __vec3(nx / len_norm, ny / len_norm, nz / len_norm);
}

function vertex_classify(verticies) {
	var len  = array_length(verticies);	
	var maxx = -infinity;
	var maxindex = 0;
	
	for( var i = 0; i < len; i++ ) {
		var _x = verticies[i].x;
		if(_x > maxx) {
			maxx    = _x;
			maxindex = i;
		}
	}
	
	var normal = calculate_polygon_normal(verticies);
	var side, _side = 0;
	var convexs     = [];
	var reflects    = [];
	var startindex  = (maxindex - 1 + len) % len;
	
	for( var i = 0; i < len; i++ ) {
		var index = (startindex + i) % len;
		var _p0 = verticies[index];
		var _p1 = verticies[(index + 1) % len];
		var _p2 = verticies[(index + 2) % len];
		
		var cross = cross_product_3d(_p0.x, _p0.y, _p0.z, _p1.x, _p1.y, _p1.z, _p2.x, _p2.y, _p2.z);
		var side = dot_product_3d(cross.x, cross.y, cross.z, normal.x, normal.y, normal.z);
		
		if(_side != 0 && sign(_side) != sign(side))
			array_push(reflects, (index + 1) % len);
			
		else {
			array_push(convexs, (index + 1) % len);
			_side = sign(side);
		}
	}
			
	return [ convexs, reflects, _side ];
}

function vertex_triangulate_convex(verticies) {
	var triangles = [];
	var len = array_length(verticies);
	
	var c0  = verticies[0];
	for( var i = 0; i < len - 2; i++ ) {
		var c1 = verticies[safe_mod(i + 1, len)];
		var c2 = verticies[safe_mod(i + 2, len)];
		array_push(triangles, [c0, c1, c2]);
	}
	
	return triangles;
}

function vertex_triangulate(verticies) { // ear clipping
	if(array_length(verticies) < 3) return [ [], verticies, 1 ];
	
	var classes   = vertex_classify(verticies);
	var convexes  = classes[0];
	var reflected = classes[1];
	var checkSide = classes[2];
	
	if(array_length(reflected) == 0) 
		return [ vertex_triangulate_convex(verticies), verticies, checkSide ];
	
	var pointInd  = array_create_ext(array_length(verticies), function(i) /*=>*/ { return i; });
	var triangles = [];
	var repeated  = 0;
	var normal    = calculate_polygon_normal(verticies);
	
	// print($"Ear cutting : {verticies}");
	
	while(array_length(pointInd) > 3) {
		if(array_length(convexes) == 0) return [ triangles, verticies, checkSide ];
		
		var len = array_length(pointInd);
		var c0  = convexes[0];
		var c0i = array_find(pointInd, c0);
		var c1  = pointInd[safe_mod(c0i - 1 + len, len)];
		var c2  = pointInd[safe_mod(c0i + 1, len)];
		
		var p0 = verticies[c0];
		var p1 = verticies[c1];
		var p2 = verticies[c2];
		
		//check if point is ear
		var isEar = true;
		for( var i = 0; i < len; i++ ) {
			var ind = pointInd[i];
			if(ind == c0 || ind == c1 || ind == c2) continue;
			
			var p = verticies[ind];
			if(point_in_triangle_3d(p.x, p.y, p.z, p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, p2.x, p2.y, p2.z)) {
				isEar = false;
				break;
			}
		}
		
		if(isEar) {
			array_remove(convexes, c0);
			array_remove(pointInd, c0);
			
			array_push(triangles, [p0, p1, p2]);
			len--;
			
			if(array_exists(reflected, c1)) {
				var c1i = array_find(pointInd, c1);
				var c1b = safe_mod(c1i - 1 + len, len);
				var c1a = safe_mod(c1i + 1, len);
				
				var p1b = verticies[pointInd[c1b]];
				var p1a = verticies[pointInd[c1a]];
				
				var cross = cross_product_3d(p1b.x, p1b.y, p1b.z, p1.x, p1.y, p1.z, p1a.x, p1a.y, p1a.z);
				var side = dot_product_3d(cross.x, cross.y, cross.z, normal.x, normal.y, normal.z);
				
				if(sign(side) == checkSide) {
					array_remove(reflected, c1);
					array_push(convexes, c1);
				}
			}
			
			if(array_exists(reflected, c2)) {
				var c2i = array_find(pointInd, c2);
				var c2b = safe_mod(c2i - 1 + len, len);
				var c2a = safe_mod(c2i + 1, len);
				
				var p2b = verticies[pointInd[c2b]];
				var p2a = verticies[pointInd[c2a]];
				
				var cross = cross_product_3d(p2b.x, p2b.y, p2b.z, p2.x, p2.y, p2.z, p2a.x, p2a.y, p2a.z);
				var side = dot_product_3d(cross.x, cross.y, cross.z, normal.x, normal.y, normal.z);
				
				if(sign(side) == checkSide) {
					array_remove(reflected, c2);
					array_push(convexes, c2);
				}
			}
			
			repeated = 0;
			
		} else {
			array_remove(convexes, c0);
			array_push(convexes, c0);
			
			if(repeated++ > len) break;
		}
	}
	
	if(array_length(pointInd) == 3) 
		array_push(triangles, [ verticies[pointInd[0]], verticies[pointInd[1]], verticies[pointInd[2]] ]);
	
	return [ triangles, verticies, checkSide ];
}
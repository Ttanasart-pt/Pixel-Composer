function polygon_simplify(points, tolerance = 4) {
	
	// Delete duplicated points
	for( var i = array_length(points) - 1; i >= 1; i-- ) {
		if(points[i].equal(points[i - 1]))
			array_delete(points, i, 1);
	}
	if(points[0].equal(array_last(points)))
		array_pop(points);
	
	var remSt = ds_stack_create();
	var len   = array_length(points);
	
	for( var i = 0; i < len; i++ ) {
		var _px0 = points[(i - 1 + len) % len].x;
		var _py0 = points[(i - 1 + len) % len].y;
		var _px1 = points[i].x;
		var _py1 = points[i].y;
		var _px2 = points[(i + 1 + len) % len].x;
		var _py2 = points[(i + 1 + len) % len].y;
		
		var dir0 = point_direction(_px0, _py0, _px1, _py1);
		var dir1 = point_direction(_px1, _py1, _px2, _py2);
		
		if((_px0 == _px1 && _py0 == _py1) || abs(dir0 - dir1) <= tolerance) 
			ds_stack_push(remSt, i);
	}
	
	while(!ds_stack_empty(remSt)) {
		var ind = ds_stack_pop(remSt);
		array_delete(points, ind, 1);
	}
	
	ds_stack_destroy(remSt);
	
	return points;
}

function polygon_points_classify(points) {
	var len = array_length(points);
	
	var maxx = -99999;
	var maxindex = 0;
	
	for( var i = 0; i < len; i++ ) {
		var _x = points[i].x;
		if(_x > maxx) {
			maxx = _x;
			maxindex = i;
		}
	}
	
	var side, _side = 0;
	var convexs     = [];
	var reflects    = [];
	var startindex  = (maxindex - 1 + len) % len;
	
	for( var i = 0; i < len; i++ ) {
		var index = (startindex + i) % len;
		var _px0 = points[index].x;
		var _py0 = points[index].y;
		var _px1 = points[(index + 1) % len].x;
		var _py1 = points[(index + 1) % len].y;
		var _px2 = points[(index + 2) % len].x;
		var _py2 = points[(index + 2) % len].y;
		
		var side = cross_product(_px0, _py0, _px1, _py1, _px2, _py2);
		
		if(_side != 0 && sign(_side) != sign(side))
			array_push(reflects, (index + 1) % len);
		else {
			array_push(convexs, (index + 1) % len);
			_side = sign(side);
		}
	}
			
	return [ convexs, reflects, _side ];
}

function polygon_triangulate_convex(points) {
	var triangles = [];
	
	var len = array_length(points);
	var c0 = points[0];
	
	for( var i = 0; i < len - 2; i++ ) {
		var c1 = points[safe_mod(i + 1, len)];
		var c2 = points[safe_mod(i + 2, len)];
		
		array_push(triangles, [c0, c1, c2]);
	}
	
	return triangles;
}

function polygon_triangulate(points, tolerance = 4) { // ear clipping
	if(array_length(points) < 3) return [ [], points, 1 ];
	
	if(tolerance > 0) points = polygon_simplify(points, tolerance);
	if(array_length(points) < 3) return [ [], points, 1 ];
	
	var classes   = polygon_points_classify(points);
	var convexes  = classes[0];
	var reflected = classes[1];
	var checkSide = classes[2];
	
	if(array_length(reflected) == 0) 
		return [ polygon_triangulate_convex(points), points, checkSide ];
	
	var pointInd  = array_create_ext(array_length(points), function(i) /*=>*/ { return i; });
	var triangles = [];
	var repeated  = 0;
	
	// print($"Ear cutting : {points}");
	
	while(array_length(pointInd) > 3) {
		if(array_length(convexes) == 0) return [ triangles, points, checkSide ];
		
		var len = array_length(pointInd);
		var c0  = convexes[0];
		var c0i = array_find(pointInd, c0);
		var c1  = pointInd[safe_mod(c0i - 1 + len, len)];
		var c2  = pointInd[safe_mod(c0i + 1, len)];
		
		var p0 = points[c0];
		var p1 = points[c1];
		var p2 = points[c2];
		
		//check if point is ear
		var isEar = true;
		for( var i = 0; i < len; i++ ) {
			var ind = pointInd[i];
			if(ind == c0 || ind == c1 || ind == c2) continue;
			
			var p = points[ind];
			if(point_in_triangle(p.x, p.y, p0.x, p0.y, p1.x, p1.y, p2.x, p2.y)) {
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
				
				var p1b = points[pointInd[c1b]];
				var p1a = points[pointInd[c1a]];
				
				var side = cross_product(p1b.x, p1b.y, p1.x, p1.y, p1a.x, p1a.y);
				if(sign(side) == checkSide) {
					array_remove(reflected, c1);
					array_push(convexes, c1);
				}
			}
			
			if(array_exists(reflected, c2)) {
				var c2i = array_find(pointInd, c2);
				var c2b = safe_mod(c2i - 1 + len, len);
				var c2a = safe_mod(c2i + 1, len);
				
				var p2b = points[pointInd[c2b]];
				var p2a = points[pointInd[c2a]];
				
				var side = cross_product(p2b.x, p2b.y, p2.x, p2.y, p2a.x, p2a.y);
				if(sign(side) == checkSide) {
					array_remove(reflected, c2);
					array_push(convexes, c2);
				}
			}
			
			repeated = 0;
		} else {
			array_remove(convexes, c0);
			array_push(convexes, c0);
			
			if(repeated++ > len) {
				// print($"point: {points}");
				// print($"index: {pointInd}");
				// print($"convx: {convexes}");
				
				// for (var i = 0, n = array_length(pointInd); i < n; i++)
				// 	print(points[pointInd[i]]);
				
				// noti_warning("Mesh error");
				break;
			}
		}
	}
	
	if(array_length(pointInd) == 3) 
		array_push(triangles, [ points[pointInd[0]], points[pointInd[1]], points[pointInd[2]] ]);
	
	return [ triangles, points, checkSide ];
}

function polygon_triangulate_convex_fan(points) {
	var triangles = [];
	
	var amo = array_length(points);
	var cx  = 0;
	var cy  = 0;
	for( var i = 0; i < amo; i++ ) {
		cx += points[i].x;
		cy += points[i].y;
	}
	
	cx /= amo;
	cy /= amo;
	
	var pc = new __vec2(cx, cy);
	for( var i = 0; i < amo; i++ )
		array_push(triangles, [ points[i], points[(i + 1) % amo], pc ]);
	
	return triangles;
}
function generate_point_in_polygon(polygon, amount = 1) {
	var minX, maxX, minY, maxY;
    var pointsInside = [];
	
	if(array_length(polygon) < 3) return pointsInside;

    // Find the minimum and maximum X and Y coordinates of the polygon
    for (var i = 0; i < array_length(polygon); i++) {
        var point = polygon[i];
        var _x = point[0];
        var _y = point[1];

        if (i == 0) {
            minX = _x;
            maxX = _x;
            minY = _y;
            maxY = _y;
        } else {
            if (_x < minX) minX = _x;
            if (_x > maxX) maxX = _x;
            if (_y < minY) minY = _y;
            if (_y > maxY) maxY = _y;
        }
    }

    // Generate random points inside the polygon
    for (var j = 0; j < amount; j++) {
        var pointInside = [ random_range(minX, maxX), random_range(minY, maxY) ];
        var numIntersections = 0;

        for (var k = 0; k < array_length(polygon); k++) {
            var currentPoint = polygon[k];
            var nextPoint = polygon[(k + 1) mod array_length(polygon)];

            if ((currentPoint[1] > pointInside[1]) != (nextPoint[1] > pointInside[1])) {
                var intersectX = (nextPoint[0] - currentPoint[0]) * (pointInside[1] - currentPoint[1]) /
                                 (nextPoint[1] - currentPoint[1]) + currentPoint[0];

                if (pointInside[0] < intersectX)
                    numIntersections++;
            }
        }

        if (numIntersections % 2 == 1)
            array_push(pointsInside, pointInside);
    }

    return pointsInside;
}

function point_in_polygon(px, py, polygon) {
	var minX, maxX, minY, maxY;
    
	if(array_length(polygon) < 3) return false;

    // Find the minimum and maximum X and Y coordinates of the polygon
    for (var i = 0; i < array_length(polygon); i++) {
        var point = polygon[i];
        var _x = point[0];
        var _y = point[1];

        if (i == 0) {
            minX = _x;
            maxX = _x;
            minY = _y;
            maxY = _y;
        } else {
            if (_x < minX) minX = _x;
            if (_x > maxX) maxX = _x;
            if (_y < minY) minY = _y;
            if (_y > maxY) maxY = _y;
        }
    }

    var numIntersections = 0;

    for (var k = 0; k < array_length(polygon); k++) {
        var currentPoint = polygon[k];
        var nextPoint = polygon[(k + 1) mod array_length(polygon)];

        if ((currentPoint[1] > py) != (nextPoint[1] > py)) {
            var intersectX = (nextPoint[0] - currentPoint[0]) * (py - currentPoint[1]) /
                                (nextPoint[1] - currentPoint[1]) + currentPoint[0];

            if (px < intersectX)
                numIntersections++;
        }
    }

	return numIntersections % 2 == 1;
}
function sprite_pack_best_fit(rectangles) {
	
	var area = new Rectangle(0, 0, 0, 0);
	if(array_length(rectangles) <= 1) return [ area, rectangles ];
	
    array_sort(rectangles, function(r1, r2) /*=>*/ {return sign(r2.w * r2.h - r1.w * r1.h)});
	
	var grW  = rectangles[0].w;
	var grH  = rectangles[0].h;
	var _or, _nr;
	
	for( var i = 1, n = array_length(rectangles); i < n; i++ ) {
        _nr = rectangles[i];
		
		grW = gcd(_nr.w, grW);
		grH = gcd(_nr.h, grH);
	}
	
    for( var i = 0, n = array_length(rectangles); i < n; i++ ) {
        var rect = rectangles[i];

        var bestSpace = noone;
        var bestArea  = new Rectangle(0, 0, 0, 0);
		
        for (var xx = area.x; xx <= area.x + area.w; xx += grW)
        for (var yy = area.y; yy <= area.y + area.h; yy += grH) {
            var space = new Rectangle(xx, yy, rect.w, rect.h);
            if (space.x + space.w > area.x + area.w || space.y + space.h > area.y + area.h)
                continue;
				
            var overlaps = false;
            for (var j = 0; j < i; j++) {
                var otherRect = rectangles[j];
                if (rectangleOverlap(space, otherRect)) {
                    overlaps = true;
                    break;
                }
            }
				
            if (!overlaps && (bestSpace == noone || space.w * space.h < bestSpace.w * bestSpace.h)) {
                bestSpace = space;
                bestArea = new Rectangle(area.x, area.y, area.w, area.h);
            }
        }

        if (bestSpace == noone) {
            area.w = max(area.w, rect.w);
            area.h += rect.h;
            rectangles[i].x = area.x;
            rectangles[i].y = area.y + area.h - rect.h;
        } else {
            rectangles[i].x = bestSpace.x;
            rectangles[i].y = bestSpace.y;
            area = bestArea;
        }
    }
	
	return [ area, rectangles ];
}

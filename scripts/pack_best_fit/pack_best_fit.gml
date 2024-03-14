function sprite_pack_best_fit(rectangles) {
    array_sort(rectangles, function(rect1, rect2) {
        return rect2.w * rect2.h - rect1.w * rect1.h;
    });
	
    var area = new Rectangle(0, 0, 0, 0);
	
	var grW = 1;
	var grH = 1;
	var _or, _nr;
	
    for (var i = 0; i < array_length(rectangles); i++) {
        _nr = rectangles[i];
		
		if(i) {
			grW = gcd(_nr.w, grW);
			grH = gcd(_nr.h, grH);
		} else {
			grW = _nr.w;
			grH = _nr.h;
		}
	}
	
    for (var i = 0; i < array_length(rectangles); i++) {
        var rect = rectangles[i];

        var bestSpace = noone;
        var bestArea = new Rectangle(0, 0, 0, 0);
		
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

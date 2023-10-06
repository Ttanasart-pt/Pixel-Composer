function sprite_pack_skyline(rectangles, width, height) {
	var maxw = 0;
	var maxh = 0;
    
    array_sort(rectangles, function(a, b) {
        return b.w - a.w;
    });
    
    var skyline = [ new Rectangle(0, 0, width, height) ];
    var packed  = [];
	
    for (var i = 0; i < array_length(rectangles); i++) {
        var rect = rectangles[i];
        var bestStrip  = noone;
        var bestWasted = width * height;
        
        for (var j = 0; j < array_length(skyline); j++) {
            var strip = skyline[j];
            if (strip.w >= rect.w && strip.h >= rect.h) {
                var wasted = strip.w * strip.h;
                if (wasted <= bestWasted) {
                    bestStrip = strip;
                    bestWasted = wasted;
                }
            }
        }
        
        if (bestStrip == noone) continue;
		
        rect.x = bestStrip.x;
        rect.y = bestStrip.y;
        array_push(packed, rect);
			
        if (bestStrip.w > rect.w)
            array_push(skyline, new Rectangle(bestStrip.x + rect.w, bestStrip.y, bestStrip.w - rect.w, bestStrip.h));
            
        if (bestStrip.h > rect.h)
            array_push(skyline, new Rectangle(bestStrip.x, bestStrip.y + rect.h, rect.w, bestStrip.h - rect.h));
            
        array_remove(skyline, bestStrip);
            
        array_sort(skyline, function(a, b) {
            return a.x - b.x;
        });
		
		maxw = max(maxw, rect.x + rect.w);
		maxh = max(maxh, rect.y + rect.h);
    }
    
    return [ new Rectangle(0, 0, maxw, maxh), packed ];
}

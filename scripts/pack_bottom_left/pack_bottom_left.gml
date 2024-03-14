function sprite_pack_bottom_left(rectangles, height = 999999) {
    var packedRectangles = [];
    var maxW = 0;
    var maxH = 0;
	
    array_sort(rectangles, function(a, b) { return b.h - a.h; });
    
    var xx = 0;
    for (var i = 0; i < array_length(rectangles); i++) {
        var rect = rectangles[i];
        var placed = false;
        
        for (var j = 0; j < array_length(packedRectangles); j++) {
            var packedRect = packedRectangles[j];
            if (packedRect.w >= rect.w && packedRect.h + rect.h <= height) {
                rect.x = packedRect.x;
                rect.y = packedRect.y + packedRect.h;
                packedRect.h += rect.h;
                placed = true;
                break;
            }
        }
        
        if (!placed) {
            rect.x = xx;
            rect.y = 0;
            xx += rect.w;
			array_push(packedRectangles, rect.clone());
        }
		
		maxW = max(maxW, rect.x + rect.w);
		maxH = max(maxH, rect.y + rect.h);
    }
	
    return [ new Rectangle(0, 0, maxW, maxH), rectangles ];
}

function sprite_pack_shelf(rectangles, width) {
	array_sort(rectangles, function(rect1, rect2) {
        return rect2.h - rect1.h;
    });
	
    var shelfY = 0;
    var shelfWidth = 0;
    var shelfHeight = 0;
    var shelfItems = [];
    var packedRectangles = [];
	
	var maxWidth  = 0;
	var maxHeight = 0;
	
	for (var i = 0; i < array_length(rectangles); i++) //make sure the width is larger than largest rectangle
		width = max(width, rectangles[i].w);
	
    for (var i = 0; i < array_length(rectangles); i++) {
        var rect = rectangles[i];
        
        if (shelfWidth + rect.w <= width) { // Add the rectangle to the current shelf
            rect.x = shelfWidth;
            rect.y = shelfY;
			
            shelfWidth += rect.w;
			shelfHeight = max(shelfHeight, rect.h);
        } else { // Start a new shelf
            shelfY	   += shelfHeight;
			shelfWidth  = rect.w;
			shelfHeight = rect.h;
			
			rect.x = 0;
            rect.y = shelfY;
        }
		
		maxWidth  = max(maxWidth,  rect.x + rect.w);
		maxHeight = max(maxHeight, rect.y + rect.h);
    }

    return [ new Rectangle(0, 0, maxWidth, maxHeight), rectangles ];
}

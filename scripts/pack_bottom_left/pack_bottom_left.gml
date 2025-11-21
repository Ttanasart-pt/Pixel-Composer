function sprite_pack_bottom_left(rectangles, width = 999999) {
    var packedRectangles = [];
    var maxW = 0;
    var maxH = 0;
	
    array_sort(rectangles, function(a, b) /*=>*/ {return sign(b.h - a.h)});
    
    var xx = 0;
    var yy = 0;
    var lh = 0;
    
    for( var i = 0, n = array_length(rectangles); i < n; i++ ) {
        var rect = rectangles[i];
        
        if(xx + rect.w > width) {
        	xx  = 0;
        	yy += lh;
        	lh  = 0;
        }
        
        rect.x = xx;
        rect.y = yy;
        xx += rect.w;
        lh  = max(lh, rect.h);
		array_push(packedRectangles, rect.clone());
        
		maxW = max(maxW, rect.x + rect.w);
		maxH = max(maxH, rect.y + rect.h);
    }
	
    return [ new Rectangle(0, 0, maxW, maxH), rectangles ];
}

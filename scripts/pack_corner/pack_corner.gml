function sprite_pack_corner(rectangles) {
	array_sort(rectangles, function(rect1, rect2) {
        return rect2.w * rect2.h - rect1.w * rect1.h;
    });
	
	var corners    = [ new Rectangle(0, 0, 9999, 9999) ];
	var antiCorner = ds_map_create();
	var maxW = 0;
    var maxH = 0;
		
	for( var i = 0, n = array_length(rectangles); i < n; i++ ) {
		var rect = rectangles[i];
		
		var minScore = 99999;
		var minIndex = 0;
		
		for( var j = 0; j < array_length(corners); j++ ) {
			if(corners[j].w <= rect.w || corners[j].h <= rect.h) continue;
			
			var newW = max(maxW, corners[j].x + rect.w);
			var newH = max(maxH, corners[j].y + rect.h);
			
			var _score = newW + newH;
			if(_score < minScore) {
				minScore = _score;
				minIndex = j;
			}
		}
		
		rect.x = corners[minIndex].x;
		rect.y = corners[minIndex].y;
		array_delete(corners, minIndex, 1);
		
		var c0 = new Rectangle(rect.x + rect.w, rect.y, 9999, 9999);
		if(!ds_map_exists(antiCorner, c0.hashOrigin()) || !antiCorner[? c0.hashOrigin()]) 
			array_push(corners, c0);
		else 
			antiCorner[? c0.hashOrigin()] = false;
		
		var c1 = new Rectangle(rect.x, rect.y + rect.h, 9999, 9999);
		if(!ds_map_exists(antiCorner, c1.hashOrigin()) || !antiCorner[? c1.hashOrigin()]) 
			array_push(corners, c1);
		else 
			antiCorner[? c1.hashOrigin()] = false;
	
		var ac = new Rectangle(rect.x + rect.w, rect.y + rect.h, 9999, 9999);
		antiCorner[? ac.hashOrigin()] = true;
		
		maxW = max(maxW, rect.x + rect.w);
		maxH = max(maxH, rect.y + rect.h);
    }
    
	ds_map_destroy(antiCorner);
	
    return [ new Rectangle(0, 0, maxW, maxH), rectangles ];
}
function line_bresenham(arr, x1, y1, x2, y2, oc, nc) {
	var dx = abs(x2 - x1);
	var dy = abs(y2 - y1);
	var ng = 0;
	
	if(dx < dy) {
		var x1t = x1;
		var x2t = x2;
		var dt  = dx;
		
		x1 = y1;
		y1 = x1t;
		x2 = y2;
		y2 = x2t;
		
		ng = 1;
		
		dx = dy;
		dy = dt;
	}
	
	var pk = 2 * dy - dx;
	
	for( var i = 0; i < dx; i++ ) {
		if(x1 < x2) x1++;
	    else		x1--;
		var cc = merge_color(oc, nc, i / dx);
		
	    if (pk < 0) {
		    if (ng == 0) array_push(arr, [x1, y1, cc]);
			else         array_push(arr, [y1, x1, cc]);
			pk = pk + 2 * dy;
		} else {
			if(y1 < y2) y1++;
			else		y1--;
			
			if (ng == 0) array_push(arr, [x1, y1, cc]);
			else         array_push(arr, [y1, x1, cc]);
			
			pk = pk + 2 * dy - 2 * dx;
		}
	}
}

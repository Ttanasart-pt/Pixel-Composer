function line_intersect(x1, y1, x2, y2, x3, y3, x4, y4) {
	var d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	if(d == 0) return false;
	
	var px = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4);
	var py = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4);
	
	return [ px / d, py / d, d ];
}
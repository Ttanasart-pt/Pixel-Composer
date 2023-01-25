function point_direction_positive(x0, y0, x1, y1) {
	var dir = point_direction(x0, y0, x1, y1);
	if(dir < 0) dir = 360 + dir;
	
	return dir;
}
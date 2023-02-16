function point_rectangle_overlap(w, h, angle) {
	var x0, y0;
	var a1 = radtodeg(arctan2(h, w));
	var a2 = 90 - a1;
		
	if(angle < a1) {
		x0 = w;
		y0 = h / 2 - w / 2 * tan(degtorad(angle));
	} else if(angle < a1 + a2 * 2) {
		x0 = w / 2 - h / 2 * tan(degtorad(angle - 90));
		y0 = 0;
	} else if(angle < a1 + a2 * 2 + a1 * 2) {
		x0 = 0;
		y0 = h / 2 + w / 2 * tan(degtorad(angle - 180));
	} else if(angle < a1 + a2 * 2 + a1 * 2 + a2 * 2) {
		x0 = w / 2 + h / 2 * tan(degtorad(angle - 270));
		y0 = h;
	} else {
		x0 = w;
		y0 = h / 2 - w / 2 * tan(degtorad(angle));
	}
			
	return [x0, y0];
}

function point_in_rectangle_points(px, py, x0, y0, x1, y1, x2, y2, x3, y3) {
	return point_in_triangle(px, py, x0, y0, x1, y1, x2, y2) || point_in_triangle(px, py, x1, y1, x2, y2, x3, y3);
}
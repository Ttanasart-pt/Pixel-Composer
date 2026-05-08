function line_intersect(x1, y1, x2, y2, x3, y3, x4, y4) {
	var d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	if(d == 0) return false;
	
	var px = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4);
	var py = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4);
	
	return [ px / d, py / d, d ];
}

function line_is_intersect_ccw(x0, y0, x1, y1, x2, y2) { return (y2 - y0) * (x1 - x0) > (y1 - y0) * (x2 - x0) }

function line_is_intersect(ax0, ay0, ax1, ay1, bx0, by0, bx1, by1) {
	return line_is_intersect_ccw(ax0, ay0, bx0, by0, bx1, by1) != line_is_intersect_ccw(ax1, ay1, bx0, by0, bx1, by1) && 
	       line_is_intersect_ccw(ax0, ay0, ax1, ay1, bx0, by0) != line_is_intersect_ccw(ax0, ay0, ax1, ay1, bx1, by1)
}

function line_intersect_rect(lx0, ly0, lx1, ly1, rx0, ry0, rx1, ry1) {
	if(point_in_rectangle(lx0, ly0, rx0, ry0, rx1, ry1)) return true;
	if(point_in_rectangle(lx1, ly1, rx0, ry0, rx1, ry1)) return true;

	if(line_is_intersect(lx0, ly0, lx1, ly1, rx0, ry0, rx0, ry1)) return true;
	if(line_is_intersect(lx0, ly0, lx1, ly1, rx0, ry1, rx1, ry1)) return true;
	if(line_is_intersect(lx0, ly0, lx1, ly1, rx1, ry1, rx1, ry0)) return true;
	if(line_is_intersect(lx0, ly0, lx1, ly1, rx1, ry0, rx0, ry0)) return true;

	return false;
}

function line_inside_rect(lx0, ly0, lx1, ly1, rx0, ry0, rx1, ry1) {
	return point_in_rectangle(lx0, ly0, rx0, ry0, rx1, ry1) && point_in_rectangle(lx1, ly1, rx0, ry0, rx1, ry1);
}

function segment_intersect(x0, y0, x1, y1, x2, y2, x3, y3) {
    var a1 = y1 - y0;
    var b1 = x0 - x1;
    var c1 = a1 * x0 + b1 * y0;

    var a2 = y3 - y2;
    var b2 = x2 - x3;
    var c2 = a2 * x2 + b2 * y2;

    var det = a1 * b2 - a2 * b1;

    if(det == 0) return false;

    var xx = (b2 * c1 - b1 * c2) / det;
    var yy = (a1 * c2 - a2 * c1) / det;

    if (xx < min(x0, x1) || xx > max(x0, x1) || xx < min(x2, x3) || xx > max(x2, x3))
        return false;

    if (yy < min(y0, y1) || yy > max(y0, y1) || yy < min(y2, y3) || yy > max(y2, y3))
        return false;

    return [xx, yy];
}
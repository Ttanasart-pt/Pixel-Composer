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

function segment_intersect(sx0, sy0, sx1, sy1, px0, py0, px1, py1) {
    var a1 = sy1 - sy0;
    var b1 = sx0 - sx1;
    var c1 = a1 * sx0 + b1 * sy0;

    var a2 = py1 - py0;
    var b2 = px0 - px1;
    var c2 = a2 * px0 + b2 * py0;

    var det = a1 * b2 - a2 * b1;

    if(det == 0) return false;

    var xx = (b2 * c1 - b1 * c2) / det;
    var yy = (a1 * c2 - a2 * c1) / det;

    if (xx < min(sx0, sx1) || xx > max(sx0, sx1) || xx < min(px0, px1) || xx > max(px0, px1))
        return false;

    if (yy < min(sy0, sy1) || yy > max(sy0, sy1) || yy < min(py0, py1) || yy > max(py0, py1))
        return false;

    return [xx, yy];
}
function eval_bezier_x(t, x0, y0, x1, y1, cx0, cy0, cx1, cy1) { INLINE return power(1 - t, 3) * x0 + 3 * power(1 - t, 2) * (t) * cx0 + 3 * power(t, 2) * (1 - t) * cx1 + power(t, 3) * x1; }
function eval_bezier_y(t, x0, y0, x1, y1, cx0, cy0, cx1, cy1) { INLINE return power(1 - t, 3) * y0 + 3 * power(1 - t, 2) * (t) * cy0 + 3 * power(t, 2) * (1 - t) * cy1 + power(t, 3) * y1; }

function eval_bezier(t, x0, y0, x1, y1, cx0, cy0, cx1, cy1) {
	var xx = power(1 - t, 3) * x0 + 3 * power(1 - t, 2) * (t) * cx0 + 3 * power(t, 2) * (1 - t) * cx1 + power(t, 3) * x1;
	var yy = power(1 - t, 3) * y0 + 3 * power(1 - t, 2) * (t) * cy0 + 3 * power(t, 2) * (1 - t) * cy1 + power(t, 3) * y1;
	
	return [xx, yy];
}

function eval_quadratic(t, x0, y0, x1, y1, cx, cy) {
	var xx = power(1 - t, 2) * x0 + 2 * (1 - t) * (t) * cx + 2 * (t) * (1 - t) * cx + power(t, 2) * x1;
	var yy = power(1 - t, 2) * y0 + 2 * (1 - t) * (t) * cy + 2 * (t) * (1 - t) * cy + power(t, 2) * y1;
	
	return [xx, yy];
}
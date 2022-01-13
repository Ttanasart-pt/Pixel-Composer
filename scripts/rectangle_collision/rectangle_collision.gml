function rectangle_inside_rectangle(bx0, by0, bx1, by1, sx0, sy0, sx1, sy1 ) {
	return min(sx0, sx1) >= min(bx0, bx1) && max(sx0, sx1) <= max(bx0, bx1) &&
		min(sy0, sy1) >= min(by0, by1) && max(sy0, sy1) <= max(by0, by1);
}
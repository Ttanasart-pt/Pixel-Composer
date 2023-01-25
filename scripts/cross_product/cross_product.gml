function cross_product(x0, y0, x1, y1, x2, y2) {
	var X1 = x1 - x0;
    var Y1 = y1 - y0;
 
    var X2 = x2 - x0;
    var Y2 = y2 - y0;
 
    return (X1 * Y2 - Y1 * X2);
}
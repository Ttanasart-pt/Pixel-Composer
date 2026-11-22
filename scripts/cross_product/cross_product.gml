function cross_product(x0, y0, x1, y1, x2, y2) {
	var X1 = x1 - x0;
    var Y1 = y1 - y0;
 
    var X2 = x2 - x0;
    var Y2 = y2 - y0;
 
    return (X1 * Y2 - Y1 * X2);
}

function cross_product_3d(x0, y0, z0, x1, y1, z1, x2, y2, z2) {
	var X1 = x1 - x0;
    var Y1 = y1 - y0;
    var Z1 = z1 - z0;
 
    var X2 = x2 - x0;
    var Y2 = y2 - y0;
    var Z2 = z2 - z0;
 
    return new __vec3(
        Y1 * Z2 - Z1 * Y2,
        Z1 * X2 - X1 * Z2,
        X1 * Y2 - Y1 * X2
    );
}


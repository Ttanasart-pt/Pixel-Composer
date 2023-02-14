function colorFromRGBArray(arr) {
	var r = round(real(arr[0]) * 255);
	var g = round(real(arr[1]) * 255);
	var b = round(real(arr[2]) * 255);
	return make_color_rgb(r, g, b);
}

function colorArrayFromReal(clr) {
	return [color_get_red(clr) / 255, color_get_green(clr) / 255, color_get_blue(clr) / 255 ];	
}

function colorBrightness(clr) {
	var r2 = color_get_red(clr) / 255;
	var g2 = color_get_green(clr) / 255;
	var b2 = color_get_blue(clr) / 255;
	return 0.299 * r2 + 0.587 * g2 + 0.224 * b2;
}

function colorMultiply(c1, c2) {
	var r1 = color_get_red(c1) / 255;
	var g1 = color_get_green(c1) / 255;
	var b1 = color_get_blue(c1) / 255;
	
	var r2 = color_get_red(c2) / 255;
	var g2 = color_get_green(c2) / 255;
	var b2 = color_get_blue(c2) / 255;
	
	return make_color_rgb((r1 * r2) * 255, (g1 * g2) * 255, (b1 * b2) * 255);
}

function color_diff(c1, c2) {
	var _c1_r =  c1 & 255;
	var _c1_g = (c1 >> 8) & 255;
	var _c1_b = (c1 >> 16) & 255;
	var _c1_a = (c1 >> 24) & 255;
	
	_c1_r = _c1_r / 255;
	_c1_g = _c1_g / 255;
	_c1_b = _c1_b / 255;
	_c1_a = _c1_a / 255;
	
	var _c2_r =  c2 & 255;
	var _c2_g = (c2 >> 8) & 255;
	var _c2_b = (c2 >> 16) & 255;
	var _c2_a = (c2 >> 24) & 255;
	
	_c2_r = _c2_r / 255;
	_c2_g = _c2_g / 255;
	_c2_b = _c2_b / 255;
	_c2_a = _c2_a / 255;
	
	var dist = sqrt(sqr(_c1_r - _c2_r) + sqr(_c1_g - _c2_g) + sqr(_c1_b - _c2_b) + sqr(_c1_a - _c2_a));
	return dist;
}
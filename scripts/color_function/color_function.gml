function colorFromRGBArray(arr) {
	var r = round(real(arr[0]) * 255);
	var g = round(real(arr[1]) * 255);
	var b = round(real(arr[2]) * 255);
	return make_color_rgb(r, g, b);
}

function color_get_alpha(color) {
	return (color & (0xFF << 24)) >> 24;
}

function colorArrayFromReal(clr) {
	return [color_get_red(clr) / 255, color_get_green(clr) / 255, color_get_blue(clr) / 255 ];	
}

function colorBrightness(clr, normalize = true) {
	var r2 = color_get_red(clr) /	(normalize? 255 : 1);
	var g2 = color_get_green(clr) / (normalize? 255 : 1);
	var b2 = color_get_blue(clr) /	(normalize? 255 : 1);
	return 0.299 * r2 + 0.587 * g2 + 0.224 * b2;
}

function colorMultiply(c1, c2) {
	if(c1 * c2 == 0) return 0;
	if(c1 == c_white) return c2;
	if(c2 == c_white) return c1;
	
	var r1 = color_get_red(c1);
	var g1 = color_get_green(c1);
	var b1 = color_get_blue(c1);
	
	var r2 = color_get_red(c2);
	var g2 = color_get_green(c2);
	var b2 = color_get_blue(c2);
	
	return make_color_rgb((r1 * r2) / 255, (g1 * g2) / 255, (b1 * b2) / 255);
}

function color_diff(c1, c2, fast = false, alpha = false) {
	var _c1_r = color_get_red(c1);
	var _c1_g = color_get_green(c1);
	var _c1_b = color_get_blue(c1);
	var _c1_a = alpha? color_get_alpha(c1) : 255;
	
	_c1_a = _c1_a / 255;
	_c1_r = _c1_r / 255 * _c1_a;
	_c1_g = _c1_g / 255 * _c1_a;
	_c1_b = _c1_b / 255 * _c1_a;
	
	var _c2_r = color_get_red(c2);
	var _c2_g = color_get_green(c2);
	var _c2_b = color_get_blue(c2);
	var _c2_a = alpha? color_get_alpha(c2) : 255;
	
	_c2_a = _c2_a / 255;
	_c2_r = _c2_r / 255 * _c2_a;
	_c2_g = _c2_g / 255 * _c2_a;
	_c2_b = _c2_b / 255 * _c2_a;
	
	if(fast) return abs(_c1_r - _c2_r) + abs(_c1_g - _c2_g) + abs(_c1_b - _c2_b) + abs(_c1_a - _c2_a);
	return sqrt(sqr(_c1_r - _c2_r) + sqr(_c1_g - _c2_g) + sqr(_c1_b - _c2_b) + sqr(_c1_a - _c2_a));
}

#region sorting functions
	function __valHSV(c, h, s, v) { return color_get_hue(c) * h + color_get_saturation(c) * s + color_get_value(c) * v; }
	function __valRGB(c, r, g, b) { return color_get_red(c) * r + color_get_green(c) * g + color_get_blue(c) * b; }
	
	function __sortBright(c1, c2) {
		var l1 = 0.299 * color_get_red(c1) + 0.587 * color_get_green(c1) + 0.114 * color_get_blue(c1);
		var l2 = 0.299 * color_get_red(c2) + 0.587 * color_get_green(c2) + 0.114 * color_get_blue(c2);
		return l2 - l1;
	}
	function __sortDark(c1, c2) { return -__sortBright(c1, c2); }
	
	function __sortHue(c1, c2) { return __valHSV(c2, 65536, 256, 1) - __valHSV(c1, 65536, 256, 1); }
	function __sortSat(c1, c2) { return __valHSV(c2, 256, 65536, 1) - __valHSV(c1, 256, 65536, 1); }
	function __sortVal(c1, c2) { return __valHSV(c2, 256, 1, 65536) - __valHSV(c1, 256, 1, 65536); }
	
	function __sortRed(c1, c2)	 { return __valRGB(c2, 65536, 256, 1) - __valRGB(c1, 65536, 256, 1); }
	function __sortGreen(c1, c2) { return __valRGB(c2, 1, 65536, 256) - __valRGB(c1, 1, 65536, 256); }
	function __sortBlue(c1, c2)  { return __valRGB(c2, 256, 1, 65536) - __valRGB(c1, 256, 1, 65536); }
#endregion
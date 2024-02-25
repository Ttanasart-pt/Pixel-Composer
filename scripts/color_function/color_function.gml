#region channels
	function cola(color, alpha = 1) { INLINE return int64((color & 0xFFFFFF) + (round(alpha * 255) << 24)); }
	function _cola(color, alpha)    { INLINE return int64((color & 0xFFFFFF) + (alpha << 24)); }
	function colda(color)           { INLINE return real(color & 0xFFFFFF); }
	
	function color_get_alpha(color)  { INLINE return is_real(color)? 255 : (color & (0xFF << 24)) >> 24; }
	function _color_get_alpha(color) { INLINE return is_real(color)?   1 : color_get_alpha(color) / 255; }

	function _color_get_red(color)   { INLINE return color_get_red(color)   / 255; }
	function _color_get_green(color) { INLINE return color_get_green(color) / 255; }
	function _color_get_blue(color)  { INLINE return color_get_blue(color)  / 255; }

	function _color_get_hue(color)        { INLINE return color_get_hue(color)        / 255; }
	function _color_get_saturation(color) { INLINE return color_get_saturation(color) / 255; }
	function _color_get_value(color)      { INLINE return color_get_value(color)      / 255; }
#endregion

#region conversions
	function make_color_rgba(r, g, b, a) { INLINE return int64(round(r) + (round(g) << 8) + (round(b) << 16) + (round(a) << 24)); }
	
	function make_color_hsva(h, s, v, a) { INLINE return _cola(make_color_hsv(h, s, v), a); }
	
	function make_color_oklab(ok, a = 1) { #region
		INLINE 
		var k   = new __vec3(ok[0], ok[1], ok[2]);
		    k.x = power(k.x, 3);
		    k.y = power(k.y, 3);
		    k.z = power(k.z, 3);
			
		var rg   = global.CVTMAT_OKLAB_RGB.multiplyVector(k);
			rg.x = power(rg.x, 1 / 2.2) * 255;
		    rg.y = power(rg.y, 1 / 2.2) * 255;
		    rg.z = power(rg.z, 1 / 2.2) * 255;
			
		return make_color_rgba(rg.x, rg.y, rg.z, a);
	} #endregion
	
	function make_color_srgba(rgb, a) { #region
		INLINE 
		var r = power(rgb[0], 1 / 2.2) * 255;
		var g = power(rgb[1], 1 / 2.2) * 255;
		var b = power(rgb[2], 1 / 2.2) * 255;
		
		return int64(round(r) + (round(g) << 8) + (round(b) << 16) + (round(a) << 24)); 
	} #endregion
	
	function colorFromRGBArray(arr) { #region
		var r = round(real(arr[0]) * 255);
		var g = round(real(arr[1]) * 255);
		var b = round(real(arr[2]) * 255);
		return make_color_rgb(r, g, b);
	} #endregion
	
	function colorArrayFromReal(clr) { #region
		INLINE
		return [ _color_get_red(clr), _color_get_green(clr), _color_get_blue(clr) ];	
	} #endregion

	function paletteToArray(_pal) { #region
		var _colors = array_create(array_length(_pal) * 4);
		for(var i = 0; i < array_length(_pal); i++) {
			_colors[i * 4 + 0] = _color_get_red(_pal[i]);
			_colors[i * 4 + 1] = _color_get_green(_pal[i]);
			_colors[i * 4 + 2] = _color_get_blue(_pal[i]);
			_colors[i * 4 + 3] = _color_get_alpha(_pal[i]);
		}
	
		return _colors;
	} #endregion
#endregion

#region color spaces
	function color_rgb(col) { #region
		INLINE
		return [ color_get_red(col) / 255, color_get_green(col) / 255, color_get_blue(col) / 255 ];
	} #endregion
	
	function color_srgb(col) { #region
		INLINE
		return [ power(color_get_red(col) / 255, 2.2), power(color_get_green(col) / 255, 2.2), power(color_get_blue(col) / 255, 2.2) ];
	} #endregion
	
	function color_hsv(col) { #region
		INLINE
		return [ color_get_hue(col) / 255, color_get_saturation(col) / 255, color_get_value(col) / 255 ];
	} #endregion
	
	global.CVTMAT_RGB_OKLAB = new __mat3([ 0.4121656120,  0.2118591070,  0.0883097947,
                                           0.5362752080,  0.6807189584,  0.2818474174,
                                           0.0514575653,  0.1074065790,  0.6302613616 ]);
										   
	global.CVTMAT_OKLAB_RGB = new __mat3([ 4.0767245293, -1.2681437731, -0.0041119885,
										  -3.3072168827,  2.6093323231, -0.7034763098,
										   0.2307590544, -0.3411344290,  1.7068625689 ]);
	
	function color_oklab(col) { #region
		INLINE
		var v   = new __vec3(color_get_red(col) / 255, color_get_green(col) / 255, color_get_blue(col) / 255);
			v.x = power(v.x, 2.2);
		    v.y = power(v.y, 2.2);
		    v.z = power(v.z, 2.2);
			
		var ok   = global.CVTMAT_RGB_OKLAB.multiplyVector(v);
		    ok.x = power(ok.x, 1 / 3);
		    ok.y = power(ok.y, 1 / 3);
		    ok.z = power(ok.z, 1 / 3);
			
		return [ ok.x, ok.y, ok.z ];
	} #endregion
#endregion

#region data
	function colorBrightness(clr, normalize = true) { #region
		INLINE
		var r2 = color_get_red(clr)   /	(normalize? 255 : 1);
		var g2 = color_get_green(clr) / (normalize? 255 : 1);
		var b2 = color_get_blue(clr)  /	(normalize? 255 : 1);
		return 0.299 * r2 + 0.587 * g2 + 0.224 * b2;
	} #endregion

	function colorMultiply(c1, c2) { #region
		if(c1 * c2 == 0) return 0;
		if(c1 == c_white) return c2;
		if(c2 == c_white) return c1;
	
		var r1 = _color_get_red(c1);
		var g1 = _color_get_green(c1);
		var b1 = _color_get_blue(c1);
		var a1 = _color_get_alpha(c1);
	
		var r2 = _color_get_red(c2);
		var g2 = _color_get_green(c2);
		var b2 = _color_get_blue(c2);
		var a2 = _color_get_alpha(c2);
	
		if(is_real(c1)) return make_color_rgb((r1 * r2) * 255, (g1 * g2) * 255, (b1 * b2) * 255);
		return make_color_rgba((r1 * r2) * 255, (g1 * g2) * 255, (b1 * b2) * 255, (a1 * a2) * 255);
	} #endregion

	function colorAdd(c1, c2) { #region
	if(c1 == 0) return c2;
	if(c2 == 0) return c1;
	
	var r1 = color_get_red(c1);
	var g1 = color_get_green(c1);
	var b1 = color_get_blue(c1);
	
	var r2 = color_get_red(c2);
	var g2 = color_get_green(c2);
	var b2 = color_get_blue(c2);
	
	return make_color_rgb(min(r1 + r2, 255), min(g1 + g2, 255), min(b1 + b2, 255));
} #endregion
#endregion

function color_diff(c1, c2, fast = false, alpha = false) { #region
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
} #endregion

#region merge
	#macro merge_color merge_color_ext
	#macro __merge_color merge_color

	function merge_color_ext(c0, c1, t) { #region
		INLINE
		if(is_real(c0)) return __merge_color(c0, c1, t);
	
		return make_color_rgba(
			clamp(round(lerp(color_get_red(c0),   color_get_red(c1),   t)), 0, 255),
			clamp(round(lerp(color_get_green(c0), color_get_green(c1), t)), 0, 255),
			clamp(round(lerp(color_get_blue(c0),  color_get_blue(c1),  t)), 0, 255),
			clamp(round(lerp(color_get_alpha(c0), color_get_alpha(c1), t)), 0, 255),
		);
	} #endregion

	function merge_color_hsv(c0, c1, t) { #region
		INLINE
		if(is_real(c0)) return make_color_hsv(
			clamp(round(lerp(color_get_hue(c0),        color_get_hue(c1),        t)), 0, 255),
			clamp(round(lerp(color_get_saturation(c0), color_get_saturation(c1), t)), 0, 255),
			clamp(round(lerp(color_get_value(c0),      color_get_value(c1),      t)), 0, 255),
		);
	
		return make_color_hsva(
			clamp(round(lerp(color_get_hue(c0),        color_get_hue(c1),        t)), 0, 255),
			clamp(round(lerp(color_get_saturation(c0), color_get_saturation(c1), t)), 0, 255),
			clamp(round(lerp(color_get_value(c0),      color_get_value(c1),      t)), 0, 255),
			clamp(round(lerp(color_get_alpha(c0),      color_get_alpha(c1),      t)), 0, 255),
		);
	} #endregion
	
	function merge_color_oklab(c0, c1, t) { #region
		INLINE
		
		var ok0 = color_oklab(c0);
		var ok1 = color_oklab(c1);
		
		var ok = [
			lerp(ok0[0], ok1[0], t),
			lerp(ok0[1], ok1[1], t),
			lerp(ok0[2], ok1[2], t),
		];
		
		var a = is_real(c0)? 255 : clamp(round(lerp(color_get_alpha(c0), color_get_alpha(c1), t)), 0, 255);
		
		return make_color_oklab(ok, a);
	} #endregion 
	
	function merge_color_srgb(c0, c1, t) { #region
		INLINE
		
		var sr0 = color_srgb(c0);
		var sr1 = color_srgb(c1);
		
		var sr = [
			lerp(sr0[0], sr1[0], t),
			lerp(sr0[1], sr1[1], t),
			lerp(sr0[2], sr1[2], t),
		];
		
		var a = is_real(c0)? 255 : clamp(round(lerp(color_get_alpha(c0), color_get_alpha(c1), t)), 0, 255);
		
		return make_color_srgba(sr, a);
	} #endregion 
#endregion

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
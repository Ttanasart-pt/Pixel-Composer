#region channels
	function cola(color, alpha = 1) { INLINE return int64((color & 0xFFFFFF) + (round(alpha * 255) << 24)); }
	function _cola(color, alpha)    { INLINE return int64((color & 0xFFFFFF) + (alpha << 24)); }
	
	function color_real(color)      { INLINE return make_color_rgb(color_get_red(color), color_get_green(color), color_get_blue(color)); }
	
	function color_get_alpha(color)  { INLINE return (color & (0xFF << 24)) >> 24; }
	
	#macro _color_get_r _color_get_red
	#macro _color_get_g _color_get_green
	#macro _color_get_b _color_get_blue
	#macro _color_get_a _color_get_alpha
	
	function _color_get_red(color)   { INLINE return color_get_red(color)   / 255; }
	function _color_get_green(color) { INLINE return color_get_green(color) / 255; }
	function _color_get_blue(color)  { INLINE return color_get_blue(color)  / 255; }
	function _color_get_alpha(color) { INLINE return color_get_alpha(color) / 255; }
	
	function _color_get_hue(color)        { INLINE return color_get_hue(color)        / 255; }
	function _color_get_saturation(color) { INLINE return color_get_saturation(color) / 255; }
	function _color_get_value(color)      { INLINE return color_get_value(color)      / 255; }
	
	function _color_get_light(color) { INLINE return 0.299 * _color_get_red(color) + 0.587 * _color_get_green(color) + 0.114 * _color_get_blue(color); }
#endregion

#region creation
	function _make_color_rgb(r, g, b)    { INLINE return make_color_rgb(r * 255, g * 255, b * 255); }
	function make_color_grey(g)          { INLINE return int64(round(g*255) + (round(g*255) << 8) + (round(g*255) << 16) + (255 << 24)); }
	function make_color_rgba(r, g, b, a) { INLINE return int64(round(r) + (round(g) << 8) + (round(b) << 16) + (round(a) << 24)); }
	function make_color_hsva(h, s, v, a) { INLINE return _cola(make_color_hsv(h, s, v), a); }
	
	function make_color_oklab(ok, a = 1) {
		INLINE 
		var k   = new __vec3(ok[0], ok[1], ok[2]);
		    k.x = power(k.x, 3);
		    k.y = power(k.y, 3);
		    k.z = power(k.z, 3);
			
		var rg   = global.CVTMAT_OKLAB_RGB.multiplyVector(k);
			rg.x = __clamp255_mf0 power(rg.x, 1 / 2.2) * 255 __clamp255_mf1;
		    rg.y = __clamp255_mf0 power(rg.y, 1 / 2.2) * 255 __clamp255_mf1;
		    rg.z = __clamp255_mf0 power(rg.z, 1 / 2.2) * 255 __clamp255_mf1;
			
		return make_color_rgba(rg.x, rg.y, rg.z, a * 255);
	}
	
	function make_color_srgba(rgb, a) {
		INLINE 
		var r = power(rgb[0], 1 / 2.2) * 255;
		var g = power(rgb[1], 1 / 2.2) * 255;
		var b = power(rgb[2], 1 / 2.2) * 255;
		
		return int64(round(r) + (round(g) << 8) + (round(b) << 16) + (round(a) << 24)); 
	}
	
	function colorFromRGBArray(arr) {
		var r = round(real(arr[0]) * 255);
		var g = round(real(arr[1]) * 255);
		var b = round(real(arr[2]) * 255);
		return make_color_rgb(r, g, b);
	}
	
	function colorToArray(clr, alpha = false) {
		INLINE
		if(alpha) return [ _color_get_red(clr), _color_get_green(clr), _color_get_blue(clr), _color_get_alpha(clr) ];	
		return [ _color_get_red(clr), _color_get_green(clr), _color_get_blue(clr) ];	
	}

	function paletteToArray(_pal) {
		var _colors = array_create(array_length(_pal) * 4);
		for(var i = 0; i < array_length(_pal); i++) {
			var _c = _pal[i];
			if(!is_real(_c)) continue;
			
			_colors[i * 4 + 0] = _color_get_red(_c);
			_colors[i * 4 + 1] = _color_get_green(_c);
			_colors[i * 4 + 2] = _color_get_blue(_c);
			_colors[i * 4 + 3] = _color_get_alpha(_c);
		}
	
		return _colors;
	}
#endregion

#region conversion
	function color_rgb(col)  { return [ color_get_red(col) / 255,             color_get_green(col) / 255,             color_get_blue(col) / 255 ];             }
	function color_srgb(col) { return [ power(color_get_red(col) / 255, 2.2), power(color_get_green(col) / 255, 2.2), power(color_get_blue(col) / 255, 2.2) ]; }
	function color_hsv(col)  { return [ color_get_hue(col) / 255,             color_get_saturation(col) / 255,        color_get_value(col) / 255 ];            }
	
	global.CVTMAT_RGB_OKLAB = new __mat3([ 0.4121656120,  0.2118591070,  0.0883097947,
                                           0.5362752080,  0.6807189584,  0.2818474174,
                                           0.0514575653,  0.1074065790,  0.6302613616 ]);
										   
	global.CVTMAT_OKLAB_RGB = new __mat3([ 4.0767245293, -1.2681437731, -0.0041119885,
										  -3.3072168827,  2.6093323231, -0.7034763098,
										   0.2307590544, -0.3411344290,  1.7068625689 ]);
	
	function color_oklab(col) {
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
	}
#endregion

#region data
	function colorBrightness(clr, normalize = true) {
		INLINE
		var r2 = color_get_red(clr)   /	(normalize? 255 : 1);
		var g2 = color_get_green(clr) / (normalize? 255 : 1);
		var b2 = color_get_blue(clr)  /	(normalize? 255 : 1);
		return 0.299 * r2 + 0.587 * g2 + 0.224 * b2;
	}

	function colorMultiplyRGB(c1, c2) {
		INLINE 
		
		if(c1 * c2 == 0) return 0;
		if(c1 == c_white) return c2;
		if(c2 == c_white) return c1;
	
	    var r1 = c1 >> 16 & 0xFF;
	    var g1 = c1 >> 8 & 0xFF;
	    var b1 = c1 & 0xFF;
	
	    var r2 = c2 >> 16 & 0xFF;
	    var g2 = c2 >> 8 & 0xFF;
	    var b2 = c2 & 0xFF;
		
	    var r = min(r1 * r2 / 255, 255);
	    var g = min(g1 * g2 / 255, 255);
	    var b = min(b1 * b2 / 255, 255);
	
	    return (r << 16) | (g << 8) | b;
	}
	
	function colorMultiply(c1, c2) {
		INLINE 
	
	    return (((c1 >> 24 & 0xFF) * (c2 >> 24 & 0xFF) / 255) << 24) | 
	           (((c1 >> 16 & 0xFF) * (c2 >> 16 & 0xFF) / 255) << 16) | 
	           (((c1 >>  8 & 0xFF) * (c2 >>  8 & 0xFF) / 255) <<  8) | 
	            ((c1       & 0xFF) * (c2       & 0xFF) / 255);
	}

	function colorAdd(c1, c2) {
		if(c1 == 0) return c2;
		if(c2 == 0) return c1;
		
		var r1 = color_get_red(c1);
		var g1 = color_get_green(c1);
		var b1 = color_get_blue(c1);
		
		var r2 = color_get_red(c2);
		var g2 = color_get_green(c2);
		var b2 = color_get_blue(c2);
		
		return make_color_rgb(min(r1 + r2, 255), min(g1 + g2, 255), min(b1 + b2, 255));
	}
#endregion

function color_diff_fast(c1, c2) {
	INLINE
	
	return (abs(_color_get_red(c1)   - _color_get_red(c2)) + 
	        abs(_color_get_green(c1) - _color_get_green(c2)) + 
	        abs(_color_get_blue(c1)  - _color_get_blue(c2))
	        ) / 3;
}

function color_diff_alpha(c1, c2) {
	INLINE
	
	return sqrt(sqr(_color_get_red(c1)   - _color_get_red(c2)) + 
	            sqr(_color_get_green(c1) - _color_get_green(c2)) + 
	            sqr(_color_get_blue(c1)  - _color_get_blue(c2)) + 
	            sqr(_color_get_alpha(c1) - _color_get_alpha(c2))
	            );
}

function color_diff(c1, c2) {
	INLINE 
	
	return sqrt(sqr(_color_get_red(c1)   - _color_get_red(c2)) + 
	            sqr(_color_get_green(c1) - _color_get_green(c2)) + 
	            sqr(_color_get_blue(c1)  - _color_get_blue(c2))
	            );
}

#region merge
	#macro merge_color merge_color_ext
	#macro __merge_color merge_color
	//!#mfunc __clamp255 {"args":["v"],"order":[0]}
#macro __clamp255_mf0  clamp(round(
#macro __clamp255_mf1 ), 0, 255)

	function merge_color_ext(c0, c1, t) {
		INLINE
		if(is_real(c0) && is_real(c1)) return __merge_color(c0, c1, t);
		
		return make_color_rgba(
			__clamp255_mf0 lerp(color_get_red(c0),   color_get_red(c1),   t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_green(c0), color_get_green(c1), t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_blue(c0),  color_get_blue(c1),  t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_alpha(c0), color_get_alpha(c1), t) __clamp255_mf1,
		);
	}
	
	function merge_color_rgba(c0, c1, t) {
		INLINE
		return make_color_rgba(
			__clamp255_mf0 lerp(color_get_red(c0),   color_get_red(c1),   t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_green(c0), color_get_green(c1), t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_blue(c0),  color_get_blue(c1),  t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_alpha(c0), color_get_alpha(c1), t) __clamp255_mf1,
		);
	}

	function merge_color_hsva(c0, c1, t) {
		return make_color_hsva(
			__clamp255_mf0 lerp(color_get_hue(c0),        color_get_hue(c1),        t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_saturation(c0), color_get_saturation(c1), t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_value(c0),      color_get_value(c1),      t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_alpha(c0),      color_get_alpha(c1),      t) __clamp255_mf1,
		);
	}
	
	function merge_color_hsv(c0, c1, t) {
		INLINE
		if(is_real(c0)) return make_color_hsv(
			__clamp255_mf0 lerp(color_get_hue(c0),        color_get_hue(c1),        t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_saturation(c0), color_get_saturation(c1), t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_value(c0),      color_get_value(c1),      t) __clamp255_mf1,
		);
	
		return make_color_hsva(
			__clamp255_mf0 lerp(color_get_hue(c0),        color_get_hue(c1),        t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_saturation(c0), color_get_saturation(c1), t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_value(c0),      color_get_value(c1),      t) __clamp255_mf1,
			__clamp255_mf0 lerp(color_get_alpha(c0),      color_get_alpha(c1),      t) __clamp255_mf1,
		);
	}
	
	function merge_color_oklab(c0, c1, t) {
		INLINE
		
		var ok0 = color_oklab(c0);
		var ok1 = color_oklab(c1);
		
		var ok = [
			lerp(ok0[0], ok1[0], t),
			lerp(ok0[1], ok1[1], t),
			lerp(ok0[2], ok1[2], t),
		];
		
		var a = __clamp255_mf0 lerp(color_get_alpha(c0), color_get_alpha(c1), t) __clamp255_mf1;
		
		return make_color_oklab(ok, a);
	} 
	
	function merge_color_srgb(c0, c1, t) {
		INLINE
		
		var sr0 = color_srgb(c0);
		var sr1 = color_srgb(c1);
		
		var sr = [
			lerp(sr0[0], sr1[0], t),
			lerp(sr0[1], sr1[1], t),
			lerp(sr0[2], sr1[2], t),
		];
		
		var a = __clamp255_mf0 lerp(color_get_alpha(c0), color_get_alpha(c1), t) __clamp255_mf1;
		
		return make_color_srgba(sr, a);
	} 
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
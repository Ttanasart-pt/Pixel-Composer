/// oklch conversion by dkaraush
/// https://gist[1]ithub.com/dkaraush/65d19d61396f5f3cd8ba7d1b4b3c9432

function multiplyMatrices(A, b) {
     return [
        A[0] * b[0] + A[1] * b[1] + A[2] * b[2],
        A[3] * b[0] + A[4] * b[1] + A[5] * b[2],
        A[6] * b[0] + A[7] * b[1] + A[8] * b[2]
    ];
}

function oklch2oklab(lch) {
    var l = lch[0];
    var c = lch[1];
    var h = lch[2];
    
    return [
        l,
        is_nan(h) ? 0 : c * dcos(h),
        is_nan(h) ? 0 : c * dsin(h)
    ];
}

function oklab2oklch(lab) {
    var l = lab[0];
    var a = lab[1];
    var b = lab[2];
    
    return [
        l,
        sqrt(a * a + b * b),
        abs(a) < 0.0002 && abs(b) < 0.0002 ? NaN : (radtodeg(arctan2(b, a)) % 360 + 360) % 360
    ];
}

function rgb2srgbLinear(rgb) {
    var result = [];
    for (var i = 0; i < 3; i++) {
        var c = rgb[i];
        result[i] = abs(c) <= 0.04045 ? c / 12.92 : (c < 0 ? -1 : 1) * power((abs(c) + 0.055) / 1.055, 2.4);
    }
    return result;
}

function srgbLinear2rgb(rgb) {
    var result = [];
    for (var i = 0; i < 3; i++) {
        var c = rgb[i];
        result[i] = abs(c) > 0.0031308 ? (c < 0 ? -1 : 1) * (1.055 * power(abs(c), 1 / 2.4) - 0.055) : 12.92 * c;
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////

function oklab2xyz(lab) {
    var LMSg = multiplyMatrices([
        1,  0.3963377773761749,  0.2158037573099136,
        1, -0.1055613458156586, -0.0638541728258133,
        1, -0.0894841775298119, -1.2914855480194092,
    ], lab);
    
    var LMS = [
    	power(LMSg[0], 3),
    	power(LMSg[1], 3),
    	power(LMSg[2], 3),
	];
	
    return multiplyMatrices([
         1.2268798758459243, -0.5578149944602171,  0.2813910456659647,
        -0.0405757452148008,  1.1122868032803170, -0.0717110580655164,
        // -0.0763729497467214, -0.4214933239627914,  1.5869240244272418,
        -0.0763729366746601, -0.4214933324022432,  1.5869240198367816,
    ], LMS);
}

////////////////////////////////////////////////////////////////////////////////////////

function xyz2oklab(xyz) {
    var LMS = multiplyMatrices([
        0.8190224379967030, 0.3619062600528904, -0.1288737815209879,
        0.0329836539323885, 0.9292868615863434,  0.0361446663506424,
        0.0481771893596242, 0.2642395317527308,  0.6335478284694309
    ], xyz);
    
    var LMSg = [
	    power(LMS[0], 1 / 3),
		power(LMS[1], 1 / 3),
		power(LMS[2], 1 / 3),	
	];
    
    return multiplyMatrices([
        0.2104542683093140,  0.7936177747023054, -0.0040720430116193,
        1.9779985324311684, -2.4285922420485799,  0.4505937096174110,
        0.0259040424655478,  0.7827717124575296, -0.8086757549230774
    ], LMSg);
}

////////////////////////////////////////////////////////////////////////////////////////

// function xyz2rgbLinear(xyz) {
//     return multiplyMatrices([
//         3.2409699419045226,  -1.537383177570094,   -0.4986107602930034,
//       -0.9692436362808796,   1.8759675015077202,   0.04155505740717559,
//         0.05563007969699366, -0.20397695888897652,  1.0569715142428786
//     ], xyz);
// }

// function rgbLinear2xyz(rgb) {
//     return multiplyMatrices([
//         0.41239079926595934, 0.357584339383878,   0.1804807884018343,
//         0.21263900587151027, 0.715168678767756,   0.07219231536073371,
//         0.01933081871559182, 0.11919477979462598, 0.9505321522496607
//     ], rgb);
// }

// function oklch2rgb(lch) { return srgbLinear2rgb(xyz2rgbLinear(oklab2xyz(oklch2oklab(lch)))); } 
// function rgb2oklch(rgb) { return oklab2oklch(xyz2oklab(rgbLinear2xyz(rgb2srgbLinear(rgb)))); }

/// oklab conversion by Björn Ottosson (Oklab OP)
/// https://bottosson[1]ithub.io/posts/oklab/
//  black - white is not fix to 0 - 1

function linear_srgb_to_oklab(rgb){
	var r = rgb[0];
	var g = rgb[1];
	var b = rgb[2];
	
    var l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
	var m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
	var s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

    var l_ = power(l, 1 / 3);
    var m_ = power(m, 1 / 3);
    var s_ = power(s, 1 / 3);

    return [
        0.2104542683093140 * l_ + 0.7936177747023054 * m_ - 0.0040720430116193 * s_,
        1.9779985324311684 * l_ - 2.4285922420485799 * m_ + 0.4505937096174110 * s_,
        0.0259040424655478 * l_ + 0.7827717124575296 * m_ - 0.8086757549230774 * s_,
    ];
}

function oklab_to_linear_srgb(lab) {
	var L = lab[0];
	var a = lab[1];
	var b = lab[2];
	
    var l_ = L + 0.3963377774 * a + 0.2158037573 * b;
    var m_ = L - 0.1055613458 * a - 0.0638541728 * b;
    var s_ = L - 0.0894841775 * a - 1.2914855480 * b;

    var l = power(l_, 3);
    var m = power(m_, 3);
    var s = power(s_, 3);

    return [
		+4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
		-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
		-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    ];
}

// function oklch2rgb(lch) { return srgbLinear2rgb(oklab_to_linear_srgb(oklch2oklab(lch))); }
// function rgb2oklch(rgb) { return oklab2oklch(linear_srgb_to_oklab(rgb2srgbLinear(rgb))); }

/// oklab conversion by Color.js
/// https://github.com/color-js/color.js/blob/main/src/spaces/oklab.js

// function xyz_to_oklab(rgb){
// 	static XYZtoLMS_M = [
//     	0.8190224379967030, 0.3619062600528904, -0.1288737815209879,
//     	0.0329836539323885, 0.9292868615863434,  0.0361446663506424,
//     	0.0481771893596242, 0.2642395317527308,  0.6335478284694309,
//     ];
    
// 	static LMStoLab_M = [
//     	0.2104542683093140,  0.7936177747023054, -0.0040720430116193,
//     	1.9779985324311684, -2.4285922420485799,  0.4505937096174110,
//     	0.0259040424655478,  0.7827717124575296, -0.8086757549230774,
//     ];
    
//     rgb = multiplyMatrices(XYZtoLMS_M, rgb);

//     rgb[0] = power(rgb[0], 1 / 3);
//     rgb[1] = power(rgb[1], 1 / 3);
//     rgb[2] = power(rgb[2], 1 / 3);

//     return multiplyMatrices(LMStoLab_M, rgb);
// }

// function oklab_to_xyz(lab) {
//     static LabtoLMS_M = [
//     	1.0000000000000000,  0.3963377773761749,  0.2158037573099136,
//     	1.0000000000000000, -0.1055613458156586, -0.0638541728258133,
//     	1.0000000000000000, -0.0894841775298119, -1.2914855480194092,
//     ];
	
//     static LMStoXYZ_M = [
//     	 1.2268798758459243, -0.5578149944602171,  0.2813910456659647,
//     	-0.0405757452148008,  1.1122868032803170, -0.0717110580655164,
//     	-0.0763729366746601, -0.4214933324022432,  1.5869240198367816,
//     ];

//     lab = multiplyMatrices(LabtoLMS_M, lab);

//     lab[0] = power(lab[0], 3);
//     lab[1] = power(lab[1], 3);
//     lab[2] = power(lab[2], 3);

//     return multiplyMatrices(LMStoXYZ_M, lab);
// }

// function oklch2rgb(lch) { return srgbLinear2rgb(xyz2rgbLinear(oklab_to_xyz(oklch2oklab(lch)))); }
// function rgb2oklch(rgb) { return oklab2oklch(xyz_to_oklab(rgbLinear2xyz(rgb2srgbLinear(rgb)))); }

/// oklab conversion by Culori
/// https://github.com/Evercoder/culori/blob/main/src/oklab/convertOklabToLrgb.js#L1

function convertOklabToLrgb(lab) {
    var l = lab[0];
    var a = lab[1];
    var b = lab[2];
    
	var L = power(l * 0.99999999845051981432 + 0.39633779217376785678  * a + 0.21580375806075880339  * b, 3 );
	var M = power(l * 1.0000000088817607767  - 0.1055613423236563494   * a - 0.063854174771705903402 * b, 3 );
	var S = power(l * 1.0000000546724109177  - 0.089484182094965759684 * a - 1.2914855378640917399   * b, 3 );

	return [ +4.076741661347994    * L - 3.307711590408193  * M + 0.230969928729428  * S, 
			 -1.2684380040921763   * L + 2.6097574006633715 * M - 0.3413193963102197 * S, 
			 -0.004196086541837188 * L - 0.7034186144594493 * M + 1.7076147009309444 * S
	];
}

function convertLrgbToOklab(rgb) {
    var r = rgb[0];
    var g = rgb[1];
    var b = rgb[2];
    
	var L = power( 0.41222147079999993 * r + 0.5363325363 * g       + 0.0514459929       * b, 1 / 3);
	var M = power( 0.2119034981999999  * r + 0.6806995450999999 * g + 0.1073969566       * b, 1 / 3);
	var S = power( 0.08830246189999998 * r + 0.2817188376 * g       + 0.6299787005000002 * b, 1 / 3);
    
    return [
		0.2104542553 * L + 0.793617785  * M - 0.0040720468 * S,
		1.9779984951 * L - 2.428592205  * M + 0.4505937099 * S,
		0.0259040371 * L + 0.7827717662 * M - 0.808675766  * S
	]
};

function oklch2rgb(lch) { return srgbLinear2rgb(convertOklabToLrgb(oklch2oklab(lch))); }
function rgb2oklch(rgb) { return oklab2oklch(convertLrgbToOklab(rgb2srgbLinear(rgb))); }


//////////////////////////////////////////////////// Gamut intersection ////////////////////////////////////////////////////

/// Björn Ottosson
/// https://bottosson[1]ithub.io/posts/gamutclipping/

// Finds the maximum saturation possible for a given hue that fits in sRGB
// Saturation here is defined as S = C/L
// a and b must be normalized so a^2 + b^2 == 1
function compute_max_saturation(a, b) {
    // Max saturation will be when one of r, g or b goes below zero.

    // Select different coefficients depending on which component goes below zero first
    var k0, k1, k2, k3, k4, wl, wm, ws;

    if (-1.88170328 * a - 0.80936493 * b > 1) {
        // Red component
        k0 = +1.19086277; k1 = +1.76576728; k2 = +0.59662641; k3 = +0.75515197; k4 = +0.56771245;
        wl = +4.0767416621; wm = -3.3077115913; ws = +0.2309699292;
        
    } else if (1.81444104 * a - 1.19445276 * b > 1) {
        // Green component
        k0 = +0.73956515; k1 = -0.45954404; k2 = +0.08285427; k3 = +0.12541070; k4 = +0.14503204;
        wl = -1.2684380046; wm = +2.6097574011; ws = -0.3413193965;
        
    } else {
        // Blue component
        k0 = +1.35733652; k1 = -0.00915799; k2 = -1.15130210; k3 = -0.50559606; k4 = +0.00692167;
        wl = -0.0041960863; wm = -0.7034186147; ws = +1.7076147010;
    }

    // Approximate max saturation using a polynomial:
    var S = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;

    // Do one step Halley's method to get closer
    // this gives an error less than 10e6, except for some blue hues where the dS/dh is close to infinite
    // this should be sufficient for most applications, otherwise do two/three steps 

    var k_l = +0.3963377774 * a + 0.2158037573 * b;
    var k_m = -0.1055613458 * a - 0.0638541728 * b;
    var k_s = -0.0894841775 * a - 1.2914855480 * b;

    var l_ = 1. + S * k_l;
    var m_ = 1. + S * k_m;
    var s_ = 1. + S * k_s;

    var l = l_ * l_ * l_;
    var m = m_ * m_ * m_;
    var s = s_ * s_ * s_;

    var l_dS = 3. * k_l * l_ * l_;
    var m_dS = 3. * k_m * m_ * m_;
    var s_dS = 3. * k_s * s_ * s_;

    var l_dS2 = 6. * k_l * k_l * l_;
    var m_dS2 = 6. * k_m * k_m * m_;
    var s_dS2 = 6. * k_s * k_s * s_;

    var f  = wl * l     + wm * m     + ws * s;
    var f1 = wl * l_dS  + wm * m_dS  + ws * s_dS;
    var f2 = wl * l_dS2 + wm * m_dS2 + ws * s_dS2;

    S = S - f * f1 / (f1 * f1 - 0.5 * f * f2);

    return S;
}

// finds L_cusp and C_cusp for a given hue
// a and b must be normalized so a^2 + b^2 == 1
// struct LC { var L; var C; };
function find_cusp(a, b) {
	// First, find the maximum saturation (saturation S = C/L)
	var S_cusp = compute_max_saturation(a, b);

	// Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
	var rgb_at_max = oklab_to_linear_srgb([ 1, S_cusp * a, S_cusp * b ]);
	var L_cusp = power(1 / max(rgb_at_max[0], rgb_at_max[1], rgb_at_max[2]), 1 / 3);
	var C_cusp = L_cusp * S_cusp;

	return [ L_cusp , C_cusp ];
}

// Finds intersection of the line defined by 
// L = L0 * (1 - t) + t * L1;
// C = t * C1;
// a and b must be normalized so a^2 + b^2 == 1
function find_gamut_intersection(a, b, L1, C1, L0) {
	// Find the cusp of the gamut triangle
	var cusp = find_cusp(a, b);

	// Find the intersection for upper and lower half seprately
	var t;
	if (((L1 - L0) * cusp[1] - (cusp[0] - L0) * C1) <= 0.) {
		// Lower half
		t = cusp[1] * L0 / (C1 * cusp[0] + cusp[1] * (L0 - L1));
		
	} else {
		// Upper half

		// First intersect with triangle
		t = cusp[1] * (L0 - 1.) / (C1 * (cusp[0] - 1.) + cusp[1] * (L0 - L1));

		// Then one step Halley's method
		var dL = L1 - L0;
		var dC = C1;

		var k_l = +0.3963377774 * a + 0.2158037573 * b;
		var k_m = -0.1055613458 * a - 0.0638541728 * b;
		var k_s = -0.0894841775 * a - 1.2914855480 * b;

		var l_dt = dL + dC * k_l;
		var m_dt = dL + dC * k_m;
		var s_dt = dL + dC * k_s;
		
		// If higher accuracy is required, 2 or 3 iterations of the following block can be used:
		var L = L0 * (1. - t) + t * L1;
		var C = t * C1;

		var l_ = L + C * k_l;
		var m_ = L + C * k_m;
		var s_ = L + C * k_s;

		var l = l_ * l_ * l_;
		var m = m_ * m_ * m_;
		var s = s_ * s_ * s_;

		var ldt = 3 * l_dt * l_ * l_;
		var mdt = 3 * m_dt * m_ * m_;
		var sdt = 3 * s_dt * s_ * s_;

		var ldt2 = 6 * l_dt * l_dt * l_;
		var mdt2 = 6 * m_dt * m_dt * m_;
		var sdt2 = 6 * s_dt * s_dt * s_;

		var r  = 4.0767416621 * l    - 3.3077115913 * m    + 0.2309699292 * s - 1;
		var r1 = 4.0767416621 * ldt  - 3.3077115913 * mdt  + 0.2309699292 * sdt;
		var r2 = 4.0767416621 * ldt2 - 3.3077115913 * mdt2 + 0.2309699292 * sdt2;

		var u_r = r1 / (r1 * r1 - 0.5 * r * r2);
		var t_r = -r * u_r;

		var g  = -1.2684380046 * l    + 2.6097574011 * m    - 0.3413193965 * s - 1;
		var g1 = -1.2684380046 * ldt  + 2.6097574011 * mdt  - 0.3413193965 * sdt;
		var g2 = -1.2684380046 * ldt2 + 2.6097574011 * mdt2 - 0.3413193965 * sdt2;

		var u_g = g1 / (g1 * g1 - 0.5 * g * g2);
		var t_g = -g * u_g;

		var b0 = -0.0041960863 * l    - 0.7034186147 * m    + 1.7076147010 * s - 1;
		var b1 = -0.0041960863 * ldt  - 0.7034186147 * mdt  + 1.7076147010 * sdt;
		var b2 = -0.0041960863 * ldt2 - 0.7034186147 * mdt2 + 1.7076147010 * sdt2;

		var u_b = b1 / (b1 * b1 - 0.5 * b0 * b2);
		var t_b = -b0 * u_b;

		t_r = u_r >= 0. ? t_r : 99999.;
		t_g = u_g >= 0. ? t_g : 99999.;
		t_b = u_b >= 0. ? t_b : 99999.;
        
		t += min(t_r, t_g, t_b);
	}

	return t;
}

//////////////////////////////////////////////////// Gamut clipping ////////////////////////////////////////////////////

function gamut_clip_preserve_chroma(rgb) {
	if (rgb[0] < 1 && rgb[1] < 1 && rgb[2] < 1 && rgb[0] > 0 && rgb[1] > 0 && rgb[2] > 0)
		return rgb;

	// var lab = linear_srgb_to_oklab(rgb);
	var lab = convertLrgbToOklab(rgb2srgbLinear(rgb))

	var L   = lab[0];
	var eps = 0.00001;
	var d   = is_nan(lab[1]) || is_nan(lab[2])? 0 : sqrt(lab[1] * lab[1] + lab[2] * lab[2]);
	var C   = max(eps, d);
	var a_  = lab[1] / C;
	var b_  = lab[2] / C;
    
	var L0 = clamp(L, 0, 1);

	var t = find_gamut_intersection(a_, b_, L, C, L0);
	var L_clipped = L0 * (1 - t) + t * L;
	var C_clipped = t * C;

	// return oklab_to_linear_srgb([ L_clipped, C_clipped * a_, C_clipped * b_ ]);
	return srgbLinear2rgb(convertOklabToLrgb([ L_clipped, C_clipped * a_, C_clipped * b_ ]));
}

function gamut_clip_project_to_0_5(rgb) {
	if (rgb[0] < 1 && rgb[1] < 1 && rgb[2] < 1 && rgb[0] > 0 && rgb[1] > 0 && rgb[2] > 0)
		return rgb;

	var lab = linear_srgb_to_oklab(rgb);

	var L   = lab[0];
	var eps = 0.00001;
	var d   = is_nan(lab[1]) || is_nan(lab[2])? 0 : sqrt(lab[1] * lab[1] + lab[2] * lab[2]);
	var C   = max(eps, d);
	var a_  = lab[1] / C;
	var b_  = lab[2] / C;

	var L0 = 0.5;

	var t = find_gamut_intersection(a_, b_, L, C, L0);
	var L_clipped = L0 * (1 - t) + t * L;
	var C_clipped = t * C;

	return oklab_to_linear_srgb([ L_clipped, C_clipped * a_, C_clipped * b_ ]);
}

function gamut_clip_project_to_L_cusp(rgb) {
	if (rgb[0] < 1 && rgb[1] < 1 && rgb[2] < 1 && rgb[0] > 0 && rgb[1] > 0 && rgb[2] > 0)
		return rgb;

	var lab = linear_srgb_to_oklab(rgb);

	var L = lab[0];
	var eps = 0.00001;
	var d   = is_nan(lab[1]) || is_nan(lab[2])? 0 : sqrt(lab[1] * lab[1] + lab[2] * lab[2]);
	var C   = max(eps, d);
	var a_ = lab[1] / C;
	var b_ = lab[2] / C;

	// The cusp is computed here and in find_gamut_intersection, an optimized solution would only compute it once.
	var cusp = find_cusp(a_, b_);

	var L0 = cusp[0];
	var t = find_gamut_intersection(a_, b_, L, C, L0);

	var L_clipped = L0 * (1 - t) + t * L;
	var C_clipped = t * C;

	return oklab_to_linear_srgb([ L_clipped, C_clipped * a_, C_clipped * b_ ]);
}

function gamut_clip_adaptive_L0_0_5(rgb, alpha = 0.05) {
	if (rgb[0] < 1 && rgb[1] < 1 && rgb[2] < 1 && rgb[0] > 0 && rgb[1] > 0 && rgb[2] > 0)
		return rgb;

	var lab = linear_srgb_to_oklab(rgb);

	var L = lab[0];
	var eps = 0.00001;
	var d   = is_nan(lab[1]) || is_nan(lab[2])? 0 : sqrt(lab[1] * lab[1] + lab[2] * lab[2]);
	var C   = max(eps, d);
	var a_ = lab[1] / C;
	var b_ = lab[2] / C;

	var Ld = L - 0.5;
	var e1 = 0.5 + abs(Ld) + alpha * C;
	var L0 = 0.5 *(1. + sign(Ld)*(e1 - sqrt(e1*e1 - 2. * abs(Ld))));

	var t = find_gamut_intersection(a_, b_, L, C, L0);
	var L_clipped = L0 * (1. - t) + t * L;
	var C_clipped = t * C;

	return oklab_to_linear_srgb([ L_clipped, C_clipped * a_, C_clipped * b_ ]);
}

function gamut_clip_adaptive_L0_L_cusp(rgb, alpha = 0.05) {
	if (rgb[0] < 1 && rgb[1] < 1 && rgb[2] < 1 && rgb[0] > 0 && rgb[1] > 0 && rgb[2] > 0)
		return rgb;

	var lab = linear_srgb_to_oklab(rgb);

	var L = lab[0];
	var eps = 0.00001;
	var d   = is_nan(lab[1]) || is_nan(lab[2])? 0 : sqrt(lab[1] * lab[1] + lab[2] * lab[2]);
	var C   = max(eps, d);
	var a_ = lab[1] / C;
	var b_ = lab[2] / C;

	// The cusp is computed here and in find_gamut_intersection, an optimized solution would only compute it once.
	var cusp = find_cusp(a_, b_);

	var Ld = L - cusp[0];
	var k = 2. * (Ld > 0 ? 1. - cusp[0] : cusp[0]);

	var e1 = 0.5 * k + abs(Ld) + alpha * C / k;
	var L0 = cusp[0] + 0.5 * (sign(Ld) * (e1 - sqrt(e1 * e1 - 2. * k * abs(Ld))));

	var t = find_gamut_intersection(a_, b_, L, C, L0);
	var L_clipped = L0 * (1. - t) + t * L;
	var C_clipped = t * C;

	return oklab_to_linear_srgb([ L_clipped, C_clipped * a_, C_clipped * b_ ]);
}
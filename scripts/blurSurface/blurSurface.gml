globalvar GAUSSIAN_COEFF; GAUSSIAN_COEFF = {};

function surface_blur_init() {
	__blur_pass = [ 0, 0 ];
}

	////- Gaussian blur

function __gaussian_get_kernel(size) {
	size = max(1, round(size));
	if(struct_has(GAUSSIAN_COEFF, size)) return GAUSSIAN_COEFF[$ size];
	
	var gau_array = array_create(size);
	var we = 0;
	var b  = 0.3 * ((size - 1) * 0.5 - 1) + 0.8;
	
	for(var i = 0; i < size; i++) {
		var _x = i * .5;
		
		gau_array[i] = (1 / sqrt(2 * pi * b)) * exp( -sqr(_x) / (2 * sqr(b)) );
		we += i? gau_array[i] * 2 : gau_array[i];
	}
	
	for(var i = 0; i < size; i++)
		gau_array[i] /= we;
	
	GAUSSIAN_COEFF[$ size] = gau_array;
	return gau_array;
}

function blur_gauss_args(_surface, _size, _sampleMode = 1) constructor {
	surface    = _surface;
	size       = _size;
	sampleMode = _sampleMode;
	
	bg         = false;
	bg_c       = c_black;      static setBG  = function(b,c) /*=>*/ { bg = b; bg_c = c; return self; }
	
	overColor  = noone;        static setOver  = function(c) /*=>*/ { overColor = c;    return self; }
	gamma      = false;        static setGamma = function(g) /*=>*/ { gamma = g;        return self; }
	
	ratio      = 1;            static setRatio = function(r) /*=>*/ { ratio = r; return self; }
	angle      = 0;            static setAngle = function(r) /*=>*/ { angle = r; return self; }
}

function surface_apply_gaussian(args) {
	var surface    = args.surface;
	var bg         = args.bg;
	var bg_c       = args.bg_c;
	var sampleMode = args.sampleMode;
	var overColor  = args.overColor;
	var gamma      = args.gamma;
	var ratio      = args.ratio;
	var angle      = args.angle;
	
	var format = surface_get_format(surface);
	var _sw    = surface_get_width_safe(surface);
	var _sh    = surface_get_height_safe(surface);
	
	__blur_pass[0] = surface_verify(__blur_pass[0], _sw, _sh, format);	
	__blur_pass[1] = surface_verify(__blur_pass[1], _sw, _sh, format);	
	
	var _sizeArr   = is_array(args.size);
	var _size      = _sizeArr? args.size[0] : args.size;
	var _sizeSurf  = _sizeArr? args.size[1] : noone;
	var _sizeJunc  = _sizeArr? args.size[2] : noone;
	var _msize     = is_array(_size)? max(_size[0], _size[1]) : _size;
		
	var gau_array = __gaussian_get_kernel(_msize);
	
	BLEND_OVERRIDE
	gpu_set_tex_filter(true);
	surface_set_target(__blur_pass[0]);
		draw_clear_alpha(bg_c, bg);
		
		shader_set(sh_blur_gaussian);
		shader_set_2("dimension", [_sw,_sh]);
		shader_set_f("weight",    gau_array);
		
		shader_set_i("sampleMode", sampleMode);
		shader_set_f_map("size",   _size, _sizeSurf, _sizeJunc);
		shader_set_i("horizontal", 1);
		shader_set_i("gamma",      gamma);
		shader_set_f("angle",      degtorad(angle));
		
		shader_set_i("overrideColor", overColor != noone);
		shader_set_f("overColor",     colToVec4(overColor));
		
		shader_set_f("sizeModulate",  1);
		
		draw_surface_safe(surface);
		shader_reset();
	surface_reset_target();
	
	surface_set_target(__blur_pass[1]);
		draw_clear_alpha(bg_c, bg);
		
		shader_set(sh_blur_gaussian);
		shader_set_f("weight",     gau_array);
		shader_set_f_map("size",   _size, _sizeSurf, _sizeJunc);
		shader_set_i("horizontal", 0);
			
		shader_set_f("sizeModulate",  ratio);
			
		draw_surface_safe(__blur_pass[0]);
		shader_reset();
	surface_reset_target();
	gpu_set_tex_filter(false);
	BLEND_NORMAL
	
	return __blur_pass[1];
}

	////- Zoom blur

function blur_zoom_args(_surface, _size, _origin_x, _origin_y, _blurMode = 0, _sampleMode = 0, _samples = 64) constructor {
	surface    = _surface;
	size       = _size;
	sizeCurve  = noone; static setSizeCurve    = function(i) /*=>*/ { sizeCurve    = i; return self; }
	
	origin_x   = _origin_x;
	origin_y   = _origin_y;
	blurMode   = _blurMode;
	sampleMode = _sampleMode;
	samples    = _samples;
	
	UVmap        = noone; 
	UVmapMix     = 0;     static setUVMap        = function(s,m) /*=>*/ { UVmap = s; UVmapMix = m; return self; }
	
	mode         = 0;     static setMode         = function(i) /*=>*/ { mode = i;         return self; }
	fadeDistance = true;  static setFadeDistance = function(i) /*=>*/ { fadeDistance = i; return self; }
	gamma        = false; static setGamma        = function(i) /*=>*/ { gamma = i;        return self; }
	
	useMask      = false; 
	mask         = noone; static setMask         = function(i) /*=>*/ { mask = i; useMask = is_surface(mask); return self; }
	
	spectralUse       = false;
	spectralIntensity = 0;
	spectralShift     = 0;
	spectralScale     = 1;
	spectralGrad      = noone;
	
	static setSpectral    = function(u,i,s,c,d) /*=>*/ { 
		spectralUse       = u;
		spectralIntensity = i;
		spectralShift     = s;
		spectralScale     = c;
		spectralGrad      = d;
		return self; 
	}
}

function surface_apply_blur_zoom(outputSurf, args) {
	if(!is_surface(args.surface)) return outputSurf;
	
	var format = surface_get_format(args.surface);
	var _sw = surface_get_width_safe(args.surface);
	var _sh = surface_get_height_safe(args.surface);
	var _ss =  max(_sw, _sh) / 2;
	
	outputSurf = surface_verify(outputSurf, _sw, _sh, format);
	
	var _sizeArr   = is_array(args.size);
	var _size      = _sizeArr? args.size[0] : args.size;
	var _sizeSurf  = _sizeArr? args.size[1] : noone;
	var _sizeJunc  = _sizeArr? args.size[2] : noone;
	
	surface_set_shader(outputSurf, args.mode? sh_blur_zoom_step : sh_blur_zoom);
		shader_set_uv(args.UVmap, args.UVmapMix);
		
		shader_set_2("dimension",   [_sw,_sh] );
		shader_set_f("center",       args.origin_x / _sw, args.origin_y / _sh);
		shader_set_f_map("strength", _size, _sizeSurf, _sizeJunc);
		shader_set_curve("s",        args.sizeCurve);
		
		shader_set_i("blurMode",     args.blurMode);
		shader_set_i("sampleMode",   args.sampleMode);
		shader_set_i("samples",      args.samples);
		shader_set_i("gamma",        args.gamma);
		shader_set_i("fadeDistance", args.fadeDistance);
		
		shader_set_i("useMask",      args.useMask);
		shader_set_surface("mask",   args.mask);
		
		shader_set_i("spectralUse",        args.spectralUse);
		shader_set_f("spectralIntensity",  args.spectralIntensity);
		shader_set_f("spectralShift",      args.spectralShift);
		shader_set_f("spectralScale",      args.spectralScale);
		if(args.spectralGrad != noone)     args.spectralGrad.shader_submit();
		
		draw_surface_safe(args.surface);
	surface_reset_shader();
	
	return outputSurf;
}

	////- Directional blur

function blur_directional_args(_surface, _size, _angle) constructor {
	surface = _surface;
	size    = _size;
	angle   = _angle;
	
	sizeCurve    = noone; static setSizeCurve    = function(i) /*=>*/ { sizeCurve    = i; return self; }
	resolution   = 1;     static setResolution   = function(i) /*=>*/ { resolution   = i; return self; }
	
	UVmap        = noone;
	UVmapMix     = 0;     static setUVMap        = function(s,m) /*=>*/ { UVmap = s; UVmapMix = m; return self; }
	
	singleDirect = false; static setSingleDirect = function(i) /*=>*/ { singleDirect = i; return self; }
	fadeDistance = false; static setFadeDistance = function(i) /*=>*/ { fadeDistance = i; return self; }
	gamma        = false; static setGamma        = function(i) /*=>*/ { gamma        = i; return self; }
	sampleMode   = 2;     static setSampleMode   = function(i) /*=>*/ { sampleMode   = i; return self; }
	
	spectralUse       = false;
	spectralIntensity = 0;
	spectralShift     = 0;
	spectralScale     = 1;
	spectralGrad      = noone;
	static setSpectral    = function(u,i,s,c,d) /*=>*/ { 
		spectralUse       = u;
		spectralIntensity = i;
		spectralShift     = s;
		spectralScale     = c;
		spectralGrad      = d;
		return self; 
	}
}

function surface_apply_blur_directional(outputSurf, args) {
	if(!is_surface(args.surface)) return outputSurf;
	
	var format = surface_get_format(args.surface);
	var _sw    = surface_get_width_safe(args.surface);
	var _sh    = surface_get_height_safe(args.surface);
	
	outputSurf = surface_verify(outputSurf, _sw, _sh, format);
	
	var _sizeArr   = is_array(args.size); 
	var _size      = _sizeArr? args.size[0] : args.size;
	var _sizeSurf  = _sizeArr? args.size[1] : noone;
	var _sizeJunc  = _sizeArr? args.size[2] : noone;
	
	var _angleArr  = is_array(args.angle);
	var _angle     = _angleArr? args.angle[0] : args.angle;
	var _angleSurf = _angleArr? args.angle[1] : noone;
	var _angleJunc = _angleArr? args.angle[2] : noone;
	
	surface_set_shader(outputSurf, sh_blur_directional, true, BLEND.over);
		gpu_set_tex_filter(true);
		shader_set_uv(args.UVmap, args.UVmapMix);
		
		shader_set_f(    "size",         max(_sw, _sh));
		shader_set_f_map("strength",     _size,  _sizeSurf,  _sizeJunc);
		shader_set_f(    "resolution",   args.resolution);
		shader_set_curve("s",            args.sizeCurve);
		
		shader_set_f_map("direction",    _angle, _angleSurf, _angleJunc);
		shader_set_i("singleDirect",     args.singleDirect);
		shader_set_i("gamma",            args.gamma);
		shader_set_i("sampleMode",	     args.sampleMode);
		shader_set_i("fadeDistance",     args.fadeDistance);
		
		shader_set_i("spectralUse",        args.spectralUse);
		shader_set_f("spectralIntensity",  args.spectralIntensity);
		shader_set_f("spectralShift",      args.spectralShift);
		shader_set_f("spectralScale",      args.spectralScale);
		if(args.spectralGrad != noone)     args.spectralGrad.shader_submit();
		
		draw_surface_safe(args.surface);
		gpu_set_tex_filter(false);
	surface_reset_shader();
	
	return outputSurf;
}
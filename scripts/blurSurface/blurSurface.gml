globalvar GAUSSIAN_COEFF;
GAUSSIAN_COEFF = {};

function surface_blur_init() {
	__blur_pass = [ 0, 0 ];
}

function __gaussian_get_kernel(size) {
	size = max(1, round(size));
	if(struct_has(GAUSSIAN_COEFF, size)) return GAUSSIAN_COEFF[$ size];
	
	var gau_array = array_create(size);
	var we        = 0;
	var b         = 0.3 * ((size - 1) * 0.5 - 1) + 0.8;
	
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

function surface_apply_gaussian(surface, size, bg = false, bg_c = c_white, sampleMode = 0, overColor = noone, gamma = false, ratio = 1, angle = 0) {
	var format = surface_get_format(surface);
	var _sw    = surface_get_width_safe(surface);
	var _sh    = surface_get_height_safe(surface);
	
	__blur_pass[0] = surface_verify(__blur_pass[0], _sw, _sh, format);	
	__blur_pass[1] = surface_verify(__blur_pass[1], _sw, _sh, format);	
	
	size = min(size, 128);
	var gau_array = __gaussian_get_kernel(size);
	
	BLEND_OVERRIDE
	gpu_set_tex_filter(true);
	surface_set_target(__blur_pass[0]);
		draw_clear_alpha(bg_c, bg);
		
		shader_set(sh_blur_gaussian);
		shader_set_f("dimension", [ _sw, _sh ]);
		shader_set_f("weight",    gau_array);
		
		shader_set_i("sampleMode", sampleMode);
		shader_set_i("size",       size);
		shader_set_i("horizontal", 1);
		shader_set_i("gamma",      gamma);
		shader_set_f("angle",      degtorad(angle));
		
		shader_set_i("overrideColor", overColor != noone);
		shader_set_f("overColor",     colToVec4(overColor));
		
		draw_surface_safe(surface);
		shader_reset();
	surface_reset_target();
	
	surface_set_target(__blur_pass[1]);
		draw_clear_alpha(bg_c, bg);
		var _size_v = round(size * ratio);
			
		shader_set(sh_blur_gaussian);
		shader_set_f("weight",    __gaussian_get_kernel(_size_v));
		shader_set_i("size",       _size_v);
		shader_set_i("horizontal", 0);
			
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
	origin_x   = _origin_x;
	origin_y   = _origin_y;
	blurMode   = _blurMode;
	sampleMode = _sampleMode;
	samples    = _samples;
	
	mode         = 0;     static setMode         = function(i) /*=>*/ { mode = i;         return self; }
	fadeDistance = true;  static setFadeDistance = function(i) /*=>*/ { fadeDistance = i; return self; }
	gamma        = false; static setGamma        = function(i) /*=>*/ { gamma = i;        return self; }
	
	useMask      = false; static setMask         = function(i) /*=>*/ { mask = i; useMask = is_surface(mask); return self; }
	mask         = noone;
}

function surface_apply_blur_zoom(outputSurf, args) {
	if(!is_surface(args.surface)) return outputSurf;
	
	var format = surface_get_format(args.surface);
	var _sw    = surface_get_width_safe(args.surface);
	var _sh    = surface_get_height_safe(args.surface);
	
	outputSurf = surface_verify(outputSurf, _sw, _sh, format);
	
	var _sizeArr   = is_array(args.size);
	var _size      = min(_sizeArr? args.size[0] : args.size, 128) / 128;
	var _sizeSurf  =  _sizeArr? args.size[1] : noone;
	var _sizeJunc  =  _sizeArr? args.size[2] : noone;
	
	surface_set_shader(outputSurf, args.mode? sh_blur_zoom_step : sh_blur_zoom);
		shader_set_f("center",       args.origin_x / _sw, args.origin_y / _sh);
		shader_set_f_map("strength", _size,  _sizeSurf,  _sizeJunc);
		shader_set_i("blurMode",     args.blurMode);
		shader_set_i("sampleMode",   args.sampleMode);
		shader_set_i("samples",      args.samples);
		shader_set_i("gamma",        args.gamma);
		shader_set_i("fadeDistance", args.fadeDistance);
		
		shader_set_i("useMask",      args.useMask);
		shader_set_surface("mask",   args.mask);
		
		draw_surface_safe(args.surface);
	surface_reset_shader();
	
	return outputSurf;
}

	////- Directional blur

function blur_directional_args(_surface, _size, _angle) constructor {
	surface = _surface;
	size    = _size;
	angle   = _angle;
	
	singleDirect = false; static setSingleDirect = function(i) /*=>*/ { singleDirect = i; return self; }
	gamma        = false; static setGamma        = function(i) /*=>*/ { gamma        = i; return self; }
	sampleMode   = 2;     static setSampleMode   = function(i) /*=>*/ { sampleMode   = i; return self; }
}

function surface_apply_blur_directional(outputSurf, args) {
	if(!is_surface(args.surface)) return outputSurf;
	
	var format = surface_get_format(args.surface);
	var _sw    = surface_get_width_safe(args.surface);
	var _sh    = surface_get_height_safe(args.surface);
	
	outputSurf = surface_verify(outputSurf, _sw, _sh, format);
	
	var _sizeArr   = is_array(args.size);
	var _size      = (_sizeArr? args.size[0] : args.size) / 128;
	var _sizeSurf  =  _sizeArr? args.size[1] : noone;
	var _sizeJunc  =  _sizeArr? args.size[2] : noone;
	
	var _angleArr  = is_array(args.angle);
	var _angle     = _angleArr? args.angle[0] : args.angle;
	var _angleSurf = _angleArr? args.angle[1] : noone;
	var _angleJunc = _angleArr? args.angle[2] : noone;
	
	surface_set_shader(outputSurf, sh_blur_directional);
		shader_set_f("size",          max(_sw, _sh));
		shader_set_f_map("strength",  _size,  _sizeSurf,  _sizeJunc);
		shader_set_f_map("direction", _angle, _angleSurf, _angleJunc);
		shader_set_i("singleDirect",  args.singleDirect);
		shader_set_i("gamma",         args.gamma);
		shader_set_i("sampleMode",	  args.sampleMode);
		
		draw_surface_safe(args.surface);
	surface_reset_shader();
	
	return outputSurf;
}
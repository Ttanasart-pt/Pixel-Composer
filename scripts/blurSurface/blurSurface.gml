globalvar GAUSSIAN_COEFF;
GAUSSIAN_COEFF = {};

function surface_blur_init() {
	__blur_hori = surface_create(1, 1);
	__blur_vert = surface_create(1, 1);
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
	
	__blur_hori = surface_verify(__blur_hori, _sw, _sh, format);	
	__blur_vert = surface_verify(__blur_vert, _sw, _sh, format);	
	
	size = min(size, 128);
	var gau_array = __gaussian_get_kernel(size);
	
	BLEND_OVERRIDE
	gpu_set_tex_filter(true);
	surface_set_target(__blur_hori);
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
	
	surface_set_target(__blur_vert);
		draw_clear_alpha(bg_c, bg);
		var _size_v = round(size * ratio);
			
		shader_set(sh_blur_gaussian);
		shader_set_f("weight",    __gaussian_get_kernel(_size_v));
		shader_set_i("size",       _size_v);
		shader_set_i("horizontal", 0);
			
		draw_surface_safe(__blur_hori);
		shader_reset();
	surface_reset_target();
	gpu_set_tex_filter(false);
	BLEND_NORMAL
	
	return __blur_vert;
}

function surface_apply_blur_zoom(surface, size, origin_x, origin_y, blurMode = 0, sampleMode = 0, samples = 64) {
	var format = surface_get_format(surface);
	var _sw    = surface_get_width_safe(surface);
	var _sh    = surface_get_height_safe(surface);
	
	__blur_hori = surface_verify(__blur_hori, _sw, _sh, format);
	size = min(size, 128) / 128;
	
	surface_set_shader(__blur_hori, sh_blur_zoom);
		shader_set_f("center",       origin_x / _sw, origin_y / _sh);
		shader_set_f_map("strength", size);
		shader_set_i("blurMode",     blurMode);
		shader_set_i("sampleMode",   sampleMode);
		shader_set_i("gamma",        0);
		shader_set_i("samples",      samples);
		shader_set_i("fadeDistance", 1);
		shader_set_i("useMask",      0);
		
		draw_surface_safe(surface);
	surface_reset_shader();
	
	return __blur_hori;
}

function surface_apply_blur_directional(surface, size, angle, samples = 64) {
	var format = surface_get_format(surface);
	var _sw    = surface_get_width_safe(surface);
	var _sh    = surface_get_height_safe(surface);
	
	__blur_hori = surface_verify(__blur_hori, _sw, _sh, format);
	size = min(size, 128) / 128;
	
	surface_set_shader(__blur_hori, sh_blur_directional);
		shader_set_f("size",          _sw, _sh);
		shader_set_f_map("strength",  size);
		shader_set_f_map("direction", angle);
		shader_set_i("scale",         0);
		shader_set_i("gamma",         0);
		shader_set_i("sampleMode",	  0);
		
		draw_surface_safe(surface);
	surface_reset_shader();
	
	return __blur_hori;
}
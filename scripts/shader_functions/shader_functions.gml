function shader_set_i(uniform, value) {
	var shader = shader_current();
	if(is_array(value)) {
		shader_set_i_array(shader, uniform, value);
		return;
	}
		
	if(argument_count > 2) {
		var array = [];
		for( var i = 1; i < argument_count; i++ )
			array_push(array, argument[i]);
		shader_set_i_array(shader, uniform, array)
		return;
	}
	
	shader_set_uniform_i(shader_get_uniform(shader, uniform), value);
}

function shader_set_i_array(shader, uniform, array) {
	shader_set_uniform_i_array(shader_get_uniform(shader, uniform), array);
}

function shader_set_f(uniform, value) {
	var shader = shader_current();
	if(is_array(value)) {
		shader_set_f_array(shader, uniform, value);
		return;
	}
	
	if(argument_count > 2) {
		var array = [];
		for( var i = 1; i < argument_count; i++ )
			array_push(array, argument[i]);
		shader_set_f_array(shader, uniform, array)
		return;
	}
	
	shader_set_uniform_f(shader_get_uniform(shader, uniform), value);
}

function shader_set_f_array(shader, uniform, array, max_length = 128) {
	shader_set_uniform_f_array_safe(shader_get_uniform(shader, uniform), array, max_length);
}

function shader_set_uniform_f_array_safe(uniform, array, max_length = 128) {
	if(!is_array(array)) return;
	if(array_length(array) == 0) return;
	if(array_length(array) > max_length)
		array_resize(array, max_length)
	
	shader_set_uniform_f_array(uniform, array);
}

function shader_set_surface(sampler, surface, linear = false, _repeat = false) {
	var shader = shader_current();
	if(!is_surface(surface)) return;
	
	var t = shader_get_sampler_index(shader, sampler);
	
	texture_set_stage(t, surface_get_texture(surface));
	gpu_set_tex_filter_ext(t, linear);
	gpu_set_tex_repeat_ext(t, _repeat);
}

//function shader_set_surface_ext(sampler, surface, linear = false, _repeat = false) {
//	var shader = shader_current();
//	if(!is_surface(surface)) return;
	
//	if (!GMD3D11_IS_SUPPORTED) {
//		shader_set_surface(sampler, surface, linear, _repeat);
//		return;
//	}
	
//	var t = shader_get_sampler_index(shader, sampler);
//	gpu_set_tex_filter_ext(t, linear);
//	gpu_set_tex_repeat_ext(t, _repeat);
	
//	d3d11_texture_set_stage_ps(t, surface_get_texture(surface));
//}

function shader_set_surface_dimension(uniform, surface) {
	var shader = shader_current();
	if(!is_surface(surface)) return;
	
	var texture = surface_get_texture(surface);
	var tw = texture_get_texel_width(texture);
	var th = texture_get_texel_height(texture);
	
	tw = 2048;
	th = 2048;
	
	shader_set_uniform_f(shader_get_uniform(shader, uniform), tw, th);
}

function shader_set_dim(uniform = "dimension", surf = noone) {
	if(!is_surface(surf)) return;
	
	shader_set_f(uniform, surface_get_width_safe(surf), surface_get_height_safe(surf));
}

function shader_set_color(uniform, col, alpha = 1) {
	shader_set_f(uniform, colToVec4(col, alpha));
}

function shader_set_palette(pal, pal_uni = "palette", amo_uni = "paletteAmount", max_length = 128) {
	shader_set_i(amo_uni, min(max_length, array_length(pal)));
	
	var _pal = [];
	for( var i = 0, n = min(max_length, array_length(pal)); i < n; i++ )
		array_append(_pal, colToVec4(pal[i]));
	
	if(array_length(_pal))
		shader_set_f(pal_uni, _pal);
}

#region prebuild
	enum BLEND {
		normal,
		add,
		over,
		alpha,
		alphamulp,
	}

	function shader_set_interpolation(surface) {
		var intp   = attributes.interpolation;
		
		gpu_set_tex_filter(intp);
		shader_set_i("interpolation",	intp);
		shader_set_f("sampleDimension", surface_get_width_safe(surface), surface_get_height_safe(surface));
		shader_set_i("sampleMode",		struct_try_get(attributes, "oversample"));
	}
	
	function surface_set_shader(surface, shader = sh_sample, clear = true, blend = BLEND.alpha) {
		if(!is_surface(surface)) {
			__surface_set = false;
			return;
		}
		
		__surface_set = true;
		surface_set_target(surface);
		if(clear) DRAW_CLEAR;
		
		switch(blend) {
			case BLEND.add :		BLEND_ADD;			break;
			case BLEND.over:		BLEND_OVERRIDE;		break;
			case BLEND.alpha:		BLEND_ALPHA;		break;
			case BLEND.alphamulp:	BLEND_ALPHA_MULP;	break;
		}
		
		if(shader == noone)
			__shader_set = false;
		else {
			__shader_set = true;
			shader_set(shader);
		}
	}
	
	function surface_reset_shader() {
		if(!__surface_set) return;
		
		gpu_set_tex_filter(false);
		BLEND_NORMAL;
		surface_reset_target();
		
		if(__shader_set)
			shader_reset();
	}
#endregion
function __init_mask_modifier(_mask_index, _ind = undefined) {
	_ind = _ind ?? array_length(inputs);
	
	newInput(_ind + 0, nodeValue_Bool("Invert mask", self, false));
	newInput(_ind + 1, nodeValue_Slider("Mask feather", self, 0, [0, 32, 0.1]));
		
	__mask_index     = _mask_index;
	__mask_mod_index = _ind;
	__mask_invert    = false;
	__mask_feather   = 0;
}

function __step_mask_modifier() {
	var _msk = is_surface(getSingleValue(__mask_index));
	inputs[__mask_mod_index + 0].setVisible(_msk);
	inputs[__mask_mod_index + 1].setVisible(_msk);
}

function __process_mask_modifier(data) {
	__mask_invert  = data[__mask_mod_index + 0];
	__mask_feather = data[__mask_mod_index + 1];
}

function mask_modify(mask, invert = false, feather = 0) {
	if(!is_surface(mask)) return mask; 
	if(!invert && feather == 0) return mask;
	
	if(!struct_has(self, "__temp_mask")) __temp_mask = surface_create(1, 1);
	
	__temp_mask = surface_verify(__temp_mask, surface_get_width_safe(mask), surface_get_height_safe(mask));
	
	surface_set_shader(__temp_mask, sh_mask_invert);
		shader_set_i("invert", invert);
		draw_surface_safe(mask);
	surface_reset_shader();
	
	if(feather > 0) {
		if(!struct_has(self, "__blur_hori")) surface_blur_init();
		__temp_mask = surface_apply_gaussian(__temp_mask, feather, false, c_white, 1, noone);
	}
	
	return __temp_mask;
}

function mask_apply(original, edited, mask, mix = 1) {
	if(!is_surface(mask) && mix == 1) return edited;
	
	var _f = surface_get_format(edited);
	var _s = surface_create_size(original, _f);
	
	if(is_surface(mask) && __mask_feather > 0) {
		if(!struct_has(self, "__blur_hori")) surface_blur_init();
		mask = surface_apply_gaussian(mask, __mask_feather, false, c_white, 1, noone);
	}
	
	surface_set_shader(_s, sh_mask);
		shader_set_surface("original", original);
		shader_set_surface("edited",   edited);
		shader_set_surface("mask",     mask);
		
		shader_set_i("useMask",  is_surface(mask));
		shader_set_i("invMask",  __mask_invert);
		shader_set_f("mixRatio", mix);
		
		draw_empty();
	surface_reset_shader();
	
	surface_free(edited);
	return _s;
}

function channel_apply(original, edited, channel) {
	if(channel == 0b1111) return edited;
	if(!surface_exists(original)) return edited;
	
	var _f = surface_get_format(edited);
	var _s = surface_create_size(original, _f);
	
	surface_set_target(_s);
		DRAW_CLEAR
		BLEND_ADD_ONE
		
		gpu_set_colorwriteenable(!(channel & 0b0001), !(channel & 0b0010), !(channel & 0b0100), !(channel & 0b1000));
		draw_surface(original, 0, 0);
		
		gpu_set_colorwriteenable(channel & 0b0001, channel & 0b0010, channel & 0b0100, channel & 0b1000);
		draw_surface(edited, 0, 0);
		
		gpu_set_colorwriteenable(1, 1, 1, 1);
		BLEND_NORMAL
	surface_reset_target();
	
	surface_free(edited);
	return _s;
}

function mask_apply_empty(_surf, _mask) {
	if(!is_surface(_mask)) return _surf;
	
	var _dim = surface_get_dimension(_surf);
	__maskedSurf = self[$ "__maskedSurf"] ?? noone;
	__maskedSurf = surface_verify(__maskedSurf, _dim[0], _dim[1])
	
	surface_set_shader(__maskedSurf, sh_mask_empty);
		shader_set_surface("mask", _mask);
		draw_surface_safe(_surf);
	surface_reset_shader();
	
	surface_set_shader(_surf)
		draw_surface_safe(__maskedSurf);
	surface_reset_shader();
	
	return _surf;
}
function __init_mask_modifier(_mask_index) { #region
	var _ind = ds_list_size(inputs);
	
	inputs[| _ind + 0] = nodeValue("Invert mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| _ind + 1] = nodeValue("Mask feather", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 32, 0.1] });
		
	__mask_index     = _mask_index;
	__mask_mod_index = _ind;
	__mask_invert    = false;
	__mask_feather   = 0;
} #endregion

function __step_mask_modifier() { #region
	var _msk = is_surface(getSingleValue(__mask_index));
	inputs[| __mask_mod_index + 0].setVisible(_msk);
	inputs[| __mask_mod_index + 1].setVisible(_msk);
} #endregion

function __process_mask_modifier(data) { #region
	__mask_invert  = data[__mask_mod_index + 0];
	__mask_feather = data[__mask_mod_index + 1];
} #endregion

function mask_modify(mask, invert = false, feather = 0) { #region
	if(!is_surface(mask)) return mask; 
	if(!invert && feather == 0) return mask;
	
	if(!struct_has(self, "__temp_mask")) __temp_mask = surface_create(1, 1);
	
	__temp_mask = surface_verify(__temp_mask, surface_get_width_safe(mask), surface_get_height_safe(mask));
	
	surface_set_shader(__temp_mask, invert? sh_invert_all : noone);
		draw_surface(mask, 0, 0);
	surface_reset_shader();
	
	if(feather > 0) {
		if(!struct_has(self, "__blur_hori")) surface_blur_init();
		__temp_mask = surface_apply_gaussian(__temp_mask, feather, false, c_white, 1, noone);
	}
	
	return __temp_mask;
} #endregion

function mask_apply(original, edited, mask, mix = 1) { #region
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
		
		draw_sprite_stretched(s_fx_pixel, 0, 0, 0, surface_get_width_safe(original), surface_get_height_safe(original));
	surface_reset_shader();
	
	surface_free(edited);
	return _s;
} #endregion

function channel_apply(original, edited, channel) { #region
	if(channel == 0b1111) return edited;
	
	var _f = surface_get_format(edited);
	var _s = surface_create_size(original, _f);
	
	surface_set_target(_s);
		DRAW_CLEAR
		BLEND_ADD
		
		gpu_set_colorwriteenable(!(channel & 0b0001), !(channel & 0b0010), !(channel & 0b0100), !(channel & 0b1000));
		draw_surface_safe(original);
		
		gpu_set_colorwriteenable(channel & 0b0001, channel & 0b0010, channel & 0b0100, channel & 0b1000);
		draw_surface_safe(edited);
		
		gpu_set_colorwriteenable(1, 1, 1, 1);
		BLEND_NORMAL
	surface_reset_target();
	
	surface_free(edited);
	return _s;
} #endregion
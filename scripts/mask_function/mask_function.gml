function mask_apply(original, edited, mask, mix = 1) {	
	if(!is_surface(mask) && mix == 1) return edited;
	
	var _f = surface_get_format(edited);
	var _s = surface_create_size(original, _f);
	
	surface_set_target(_s);
	shader_set(sh_mask);
		texture_set_stage(shader_get_sampler_index(sh_mask, "original"), surface_get_texture(original));
		texture_set_stage(shader_get_sampler_index(sh_mask, "edited"),	 surface_get_texture(edited));
		
		shader_set_uniform_i(shader_get_uniform(sh_mask, "useMask"), is_surface(mask));
		texture_set_stage(shader_get_sampler_index(sh_mask, "mask"), surface_get_texture(mask));
			
		shader_set_uniform_f(shader_get_uniform(sh_mask, "mixRatio"), mix);
		
		draw_sprite_stretched(s_fx_pixel, 0, 0, 0, surface_get_width_safe(original), surface_get_height_safe(original));
	shader_reset();
	surface_reset_target();
	
	surface_free(edited);
	return _s;
}

function channel_apply(original, edited, channel) {
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
}
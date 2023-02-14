function mask_apply(original, edited, mask, mix = 1) {	
	if(!is_surface(mask) || mix == 1) return edited;
	
	var _s = surface_create_size(original);
	
	surface_set_target(_s);
	shader_set(sh_mask);
		texture_set_stage(shader_get_sampler_index(sh_mask, "original"), surface_get_texture(original));
		texture_set_stage(shader_get_sampler_index(sh_mask, "edited"),	 surface_get_texture(edited));
		
		shader_set_uniform_i(shader_get_uniform(sh_mask, "useMask"), is_surface(mask));
		texture_set_stage(shader_get_sampler_index(sh_mask, "mask"),	 surface_get_texture(mask));
			
		shader_set_uniform_f(shader_get_uniform(sh_mask, "mixRatio"), mix);
		
		draw_sprite_stretched(s_fx_pixel, 0, 0, 0, surface_get_width(original), surface_get_height(original));
	shader_reset();
	surface_reset_target();
	
	surface_free(edited);
	return _s;
}
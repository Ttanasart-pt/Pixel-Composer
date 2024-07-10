/// fd_rectangle_update_material(instance id)
function fd_rectangle_update_material(domain) {
	// Updates the material textures of the fluid dynamics rectangle, proceeding the simulation of the material textures one step further.
	// Usually you want to call fd_rectangle_update to update the fluid dynamics rectangle as a whole. fd_rectangle_update performs fd_rectangle_update_velocity followed by fd_rectangle_update_material.
	// However, if you want more control you can call these scripts yourself.
	// instance id: The instance id of the fluid dynamics rectangle.

	with (domain) {
	    var temporary = noone, velocity_texture = noone;

	    texture_set_repeat(texture_repeat);
	    texture_set_interpolation(true);
    
	    draw_enable_alphablend(false);
    
	        fd_rectangle_assure_surfaces_exist(id);
        
	        if (inherit_velocity) velocity_texture = surface_get_texture(inherit_velocity_parent.sf_velocity); else velocity_texture = surface_get_texture(sf_velocity);
        
	        // Advects material.
	        switch (material_type) {
	            case FD_MATERIAL_TYPE.A_8:
	                surface_set_target(sf_material_0_temporary);
	                    shader_set(sh_fd_advect_material_a_8_glsl);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_a_8_glsl, "texture_velocity"), velocity_texture);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_a_8_glsl, "texture_world"), surface_get_texture(sf_world));
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_8_glsl, "texel_size"), sf_material_texel_width, sf_material_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_8_glsl, "precalculated"), material_time_step * sf_material_texel_width, material_time_step * sf_material_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_8_glsl, "precalculated_1"), sf_material_texel_width * 0.5, sf_material_texel_height * 0.5,
	                                    sf_material_texel_width * -0.5, sf_material_texel_height * -0.5);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_8_glsl, "precalculated_2"), material_dissipation_type, material_dissipation_value, material_maccormack_weight * 0.5);
	                        draw_surface_safe(sf_material_0);
	                    shader_reset();
	                surface_reset_target();
	                temporary = sf_material_0; sf_material_0 = sf_material_0_temporary; sf_material_0_temporary = temporary;
	                break;
                
	            case FD_MATERIAL_TYPE.RGBA_8:
	                surface_set_target(sf_material_0_temporary);
	                    shader_set(sh_fd_advect_material_rgba_8_glsl);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_rgba_8_glsl, "texture_velocity"), velocity_texture);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_rgba_8_glsl, "texture_world"), surface_get_texture(sf_world));
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_8_glsl, "texel_size"), sf_material_texel_width, sf_material_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_8_glsl, "dissipation_type"), material_dissipation_type);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_8_glsl, "dissipation_value"), material_dissipation_value);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_8_glsl, "maccormack_weight_half"), material_maccormack_weight * 0.5);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_8_glsl, "precalculated"), material_time_step * sf_material_texel_width, material_time_step * sf_material_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_8_glsl, "precalculated_1"), sf_material_texel_width * 0.5, sf_material_texel_height * 0.5,
	                                    sf_material_texel_width * -0.5, sf_material_texel_height * -0.5);
	                        draw_surface_safe(sf_material_0);
	                    shader_reset();
	                surface_reset_target();
	                temporary = sf_material_0; sf_material_0 = sf_material_0_temporary; sf_material_0_temporary = temporary;
	                break;
        
	            case FD_MATERIAL_TYPE.A_16:
	                surface_set_target(sf_material_0_temporary);
	                    shader_set(sh_fd_advect_material_a_16_glsl);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_a_16_glsl, "texture_velocity"), velocity_texture);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_a_16_glsl, "texture_world"), surface_get_texture(sf_world));
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_16_glsl, "texel_size"), sf_material_texel_width, sf_material_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_16_glsl, "precalculated"), material_time_step * sf_material_texel_width, material_time_step * sf_material_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_16_glsl, "precalculated_1"), sf_material_texel_width * 0.5, sf_material_texel_height * 0.5,
	                                    sf_material_texel_width * -0.5, sf_material_texel_height * -0.5);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_a_16_glsl, "precalculated_2"), material_dissipation_type, material_dissipation_value, material_maccormack_weight * 0.5);
	                        draw_surface_safe(sf_material_0);
	                    shader_reset();
	                surface_reset_target();
	                temporary = sf_material_0; sf_material_0 = sf_material_0_temporary; sf_material_0_temporary = temporary;
	                break;
            
	            case FD_MATERIAL_TYPE.RGBA_16:
	                shader_set(sh_fd_advect_material_rgba_16_glsl);
	                    texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_rgba_16_glsl, "texture_material_1"), surface_get_texture(sf_material_1));
	                    texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_rgba_16_glsl, "texture_velocity"), velocity_texture);
	                    texture_set_stage(shader_get_sampler_index(sh_fd_advect_material_rgba_16_glsl, "texture_world"), surface_get_texture(sf_world));
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "texel_size"), sf_material_texel_width, sf_material_texel_height);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "dissipation_type"), material_dissipation_type);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "dissipation_value"), material_dissipation_value);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "maccormack_weight_half"), material_maccormack_weight * 0.5);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "precalculated"), material_time_step * sf_material_texel_width, material_time_step * sf_material_texel_height);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "precalculated_1"), sf_material_texel_width * 0.5, sf_material_texel_height * 0.5,
	                                sf_material_texel_width * -0.5, sf_material_texel_height * -0.5);
                    
	                    surface_set_target(sf_material_0_temporary);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "target"), 0);
	                        draw_surface_safe(sf_material_0);    
	                    surface_reset_target();
                        
	                    surface_set_target(sf_material_1_temporary);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_material_rgba_16_glsl, "target"), 1);
	                        draw_surface_safe(sf_material_0);
	                    surface_reset_target();
                        
	                    temporary = sf_material_0; sf_material_0 = sf_material_0_temporary; sf_material_0_temporary = temporary;
	                    temporary = sf_material_1; sf_material_1 = sf_material_1_temporary; sf_material_1_temporary = temporary;
	                shader_reset();
	                break;
	        }
    
	    draw_enable_alphablend(true);
	}



}

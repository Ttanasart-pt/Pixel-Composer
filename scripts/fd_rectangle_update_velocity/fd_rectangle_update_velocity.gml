/// fd_rectangle_update_velocity(instance id)
function fd_rectangle_update_velocity(domain) {
	// Updates the velocity texture of the fluid dynamics rectangle, proceeding the simulation of the velocity texture one step further.
	// Usually you want to call fd_rectangle_update to update the fluid dynamics rectangle as a whole. fd_rectangle_update performs fd_rectangle_update_velocity followed by fd_rectangle_update_material.
	// However, if you want more control you can call these scripts yourself.
	// instance id: The instance id of the fluid dynamics rectangle.

	with (domain) {
	    if (!inherit_velocity) {
    
	        var temporary = noone;
    
	        texture_set_repeat(texture_repeat);
	        texture_set_interpolation(true);
        
	        draw_enable_alphablend(false);
        
	            fd_rectangle_assure_surfaces_exist(id);
            
	            // Advects velocity.
	            surface_set_target(sf_velocity_temporary);
	                switch (acceleration_type) {
	                    case 0:
	                        shader_set(sh_fd_advect_velocity_0_glsl);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_velocity_0_glsl, "texture_world"), surface_get_texture(sf_world));
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_velocity_0_glsl, "precalculated"), velocity_time_step * sf_velocity_texel_width, velocity_time_step * sf_velocity_texel_height, sf_velocity_texel_width, sf_velocity_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_velocity_0_glsl, "precalculated_1"), velocity_dissipation_type, velocity_dissipation_value, velocity_maccormack_weight * 0.5);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_velocity_0_glsl, "acceleration"), acceleration_x, acceleration_y);
	                        break;
                
	                    case 1:
	                        shader_set(sh_fd_advect_velocity_1_glsl);
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_velocity_1_glsl, "texture_world"), surface_get_texture(sf_world));
	                        texture_set_stage(shader_get_sampler_index(sh_fd_advect_velocity_1_glsl, "texture_material"), surface_get_texture(sf_material_0));
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_velocity_1_glsl, "precalculated"), velocity_time_step * sf_velocity_texel_width, velocity_time_step * sf_velocity_texel_height, sf_velocity_texel_width, sf_velocity_texel_height);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_velocity_1_glsl, "precalculated_1"), velocity_dissipation_type, velocity_dissipation_value, velocity_maccormack_weight * 0.5);
	                        shader_set_uniform_f(shader_get_uniform(sh_fd_advect_velocity_1_glsl, "acceleration"), acceleration_x, acceleration_y, acceleration_a, acceleration_b);
	                        break;
	                }
	                draw_surface(sf_velocity, 0, 0);
	                shader_reset();
	            surface_reset_target();
	            temporary = sf_velocity; sf_velocity = sf_velocity_temporary; sf_velocity_temporary = temporary;
            
	            // Calculates divergence of velocity.
	            surface_set_target(sf_pressure);
	                shader_set(sh_fd_calculate_velocity_divergence_glsl);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_calculate_velocity_divergence_glsl, "initial_value_pressure"), initial_value_pressure);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_calculate_velocity_divergence_glsl, "texel_size"), sf_velocity_texel_width, sf_velocity_texel_height);
	                    draw_surface_stretched(sf_velocity, 0, 0, sf_pressure_width, sf_pressure_height);
	                shader_reset();
	            surface_reset_target();
            
	            if (pressure_iteration_type >= 0) {
	                shader_set(sh_fd_calculate_pressure_jacobi_glsl);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_calculate_pressure_jacobi_glsl, "texel_size"), sf_pressure_texel_width, sf_pressure_texel_height);
	                    repeat (pressure_iteration_type) {
	                        surface_set_target(sf_pressure_temporary);
	                            draw_surface(sf_pressure, 0, 0);
	                        surface_reset_target();
	                        temporary = sf_pressure; sf_pressure = sf_pressure_temporary; sf_pressure_temporary = temporary;
	                    }
	                shader_reset();
	            } else {
	                shader_set(sh_fd_calculate_pressure_srj_glsl);
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_calculate_pressure_srj_glsl, "texel_size"), sf_pressure_texel_width, sf_pressure_texel_height);
	                    var length = array_length(pressure_relaxation_parameter);
	                    for (var i = 0; i < length; ++i) {
	                        if (pressure_relaxation_parameter[i] != -1) shader_set_uniform_f(shader_get_uniform(sh_fd_calculate_pressure_srj_glsl, "precalculated"), 1 - pressure_relaxation_parameter[i], 0.25 * pressure_relaxation_parameter[i]);
	                        surface_set_target(sf_pressure_temporary);
	                            draw_surface(sf_pressure, 0, 0);
	                        surface_reset_target();
	                        temporary = sf_pressure; sf_pressure = sf_pressure_temporary; sf_pressure_temporary = temporary;
	                    }
	                shader_reset();
	            }
            
	            // Calculates the gradient of pressure and subtracts it from the velocity.
	            surface_set_target(sf_velocity_temporary);
	                shader_set(sh_fd_subtract_pressure_gradient_glsl);
	                    texture_set_stage(shader_get_sampler_index(sh_fd_subtract_pressure_gradient_glsl, "texture_pressure"), surface_get_texture(sf_pressure));
	                    shader_set_uniform_f(shader_get_uniform(sh_fd_subtract_pressure_gradient_glsl, "texel_size"), sf_pressure_texel_width, sf_pressure_texel_height);
	                    draw_surface(sf_velocity, 0, 0);
	                shader_reset();
	            surface_reset_target();
	            temporary = sf_velocity; sf_velocity = sf_velocity_temporary; sf_velocity_temporary = temporary;
        
	        draw_enable_alphablend(true);
        
	    }
	}



}

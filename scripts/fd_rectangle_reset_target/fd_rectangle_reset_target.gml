/// fd_rectangle_reset_target(instance id)
function fd_rectangle_reset_target(domain) {
	// Resets the target of the fluid dynamics rectangle. Should be used after fd_rectangle_set_target.
	// instance id: The instance id of the fluid dynamics rectangle.

	with (domain) {
	    surface_reset_target();    

	    switch (target_type) {
	        case FD_TARGET_TYPE.ADD_MATERIAL:
	            draw_set_blend_mode(bm_normal);
	            break;
            
	        case FD_TARGET_TYPE.REPLACE_MATERIAL_ADVANCED:
	            shader_reset();
	            draw_enable_alphablend(true);
	            var temporary = sf_material_0_temporary; sf_material_0_temporary = sf_material_0; sf_material_0 = temporary;
	            break;
        
	        case FD_TARGET_TYPE.REPLACE_VELOCITY:
	            break;
            
	        case FD_TARGET_TYPE.ADD_VELOCITY:
	            shader_reset();
	            draw_enable_alphablend(true);
	            var temporary = sf_velocity_temporary; sf_velocity_temporary = sf_velocity; sf_velocity = temporary;
	            break;
	    }
	}
}

/// fd_rectangle_assure_surfaces_exist(instance id)
function fd_rectangle_assure_surfaces_exist(domain) {
	with (domain) {
	    if (!surface_exists(sf_pressure)) {sf_pressure = surface_create(sf_pressure_width, sf_pressure_height); surface_set_target(sf_pressure); draw_clear_alpha($000000, 0); surface_reset_target();}
	    if (!surface_exists(sf_pressure_temporary)) {sf_pressure_temporary = surface_create(sf_pressure_width, sf_pressure_height);}
    
	    if (!inherit_velocity) {
	        if (!surface_exists(sf_velocity)) {sf_velocity = surface_create(sf_velocity_width, sf_velocity_height); surface_set_target(sf_velocity); draw_clear_alpha($008080, 0); surface_reset_target();}
	        if (!surface_exists(sf_velocity_temporary)) {sf_velocity_temporary = surface_create(sf_velocity_width, sf_velocity_height);}
	    }
    
	    if (!surface_exists(sf_material_0)) {
	        sf_material_0 = surface_create(sf_material_width, sf_material_height); surface_set_target(sf_material_0); draw_clear_alpha($000000, 0); surface_reset_target();
	        material_surface_was_created = true;
	    }
	    if (!surface_exists(sf_material_0_temporary)) {sf_material_0_temporary = surface_create(sf_material_width, sf_material_height);}
		if (!surface_exists(sf_material_0_temporary_1)) {sf_material_0_temporary_1 = surface_create(sf_material_width, sf_material_height);}
	    if (!surface_exists(sf_material_1)) {sf_material_1 = surface_create(sf_material_width, sf_material_height); surface_set_target(sf_material_1); draw_clear_alpha($000000, 0); surface_reset_target();}
	    if (!surface_exists(sf_material_1_temporary)) {sf_material_1_temporary = surface_create(sf_material_width, sf_material_height);}
    
	    if (!surface_exists(sf_world)) sf_world_update = true;
	    if (sf_world_update) {
	        if (collision_mask_type == 0) {
	            sf_world = surface_create(sprite_get_width(collision_mask_sprite_index), sprite_get_height(collision_mask_sprite_index));
	            surface_set_target(sf_world);
	                draw_clear_alpha($00FFFF, 0);
	                draw_sprite(collision_mask_sprite_index, collision_mask_image_index, 0, 0);
	            surface_reset_target();
	        } else if (collision_mask_type == 1) {
	            //var error_string = "Fluid Dynamics error. An invalid collision mask surface was provided for a fluid dynamics rectangle." + chr(13) + chr(10) + "It could be that the surface spontaneously ceased to exist (because " +
	            //            "of surfaces\' volatile behavior)" + chr(13) + chr(10) + "thereby making it invalid. When setting your own collision masks with fd_rectangle_set_collision_mask_surface," + chr(13) + chr(10) +
	            //            "make sure to manually assure their existence each time before calling fd_rectangle_update." + chr(13) + chr(10);
	            //show_debug_message(error_string);
	            //show_error(error_string, false);
	        } else if (collision_mask_type == 2) {
	            sf_world = surface_create(sf_width, sf_height);
	            surface_set_target(sf_world);
	                draw_clear_alpha($00FFFF, 0);
	            surface_reset_target();
	        }
	        sf_world_update = false;
	    }
	}
}

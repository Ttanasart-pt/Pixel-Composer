/// fd_rectangle_set_collision_mask_surface(instance id, surface id)
function fd_rectangle_set_collision_mask_surface(domain, surface) {
	// Sets the collision mask to a surface.
	// instance id: The instance id of the fluid dynamics rectangle.
	// surface id: The id of the surface to use as the new collision mask.

	with (domain) {
	    if (sf_world != surface) {
	        surface_free(sf_world);
	        sf_world = surface;
	    }
    
	    collision_mask_type = 1;
	    collision_mask_sprite_index = -1;
	    collision_mask_image_index = -1;
	}



}

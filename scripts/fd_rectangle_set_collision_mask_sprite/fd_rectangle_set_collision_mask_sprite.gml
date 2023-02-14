/// fd_rectangle_set_collision_mask_sprite(instance id, sprite index, image index)
function fd_rectangle_set_collision_mask_sprite(domain, sprite_index, image_index) {
	// Sets the collision mask of the fluid dynamics to a sprite.
	// instance id: The instance id of the fluid dynamics rectangle.
	// sprite index: The sprite index of the new collision mask.
	// image index: The image index of the new collision mask.

	with (domain) {
	    if (collision_mask_type == 0) {
	        if (collision_mask_sprite_index != sprite_index) {
	            sf_world_update = true;
	        } else if (collision_mask_image_index != image_index) {
	            sf_world_update = true;
	        }
	    } else if (collision_mask_type == 2) {
	        surface_free(sf_world);
	    }
    
	    collision_mask_type = 0;
	    collision_mask_sprite_index = sprite_index;
	    collision_mask_image_index = image_index;
	}
}

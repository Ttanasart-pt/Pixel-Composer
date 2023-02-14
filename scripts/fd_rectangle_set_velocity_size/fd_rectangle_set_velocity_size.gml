/// fd_rectangle_set_velocity_size(instance id, width, height);
function fd_rectangle_set_velocity_size(domain, width, height) {
	// Sets the size of the velocity texture used for the fluid dynamics simulation. Usually you want to keep this the same size as the other textures.
	// instance id: The instance id of the fluid dynamics rectangle.
	// width, height: The width and height of the texture.

	with (domain) {
	    surface_free(sf_velocity); surface_free(sf_velocity_temporary);
	    sf_velocity_width = width;
	    sf_velocity_height = height;
	    sf_velocity_texel_width = 1 / sf_velocity_width;
	    sf_velocity_texel_height = 1 / sf_velocity_height;
	}



}

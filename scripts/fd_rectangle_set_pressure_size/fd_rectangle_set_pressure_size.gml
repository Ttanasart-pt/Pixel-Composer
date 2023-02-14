/// fd_rectangle_set_pressure_size(instance id, width, height);
function fd_rectangle_set_pressure_size(domain, width, height) {
	// Sets the size of the pressure texture used for the fluid dynamics simulation. Usually you want to keep this the same size as the other textures.
	// instance id: The instance id of the fluid dynamics rectangle.
	// width, height: The width and height of the texture.

	with (domain) {
	    surface_free(sf_pressure); surface_free(sf_pressure_temporary);
	    sf_pressure_width = width;
	    sf_pressure_height = height;
	    sf_pressure_texel_width = 1 / sf_pressure_width;
	    sf_pressure_texel_height = 1 / sf_pressure_height;
	}
}

/// fd_rectangle_get_material_surface(instance id)
function fd_rectangle_get_material_surface(domain) {
	// Returns the material surface of a fluid dynamics rectangle.
	// Formats:
	// FD_MATERIAL_TYPE.RGBA_16: You will receive the surface containing the most significant bits of the red, green, blue and alpha in the normal order.
	// FD_MATERIAL_TYPE.RGBA_8: You will receive the surface containing the red, green, blue and alpha in the normal order.
	// FD_MATERIAL_TYPE.A_16: You will receive a surface containing the most significant 8 bits of alpha in the alpha channel, and the least significant 8 bits in the blue channel.
	// FD_MATERIAL_TYPE.A_8: You will receive a surface containing the alpha, and it will be in the alpha channel.
	// instance id: The instance id of the fluid dynamics rectangle.

	return domain.sf_material_0;



}

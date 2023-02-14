/// fd_rectangle_get_collision_mask_surface(instance id)
function fd_rectangle_get_collision_mask_surface(domain) {
	// Returns the collision mask surface of the fluid dynamics rectangle.
	// Even if you have the collision mask set to a sprite, it will still need a surface to function, so
	// this will always give the active collision mask.
	// instance id: The instance id of the fluid dynamics rectangle.

	return domain.sf_world;
}

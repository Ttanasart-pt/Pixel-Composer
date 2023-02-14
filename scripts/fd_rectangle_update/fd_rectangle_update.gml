/// fd_rectangle_update(instance id)
function fd_rectangle_update(domain) {
	// Updates the fluid dynamics rectangle, proceeding the simulation one step further.
	// instance id: The instance id of the fluid dynamics rectangle to update.

	fd_rectangle_update_velocity(domain);
	fd_rectangle_update_material(domain);
}

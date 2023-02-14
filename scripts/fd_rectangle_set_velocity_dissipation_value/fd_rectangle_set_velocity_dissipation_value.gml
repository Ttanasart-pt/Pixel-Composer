/// fd_rectangle_set_velocity_dissipation_value(instance id, dissipation value)
function fd_rectangle_set_velocity_dissipation_value(domain, dissipation) {
	// Sets the amount of dissipation of the velocity of fluid, as in how much it slows down over time.
	// instance id: The instance id of the fluid dynamics rectangle.
	// dissipation value: The value affecting the dissipation of velocity. See fd_rectangle_set_velocity_dissipation_type for an explanation on
	//     what this value should be.

	domain.velocity_dissipation_value = dissipation;
}

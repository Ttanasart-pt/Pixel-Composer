/// fd_rectangle_set_velocity_dissipation_type(instance id, dissipation type)
function fd_rectangle_set_velocity_dissipation_type(domain, dissipation_type) {
	// Sets the type of dissipation for the velocity of a fluid dynamics rectangle.
	// instance id: The instance id of the fluid dynamics rectangle.
	// dissipation type: The type of dissipation to use, either 0 or 1:
	//     0: The dissipation value is multiplied with the velocity, meaning that a dissipation value of 1 will maintain
	//     the velocity without changing it, and 0 will instantly stop it. A value of 0.999 will slowly slow the fluid down.
	//     A value of 0.99 will slow it down slightly quicker. A value of 0.95 will slow it down pretty fast. Etc.
	//     1: The dissipation value is subtracted toward 0 for the velocity, meaning that a dissipation value of 0 will subtract nothing from the velocity,
	//     making it unchanged. A value of e.g. 0.001 will subtract 0.001 from the x and y velocity until it stops.

	domain.velocity_dissipation_type = dissipation_type;
}

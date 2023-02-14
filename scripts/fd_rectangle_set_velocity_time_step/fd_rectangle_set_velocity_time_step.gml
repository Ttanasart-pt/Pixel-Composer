/// fd_rectangle_set_velocity_time_step(instance id, time step)
function fd_rectangle_set_velocity_time_step(domain, timestep) {
	// Sets the velocity time step of the fluid dynamics rectangle. This is a value that affects how
	// quickly the velocity of the fluid moves itself around (advection). Usually you want this to be the same as the material time step.
	// instance id: The instance id of the fluid dynamics rectangle.
	// time step: 1 is the default value. Lower values will make the fluid move slower. High values make it faster,
	//     but will also be less precise.

	domain.velocity_time_step = timestep;
}

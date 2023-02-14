/// fd_rectangle_set_material_time_step(instance id, time step)
function fd_rectangle_set_material_time_step(domain, timestep) {
	// Sets the material time step of the fluid dynamics rectangle. This is a value that affects how
	// quickly the fluid moves around. Usually you want this to be the same as the velocity time step.
	// instance id: The instance id of the fluid dynamics rectangle.
	// time step: 1 is the default value. Lower values will make the fluid move slower. High values make it faster,
	//     but will also be less precise.

	domain.material_time_step = timestep;
}

/// fd_rectangle_set_material_maccormack_weight(instance id, MacCormack weight)
function fd_rectangle_set_material_maccormack_weight(domain, weight) {
	// Sets the MacCormack weight for the material advection of the fluid dynamics simulation.
	// This is a value between 0 and 1 where 0 represents the result of a Semi-Lagrangian advection scheme,
	// and 1 the result of a MacCormack advection scheme. Any value in between will blend the result of the
	// two schemes. The result of a high MacCormack weight is that the material will have significantly
	// higher detail. In the case of material advection (as opposed to velocity advection) this is usually undesirable
	// and should be set to 0 or a low value.
	// instance id: The instance id of the fluid dynamics rectangle.
	// MacCormack weight: A value between 0 and 1 for how much of the effect to be used.

	domain.material_maccormack_weight = weight;
}

/// fd_rectangle_set_material_dissipation_type(instance id, dissipation type)
function fd_rectangle_set_material_dissipation_type(domain, discipate_type) {
	// Sets the type of dissipation for the material of a fluid dynamics rectangle.
	// instance id: The instance id of the fluid dynamics rectangle.
	// dissipation type: The type of dissipation to use, either 0 or 1:
	//     0: The dissipation value is multiplied with the material alpha, meaning that a dissipation value of 1 will maintain
	//     the alpha without changing it, and 0 will instantly make it invisible. A value of 0.999 will slowly fade out the material.
	//     1: The dissipation value is subtracted from the alpha, meaning that a dissipation value of 0 will subtract nothing from the alpha,
	//     making it unchanged. A value of e.g. 0.001 will subtract 0.001 from the alpha until it has disappeared completely.

	domain.material_dissipation_type = discipate_type;
}

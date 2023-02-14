/// fd_rectangle_set_material_dissipation_value(instance id, dissipation value)
function fd_rectangle_set_material_dissipation_value(domain, discipate) {
	// Sets the amount of dissipation of the material of fluid, as in how quickly it fades out.
	// instance id: The instance id of the fluid dynamics rectangle.
	// dissipation value: The value affecting the dissipation of the material. See fd_rectangle_set_material_dissipation_type for an explanation on
	//     what this value should be.

	domain.material_dissipation_value = discipate;
}

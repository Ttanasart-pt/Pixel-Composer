/// fd_rectangle_set_material_type(instance id, type)
function fd_rectangle_set_material_type(domain, type) {
	// Sets the material type for the fluid dynamics rectangle. The material type has to do with what kind of data and how much data you want to use for the fluid dynamics rectangle.
	// instance id: The instance id of the fluid dynamics rectangle.
	// type: Enum type. Select one of these:
	//     FD_MATERIAL_TYPE.RGBA_16: The fluid dynamics material will be able to hold red, green, blue and alpha, each with 16 bits of precision.
	//     FD_MATERIAL_TYPE.RGBA_8: Same as RGBA_16, but with 8 bits instead of 16.
	//     FD_MATERIAL_TYPE.A_16: The fluid dynamics material will hold one value, with 16 bits of precision.
	//     FD_MATERIAL_TYPE.A_8: The fluid dynamics material will hold one value, with 8 bits of precision.

	domain.material_type = type;
}

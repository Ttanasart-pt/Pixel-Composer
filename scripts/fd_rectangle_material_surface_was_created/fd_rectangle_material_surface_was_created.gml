/// fd_rectangle_material_surface_was_created(instance id);
function fd_rectangle_material_surface_was_created(domain) {
	// This is a script that returns true whenever the material surface was created. This can be useful in case it spontaneously disappears from memory and you want to recreate it.
	// Surfaces are volatile, so this should be accounted for if the content is important to store.
	// instance id: The instance id of the fluid dynamics rectangle.

	with (domain) {
	    if (material_surface_was_created) {
	        material_surface_was_created = false;
	        return true;
	    }
	    return false;
	}



}

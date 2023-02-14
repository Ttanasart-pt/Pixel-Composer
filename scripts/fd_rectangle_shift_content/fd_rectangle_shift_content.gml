/// fd_rectangle_shift_content(instance id, x amount, y amount)
function fd_rectangle_shift_content(domain, xamount, yamount) {
	// Shifts the position of the content of a fluid dynamics rectangle.
	// Useful if you want to e.g. make a fluid dynamics rectangle that follows the view.
	// instance id: The instance id of the fluid dynamics rectangle.
	// x amount, y amount: The amount of pixels to shift the content of the fluid dynamics rectangle with.

	draw_enable_alphablend(false);
	with (domain) {
	    surface_set_target(sf_velocity_temporary);
	        draw_clear_alpha($7F7F7F, 0.5);
	        draw_surface(sf_velocity, xamount, yamount);
	    surface_reset_target();
	    var t = sf_velocity; sf_velocity = sf_velocity_temporary; sf_velocity_temporary = t;
        
	    surface_set_target(sf_material_0_temporary);
	        draw_clear_alpha(c_black, 0);
	        draw_surface(sf_material_0, xamount, yamount);
	    surface_reset_target();
	    var t = sf_material_0; sf_material_0 = sf_material_0_temporary; sf_material_0_temporary = t;
        
	    if (material_type == FD_MATERIAL_TYPE.RGBA_16) {
	        surface_set_target(sf_material_1_temporary);
	            draw_clear_alpha(c_black, 0);
	            draw_surface(sf_material_1, xamount, yamount);
	        surface_reset_target();
	        var t = sf_material_1; sf_material_1 = sf_material_1_temporary; sf_material_1_temporary = t;
	    }
	}
	draw_enable_alphablend(true);
}

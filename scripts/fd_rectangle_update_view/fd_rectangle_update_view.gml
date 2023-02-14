/// fd_rectangle_update_view(instance_id)
function fd_rectangle_update_view(domain) {
	// Updates a fluid dynamics rectangle attached to a view, proceeding the simulation one step further.
	// instance id: The instance id of the fluid dynamics rectangle to update.

	with (domain) {  
	    if (!surface_exists(sf_world)) {
	        sf_world = surface_create(
	                (__view_get( e__VW.WView, fd_view_number ) / fd_wratio) + (2 * fd_edge_buffer_size), 
	                (__view_get( e__VW.HView, fd_view_number ) / fd_hratio) + (2 * fd_edge_buffer_size));
	        sf_world_update = false;
	    }
    
	    fd_rectangle_update(domain);

	    surface_set_target(sf_world);
	        draw_clear_alpha(0, c_black);
	    surface_reset_target();
	}
}

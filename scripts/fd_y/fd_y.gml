/// fd_y(instance id, y)
function fd_y(argument0, argument1) {
	// Returns the y coordinate on the fluid dynamics surface.

	return ((argument1 - __view_get( e__VW.YView, argument0.fd_view_number )) / argument0.fd_hratio) + argument0.fd_edge_buffer_size;



}

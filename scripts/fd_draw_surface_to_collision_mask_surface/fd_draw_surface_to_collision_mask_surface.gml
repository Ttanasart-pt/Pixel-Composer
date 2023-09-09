///fd_draw_surface_to_collision_mask_surface(fd instance id, surface id, x, y, xscale, yscale, rot, color, alpha);
function fd_draw_surface_to_collision_mask_surface(domain, surface, _x, _y, xscale, yscale, rot, color, alpha) {
	// Draws a surface to a fluid dynamics rectangle's collision mask surface. If a fluid dynamics rectangle is attached to a view (as obtained from fd_rectangle_create_view),
	// this script should be called every step to draw the surface blocking the fluid. This will draw the surface at the correct position in the collision mask according to the
	// new view position. Call it before fd_rectangle_update_view. If you e.g. call fd_rectangle_update_view in the step event, call this in the begin step event.
	// instance id: The instance id of the fluid dynamics rectangle.
	// surface id, x, y, xscale, yscale, rot, color, alpha: See draw_surface_ext_safe in the GameMaker manual.

	surface_set_target(fd_rectangle_get_collision_mask_surface(domain));
	    draw_surface_ext_safe(surface, fd_x(domain, _x), fd_y(domain, _y), xscale / domain.fd_wratio, yscale / domain.fd_hratio, rot, color, alpha);
	surface_reset_target();
}

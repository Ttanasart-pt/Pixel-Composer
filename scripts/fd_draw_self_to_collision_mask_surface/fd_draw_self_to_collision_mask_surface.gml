///fd_draw_self_to_collision_mask_surface(instance id);
function fd_draw_self_to_collision_mask_surface(domain) {
	// Draws a sprite to a fluid dynamics rectangle's collision mask surface. If a fluid dynamics rectangle is attached to a view (as obtained from fd_rectangle_create_view),
	// this script should be called every step for the collision instances that block the fluid. This will draw the sprite at the correct position in the collision mask according
	// to the new view position. Call it before fd_rectangle_update_view. If you e.g. call fd_rectangle_update_view in the step event, call this in the begin step event.
	// instance id: The instance id of the fluid dynamics rectangle.

	surface_set_target(fd_rectangle_get_collision_mask_surface(domain));
	    draw_sprite_ext(sprite_index, image_index, fd_x(domain, x), fd_y(domain, y), image_xscale / domain.fd_wratio, image_yscale / domain.fd_hratio, image_angle, image_blend, image_alpha);
	surface_reset_target();
}

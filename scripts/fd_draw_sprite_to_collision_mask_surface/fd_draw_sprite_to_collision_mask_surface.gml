/// fd_draw_sprite_to_collision_mask_surface(instance id, sprite, subimg, x, y, xscale, yscale, rot, color, alpha);
function fd_draw_sprite_to_collision_mask_surface(domain, sprite_index, image_index, _x, _y, xscale, yscale, rot, color, alpha) {
	// Draws a sprite to a fluid dynamics rectangle's collision mask surface. If a fluid dynamics rectangle is attached to a view (as obtained from fd_rectangle_create_view),
	// this script should be called every step for the collision instances that block the fluid. This will draw the sprite at the correct position in the collision mask according
	// to the new view position. Call it before fd_rectangle_update_view. If you e.g. call fd_rectangle_update_view in the step event, call this in the begin step event.
	// instance id: The instance id of the fluid dynamics rectangle.
	// sprite, subimg, x, y, xscale, yscale, rot, color, alpha: See draw_sprite_ext in the GameMaker manual.

	surface_set_target(fd_rectangle_get_collision_mask_surface(domain));
	    draw_sprite_ext(sprite_index, image_index, fd_x(domain, _x), fd_y(domain, _y), xscale / domain.fd_wratio, yscale / domain.fd_hratio, rot, color, alpha);
	surface_reset_target();





}

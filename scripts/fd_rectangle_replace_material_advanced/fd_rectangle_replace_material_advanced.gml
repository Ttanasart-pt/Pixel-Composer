/// fd_rectangle_replace_material_advanced(instance id, sprite index, image index, x, y, xscale, yscale, color, alpha)
function fd_rectangle_replace_material_advanced(domain, sprite_index, image_index, _x, _y, xscale, yscale, color, alpha) {
	// Like fd_rectangle_replace_material, but accounts for transparency issues with surfaces. It's a bit slower though.
	// instance id: The instance id of the fluid dynamics rectangle.
	// sprite index: The sprite to draw.
	// image index: The image index of the sprite to draw.
	// x, y: The position inside the fluid dynamics rectangle to draw the sprite at.
	// xscale, yscale: The scale to draw at.
	// color: The color blend to draw with.
	// alpha: The alpha to draw with.

	with (domain) {
	    fd_rectangle_set_target(id, FD_TARGET_TYPE.REPLACE_MATERIAL_ADVANCED);
	        draw_sprite_ext(sprite_index, image_index, _x, _y, xscale, yscale, 0, color, alpha);
	    fd_rectangle_reset_target(id);
	}
}
